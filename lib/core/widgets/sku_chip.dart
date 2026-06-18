import 'package:flutter/material.dart';

class SkuChip extends StatelessWidget {
  final String sku;
  final bool dense;

  const SkuChip({
    super.key,
    required this.sku,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanSku = sku.trim();
    if (cleanSku.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border.all(color: Colors.indigo.shade100),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        cleanSku,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.indigo.shade700,
          fontSize: dense ? 10.5 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
