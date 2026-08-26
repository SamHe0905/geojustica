import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';

/// Ícone do conjunto Phosphor renderizado a partir de SVG (`assets/icons/*.svg`).
///
/// Usar SVG em vez de um pacote de fonte de ícones evita depender de classes
/// que o SDK marcou como `final` (o que quebraria o build). A cor sobrescreve
/// todo o traço/preenchimento do SVG.
class GeoIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;

  const GeoIcon(this.name, {super.key, this.size = 24, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
