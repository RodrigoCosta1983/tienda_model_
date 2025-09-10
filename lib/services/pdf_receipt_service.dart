import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/sale_order_model.dart';

class PdfReceiptService {
  Future<void> generateAndShareReceipt(SaleOrder order) async {
    final user = FirebaseAuth.instance.currentUser!;
    final profileSnapshot = await FirebaseFirestore.instance.collection('user_profiles').doc(user.uid).get();
    final sellerData = profileSnapshot.data() ?? {};

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildPdfContent(order, sellerData);
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'recibo_${order.id.substring(0, 6)}.pdf',
    );
  }

  pw.Widget _buildPdfContent(SaleOrder order, Map<String, dynamic> sellerData) {
    final notes = order.notes;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Cabeçalho (sem alterações)
        pw.Text(sellerData['fullName'] ?? 'Nome da Empresa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
        pw.Text('CNPJ/CPF: ${sellerData['documentNumber'] ?? ''}'),
        pw.Text('Telefone: ${sellerData['phone'] ?? ''}'),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 20),

        // Detalhes da Venda (sem alterações)
        pw.Center(child: pw.Text('COMPROVANTE DE VENDA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18))),
        pw.SizedBox(height: 20),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(order.date)}'),
              pw.Text('Recibo #${order.id.substring(0, 6).toUpperCase()}'),
            ]
        ),
        pw.SizedBox(height: 10),
        pw.Text('Cliente: ${order.customer?.name ?? 'Consumidor Final'}'),
        pw.Divider(),
        if (notes != null && notes.isNotEmpty)
          pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Observações:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(notes),
                    pw.Divider(),
                  ]
              )
          ),
        pw.SizedBox(height: 20),

        // Tabela de Itens (sem alterações)
        pw.Text('ITENS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
            headers: ['Produto', 'Qtd', 'Preço Unit.', 'Subtotal'],
            data: order.products.map((item) {
              return [
                item.name,
                item.quantity.toString(),
                'R\$ ${item.price.toStringAsFixed(2)}',
                'R\$ ${(item.price * item.quantity).toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerRight,
            columnWidths: { 0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(2) }
        ),
        pw.Divider(),
        pw.SizedBox(height: 20),

        // --- TOTAIS E FORMA DE PAGAMENTO (COM ALTERAÇÃO) ---
        pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Forma de Pagamento: ${order.paymentMethod}'),

                  // 👇 CONDIÇÃO PARA MOSTRAR A DATA DE VENCIMENTO 👇
                  if (!order.isPaid && order.dueDate != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        'Vencimento: ${DateFormat('dd/MM/yyyy').format(order.dueDate!)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                      ),
                    ),

                  pw.SizedBox(height: 5),
                  pw.Text(
                    'TOTAL: R\$ ${order.amount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                  ),
                ]
            )
        ),
        pw.Spacer(),
        pw.Center(child: pw.Text('--- Gerado por Gelo Gestor ---', style: pw.TextStyle(color: PdfColors.grey))),
      ],
    );
  }
}