class PurchaseInvoiceDraft {
  int? supplierId;
  int? locationId;
  String transactionDate;
  String status;
  String paymentStatus;
  String refNo;
  String discountType;
  double discountAmount;
  int? taxId;
  double shippingCharges;
  String additionalNotes;
  List<PurchaseProductDraft> products;
  List<PaymentDraft> payments;

  PurchaseInvoiceDraft({
    this.supplierId,
    this.locationId,
    String? transactionDate,
    this.status = 'received',
    this.paymentStatus = 'due',
    this.refNo = '',
    this.discountType = 'fixed',
    this.discountAmount = 0,
    this.taxId,
    this.shippingCharges = 0,
    this.additionalNotes = '',
    List<PurchaseProductDraft>? products,
    List<PaymentDraft>? payments,
  })  : transactionDate = transactionDate ?? DateTime.now().toIso8601String(),
        products = products ?? [],
        payments = payments ?? [];

  double get subtotal => products.fold(0, (s, p) => s + p.lotsTotal);
  double get total => subtotal - discountAmount + shippingCharges;
}

class PurchaseProductDraft {
  final int localProductRowId;
  int productId;
  int variationId;
  String productName;
  String sku;
  String unit;
  List<PurchaseLotDraft> lots;

  PurchaseProductDraft({
    required this.localProductRowId,
    required this.productId,
    this.variationId = 0,
    this.productName = '',
    this.sku = '',
    this.unit = 'pcs',
    List<PurchaseLotDraft>? lots,
  }) : lots = lots ?? [];

  double get lotsTotal => lots.fold(0, (s, l) => s + l.subtotal);
}

class PurchaseLotDraft {
  final int localLotRowId;
  String lotNumber;
  double quantity;
  double purchasePrice;
  double purchasePriceIncTax;
  int? taxId;
  double itemTax;
  DateTime? mfgDate;
  DateTime? expDate;
  double profitPercent;
  double defaultSellPrice;

  PurchaseLotDraft({
    required this.localLotRowId,
    this.lotNumber = '',
    this.quantity = 1,
    this.purchasePrice = 0,
    this.purchasePriceIncTax = 0,
    this.taxId,
    this.itemTax = 0,
    this.mfgDate,
    this.expDate,
    this.profitPercent = 0,
    this.defaultSellPrice = 0,
  });

  double get subtotal => quantity * purchasePriceIncTax;

  PurchaseLotDraft copyWith({
    int? localLotRowId,
    String? lotNumber,
    double? quantity,
    double? purchasePrice,
    double? purchasePriceIncTax,
    int? taxId,
    double? itemTax,
    DateTime? mfgDate,
    DateTime? expDate,
    double? profitPercent,
    double? defaultSellPrice,
  }) =>
      PurchaseLotDraft(
        localLotRowId: localLotRowId ?? this.localLotRowId,
        lotNumber: lotNumber ?? this.lotNumber,
        quantity: quantity ?? this.quantity,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        purchasePriceIncTax: purchasePriceIncTax ?? this.purchasePriceIncTax,
        taxId: taxId ?? this.taxId,
        itemTax: itemTax ?? this.itemTax,
        mfgDate: mfgDate ?? this.mfgDate,
        expDate: expDate ?? this.expDate,
        profitPercent: profitPercent ?? this.profitPercent,
        defaultSellPrice: defaultSellPrice ?? this.defaultSellPrice,
      );

  Map<String, dynamic> toPayload(int productId, int variationId) => {
    'product_id': productId,
    'variation_id': variationId,
    'quantity': quantity,
    'purchase_price': purchasePrice,
    'purchase_price_inc_tax': purchasePriceIncTax,
    'item_tax': itemTax,
    'tax_id': taxId,
    'lot_number': lotNumber,
    'mfg_date': mfgDate?.toIso8601String(),
    'exp_date': expDate?.toIso8601String(),
    'profit_percent': profitPercent,
    'default_sell_price': defaultSellPrice,
  };
}

class PaymentDraft {
  double amount;
  String method;
  String paidOn;
  String note;

  PaymentDraft({
    this.amount = 0,
    this.method = 'cash',
    String? paidOn,
    this.note = '',
  }) : paidOn = paidOn ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'method': method,
    'paid_on': paidOn,
    'note': note,
  };
}
