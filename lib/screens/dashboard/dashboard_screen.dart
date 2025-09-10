import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/cash_flow_provider.dart';
import '../../widgets/monthly_sales_chart.dart';
import '../../widgets/sales_chart.dart';
import '../sales/sales_history_screen.dart';

// Enum para controlar o período selecionado
enum TimePeriod { day, week, month }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TimePeriod _selectedPeriod = TimePeriod.day;

  // Função para exibir o gráfico semanal
  // Em dashboard_screen.dart

  void _showWeeklySalesChartDialog(Map<int, double> weeklySalesData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // 👇 ADICIONE ESTAS LINHAS PARA MUDAR O FUNDO
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // 👆 FIM DAS LINHAS ADICIONADAS

        title: const Text('Vendas da Semana', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          height: 300,
          width: 400,
          child: SalesChart(weeklySales: weeklySalesData),
        ),
        actions: [
          TextButton(
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // Função para exibir o gráfico mensal

  void _showMonthlySalesChartDialog(Map<int, double> monthlySalesData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // 👇 Adicione estas linhas para o estilo escuro
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: const Text('Vendas do Mês (por Semana)', style: TextStyle(color: Colors.white)),
        content: SizedBox(
            height: 300,
            width: 400,
            child: MonthlySalesChart(monthlySales: monthlySalesData)),
        actions: [
          TextButton(
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // SUGESTÃO DE MELHORIA para o seu _buildInfoCard
  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      // Usar a cor do schema para o card, para melhor consistência com o tema
      color: colorScheme.surface.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e Título na mesma linha
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor ?? colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(), // Usa o espaço disponível para empurrar o valor para baixo

            // Valor com FittedBox para autoajuste
            SizedBox(
              height: 40, // Altura fixa para o valor se ajustar dentro
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(appBar: AppBar(title: const Text("Dashboard")), body: const Center(child: Text('Nenhum usuário logado.')));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.4 : 0.15,
              child: Image.asset(
                isDarkMode
                    ? 'assets/backgrounds/background_light.png'
                    : 'assets/images/background_dark.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users').doc(user.uid)
                  .collection('sales').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar dados.'));
                }

                final salesDocs = snapshot.data?.docs ?? [];

                final today = DateTime.now();
                final salesFiltered = salesDocs.where((doc) {
                  final orderDate = (doc['date'] as Timestamp).toDate();
                  switch (_selectedPeriod) {
                    case TimePeriod.day:
                      return orderDate.day == today.day && orderDate.month == today.month && orderDate.year == today.year;
                    case TimePeriod.week:
                      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
                      return orderDate.isAfter(startOfWeek.subtract(const Duration(days: 1)));
                    case TimePeriod.month:
                      return orderDate.month == today.month && orderDate.year == today.year;
                    default:
                      return false;
                  }
                }).fold(0.0, (sum, doc) => sum + (doc['amount'] as num));

                String salesTitle;
                switch (_selectedPeriod) {
                  case TimePeriod.day: salesTitle = 'Vendas de Hoje'; break;
                  case TimePeriod.week: salesTitle = 'Vendas da Semana'; break;
                  case TimePeriod.month: salesTitle = 'Vendas do Mês'; break;
                  default: salesTitle = 'Vendas';
                }

                final Map<int, double> weeklySalesSummary = {0:0,1:0,2:0,3:0,4:0,5:0,6:0};
                final Map<int, double> monthlySalesSummary = {0:0,1:0,2:0,3:0,4:0};
                final monthlyOrders = salesDocs.where((doc) {
                  final orderDate = (doc['date'] as Timestamp).toDate();
                  return orderDate.month == today.month && orderDate.year == today.year;
                });

                for (var doc in monthlyOrders) {
                  final orderDate = (doc['date'] as Timestamp).toDate();
                  final orderAmount = (doc['amount'] as num).toDouble();
                  final dayOfWeek = orderDate.weekday;
                  weeklySalesSummary.update(dayOfWeek - 1, (value) => value + orderAmount, ifAbsent: () => orderAmount);
                  int weekOfMonth = ((orderDate.day - 1) / 7).floor();
                  monthlySalesSummary.update(weekOfMonth, (value) => value + orderAmount, ifAbsent: () => orderAmount);
                }

                final pendingFiado = salesDocs.where((doc) => doc['isPaid'] == false).fold(0.0, (sum, doc) => sum + (doc['amount'] as num));
                final overdueCount = salesDocs.where((doc) => doc['isPaid'] == false && (doc['dueDate'] as Timestamp).toDate().isBefore(today)).length;

                VoidCallback? salesCardOnTap;
                switch (_selectedPeriod) {
                  case TimePeriod.week:
                    salesCardOnTap = () => _showWeeklySalesChartDialog(weeklySalesSummary);
                    break;
                  case TimePeriod.month:
                    salesCardOnTap = () => _showMonthlySalesChartDialog(monthlySalesSummary);
                    break;
                  case TimePeriod.day:
                  default:
                    salesCardOnTap = () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => const SalesHistoryScreen(filter: SalesHistoryFilter.today),
                    ));
                    break;
                }

                final List<Widget> infoCards = [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: salesCardOnTap,
                    child: _buildInfoCard(context, title: salesTitle, value: 'R\$ ${salesFiltered.toStringAsFixed(2)}', icon: Icons.point_of_sale),
                  ),
                  Consumer<CashFlowProvider>(
                    builder: (context, cashFlowData, child) {
                      return _buildInfoCard(
                        context,
                        title: 'Caixa Atual',
                        value: 'R\$ ${cashFlowData.currentBalance.toStringAsFixed(2)}',
                        icon: Icons.wallet_sharp,
                        iconColor: Colors.green,
                      );
                    },
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SalesHistoryScreen(filter: SalesHistoryFilter.pending))),
                    child: _buildInfoCard(context, title: 'Contas a Receber (Fiado)', value: 'R\$ ${pendingFiado.toStringAsFixed(2)}', icon: Icons.receipt_long, iconColor: Colors.orange),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SalesHistoryScreen(filter: SalesHistoryFilter.overdue))),
                    child: _buildInfoCard(context, title: 'Contas Vencidas', value: '$overdueCount', icon: Icons.warning_amber_rounded, iconColor: Colors.red),
                  ),
                ];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                      child: ToggleButtons(
                        isSelected: [
                          _selectedPeriod == TimePeriod.day,
                          _selectedPeriod == TimePeriod.week,
                          _selectedPeriod == TimePeriod.month,
                        ],
                        onPressed: (index) {
                          setState(() {
                            if (index == 0) _selectedPeriod = TimePeriod.day;
                            if (index == 1) _selectedPeriod = TimePeriod.week;
                            if (index == 2) _selectedPeriod = TimePeriod.month;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Hoje')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Semana')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Mês')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 700) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              child: Wrap(
                                spacing: 20.0,
                                runSpacing: 20.0,
                                alignment: WrapAlignment.center,
                                children: infoCards.map((card) => SizedBox(width: 280, child: card)).toList(),
                              ),
                            );
                          } else {
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth > 420 ? 2 : 1,
                                childAspectRatio: constraints.maxWidth > 420 ? 1.3 : 1.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: infoCards.length,
                              itemBuilder: (context, index) => infoCards[index],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}