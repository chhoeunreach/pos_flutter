List<Map<String, dynamic>> productVariations(Map<String, dynamic> product) {
  final selected = product['selected_variation'];
  if (selected is Map) return [Map<String, dynamic>.from(selected)];

  final direct = product['variations'];
  if (direct is List && direct.isNotEmpty) {
    return direct
        .whereType<Map>()
        .map((variation) => Map<String, dynamic>.from(variation))
        .toList();
  }

  final grouped = product['product_variations'];
  if (grouped is List) {
    final variations = <Map<String, dynamic>>[];
    for (final rawGroup in grouped.whereType<Map>()) {
      final group = Map<String, dynamic>.from(rawGroup);
      final groupName = group['name']?.toString();
      final groupVariations = group['variations'];
      if (groupVariations is! List) continue;
      for (final rawVariation in groupVariations.whereType<Map>()) {
        final variation = Map<String, dynamic>.from(rawVariation);
        variation['variation_group_name'] ??= groupName;
        variations.add(variation);
      }
    }
    return variations;
  }

  return const [];
}

Map<String, dynamic> firstProductVariation(Map<String, dynamic> product) {
  final variations = productVariations(product);
  return variations.isEmpty ? <String, dynamic>{} : variations.first;
}

List<Map<String, dynamic>> productVariationOptions(
    Map<String, dynamic> product) {
  final variations = productVariations(product);
  if (variations.isEmpty) return [product];

  return variations.map((variation) {
    final copy = Map<String, dynamic>.from(product);
    copy['selected_variation'] = variation;
    copy['variation_id'] = variation['id'];
    copy['variations'] = [variation];
    return copy;
  }).toList();
}

String variationDisplayName(Map<String, dynamic> variation) {
  final pieces = <String>[];

  void add(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'DUMMY') return;
    if (!pieces.contains(text)) pieces.add(text);
  }

  add(variation['variation_group_name']);
  add(variation['product_variation_name']);
  add(variation['name']);
  add(variation['variation_name']);
  add(variation['variation_value']);
  add(variation['value']);

  return pieces.join(' - ');
}

String productDisplayName(
    Map<String, dynamic> product, Map<String, dynamic> variation) {
  final productName = product['name']?.toString() ?? '';
  final variationName = variationDisplayName(variation);
  if (variationName.isEmpty) return productName;
  if (variationName == productName) return productName;
  return '$productName - $variationName';
}

String productUnitLabel(Map<String, dynamic> product) {
  final unit = product['unit'];
  if (unit is Map) {
    for (final key in const ['short_name', 'actual_name', 'name']) {
      final value = unit[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }
  }

  for (final key in const ['unit_name', 'unit_short_name']) {
    final value = product[key]?.toString().trim();
    if (value != null && value.isNotEmpty && value != 'null') return value;
  }

  if (unit is String) {
    final value = unit.trim();
    if (value.isNotEmpty && value != 'null') return value;
  }

  return 'pcs';
}

List productStockList(Map<String, dynamic> product,
    [Map<String, dynamic>? variation]) {
  final selectedVariation = variation ?? firstProductVariation(product);
  for (final value in [
    selectedVariation['stock'],
    selectedVariation['variation_location_details'],
    product['stock'],
    product['stock_details'],
    product['variation_location_details'],
  ]) {
    if (value is List) return value;
  }
  return const [];
}

double productStockTotal(Map<String, dynamic> product,
    [Map<String, dynamic>? variation]) {
  return _stockTotal(productStockList(product, variation));
}

double _stockTotal(List stockList) {
  return stockList.fold<double>(0, (sum, item) {
    if (item is! Map) return sum;
    final direct = _asDouble(item['qty_available']) ??
        _asDouble(item['stock']) ??
        _asDouble(item['quantity']);
    if (direct != null) return sum + direct;
    final locations = item['locations'];
    if (locations is List) return sum + _stockTotal(locations);
    return sum;
  });
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '').trim());
  return null;
}
