import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sale_order_model.dart';
import '../providers/cash_flow_provider.dart';
import '../providers/sales_provider.dart';
import '../services/pdf_receipt_service.dart'; // Importa nosso serviço de PDF

class OrderItemWidget extends StatelessWidget {
  final SaleOrder order;
  const OrderItemWidget({super.key, required this.order});

  // Função para chamar o serviço de PDF
  Future<void> _generatePdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await PdfReceiptService().generateAndShareReceipt(order);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
      );
    } finally {
      Navigator.of(context).pop(); // Fecha o indicador de loading
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = !order.isPaid && order.dueDate != null && order.dueDate!.isBefore(DateTime.now());
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    final cashFlowProvider = Provider.of<CashFlowProvider>(context, listen: false);

    return Card(
      shape: isOverdue
          ? RoundedRectangleBorder(
        side: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      )
          : null,
      margin: const EdgeInsets.all(10),
      child: ExpansionTile(
        key: PageStorageKey(order.id),
        title: Text('R\$ ${order.amount.toStringAsFixed(2)}'),
        subtitle: Text(
          order.customer != null
              ? 'Cliente: ${order.customer!.name}'
              : 'Pagamento: ${order.paymentMethod}',
        ),
        trailing: Text(DateFormat('dd/MM/yy').format(order.date)),
        leading: order.isPaid
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (isOverdue
            ? const Icon(Icons.warning, color: Colors.red)
            : const Icon(Icons.receipt_long)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.dueDate != null)
                  Row(
                    children: [
                      Text(
                        'Vencimento: ${DateFormat('dd/MM/yyyy').format(order.dueDate!)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? Colors.red : Colors.grey[700],
                        ),
                      ),
                      if (isOverdue)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text('(VENCIDO)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        )
                    ],
                  ),
                const Divider(),
                ...order.products.map(
                      (prod) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(prod.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${prod.quantity}x R\$${prod.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.grey))
                      ],
                    ),
                  ),
                ).toList(),

                // --- BOTÕES DE AÇÃO ---
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      // Botão para gerar o recibo
                      OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Recibo'),
                        onPressed: () => _generatePdf(context),
                      ),

                      const Spacer(), // Adiciona um espaço flexível

                      // Botão para marcar como pago (só aparece se for fiado)
                      if (!order.isPaid && order.customer != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Marcar como Pago'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            salesProvider.markOrderAsPaid(order.id, order.amount, cashFlowProvider);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}