import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesChart extends StatelessWidget {
  final Map<int, double> weeklySales;

  const SalesChart({super.key, required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    // Define as cores para cada barra, como na imagem de referência
    final List<Color> barColors = [
      Colors.blue.shade400,
      Colors.pink.shade300,
      Colors.amber.shade400,
      Colors.teal.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.green.shade400,
    ];

    // Encontra o maior valor de venda para ajustar a altura do gráfico
    double maxSale = 100.0; // Valor padrão para o gráfico não ficar vazio
    if (weeklySales.isNotEmpty && weeklySales.values.any((v) => v > 0)) {
      maxSale = weeklySales.values.reduce((a, b) => a > b ? a : b);
    }

    return BarChart(
      BarChartData(
        // Alinhamento e espaçamento das barras
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSale * 1.2, // Um pouco de espaço no topo

        // --- ESTILOS VISUAIS ---

        // 1. Tooltips (informação ao tocar na barra)
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.grey[800], // This parameter is no longer defined
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY;
              return BarTooltipItem(
                'R\$ ${value.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),

        // 2. Títulos dos Eixos (X e Y)
        titlesData: FlTitlesData(
          show: true,
          // Títulos da parte de baixo (Eixo X - Dias da Semana)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                String text;
                switch (value.toInt()) {
                  case 0: text = 'Dom'; break;
                  case 1: text = 'Seg'; break;
                  case 2: text = 'Ter'; break;
                  case 3: text = 'Qua'; break;
                  case 4: text = 'Qui'; break;
                  case 5: text = 'Sex'; break;
                  case 6: text = 'Sáb'; break;
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
                // Não mostra o valor 0 no eixo
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          // Desativa títulos de cima e da direita
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
          drawVerticalLine: false, // Sem linhas verticais
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white54, strokeWidth: 1,);
          },
        ),

        // 5. Definição das Barras
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklySales[index] ?? 0,
                color: barColors[index],
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