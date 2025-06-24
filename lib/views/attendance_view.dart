import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/employee_controller.dart';
import 'package:intl/intl.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<EmployeeController>(
            context,
            listen: false,
          ).loadTodayStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EmployeeController>(context, listen: false);
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pointage"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<EmployeeController>(
          builder:
              (context, controller, _) => Column(
                children: [
                  // Message d'attention si pas encore pointé
                  if (!controller.hasCheckedIn)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "⚠️ Attention : Tu n'as pas encore pointé aujourd'hui. Si tu ne pointes pas, tu seras noté comme absent.",
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Boutons de pointage
                  Row(
                    children: [
                      // Bouton d'entrée
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.hasCheckedIn ||
                                      controller.isPermanentlyOut
                                  ? null
                                  : () async {
                                    final now = DateTime.now();
                                    if (now.hour > 8 ||
                                        (now.hour == 8 && now.minute > 0)) {
                                      await _showLateWarning();
                                    }
                                    await controller.checkIn();
                                    await controller
                                        .loadTodayStatus(); // Refresh after check-in
                                  },
                          icon: const Icon(Icons.login),
                          label: const Text("Pointer l'entrée"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                controller.hasCheckedIn
                                    ? Colors.grey
                                    : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Bouton de sortie ou retour d'autorisation
                      Expanded(
                        child:
                            controller.isOnAuthorization
                                ? ElevatedButton.icon(
                                  onPressed: () async {
                                    await controller.returnFromPermission();
                                    await controller
                                        .loadTodayStatus(); // Refresh after return
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text("Retour d'autorisation"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )
                                : ElevatedButton.icon(
                                  onPressed:
                                      (!controller.hasCheckedIn ||
                                              controller.hasCheckedOut ||
                                              controller.isPermanentlyOut)
                                          ? null
                                          : () => _handleEarlyExit(controller),
                                  icon: const Icon(Icons.logout),
                                  label: const Text("Pointer la sortie"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (!controller.hasCheckedIn ||
                                                controller.hasCheckedOut)
                                            ? Colors.grey
                                            : Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Affichage des temps de pointage
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pointages d'aujourd'hui",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (controller.checkInTime != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.login,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Heure d'entrée : ${timeFormat.format(controller.checkInTime!)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (controller.checkOutTime != null) ...[
                            Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Heure de sortie : ${timeFormat.format(controller.checkOutTime!)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (controller.isOnAuthorization) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "En autorisation",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (controller.isPermanentlyOut) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Sortie définitive",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistiques hebdomadaires
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Statistiques hebdomadaires",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),

                          FutureBuilder<Map<String, dynamic>>(
                            future: controller.calculateWeeklyStats(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final stats = snapshot.data!;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Heures travaillées :"),
                                      Text(
                                        "${(stats['totalHours'] > 5 ? stats['totalHours'] - 1 : stats['totalHours']).toStringAsFixed(1)}h",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Jours présents :"),
                                      Text(
                                        "${stats['daysPresent']}/5",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Retards :"),
                                      Text(
                                        "${stats['lateCount']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              stats['lateCount'] > 0
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Future<void> _showLateWarning() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text("Retard", style: TextStyle(color: Colors.red)),
              ],
            ),
            content: const Text(
              "Vous êtes en retard ! L'heure normale d'arrivée est 8h00. Une réclamation sera envoyée à l'administrateur.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Compris"),
              ),
            ],
          ),
    );
  }

  Future<void> _handleEarlyExit(EmployeeController controller) async {
    final now = DateTime.now();

    if (now.hour < 17) {
      final result = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Sortie anticipée"),
              content: const Text(
                "Ce n'est pas encore 17h00. Est-ce un cas d'urgence ?\n\nChoisissez une option :",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop("definitive"),
                  child: const Text(
                    "Je sors définitivement",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop("permission"),
                  child: const Text(
                    "Je prends une autorisation",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annuler"),
                ),
              ],
            ),
      );

      if (result == "definitive") {
        await controller.checkOut(permanent: true);
        await controller.loadTodayStatus(); // Refresh after check-out
      } else if (result == "permission") {
        await controller.setPermission();
        await controller.loadTodayStatus(); // Refresh after setting permission
      }
    } else {
      // Sortie normale à 17h ou après
      await controller.checkOut(permanent: false);
      await controller.loadTodayStatus(); // Refresh after check-out
    }
  }
}
