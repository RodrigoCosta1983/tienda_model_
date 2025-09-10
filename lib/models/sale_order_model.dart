import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import './customer_model.dart';

class SaleOrder {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;
  final Customer? customer;
  final DateTime? dueDate;
  final String paymentMethod;
  final bool isPaid;
  final String? notes; // Corrigido: Declarado apenas uma vez

  SaleOrder({
    required this.id,
    required this.amount,
    required this.products,
    required this.date,
    this.customer,
    this.dueDate,
    required this.paymentMethod,
    required this.isPaid,
    this.notes, // Corrigido: Incluído apenas uma vez
  });

  // Construtor que cria um SaleOrder a partir de um documento do Firestore
  factory SaleOrder.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    // Lógica para converter a lista de produtos do Firestore para uma lista de CartItem
    final List<CartItem> loadedProducts = (data['products'] as List<dynamic>? ?? [])
        .map((item) {
      // Criando um CartItem a partir do mapa de cada produto
      return CartItem(
        id: item['productId'],
        name: item['name'],
        quantity: item['quantity'],
        price: (item['price'] as num).toDouble(),
      );
    })
        .toList();

    return SaleOrder(
      id: snapshot.id,
      amount: (data['amount'] as num).toDouble(),
      products: loadedProducts,
      date: (data['date'] as Timestamp).toDate(),
      customer: data['customerId'] != null
          ? Customer(id: data['customerId'], name: data['customerName'], phone: data['customerPhone'] ?? '')
          : null,
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      isPaid: data['isPaid'] ?? false,
      paymentMethod: data['paymentMethod'] ?? 'N/D',
      notes: data['notes'] as String?,
    );
  }
}