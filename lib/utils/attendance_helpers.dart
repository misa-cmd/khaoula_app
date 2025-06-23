import 'package:intl/intl.dart';
import 'package:flutter/material.dart'; 
class AttendanceHelpers {
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return "${hours}h${minutes.toString().padLeft(2, '0')}";
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Bonjour";
    } else if (hour < 18) {
      return "Bon après-midi";
    } else {
      return "Bonsoir";
    }
  }

  static bool isWorkingDay(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5; // Lundi à Vendredi
  }

  static bool isLateArrival(DateTime checkInTime) {
    return checkInTime.hour > 8 || (checkInTime.hour == 8 && checkInTime.minute > 0);
  }

  static bool isEarlyDeparture(DateTime checkOutTime) {
    return checkOutTime.hour < 17;
  }

  static String getWorkingTimeStatus(DateTime checkInTime, DateTime? checkOutTime) {
    if (checkOutTime == null) {
      final duration = DateTime.now().difference(checkInTime);
      return "En cours : ${formatDuration(duration)}";
    } else {
      final duration = checkOutTime.difference(checkInTime);
      return "Terminé : ${formatDuration(duration)}";
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'permission':
        return Colors.orange;
      case 'late':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Présent';
      case 'absent':
        return 'Absent';
      case 'permission':
        return 'En autorisation';
      case 'late':
        return 'En retard';
      default:
        return 'Inconnu';
    }
  }
}