class MockData {
  // ─── AUTH ──────────────────────────────────────────────────────
  static Map<String, dynamic> loginResponse = {
    'success': true,
    'message': 'Login successful',
    'data': {
      'token': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.mock_token',
      'token_type': 'Bearer',
      'user': {
        'id': 1,
        'surname': 'Admin',
        'first_name': 'User',
        'last_name': null,
        'full_name': 'Admin User',
        'username': 'admin',
        'email': 'admin@pos.com',
        'language': 'en',
        'business_id': 1,
        'image_url': null,
        'role_name': 'Admin',
      },
    },
  };

  static Map<String, dynamic> meResponse = {
    'success': true,
    'data': {
      'id': 1,
      'surname': 'Admin',
      'first_name': 'User',
      'last_name': null,
      'full_name': 'Admin User',
      'username': 'admin',
      'email': 'admin@pos.com',
      'language': 'en',
      'business_id': 1,
      'image_url': null,
      'role_name': 'Admin',
    },
  };

  static Map<String, dynamic> permissionsResponse = {
    'success': true,
    'data': {
      'all_permissions': [
        'sell.create', 'sell.view', 'sell.update', 'sell.delete',
        'purchase.create', 'purchase.view', 'purchase.update', 'purchase.delete',
        'product.create', 'product.view', 'product.update', 'product.delete',
        'customer.create', 'customer.view', 'customer.update', 'customer.delete',
        'supplier.create', 'supplier.view', 'supplier.update', 'supplier.delete',
        'expense.add', 'expense.view', 'expense.edit', 'expense.delete',
        'stock.adjustment.create', 'stock.transfer.create',
        'stock_report.view', 'sales_report.view', 'purchase_report.view',
        'expense_report.view', 'profit_loss_report.view',
        'customer_statement.view', 'supplier_statement.view',
        'payment.view', 'payment.create', 'payment.edit',
        'settings.view',
      ],
      'can_access_all_locations': true,
      'role': 'Admin',
    },
  };

  static Map<String, dynamic> locationsResponse = {
    'success': true,
    'data': [
      {'id': 1, 'name': 'Main Store', 'location_id': 'ST001', 'landmark': 'Downtown', 'city': 'NYC', 'state': 'NY', 'country': 'USA', 'zip_code': '10001', 'mobile': '1234567890', 'email': 'store@pos.com', 'is_active': true, 'invoice_scheme_id': 1, 'invoice_layout_id': 1, 'sale_invoice_scheme_id': 1, 'selling_price_group_id': null},
      {'id': 2, 'name': 'Branch 1', 'location_id': 'ST002', 'landmark': 'Uptown', 'city': 'NYC', 'state': 'NY', 'country': 'USA', 'zip_code': '10002', 'mobile': null, 'email': null, 'is_active': true, 'invoice_scheme_id': 1, 'invoice_layout_id': 1, 'sale_invoice_scheme_id': 1, 'selling_price_group_id': null},
    ],
  };

  // ─── CONTACTS (customers + suppliers) ────────────────────────
  static List<Map<String, dynamic>> customers = [
    {
      'id': 1, 'name': 'John Doe', 'supplier_business_name': null,
      'contact_id': 'CUST-001', 'mobile': '1234567890',
      'email': 'john@example.com', 'tax_number': 'TAX001',
      'city': 'NYC', 'state': 'NY', 'country': 'USA',
      'address_line_1': '123 Main St', 'address_line_2': null,
      'zip_code': '10001', 'land_mark': null,
      'customer_group_id': null, 'pay_term_number': null,
      'pay_term_type': null, 'credit_limit': null,
      'balance': 150.00, 'total_purchase': 0, 'total_invoice': 450.00,
      'opening_balance': 0,
      'created_at': '2024-01-01T00:00:00.000000Z',
    },
    {
      'id': 2, 'name': 'Jane Smith', 'supplier_business_name': null,
      'contact_id': 'CUST-002', 'mobile': '0987654321',
      'email': 'jane@example.com', 'tax_number': null,
      'city': 'LA', 'state': 'CA', 'country': 'USA',
      'address_line_1': '456 Oak Ave', 'address_line_2': 'Suite 100',
      'zip_code': '90001', 'land_mark': 'Near Park',
      'customer_group_id': null, 'pay_term_number': 30,
      'pay_term_type': 'days', 'credit_limit': 2000.00,
      'balance': 0.00, 'total_purchase': 0, 'total_invoice': 230.00,
      'opening_balance': 0,
      'created_at': '2024-01-01T00:00:00.000000Z',
    },
  ];

