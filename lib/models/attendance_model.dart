class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime date;
  final bool isLate;
  final bool isEarlyDeparture;
  final bool hasAuthorization;
  final bool isOnAuthorization;
  final bool isPermanentDeparture;
  final String? lateReason;
  final String? earlyDepartureReason;
  final List<Map<String, DateTime>> authorizationPeriods; // Nouvelle propriété pour gérer les autorisations

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.checkInTime,
    this.checkOutTime,
    required this.date,
    this.isLate = false,
    this.isEarlyDeparture = false,
    this.hasAuthorization = false,
    this.isOnAuthorization = false,
    this.isPermanentDeparture = false,
    this.lateReason,
    this.earlyDepartureReason,
    this.authorizationPeriods = const [],
  });

  // Getters pour la rétrocompatibilité
  DateTime? get arrivalTime => checkInTime;
  DateTime? get departureTime => checkOutTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'checkInTime': checkInTime?.millisecondsSinceEpoch,
      'checkOutTime': checkOutTime?.millisecondsSinceEpoch,
      'date': date.millisecondsSinceEpoch,
      'isLate': isLate,
      'isEarlyDeparture': isEarlyDeparture,
      'hasAuthorization': hasAuthorization,
      'isOnAuthorization': isOnAuthorization,
      'isPermanentDeparture': isPermanentDeparture,
      'lateReason': lateReason,
      'earlyDepartureReason': earlyDepartureReason,
      'authorizationPeriods': authorizationPeriods.map((period) => {
        'start': period['start']?.millisecondsSinceEpoch,
        'end': period['end']?.millisecondsSinceEpoch,
      }).toList(),
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      checkInTime: map['checkInTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['checkInTime'])
          : null,
      checkOutTime: map['checkOutTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['checkOutTime'])
          : null,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      isLate: map['isLate'] ?? false,
      isEarlyDeparture: map['isEarlyDeparture'] ?? false,
      hasAuthorization: map['hasAuthorization'] ?? false,
      isOnAuthorization: map['isOnAuthorization'] ?? false,
      isPermanentDeparture: map['isPermanentDeparture'] ?? false,
      lateReason: map['lateReason'],
      earlyDepartureReason: map['earlyDepartureReason'],
      authorizationPeriods: (map['authorizationPeriods'] as List?)?.map((period) => {
        'start': period['start'] != null ? DateTime.fromMillisecondsSinceEpoch(period['start']) : null,
        'end': period['end'] != null ? DateTime.fromMillisecondsSinceEpoch(period['end']) : null,
      }).cast<Map<String, DateTime>>().toList() ?? [],
    );
  }

  double getWorkedHours() {
    if (checkInTime != null && checkOutTime != null) {
      final duration = checkOutTime!.difference(checkInTime!);
      // Soustraire les périodes d'autorisation
      double authorizationHours = 0;
      for (var period in authorizationPeriods) {
        if (period['start'] != null && period['end'] != null) {
          authorizationHours += period['end']!.difference(period['start']!).inMinutes / 60.0;
        }
      }
      return (duration.inMinutes / 60.0) - authorizationHours;
    }
    return 0.0;
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? date,
    bool? isLate,
    bool? isEarlyDeparture,
    bool? hasAuthorization,
    bool? isOnAuthorization,
    bool? isPermanentDeparture,
    String? lateReason,
    String? earlyDepartureReason,
    List<Map<String, DateTime>>? authorizationPeriods,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      date: date ?? this.date,
      isLate: isLate ?? this.isLate,
      isEarlyDeparture: isEarlyDeparture ?? this.isEarlyDeparture,
      hasAuthorization: hasAuthorization ?? this.hasAuthorization,
      isOnAuthorization: isOnAuthorization ?? this.isOnAuthorization,
      isPermanentDeparture: isPermanentDeparture ?? this.isPermanentDeparture,
      lateReason: lateReason ?? this.lateReason,
      earlyDepartureReason: earlyDepartureReason ?? this.earlyDepartureReason,
      authorizationPeriods: authorizationPeriods ?? this.authorizationPeriods,
    );
  }
}