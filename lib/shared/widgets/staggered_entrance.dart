import 'package:flutter/material.dart';

/// Entrada escalonada (fade + rise) nativa, sem dependência.
///
/// Cada filho aparece um pouco depois do anterior, rápido e sutil — na linha da
/// contenção (a melhor animação é a que passa despercebida). Respeita
/// `MediaQuery.disableAnimations` (prefers-reduced-motion): nesse caso o
/// conteúdo já entra pronto, sem movimento.
class StaggeredEntrance extends StatefulWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration stagger;
  final Duration itemDuration;

  const StaggeredEntrance({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.stagger = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 340),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  Duration get _total {
    final n = widget.children.length;
    return widget.itemDuration + widget.stagger * (n > 0 ? n - 1 : 0);
  }

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _total);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    final totalMs = _total.inMilliseconds;
    final itemMs = widget.itemDuration.inMilliseconds;
    final stagMs = widget.stagger.inMilliseconds;

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _buildItem(i, totalMs, itemMs, stagMs),
      ],
    );
  }

  Widget _buildItem(int i, int totalMs, int itemMs, int stagMs) {
    final startMs = stagMs * i;
    final begin = totalMs == 0 ? 0.0 : startMs / totalMs;
    final end = totalMs == 0 ? 1.0 : (startMs + itemMs) / totalMs;
    final curved = CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: widget.children[i],
      ),
    );
  }
}
