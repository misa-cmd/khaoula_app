import 'package:flutter/material.dart';

class ScheduleView extends StatelessWidget {
  final List<Map<String, String>> schedule = [
    {'jour': 'Lundi', 'horaire': '08:00 - 17:00'},
    {'jour': 'Mardi', 'horaire': '08:00 - 17:00'},
    {'jour': 'Mercredi', 'horaire': '08:00 - 17:00'},
    {'jour': 'Jeudi', 'horaire': '08:00 - 17:00', 'special': 'true'},
    {'jour': 'Vendredi', 'horaire': '08:00 - 17:00'},
    {'jour': 'Samedi', 'horaire': 'Repos'},
    {'jour': 'Dimanche', 'horaire': 'Repos'},
  ];

  ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Gestion des Plannings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF3F5044),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Actualiser les données en temps réel
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Plannings actualisés'),
                  backgroundColor: Color(0xFF3F5044),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // En-tête avec informations
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Color(0xFF3F5044),
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Horaires Attribués',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F5044),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Consultation en temps réel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'En ligne',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Liste des horaires
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // En-tête du tableau
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFF3F5044).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Jour',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F5044),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Horaires',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F5044),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Statut',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F5044),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Liste des jours
                      Expanded(
                        child: ListView.builder(
                          itemCount: schedule.length,
                          itemBuilder: (context, index) {
                            final jour = schedule[index];
                            bool isWeekend = jour['horaire'] == 'Repos';
                            bool isToday = _isToday(jour['jour']!);
                            bool isSpecial = jour['special'] == 'true';

                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    isSpecial
                                        ? Colors.grey[200]
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    isSpecial
                                        ? Border.all(
                                          color: Colors.grey[400]!,
                                          width: 1,
                                        )
                                        : null,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSpecial)
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey[600],
                                              size: 16,
                                            ),
                                          if (isSpecial) SizedBox(width: 4),
                                          Text(
                                            jour['jour']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        jour['horaire']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isWeekend
                                                  ? Colors.orange[700]
                                                  : Colors.black87,
                                          fontWeight:
                                              isWeekend
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isWeekend
                                                  ? Colors.orange[100]
                                                  : Colors.green[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          isWeekend
                                              ? Icons.weekend
                                              : Icons.work,
                                          color:
                                              isWeekend
                                                  ? Colors.orange[700]
                                                  : Colors.green[700],
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Statistiques en bas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Jours travaillés',
                      '5',
                      Icons.work,
                      Colors.green,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      'Heures/semaine',
                      '45h',
                      Icons.access_time,
                      Colors.blue,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      'Jours de repos',
                      '2',
                      Icons.weekend,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _isToday(String jour) {
    final now = DateTime.now();
    final weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return weekdays[now.weekday - 1] == jour;
  }
}
