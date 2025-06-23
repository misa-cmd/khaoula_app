class AppConstants {
  // Heures de travail
  static const int workStartHour = 8;
  static const int workEndHour = 17;
  static const int workDaysPerWeek = 5;
  static const double standardWorkHoursPerDay = 8.0;
  static const double standardWorkHoursPerWeek = 40.0;

  // Messages
  static const String lateWarningMessage = 
      "Vous êtes en retard ! L'heure normale d'arrivée est 8h00. Une réclamation sera envoyée à l'administrateur.";
  
  static const String earlyExitMessage = 
      "Ce n'est pas encore 17h00. Est-ce un cas d'urgence ?\n\nChoisissez une option :";
  
  static const String notCheckedInWarning = 
      "⚠️ Attention : Tu n'as pas encore pointé aujourd'hui. Si tu ne pointes pas, tu seras noté comme absent.";

  // Couleurs
  static const Map<String, int> statusColors = {
    'present': 0xFF4CAF50,   // Vert
    'absent': 0xFFFF5722,    // Rouge
    'permission': 0xFFFF9800, // Orange
    'late': 0xFFFFC107,      // Amber
  };

  // Formats de date
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
}