  static List<Map<String, dynamic>> suppliers = [
    {
      'id': 3, 'name': 'Tech Distributor', 'supplier_business_name': 'Tech Dist Inc.',
      'contact_id': 'SUPP-001', 'mobile': '1112223333',
      'email': 'info@techdist.com', 'tax_number': 'TAX-SUP-001',
      'city': 'NYC', 'state': 'NY', 'country': 'USA',
      'address_line_1': '789 Industrial Blvd', 'address_line_2': null,
      'zip_code': '10003', 'land_mark': 'Warehouse District',
      'customer_group_id': null, 'pay_term_number': 30,
      'pay_term_type': 'days', 'credit_limit': null,
      'balance': 500.00, 'total_purchase': 1200.00, 'total_invoice': 0,
      'opening_balance': 0,
      'created_at': '2024-01-01T00:00:00.000000Z',
    },
  ];

  // ─── DASHBOARD ────────────────────────────────────────────────
  static Map<String, dynamic> dashboardResponse = {
    'success': true,
    'data': {
      'total_sale': 15250.00,
      'actual_income': 12450.00,
      'customer_payment': 2100.00,
      'collection_payment': 500.00,
      'expenses': 2800.00,
      'due': 3100.00,
      'low_stock_count': 5,
      'recent_sales': [
        {
          'id': 1, 'invoice_no': 'SALE001',
          'final_total': 450.00, 'payment_status': 'paid',
          'transaction_date': '2024-01-15 10:30:00',
          'contact_name': 'John Doe',
          'created_by': 'Admin User',
        },
        {
          'id': 2, 'invoice_no': 'SALE002',
          'final_total': 230.00, 'payment_status': 'due',
          'transaction_date': '2024-01-15 11:00:00',
          'contact_name': 'Jane Smith',
          'created_by': 'Admin User',
        },
      ],
      'top_products': [
        {'name': 'Product A', 'total_qty': 45, 'total_amount': 2250.00},
        {'name': 'Product B', 'total_qty': 30, 'total_amount': 1800.00},
        {'name': 'Product C', 'total_qty': 25, 'total_amount': 1250.00},
      ],
    },
  };

