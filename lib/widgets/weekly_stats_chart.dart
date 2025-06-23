import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyStatsChart extends StatelessWidget {
  final Map<String, dynamic> stats;

  const WeeklyStatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistiques de la semaine",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            
            // Graphique en barres pour les heures par jour
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barGroups: _buildBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['L', 'M', 'M', 'J', 'V'];
                          return Text(days[value.toInt()]);
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Résumé des statistiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Total heures",
                  "${stats['totalHours'].toStringAsFixed(1)}h",
                  Colors.blue,
                ),
                _buildStatItem(
                  "Jours présents",
                  "${stats['daysPresent']}/5",
                  Colors.green,
                ),
                _buildStatItem(
                  "Retards",
                  "${stats['lateCount']}",
                  stats['lateCount'] > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    // Données simulées pour les heures par jour
    // Dans une vraie implémentation, cela viendrait de Firebase
    final dailyHours = [8.0, 7.5, 8.2, 6.0, 8.0]; // Lun, Mar, Mer, Jeu, Ven
    
    return dailyHours.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.value >= 8 ? Colors.green : Colors.orange,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}