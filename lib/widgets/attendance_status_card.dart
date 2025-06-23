import 'package:flutter/material.dart';

class AttendanceStatusCard extends StatelessWidget {
  final String status;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isOnAuthorization;
  final bool isPermanentlyOut;

  const AttendanceStatusCard({
    super.key,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.isOnAuthorization = false,
    this.isPermanentlyOut = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isPermanentlyOut) {
      statusColor = Colors.red;
      statusIcon = Icons.exit_to_app;
      statusText = "Sortie définitive";
    } else if (isOnAuthorization) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = "En autorisation";
    } else if (checkInTime != null && checkOutTime == null) {
      statusColor = Colors.green;
      statusIcon = Icons.work;
      statusText = "Au travail";
    } else if (checkInTime != null && checkOutTime != null) {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle;
      statusText = "Journée terminée";
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.person_off;
      statusText = "Pas encore pointé";
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription() {
    if (isPermanentlyOut) {
      return "Vous avez quitté définitivement pour aujourd'hui";
    } else if (isOnAuthorization) {
      return "Vous êtes en autorisation temporaire";
    } else if (checkInTime != null && checkOutTime == null) {
      final duration = DateTime.now().difference(checkInTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return "Travail en cours depuis ${hours}h${minutes.toString().padLeft(2, '0')}";
    } else if (checkInTime != null && checkOutTime != null) {
      final duration = checkOutTime!.difference(checkInTime!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return "Journée terminée : ${hours}h${minutes.toString().padLeft(2, '0')} travaillées";
    } else {
      return "Vous devez pointer votre arrivée";
    }
  }
}