  // ─── PRODUCTS ─────────────────────────────────────────────────
  static List<Map<String, dynamic>> products = [
    {
      'id': 1, 'name': 'Wireless Mouse', 'sku': 'WM-001', 'type': 'single',
      'unit_id': 1, 'brand_id': 1, 'category_id': 1, 'sub_category_id': null,
      'tax': 1, 'tax_type': 'exclusive', 'enable_stock': true,
      'alert_quantity': 10, 'image': null, 'image_url': null,
      'product_description': 'Wireless optical mouse', 'weight': '0.2kg',
      'barcode_type': 'C128', 'not_for_selling': false,
      'created_at': '2024-01-01T00:00:00.000000Z',
      'brand': {'id': 1, 'name': 'Logitech'},
      'category': {'id': 1, 'name': 'Electronics'},
      'unit': {'id': 1, 'name': 'Pieces', 'short_name': 'pcs'},
      'variations': [{
        'id': 1, 'name': 'Default', 'product_id': 1, 'sub_sku': 'WM-001',
        'product_variation_id': null, 'variation_value_id': null,
        'default_purchase_price': 12.00, 'dpp_inc_tax': 12.00,
        'profit_percent': 50.00, 'default_sell_price': 25.00,
        'sell_price_inc_tax': 25.00, 'product_variation': null,
        'stock': [
          {'location_id': 1, 'qty_available': 30.0},
          {'location_id': 2, 'qty_available': 20.0},
        ],
      }],
      'product_locations': [
        {'id': 1, 'name': 'Main Store'},
        {'id': 2, 'name': 'Branch 1'},
      ],
      'default_selling_price': 25.00,
      'default_purchase_price': 12.00,
    },
    {
      'id': 2, 'name': 'USB Keyboard', 'sku': 'UK-002', 'type': 'single',
      'unit_id': 1, 'brand_id': 1, 'category_id': 1, 'sub_category_id': null,
      'tax': 1, 'tax_type': 'exclusive', 'enable_stock': true,
      'alert_quantity': 10, 'image': null, 'image_url': null,
      'product_description': null, 'weight': '0.5kg',
      'barcode_type': 'C128', 'not_for_selling': false,
      'created_at': '2024-01-01T00:00:00.000000Z',
      'brand': {'id': 1, 'name': 'Logitech'},
      'category': {'id': 1, 'name': 'Electronics'},
      'unit': {'id': 1, 'name': 'Pieces', 'short_name': 'pcs'},
      'variations': [{
        'id': 2, 'name': 'Default', 'product_id': 2, 'sub_sku': 'UK-002',
        'product_variation_id': null, 'variation_value_id': null,
        'default_purchase_price': 18.00, 'dpp_inc_tax': 18.90,
        'profit_percent': 50.00, 'default_sell_price': 35.00,
        'sell_price_inc_tax': 36.75, 'product_variation': null,
        'stock': [
          {'location_id': 1, 'qty_available': 20.0},
          {'location_id': 2, 'qty_available': 10.0},
        ],
      }],
      'product_locations': [
        {'id': 1, 'name': 'Main Store'},
        {'id': 2, 'name': 'Branch 1'},
      ],
      'default_selling_price': 35.00,
      'default_purchase_price': 18.00,
    },
    {
      'id': 3, 'name': 'HDMI Cable', 'sku': 'HD-003', 'type': 'single',
      'unit_id': 1, 'brand_id': 2, 'category_id': 1, 'sub_category_id': null,
      'tax': null, 'tax_type': 'exclusive', 'enable_stock': true,
      'alert_quantity': 20, 'image': null, 'image_url': null,
      'product_description': null, 'weight': '0.1kg',
      'barcode_type': 'C128', 'not_for_selling': false,
      'created_at': '2024-01-01T00:00:00.000000Z',
      'brand': {'id': 2, 'name': 'Samsung'},
      'category': {'id': 1, 'name': 'Electronics'},
      'unit': {'id': 1, 'name': 'Pieces', 'short_name': 'pcs'},
      'variations': [{
        'id': 3, 'name': 'Default', 'product_id': 3, 'sub_sku': 'HD-003',
        'product_variation_id': null, 'variation_value_id': null,
        'default_purchase_price': 5.00, 'dpp_inc_tax': 5.00,
        'profit_percent': 50.00, 'default_sell_price': 12.00,
        'sell_price_inc_tax': 12.00, 'product_variation': null,
        'stock': [
          {'location_id': 1, 'qty_available': 60.0},
          {'location_id': 2, 'qty_available': 40.0},
        ],
      }],
      'product_locations': [
        {'id': 1, 'name': 'Main Store'},
        {'id': 2, 'name': 'Branch 1'},
      ],
      'default_selling_price': 12.00,
      'default_purchase_price': 5.00,
    },
    {
      'id': 4, 'name': 'Office Chair', 'sku': 'OC-004', 'type': 'single',
      'unit_id': 1, 'brand_id': 3, 'category_id': 2, 'sub_category_id': null,
      'tax': 1, 'tax_type': 'exclusive', 'enable_stock': true,
      'alert_quantity': 5, 'image': null, 'image_url': null,
      'product_description': 'Ergonomic office chair', 'weight': '15kg',
      'barcode_type': 'C128', 'not_for_selling': false,
      'created_at': '2024-01-01T00:00:00.000000Z',
      'brand': {'id': 3, 'name': 'IKEA'},
      'category': {'id': 2, 'name': 'Furniture'},
      'unit': {'id': 1, 'name': 'Pieces', 'short_name': 'pcs'},
      'variations': [{
        'id': 4, 'name': 'Default', 'product_id': 4, 'sub_sku': 'OC-004',
        'product_variation_id': null, 'variation_value_id': null,
        'default_purchase_price': 80.00, 'dpp_inc_tax': 80.00,
        'profit_percent': 50.00, 'default_sell_price': 150.00,
        'sell_price_inc_tax': 165.00, 'product_variation': null,
        'stock': [
          {'location_id': 1, 'qty_available': 10.0},
          {'location_id': 2, 'qty_available': 5.0},
        ],
      }],
      'product_locations': [
        {'id': 1, 'name': 'Main Store'},
        {'id': 2, 'name': 'Branch 1'},
      ],
      'default_selling_price': 150.00,
      'default_purchase_price': 80.00,
    },
    {
      'id': 5, 'name': 'Notebook A5', 'sku': 'NB-005', 'type': 'single',
      'unit_id': 1, 'brand_id': null, 'category_id': 3, 'sub_category_id': null,
      'tax': null, 'tax_type': 'exclusive', 'enable_stock': true,
      'alert_quantity': 20, 'image': null, 'image_url': null,
      'product_description': null, 'weight': null,
      'barcode_type': 'C128', 'not_for_selling': false,
      'created_at': '2024-01-01T00:00:00.000000Z',
      'brand': null, 'category': {'id': 3, 'name': 'Stationery'},
      'unit': {'id': 1, 'name': 'Pieces', 'short_name': 'pcs'},
      'variations': [{
        'id': 5, 'name': 'Default', 'product_id': 5, 'sub_sku': 'NB-005',
        'product_variation_id': null, 'variation_value_id': null,
        'default_purchase_price': 1.00, 'dpp_inc_tax': 1.00,
        'profit_percent': 50.00, 'default_sell_price': 3.00,
        'sell_price_inc_tax': 3.00, 'product_variation': null,
        'stock': [
          {'location_id': 1, 'qty_available': 5.0},
          {'location_id': 2, 'qty_available': 3.0},
        ],
      }],
      'product_locations': [
        {'id': 1, 'name': 'Main Store'},
        {'id': 2, 'name': 'Branch 1'},
      ],
      'default_selling_price': 3.00,
      'default_purchase_price': 1.00,
    },
  ];

