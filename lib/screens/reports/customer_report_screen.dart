// lib/screens/reports/customer_report_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/customer_performance_model.dart';
import '../../providers/sales_provider.dart';
import 'customer_sales_history_screen.dart';

enum CustomerSortBy { totalPurchased, pendingAmount }

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
  Future<List<CustomerPerformance>>? _performanceFuture;
  CustomerSortBy _sortBy = CustomerSortBy.totalPurchased;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    // Para clientes, geralmente analisamos o histórico completo
    _performanceFuture = salesProvider.calculateCustomerPerformance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Clientes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                _sortBy == CustomerSortBy.totalPurchased,
                _sortBy == CustomerSortBy.pendingAmount,
              ],
              onPressed: (index) {
                setState(() {
                  _sortBy = index == 0 ? CustomerSortBy.totalPurchased : CustomerSortBy.pendingAmount;
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Maiores Compradores')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Maiores Devedores')),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CustomerPerformance>>(
              future: _performanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao gerar relatório: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma venda a clientes encontrada.'));
                }

                final customers = snapshot.data!;
                // Ordena a lista com base no filtro selecionado
                if (_sortBy == CustomerSortBy.totalPurchased) {
                  customers.sort((a, b) => b.totalAmountPurchased.compareTo(a.totalAmountPurchased));
                } else {
                  customers.sort((a, b) => b.pendingAmount.compareTo(a.pendingAmount));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isTopDebtor = _sortBy == CustomerSortBy.pendingAmount && customer.pendingAmount > 0;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(customer.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${customer.purchaseCount} compras | Última em: ${DateFormat('dd/MM/yy').format(customer.lastPurchaseDate)}',
                        ),
                        trailing: Text(
                          _sortBy == CustomerSortBy.totalPurchased
                              ? 'R\$ ${customer.totalAmountPurchased.toStringAsFixed(2)}'
                              : 'R\$ ${customer.pendingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isTopDebtor ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => CustomerSalesHistoryScreen(
                                customerId: customer.customerId,
                                customerName: customer.customerName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}