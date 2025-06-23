import 'package:flutter/material.dart'; // Import du package Flutter pour les widgets et les outils de gestion d'état.
import 'package:myapp/models/user_model.dart'; // Import du modèle représentant un utilisateur.
import 'package:myapp/models/attendance_model.dart'; // Import du modèle représentant une présence (pointage).
import 'package:myapp/models/leave_model.dart'; // Import du modèle représentant une demande de congé.
import 'package:myapp/services/firebase_service.dart'; // Import du service Firebase pour l'accès aux données.
import 'package:intl/intl.dart'; // Import pour formater les dates et heures.

class EmployeeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseService get firebaseService => _firebaseService;

  // Données & états
  List<UserModel> _employees = [];
  List<AttendanceModel> _todayAttendance = [];
  List<LeaveModel> _leaves = [];
  List<LeaveModel> _employeeLeaves = [];
  List<Map<String, dynamic>> _lateReports = [];

  bool _isLoading = false;

   // États de pointage
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  bool isOnAuthorization = false;
  bool isPermanentlyOut = false;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String workedHours = '';

   // Getters
  bool get isLoading => _isLoading;
  List<UserModel> get employees => _employees;
  List<AttendanceModel> get todayAttendance => _todayAttendance;
  List<LeaveModel> get leaves => _leaves;
  List<LeaveModel> get employeeLeaves => _employeeLeaves;
  List<Map<String, dynamic>> get lateReports => _lateReports;

  // ====================== PRÉSENCE ======================
  Future<void> loadTodayStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final data = await _firebaseService.getTodayStatus();
      hasCheckedIn = data['checkIn'] ?? false;
      hasCheckedOut = data['checkOut'] ?? false;
      checkInTime = data['checkInTime'];
      checkOutTime = data['checkOutTime'];
      isOnAuthorization = data['isOnAuthorization'] ?? false;
      isPermanentlyOut = data['isPermanentlyOut'] ?? false;
      workedHours = data['workedHours']?.toString() ?? '';
    } catch (e) {
      print('Erreur lors du chargement du statut: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkIn() async {
    try {
      await _firebaseService.checkIn();
      checkInTime = DateTime.now();
      hasCheckedIn = true;
      isOnAuthorization = false;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du pointage d\'entrée: $e');
    }
  }

  Future<void> checkOut({required bool permanent}) async {
    try {
      await _firebaseService.checkOut(permanent: permanent);
      checkOutTime = DateTime.now();
      hasCheckedOut = true;
      if (permanent) {
        isPermanentlyOut = true;
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors du pointage de sortie: $e');
    }
  }

  Future<void> setPermission() async {
    try {
      await _firebaseService.setPermission();
      isOnAuthorization = true;
      hasCheckedOut = true; // Temporairement sorti
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la demande d\'autorisation: $e');
    }
  }

  Future<void> returnFromPermission() async {
    try {
      await _firebaseService.returnFromPermission();
      isOnAuthorization = false;
      hasCheckedOut = false; // De retour au travail
      notifyListeners();
    } catch (e) {
      print('Erreur lors du retour d\'autorisation: $e');
    }
  }

  Future<Map<String, dynamic>> calculateWeeklyStats() async {
    try {
      return await _firebaseService.calculateWeeklyStats();
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {
        'totalHours': 0.0,
        'daysPresent': 0,
        'lateCount': 0,
      };
    }
  }

  // ====================== EMPLOYÉS ======================
  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    _employees = await _firebaseService.getEmployees();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEmployee(String uid) async {
    await _firebaseService.deleteEmployee(uid);
    await loadEmployees();
  }

  Future<void> updateEmployee(UserModel user) async {
    await _firebaseService.updateEmployee(user);
    await loadEmployees();
  }

  // ====================== CONGÉS ======================
  Future<bool> submitLeaveRequest(DateTime startDate, DateTime endDate, String reason) async {
    try {
      await _firebaseService.submitLeaveRequest(startDate, endDate, reason);
      await loadEmployeeLeaves();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadEmployeeLeaves() async {
    _isLoading = true;
    notifyListeners();
    _employeeLeaves = await _firebaseService.getEmployeeLeaves();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllLeaves() async {
    _isLoading = true;
    notifyListeners();
    _leaves = await _firebaseService.getAllLeaves();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateLeaveStatus(String leaveId, LeaveStatus status) async {
    await _firebaseService.updateLeaveStatus(leaveId, status);
    await loadAllLeaves();
  }

  // ====================== UTILITAIRES ======================
  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  String formatTime(DateTime time) => DateFormat('HH:mm').format(time);
}
