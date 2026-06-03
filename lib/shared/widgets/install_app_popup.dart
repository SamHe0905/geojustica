import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/install_popup_provider.dart';
import '../../services/pwa_install_service.dart';

/// Exibe o popup automaticamente quando montado (1x por dispositivo).
class InstallAppPopup extends ConsumerStatefulWidget {
  const InstallAppPopup({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<InstallAppPopup> createState() => _InstallAppPopupState();
}

class _InstallAppPopupState extends ConsumerState<InstallAppPopup> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShow());
  }

  Future<void> _maybeShow() async {
    if (_shown) return;
    final svc = PwaInstallService.instance;
    await svc.waitReady();

    if (!mounted) return;
    if (svc.isInstalled) return; // já está instalado

    final should = await ref.read(installPopupProvider.notifier).shouldShow();
    if (!mounted || !should) return;

    _shown = true;
    // Pequeno atraso pra não atropelar a UI
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _InstallDialog(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _InstallDialog extends ConsumerWidget {
  const _InstallDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = PwaInstallService.instance;
    final platform = svc.platform;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.balance, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Instale o GeoJustiça',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tenha acesso rápido pela tela inicial do seu dispositivo, com ícone próprio e funcionamento parecido com um app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                _buildBenefits(),
                const SizedBox(height: 22),
                _buildInstructions(context, platform, ref),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await ref.read(installPopupProvider.notifier).dismiss();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Agora não'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _benefit(Icons.flash_on_rounded, 'Abre mais rápido'),
          _benefit(Icons.offline_bolt_rounded, 'Funciona offline parcialmente'),
          _benefit(Icons.notifications_active_rounded, 'Ícone na tela inicial'),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInstructions(
      BuildContext context, DevicePlatform platform, WidgetRef ref) {
    if (platform == DevicePlatform.ios) return _iosSteps();
    return _genericSteps(platform);
  }

  Widget _iosSteps() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_iphone_rounded, color: AppColors.secondary),
              SizedBox(width: 8),
              Text('Para instalar no iPhone:',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          _step('1', 'Toque no botão Compartilhar',
              icon: Icons.ios_share_rounded),
          _step('2', 'Role e toque em "Adicionar à Tela de Início"',
              icon: Icons.add_box_outlined),
          _step('3', 'Toque em "Adicionar"', icon: Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _genericSteps(DevicePlatform p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                p == DevicePlatform.android
                    ? Icons.phone_android_rounded
                    : Icons.computer_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                p == DevicePlatform.android
                    ? 'Para instalar no Android:'
                    : 'Para instalar no computador:',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _step('1',
              'Abra o menu do navegador (⋮ no canto)',
              icon: Icons.more_vert_rounded),
          _step('2',
              p == DevicePlatform.android
                  ? 'Toque em "Adicionar à tela inicial" ou "Instalar app"'
                  : 'Clique em "Instalar GeoJustiça"',
              icon: Icons.download_rounded),
          _step('3', 'Confirme a instalação',
              icon: Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _step(String n, String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
                color: AppColors.secondary, shape: BoxShape.circle),
            child: Center(
              child: Text(n,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, height: 1.4))),
          if (icon != null) Icon(icon, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

