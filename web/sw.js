// GeoJustiça - Service Worker
// Estratégia: stale-while-revalidate para HTML, cache-first para assets

const CACHE_VERSION = 'geojustica-v2';
const RUNTIME_CACHE = 'geojustica-runtime';

const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/logo.svg',
];

// Install: pré-cache dos essenciais
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

// Activate: limpa caches antigos
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys
          .filter((k) => k !== CACHE_VERSION && k !== RUNTIME_CACHE)
          .map((k) => caches.delete(k))
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch: estratégia de cache
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Ignora requisições não-GET
  if (req.method !== 'GET') return;

  const url = new URL(req.url);

  // Ignora requisições ao Supabase (sempre online pra dados frescos)
  if (url.hostname.includes('supabase')) return;

  // Ignora requisições a outros domínios (CDN, OpenStreetMap)
  if (url.origin !== self.location.origin) {
    // Para tiles do OpenStreetMap, faz cache mas não bloqueia
    if (url.hostname.includes('tile.openstreetmap')) {
      event.respondWith(
        caches.open(RUNTIME_CACHE).then((cache) =>
          cache.match(req).then((cached) =>
            cached || fetch(req).then((response) => {
              if (response.ok) cache.put(req, response.clone());
              return response;
            }).catch(() => cached)
          )
        )
      );
    }
    return;
  }

  // Para arquivos JS/CSS/imagens: cache-first
  if (/\.(js|css|woff2?|ttf|otf|svg|png|jpg|jpeg|gif|ico)$/i.test(url.pathname)) {
    event.respondWith(
      caches.match(req).then((cached) => {
        if (cached) return cached;
        return fetch(req).then((response) => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(RUNTIME_CACHE).then((cache) => cache.put(req, clone));
          }
          return response;
        });
      })
    );
    return;
  }

  // Para HTML: network-first com fallback para cache
  event.respondWith(
    fetch(req)
      .then((response) => {
        if (response.ok) {
          const clone = response.clone();
          caches.open(RUNTIME_CACHE).then((cache) => cache.put(req, clone));
        }
        return response;
      })
      .catch(() => caches.match(req).then((cached) => cached || caches.match('/')))
  );
});

// Background sync (para denúncias quando voltar online)
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-reports') {
    // O Flutter pode escutar mensagens deste SW para retentar envios.
    self.clients.matchAll().then((clients) => {
      clients.forEach((c) => c.postMessage({ type: 'retry-pending-reports' }));
    });
  }
});

// Mensagens do app (futuro)
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});