  static List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Electronics', 'parent_id': null},
    {'id': 2, 'name': 'Furniture', 'parent_id': null},
    {'id': 3, 'name': 'Stationery', 'parent_id': null},
  ];

  static List<Map<String, dynamic>> brands = [
    {'id': 1, 'name': 'Logitech'},
    {'id': 2, 'name': 'Samsung'},
    {'id': 3, 'name': 'IKEA'},
  ];

  // ─── POS ──────────────────────────────────────────────────────
  static Map<String, dynamic> posSettingsResponse = {
    'success': true,
    'data': {
      'business': {'id': 1, 'name': 'My Business', 'currency': {'id': 1, 'code': 'USD', 'symbol': '\$', 'thousand_separator': ',', 'decimal_separator': '.'}},
      'locations': [
        {'id': 1, 'name': 'Main Store', 'location_id': 'ST001', 'selling_price_group_id': null, 'default_payment_accounts': {'cash': 1, 'card': 2}, 'invoice_scheme_id': 1, 'invoice_layout_id': 1, 'sale_invoice_scheme_id': 1},
      ],
      'walk_in_customer': {'id': 1, 'name': 'Walk-in Customer', 'mobile': null, 'balance': 0},
      'tax_rates': [
        {'id': 1, 'name': 'VAT 10%', 'amount': 10, 'is_tax_group': false},
      ],
      'payment_types': {'cash': 'Cash', 'card': 'Card', 'cheque': 'Cheque', 'bank_transfer': 'Bank Transfer', 'advance': 'Advance'},
      'currencies': [{'id': 1, 'code': 'USD', 'symbol': '\$', 'thousand_separator': ',', 'decimal_separator': '.'}],
    },
  };

  static Map<String, dynamic> validateCartResponse = {
    'success': true,
    'data': {
      'total_before_tax': 37.50,
      'tax': 3.75,
      'discount': 10.00,
      'final_total': 31.25,
      'item_count': 2,
      'errors': [],
      'warnings': [],
    },
  };

  static Map<String, dynamic> createSaleResponse = {
    'success': true,
    'message': 'Sale added successfully',
    'data': {
      'id': 10,
      'type': 'sell',
      'status': 'final',
      'sub_status': null,
      'invoice_no': 'SALE010',
      'ref_no': null,
      'transaction_date': '2024-01-15 10:30:00',
      'total_before_tax': 100.00,
      'tax_amount': 10.00,
      'discount_type': null,
      'discount_amount': 0,
      'shipping_charges': 0,
      'final_total': 110.00,
      'payment_status': 'paid',
      'additional_notes': null,
      'staff_note': null,
      'contact_id': 1,
      'location_id': 1,
      'created_by': 1,
      'is_direct_sale': 1,
      'is_suspend': 0,
      'pay_term_number': null,
      'pay_term_type': null,
      'created_at': '2024-01-15T10:30:00.000000Z',
      'contact': {'id': 1, 'name': 'Walk-in Customer', 'mobile': null, 'supplier_business_name': null},
      'location': {'id': 1, 'name': 'Main Store'},
      'created_by_user': {'id': 1, 'full_name': 'Admin User'},
      'payment_lines': [{'id': 1, 'amount': 110.00, 'method': 'cash', 'payment_ref_no': 'PAY-001', 'paid_on': '2024-01-15 10:30:00'}],
      'sell_lines': [{
        'id': 1, 'product_id': 1, 'variation_id': 1, 'quantity': 2,
        'unit_price': 10.00, 'unit_price_inc_tax': 11.50,
        'unit_price_before_discount': 12.00,
        'line_discount_type': null, 'line_discount_amount': 0,
        'item_tax': 1.50, 'tax_id': 1, 'sell_line_note': null, 'sub_unit_id': null,
        'product': {'id': 1, 'name': 'Wireless Mouse'},
        'variations': {'id': 1, 'name': 'Default', 'sub_sku': 'WM-001'},
      }],
      'paid_amount': 110.00,
      'due_amount': 0.00,
    },
  };

  // ─── TRANSACTIONS (Sales, Purchases, Expenses) ────────────────
  static List<Map<String, dynamic>> sales = [
    {
      'id': 1, 'type': 'sell', 'status': 'final', 'sub_status': null,
      'invoice_no': 'SALE001', 'ref_no': null,
      'transaction_date': '2024-01-15 10:30:00',
      'total_before_tax': 85.00, 'tax_amount': 8.50,
      'discount_type': null, 'discount_amount': 0,
      'shipping_charges': 0, 'final_total': 450.00,
      'payment_status': 'paid',
      'additional_notes': null, 'staff_note': null,
      'contact_id': 1, 'location_id': 1, 'created_by': 1,
      'is_direct_sale': 1, 'is_suspend': 0,
      'pay_term_number': null, 'pay_term_type': null,
      'created_at': '2024-01-15T10:30:00.000000Z',
      'contact': {'id': 1, 'name': 'John Doe', 'mobile': '1234567890', 'supplier_business_name': null},
      'location': {'id': 1, 'name': 'Main Store'},
      'created_by_user': {'id': 1, 'full_name': 'Admin User'},
      'payment_lines': [{'id': 1, 'amount': 450.00, 'method': 'cash', 'payment_ref_no': 'PAY-001', 'paid_on': '2024-01-15 10:30:00', 'payment_account': {'id': 1, 'name': 'Cash'}}],
      'sell_lines': [{'id': 1, 'product_id': 1, 'variation_id': 1, 'quantity': 2, 'unit_price': 25.00, 'unit_price_inc_tax': 25.00, 'unit_price_before_discount': 25.00, 'line_discount_type': null, 'line_discount_amount': 0, 'item_tax': 0, 'tax_id': null, 'sell_line_note': null, 'sub_unit_id': null, 'product': {'id': 1, 'name': 'Wireless Mouse'}, 'variations': {'id': 1, 'name': 'Default', 'sub_sku': 'WM-001'}}],
      'paid_amount': 450.00, 'due_amount': 0.00,
    },
    {
      'id': 2, 'type': 'sell', 'status': 'final', 'sub_status': null,
      'invoice_no': 'SALE002', 'ref_no': null,
      'transaction_date': '2024-01-15 11:00:00',
      'total_before_tax': 209.09, 'tax_amount': 20.91,
      'discount_type': null, 'discount_amount': 0,
      'shipping_charges': 0, 'final_total': 230.00,
      'payment_status': 'due',
      'contact': {'id': 2, 'name': 'Jane Smith', 'mobile': '0987654321', 'supplier_business_name': null},
      'location': {'id': 1, 'name': 'Main Store'},
      'created_by_user': {'id': 1, 'full_name': 'Admin User'},
      'sell_lines': [{'id': 2, 'product_id': 4, 'variation_id': 4, 'quantity': 1, 'unit_price': 150.00, 'unit_price_inc_tax': 165.00, 'unit_price_before_discount': 150.00, 'line_discount_type': null, 'line_discount_amount': 0, 'item_tax': 15.00, 'tax_id': 1, 'sell_line_note': null, 'sub_unit_id': null, 'product': {'id': 4, 'name': 'Office Chair'}, 'variations': {'id': 4, 'name': 'Default', 'sub_sku': 'OC-004'}}],
      'paid_amount': 100.00, 'due_amount': 130.00,
    },
  ];

  static List<Map<String, dynamic>> purchases = [
    {
      'id': 1, 'type': 'purchase', 'status': 'received', 'sub_status': null,
      'ref_no': 'PO-001', 'invoice_no': null,
      'transaction_date': '2024-01-14 09:00:00',
      'total_before_tax': 1090.91, 'tax_amount': 109.09,
      'discount_type': null, 'discount_amount': 0,
      'shipping_charges': 0, 'final_total': 1200.00,
      'payment_status': 'due',
      'contact': {'id': 3, 'name': 'Tech Distributor', 'mobile': '1112223333', 'supplier_business_name': 'Tech Dist Inc.'},
      'location': {'id': 1, 'name': 'Main Store'},
      'created_by_user': {'id': 1, 'full_name': 'Admin User'},
      'purchase_lines': [{'id': 1, 'product_id': 1, 'variation_id': 1, 'quantity': 50, 'unit_cost_before_discount': 12.00, 'unit_cost': 12.00, 'unit_cost_inc_tax': 12.00, 'line_discount_type': null, 'line_discount_amount': 0, 'item_tax': 0, 'tax_id': null, 'purchase_line_note': null, 'quantity_sold': 0, 'quantity_adjusted': 0, 'quantity_returned': 0, 'product': {'id': 1, 'name': 'Wireless Mouse'}, 'variations': {'id': 1, 'name': 'Default', 'sub_sku': 'WM-001'}}],
      'paid_amount': 700.00, 'due_amount': 500.00,
    },
  ];

  static List<Map<String, dynamic>> expenses = [
    {
      'id': 1, 'type': 'expense',
      'ref_no': 'EXP-001',
      'transaction_date': '2024-01-15',
      'final_total': 200.00,
      'payment_status': 'paid',
      'additional_notes': 'Electricity bill',
      'expense_category_id': 1, 'expense_for': null,
      'location_id': 1, 'created_by': 1, 'tax_id': null, 'tax_amount': 0,
      'created_at': '2024-01-15T00:00:00.000000Z',
      'expense_category': null,
      'location': {'id': 1, 'name': 'Main Store'},
      'transaction_for': null,
      'payment_lines': [{'id': 2, 'amount': 200.00, 'method': 'cash', 'payment_ref_no': 'PAY-002', 'paid_on': '2024-01-15'}],
    },
  ];

  static List<Map<String, dynamic>> expenseCategories = [
    {'id': 1, 'name': 'Utilities', 'code': 'UTIL', 'parent_id': null, 'sub_categories': [
      {'id': 2, 'name': 'Electricity', 'code': 'ELEC', 'parent_id': 1, 'sub_categories': []},
    ]},
    {'id': 3, 'name': 'Rent', 'code': 'RENT', 'parent_id': null, 'sub_categories': []},
  ];

  // ─── PAYMENTS ─────────────────────────────────────────────────
  static List<Map<String, dynamic>> payments = [
    {
      'id': 1, 'transaction_id': 1,
      'amount': 450.00, 'method': 'cash',
      'payment_ref_no': 'PAY-001',
      'paid_on': '2024-01-15 10:30:00',
      'card_transaction_number': null, 'card_number': null,
      'card_type': null, 'card_holder_name': null,
      'cheque_number': null, 'bank_account_number': null,
      'note': null, 'account_id': 1,
      'payment_for': 1, 'created_by': 1, 'is_return': 0,
      'created_at': '2024-01-15T10:30:00.000000Z',
      'payment_account': {'id': 1, 'name': 'Cash'},
      'created_user': {'id': 1, 'full_name': 'Admin'},
      'transaction': {'id': 1, 'invoice_no': 'SALE001', 'type': 'sell', 'final_total': 450.00},
    },
  ];

  static List<Map<String, dynamic>> paymentMethods = [
    {'key': 'cash', 'label': 'Cash'},
    {'key': 'card', 'label': 'Card'},
    {'key': 'cheque', 'label': 'Cheque'},
    {'key': 'bank_transfer', 'label': 'Bank Transfer'},
    {'key': 'advance', 'label': 'Advance'},
    {'key': 'custom_pay_1', 'label': 'Custom 1'},
  ];

  // ─── REPORTS ─────────────────────────────────────────────────
  static Map<String, dynamic> cashierReport = {
    'success': true,
    'data': {
      'summary': {
        'total_sale': 15250.00, 'actual_income': 12450.00,
        'customer_payment': 2100.00, 'collection_payment': 500.00,
        'expenses': 2800.00, 'due': 3100.00,
      },
      'user_cashier': {'total_sale': 15250.00, 'amount': 14550.00},
      'location': {
        'Main Store': {'total_sale': 10250.00, 'amount': 9750.00},
        'Branch 1': {'total_sale': 5000.00, 'amount': 4800.00},
      },
      'customer_group': {},
      'brand': {
        'Logitech': {'total_sale': 5000.00},
        'Samsung': {'total_sale': 3000.00},
      },
      'payment_method': {
        'Cash': {'total_sale': 8000.00},
        'Card': {'total_sale': 4500.00},
      },
      'detail': {
        'sales': [{'id': 1, 'invoice_no': 'SALE001', 'final_total': 450.00, 'paid_amount': 450.00, 'payment_status': 'paid', 'contact_name': 'John Doe'}],
        'customer_payments': [{'customer_name': 'John Doe', 'amount': 500.00, 'method': 'Cash'}],
        'collection_payments': [],
        'expenses': [{'category_name': 'Utilities', 'amount': 200.00, 'note': 'Electricity bill'}],
      },
      'payment_types': {'Cash': 8000.00, 'Card': 4500.00},
    },
  };

  static Map<String, dynamic> salesReport = {
    'success': true,
    'data': {
      'summary': {'total_sales': 5, 'total_amount': 550.00, 'total_paid': 500.00, 'total_due': 50.00},
      'sales': [
        {'id': 1, 'invoice_no': 'SALE001', 'final_total': 450.00, 'payment_status': 'paid', 'transaction_date': '2024-01-15', 'contact_name': 'John Doe'},
        {'id': 2, 'invoice_no': 'SALE002', 'final_total': 100.00, 'payment_status': 'due', 'transaction_date': '2024-01-15', 'contact_name': 'Jane Smith'},
      ],
    },
  };

  static Map<String, dynamic> customersDueReport = {
    'success': true,
    'data': {
      'total_due': 1500.00,
      'customers': [
        {'id': 1, 'name': 'John Doe', 'mobile': '1234567890', 'email': 'john@example.com', 'balance': 500.00, 'credit_limit': 1000.00},
        {'id': 2, 'name': 'Jane Smith', 'mobile': '0987654321', 'email': 'jane@example.com', 'balance': 1000.00, 'credit_limit': 2000.00},
      ],
    },
  };

  static Map<String, dynamic> stockReport = {
    'success': true,
    'data': {
      'total_stock_value': 5000.00,
      'products': [
        {'id': 1, 'name': 'Product A', 'sku': 'SKU001', 'total_qty': 100, 'stock_value': 1000.00, 'alert_quantity': 10},
        {'id': 2, 'name': 'Product B', 'sku': 'SKU002', 'total_qty': 50, 'stock_value': 500.00, 'alert_quantity': 5},
      ],
    },
  };

  static Map<String, dynamic> lowStockResponse = {
    'success': true,
    'data': [
      {'product_id': 5, 'product_name': 'Notebook A5', 'sku': 'NB-005', 'variation_id': 5, 'variation_name': 'Default', 'location_id': 1, 'qty_available': 5, 'alert_quantity': 20},
      {'product_id': 5, 'product_name': 'Notebook A5', 'sku': 'NB-005', 'variation_id': 5, 'variation_name': 'Default', 'location_id': 2, 'qty_available': 3, 'alert_quantity': 20},
    ],
  };

  // ─── SETTINGS ─────────────────────────────────────────────────
  static Map<String, dynamic> settingsResponse = {
    'success': true,
    'data': {
      'business': {
        'id': 1, 'name': 'My Business',
        'start_date': '2020-01-01',
        'default_profit_percent': 25,
        'currency': {'id': 1, 'code': 'USD', 'symbol': '\$', 'thousand_separator': ',', 'decimal_separator': '.'},
        'currency_precision': 2, 'quantity_precision': 2,
        'time_format': 'h:i A',
      },
      'locations': [
        {'id': 1, 'name': 'Main Store', 'location_id': 'ST001', 'landmark': 'Downtown', 'city': 'NYC', 'state': 'NY', 'country': 'USA'},
        {'id': 2, 'name': 'Branch 1', 'location_id': 'ST002', 'landmark': 'Uptown', 'city': 'NYC', 'state': 'NY', 'country': 'USA'},
      ],
      'tax_rates': [
        {'id': 1, 'name': 'VAT 10%', 'amount': 10, 'is_tax_group': false},
      ],
      'payment_accounts': [
        {'id': 1, 'name': 'Cash', 'account_type': 'cash'},
        {'id': 2, 'name': 'Bank Account', 'account_type': 'bank'},
      ],
    },
  };

  // ─── LOW STOCK (standalone) ──────────────────────────────────
  static List<Map<String, dynamic>> lowStockList = [
    {'product_id': 5, 'product_name': 'Notebook A5', 'sku': 'NB-005', 'variation_id': 5, 'variation_name': 'Default', 'location_id': 1, 'qty_available': 5, 'alert_quantity': 20},
  ];
}
