import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlySalesChart extends StatelessWidget {
  final Map<int, double> monthlySales; // Espera um mapa com 5 semanas (0 a 4)

  const MonthlySalesChart({super.key, required this.monthlySales});

  @override
  Widget build(BuildContext context) {
    // Paleta de cores para as 5 semanas
    final List<Color> barColors = [
      Colors.blue.shade400,
      Colors.pink.shade300,
      Colors.amber.shade400,
      Colors.teal.shade300,
      Colors.purple.shade300,
    ];

    double maxSale = 100.0;
    if (monthlySales.isNotEmpty && monthlySales.values.any((v) => v > 0)) {
      maxSale = monthlySales.values.reduce((a, b) => a > b ? a : b);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSale * 1.2, // Espaço extra no topo

        // --- ESTILOS VISUAIS ---

        // 1. Tooltips (informação ao tocar na barra)
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            //tooltipBackgroundColor: Colors.grey[800],
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final weekNumber = group.x.toInt() + 1;
              final value = rod.toY;
              return BarTooltipItem(
                'Semana $weekNumber\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: 'R\$ ${value.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.yellow[400], fontWeight: FontWeight.w500),
                  ),
                ],
              );
            },
          ),
        ),

        // 2. Títulos dos Eixos (X e Y)
        titlesData: FlTitlesData(
          show: true,
          // Títulos da parte de baixo (Eixo X - Semanas)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(
                  color: Colors.white, // Corrigido para branco
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                String text;
                switch (value.toInt()) {
                  case 0: text = 'S1'; break;
                  case 1: text = 'S2'; break;
                  case 2: text = 'S3'; break;
                  case 3: text = 'S4'; break;
                  case 4: text = 'S5'; break;
                  default: text = ''; break;
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
              },
              reservedSize: 38,
            ),
          ),
          // Títulos da esquerda (Eixo Y - Valores em R$)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        // 3. Bordas do Gráfico
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
          ),
        ),

        // 4. Linhas de Grade
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white54, strokeWidth: 1);
          },
        ),

        // 5. Definição das Barras
        barGroups: List.generate(5, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthlySales[index] ?? 0,
                color: barColors[index % barColors.length], // Usa as cores da nossa lista
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              )
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }
}