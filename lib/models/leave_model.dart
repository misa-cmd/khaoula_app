import 'package:flutter/material.dart';
// Enumération représentant les états possibles d'une demande de congé.
enum LeaveStatus {
  en_cours, // La demande est en attente de traitement.
  accepte,  // La demande a été acceptée.
  refuse    // La demande a été refusée.
}

// Modèle de données représentant une demande de congé.
class LeaveModel {
  final String id; // Identifiant unique de la demande.
  final String employeeId; // Identifiant de l'employé qui a fait la demande.
  final String employeeName; // Nom de l'employé concerné.
  final DateTime startDate; // Date de début du congé.
  final DateTime endDate; // Date de fin du congé.
  final LeaveStatus status; // Statut actuel de la demande (en cours, acceptée, refusée).
  final DateTime requestDate; // Date à laquelle la demande a été soumise.
  final String reason; // Raison du congé (ex: maladie, vacances, etc.).

  // Constructeur de la classe avec paramètres requis et une valeur par défaut pour le statut et la raison.
  LeaveModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    this.status = LeaveStatus.en_cours, // Par défaut, la demande est en cours.
    required this.requestDate,
    this.reason = '', // Par défaut, la raison est vide.
  });

  // Méthode pour calculer le nombre de jours de congé
  int get numberOfDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Méthode pour obtenir le nombre de jours qui tombent dans une année spécifique
  int getDaysInYear(int year) {
    DateTime startOfYear = DateTime(year, 1, 1);
    DateTime endOfYear = DateTime(year, 12, 31, 23, 59, 59);
    
    // Vérifier si les dates de congé chevauchent avec l'année demandée
    if (endDate.isAfter(startOfYear.subtract(Duration(days: 1))) && 
        startDate.isBefore(endOfYear.add(Duration(days: 1)))) {
      
      // Calculer les jours qui tombent dans l'année spécifiée
      DateTime effectiveStart = startDate.isBefore(startOfYear) ? startOfYear : startDate;
      DateTime effectiveEnd = endDate.isAfter(endOfYear) ? endOfYear : endDate;
      
      return effectiveEnd.difference(effectiveStart).inDays + 1;
    }
    
    return 0; // Aucun jour ne tombe dans cette année
  }

  // Méthode pour vérifier si le congé concerne l'année en cours
  bool isForCurrentYear() {
    int currentYear = DateTime.now().year;
    return getDaysInYear(currentYear) > 0;
  }

  // Convertit l'objet LeaveModel en une map, pour stockage dans une base de données comme Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Identifiant de la demande.
      'employeeId': employeeId, // Identifiant de l'employé.
      'employeeName': employeeName, // Nom de l'employé.
      'startDate': startDate.millisecondsSinceEpoch, // Date de début convertie en millisecondes.
      'endDate': endDate.millisecondsSinceEpoch, // Date de fin convertie en millisecondes.
      'status': status.toString().split('.').last, // Convertit le statut en chaîne ('en_cours', etc.).
      'requestDate': requestDate.millisecondsSinceEpoch, // Date de demande en millisecondes.
      'reason': reason, // Raison du congé.
    };
  }

  // Crée un objet LeaveModel à partir d'une map (ex: depuis Firebase).
  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['id'] ?? '', // Récupère l'ID ou une chaîne vide si null.
      employeeId: map['employeeId'] ?? '', // ID de l'employé ou vide.
      employeeName: map['employeeName'] ?? '', // Nom de l'employé ou vide.
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0), // Convertit la date de début.
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0), // Convertit la date de fin.

      // Convertit la chaîne du statut en valeur de l'énumération LeaveStatus.
      status: LeaveStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'], // Compare avec le nom du statut.
        orElse: () => LeaveStatus.en_cours, // Si non trouvé, retourne 'en_cours'.
      ),

      // Convertit la date de demande.
      requestDate: DateTime.fromMillisecondsSinceEpoch(map['requestDate'] ?? 0),

      reason: map['reason'] ?? '', // Récupère la raison ou chaîne vide si absente.
    );
  }

  // Méthode pour créer une copie avec des modifications
  LeaveModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? startDate,
    DateTime? endDate,
    LeaveStatus? status,
    DateTime? requestDate,
    String? reason,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      reason: reason ?? this.reason,
    );
  }

  // Méthode pour obtenir une représentation textuelle du statut
  String get statusText {
    switch (status) {
      case LeaveStatus.en_cours:
        return 'En cours';
      case LeaveStatus.accepte:
        return 'Accepté';
      case LeaveStatus.refuse:
        return 'Refusé';
    }
  }

  // Méthode pour obtenir la couleur associée au statut
  Color get statusColor {
    switch (status) {
      case LeaveStatus.en_cours:
        return Colors.orange;
      case LeaveStatus.accepte:
        return Colors.green;
      case LeaveStatus.refuse:
        return Colors.red;
    }
  }

  @override
  String toString() {
    return 'LeaveModel(id: $id, employeeName: $employeeName, startDate: $startDate, endDate: $endDate, status: $status, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LeaveModel &&
      other.id == id &&
      other.employeeId == employeeId &&
      other.employeeName == employeeName &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.status == status &&
      other.requestDate == requestDate &&
      other.reason == reason;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      employeeId.hashCode ^
      employeeName.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      status.hashCode ^
      requestDate.hashCode ^
      reason.hashCode;
  }
}


