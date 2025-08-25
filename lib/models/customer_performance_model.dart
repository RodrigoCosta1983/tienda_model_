// lib/models/customer_performance_model.dart

class CustomerPerformance {
  final String customerId;
  final String customerName;
  double totalAmountPurchased;
  double pendingAmount; // Saldo devedor (fiado)
  int purchaseCount;
  DateTime lastPurchaseDate;

  CustomerPerformance({
    required this.customerId,
    required this.customerName,
    required this.lastPurchaseDate,
    this.totalAmountPurchased = 0.0,
    this.pendingAmount = 0.0,
    this.purchaseCount = 0,
  });
}