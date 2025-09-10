import 'package:flutter/material.dart';
import './abc_report_screen.dart';
import './customer_report_screen.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análises e Relatórios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildReportCard(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Análise de Produtos (ABC)',
            subtitle: 'Descubra quais são seus produtos mais importantes.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AbcReportScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildReportCard(
            context: context,
            icon: Icons.people_alt_outlined,
            title: 'Análise de Clientes',
            subtitle: 'Veja quem são seus maiores compradores e devedores.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CustomerReportScreen()),
              );
            },
          ),
          // No futuro, novos relatórios podem ser adicionados aqui
        ],
      ),
    );
  }

  // Widget auxiliar para criar os cards de opção
  Widget _buildReportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}