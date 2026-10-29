import 'package:flutter/material.dart';

const int kLowStockThreshold = 10;

bool isLowStock(int stock) => stock > 0 && stock < kLowStockThreshold;

class StockBadge extends StatefulWidget {
  final int stock;

  final bool compact;

  const StockBadge({super.key, required this.stock, this.compact = false});

  @override
  State<StockBadge> createState() => _StockBadgeState();
}

class _StockBadgeState extends State<StockBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant StockBadge old) {
    super.didUpdateWidget(old);
    _syncPulse();
  }

  void _syncPulse() {
    if (isLowStock(widget.stock)) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stock = widget.stock;

    if (stock <= 0) {
      return _chip(
        icon: Icons.remove_shopping_cart_outlined,
        text: 'สินค้าหมด',
        fg: scheme.onError,
        bg: scheme.error,
        style: textTheme.labelMedium,
      );
    }

    if (isLowStock(stock)) {
      return _chip(
        icon: Icons.warning_amber_rounded,
        text: widget.compact
            ? 'เหลือเพียง $stock ชิ้น!'
            : 'ใกล้หมด! เหลือเพียง $stock ชิ้น',
        fg: scheme.error,
        bg: scheme.errorContainer,
        border: scheme.error,
        pulse: _pulse,
        style: textTheme.labelMedium,
      );
    }

    const green = Color(0xFF2E7D32);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 8, color: green),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'มีสินค้า $stock ชิ้น',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(color: green),
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String text,
    required Color fg,
    required Color bg,
    Color? border,
    Animation<double>? pulse,
    TextStyle? style,
  }) {
    Widget iconW = Icon(icon, size: 16, color: fg);
    if (pulse != null) {
      iconW = FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1).animate(pulse),
        child: iconW,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconW,
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style?.copyWith(color: fg, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
