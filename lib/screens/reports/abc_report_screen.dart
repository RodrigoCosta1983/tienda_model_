// lib/screens/reports/abc_report_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/abc_product_model.dart';
import '../../providers/sales_provider.dart';

// Enum para controlar o período do filtro
enum ReportPeriod { last7days, last30days, allTime }

class AbcReportScreen extends StatefulWidget {
  const AbcReportScreen({super.key});

  @override
  State<AbcReportScreen> createState() => _AbcReportScreenState();
}

class _AbcReportScreenState extends State<AbcReportScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.last30days;
  Future<List<AbcProduct>>? _abcAnalysisFuture;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento do relatório ao abrir a tela
    _generateReport();
  }

  void _generateReport() {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    DateTime? startDate;

    if (_selectedPeriod == ReportPeriod.last7days) {
      startDate = DateTime.now().subtract(const Duration(days: 7));
    } else if (_selectedPeriod == ReportPeriod.last30days) {
      startDate = DateTime.now().subtract(const Duration(days: 30));
    }
    // Se for 'allTime', startDate continua null, buscando todos os registros

    // Atribui o Future à variável de estado para o FutureBuilder usar
    setState(() {
      _abcAnalysisFuture = salesProvider.calculateAbcAnalysis(startDate: startDate);
    });
  }

  // Helper para obter a cor da classe
  Color _getClassColor(String classification) {
    switch (classification) {
      case 'A': return Colors.green.shade600;
      case 'B': return Colors.blue.shade600;
      case 'C': return Colors.grey.shade600;
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Produtos (ABC)'),
      ),
      body: Column(
        children: [
          // Filtro de período
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                _selectedPeriod == ReportPeriod.last7days,
                _selectedPeriod == ReportPeriod.last30days,
                _selectedPeriod == ReportPeriod.allTime,
              ],
              onPressed: (index) {
                setState(() {
                  if (index == 0) _selectedPeriod = ReportPeriod.last7days;
                  if (index == 1) _selectedPeriod = ReportPeriod.last30days;
                  if (index == 2) _selectedPeriod = ReportPeriod.allTime;
                  _generateReport(); // Gera o relatório novamente com o novo filtro
                });
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('7 Dias')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('30 Dias')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Tudo')),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AbcProduct>>(
              future: _abcAnalysisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao gerar relatório: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhuma venda encontrada no período para gerar o relatório.'));
                }

                final products = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getClassColor(product.classification),
                          child: Text(
                            product.classification,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${product.totalQuantity} vendidos | ${product.percentageOfTotal.toStringAsFixed(2)}% da receita',
                        ),
                        trailing: Text(
                          'R\$ ${product.totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
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