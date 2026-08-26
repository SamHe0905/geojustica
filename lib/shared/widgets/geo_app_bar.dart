import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import 'geo_icon.dart';

class GeoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final List<Widget>? actions;

  const GeoAppBar({super.key, this.title, this.showBack = true, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (!showBack) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: GeoIcon('scales', color: Colors.white, size: 19)),
            ),
            const SizedBox(width: 11),
          ],
          Text(
            title ?? AppStrings.appName,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      leading: showBack
          ? IconButton(
              icon: const GeoIcon('caret_left', color: Colors.white, size: 22),
              tooltip: 'Voltar',
              // Voltar seguro: se não há pra onde voltar, vai pra home em vez
              // de esvaziar o Navigator (o que mostrava só o fundo verde).
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            )
          : null,
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
