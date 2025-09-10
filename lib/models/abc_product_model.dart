// lib/models/abc_product_model.dart
class AbcProduct {
  final String productId;
  final String productName;
  double totalRevenue;
  int totalQuantity;
  double percentageOfTotal;
  String classification;

  AbcProduct({
    required this.productId,
    required this.productName,
    this.totalRevenue = 0.0,
    this.totalQuantity = 0,
    this.percentageOfTotal = 0.0,
    this.classification = '',
  });
}