import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CustomerSalesHistoryScreen extends StatelessWidget {
  final String customerId;
  final String customerName;

  const CustomerSalesHistoryScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: const Center(child: Text("Usuário não logado.")));
    }

    // Query que busca as vendas filtradas pelo ID do cliente
    final salesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sales')
        .where('customerId', isEqualTo: customerId)
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Compras de $customerName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: salesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar vendas: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma compra encontrada para este cliente.'));
          }

          final salesDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: salesDocs.length,
            itemBuilder: (context, index) {
              final saleData = salesDocs[index].data() as Map<String, dynamic>;
              final saleDate = (saleData['date'] as Timestamp).toDate();
              final amount = (saleData['amount'] as num).toDouble();
              final isPaid = saleData['isPaid'] as bool;
              final paymentMethod = saleData['paymentMethod'] ?? 'N/D';

              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    'Compra de R\$ ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Data: ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(saleDate)}'),
                  trailing: Text(
                    isPaid ? 'Pago ($paymentMethod)' : 'Pendente',
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Você pode adicionar um onTap aqui para ver os detalhes dos produtos daquela compra
                ),
              );
            },
          );
        },
      ),
    );
  }
}