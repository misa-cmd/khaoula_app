import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/attendance_model.dart';
import 'package:myapp/models/leave_model.dart';
import 'package:intl/intl.dart';

import 'package:myapp/controllers/employee_controller.dart';

/// Service principal pour gérer toutes les interactions avec Firebase
/// Gère l'authentification, les utilisateurs, les présences et les congés
class FirebaseService {
  // Instances Firebase pour l'authentification et la base de données
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== nv condition de conge ==========
  // Ajoutez ces méthodes à votre classe FirebaseService existante

  /// Calcule le nombre total de jours de congés approuvés pour un employé dans l'année en cours
  Future<int> getApprovedLeaveDaysForCurrentYear(String employeeId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1);
      DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

      QuerySnapshot snapshot =
          await _firestore
              .collection('leaves')
              .where('employeeId', isEqualTo: employeeId)
              .where('status', isEqualTo: 'accepte')
              .get();

      int totalDays = 0;
      for (var doc in snapshot.docs) {
        LeaveModel leave = LeaveModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        // Vérifier si les dates de congé chevauchent avec l'année en cours
        if (leave.endDate.isAfter(startOfYear.subtract(Duration(days: 1))) &&
            leave.startDate.isBefore(endOfYear.add(Duration(days: 1)))) {
          // Calculer les jours qui tombent dans l'année en cours
          DateTime effectiveStart =
              leave.startDate.isBefore(startOfYear)
                  ? startOfYear
                  : leave.startDate;
          DateTime effectiveEnd =
              leave.endDate.isAfter(endOfYear) ? endOfYear : leave.endDate;

          int days = effectiveEnd.difference(effectiveStart).inDays + 1;
          totalDays += days;
        }
      }

      return totalDays;
    } catch (e) {
      print('Erreur calcul jours congés: $e');
      return 0;
    }
  }

  /// Calcule le nombre de jours demandés (toutes demandes confondues) pour l'année en cours
  Future<int> getRequestedLeaveDaysForCurrentYear(String employeeId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1);
      DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

      QuerySnapshot snapshot =
          await _firestore
              .collection('leaves')
              .where('employeeId', isEqualTo: employeeId)
              .get();

      int totalDays = 0;
      for (var doc in snapshot.docs) {
        LeaveModel leave = LeaveModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        // Vérifier si les dates de congé chevauchent avec l'année en cours
        if (leave.endDate.isAfter(startOfYear.subtract(Duration(days: 1))) &&
            leave.startDate.isBefore(endOfYear.add(Duration(days: 1)))) {
          // Calculer les jours qui tombent dans l'année en cours
          DateTime effectiveStart =
              leave.startDate.isBefore(startOfYear)
                  ? startOfYear
                  : leave.startDate;
          DateTime effectiveEnd =
              leave.endDate.isAfter(endOfYear) ? endOfYear : leave.endDate;

          int days = effectiveEnd.difference(effectiveStart).inDays + 1;
          totalDays += days;
        }
      }

      return totalDays;
    } catch (e) {
      print('Erreur calcul jours demandés: $e');
      return 0;
    }
  }

  /// Calcule le nombre de jours en attente pour l'année en cours
  Future<int> getPendingLeaveDaysForCurrentYear(String employeeId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1);
      DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

      QuerySnapshot snapshot =
          await _firestore
              .collection('leaves')
              .where('employeeId', isEqualTo: employeeId)
              .where('status', isEqualTo: 'en_cours')
              .get();

      int totalDays = 0;
      for (var doc in snapshot.docs) {
        LeaveModel leave = LeaveModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        // Vérifier si les dates de congé chevauchent avec l'année en cours
        if (leave.endDate.isAfter(startOfYear.subtract(Duration(days: 1))) &&
            leave.startDate.isBefore(endOfYear.add(Duration(days: 1)))) {
          // Calculer les jours qui tombent dans l'année en cours
          DateTime effectiveStart =
              leave.startDate.isBefore(startOfYear)
                  ? startOfYear
                  : leave.startDate;
          DateTime effectiveEnd =
              leave.endDate.isAfter(endOfYear) ? endOfYear : leave.endDate;

          int days = effectiveEnd.difference(effectiveStart).inDays + 1;
          totalDays += days;
        }
      }

      return totalDays;
    } catch (e) {
      print('Erreur calcul jours en attente: $e');
      return 0;
    }
  }

  /// Vérifie si une nouvelle demande de congé dépasse la limite annuelle
  Future<bool> canRequestLeave(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      int currentApprovedDays = await getApprovedLeaveDaysForCurrentYear(
        employeeId,
      );
      int currentPendingDays = await getPendingLeaveDaysForCurrentYear(
        employeeId,
      );

      // Calculer les jours de la nouvelle demande pour l'année en cours
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1);
      DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

      int newRequestDays = 0;
      if (endDate.isAfter(startOfYear.subtract(Duration(days: 1))) &&
          startDate.isBefore(endOfYear.add(Duration(days: 1)))) {
        DateTime effectiveStart =
            startDate.isBefore(startOfYear) ? startOfYear : startDate;
        DateTime effectiveEnd =
            endDate.isAfter(endOfYear) ? endOfYear : endDate;
        newRequestDays = effectiveEnd.difference(effectiveStart).inDays + 1;
      }

      // Vérifier si le total ne dépasse pas 30 jours
      return (currentApprovedDays + currentPendingDays + newRequestDays) <= 30;
    } catch (e) {
      print('Erreur vérification limite congés: $e');
      return false;
    }
  }

  // ========== GESTION DE L'AUTHENTIFICATION ==========

  /// Inscription d'un nouvel utilisateur
  /// Crée un compte Firebase Auth et enregistre les données utilisateur dans Firestore
  /// Détermine automatiquement si l'utilisateur est admin basé sur l'email
  Future<UserModel?> signUp(String nom, String email, String password) async {
    try {
      // Création du compte Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Création du modèle utilisateur avec détermination du rôle admin
      UserModel user = UserModel(
        uid: result.user!.uid,
        nom: nom,
        email: email,
        isAdmin:
            email ==
            'admin1@test.com', // Logique de détermination du rôle admin
        createdAt: DateTime.now(),
      );

      // Sauvegarde des données utilisateur dans Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      print('Erreur inscription: $e');
      return null;
    }
  }

  /// Connexion d'un utilisateur existant
  /// Authentifie avec Firebase Auth et récupère/met à jour les données depuis Firestore
  /// Vérifie et synchronise le statut admin si nécessaire
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Authentification Firebase
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupération des données utilisateur depuis Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

        // Vérification et synchronisation du statut admin
        bool shouldBeAdmin = email == 'admin1@test.com';
        if (userData['isAdmin'] != shouldBeAdmin) {
          // Mise à jour du statut admin dans Firestore si discordance
          await _firestore.collection('users').doc(result.user!.uid).update({
            'isAdmin': shouldBeAdmin,
          });
          userData['isAdmin'] = shouldBeAdmin;
        }

        return UserModel.fromMap(userData);
      }
      return null;
    } catch (e) {
      print('Erreur connexion: $e');
      return null;
    }
  }

  /// Déconnexion de l'utilisateur actuel
  /// Supprime la session Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ========== GESTION DES UTILISATEURS/EMPLOYÉS ==========

  /// Récupération de tous les employés (utilisateurs non-admin)
  /// Utilisé par les admins pour afficher la liste des employés
  Future<List<UserModel>> getEmployees() async {
    try {
      // Requête pour récupérer uniquement les employés (non-admins)
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isAdmin', isEqualTo: false)
              .get();

      // Conversion des documents Firestore en objets UserModel
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur récupération employés: $e');
      return [];
    }
  }

  /// Suppression d'un employé
  /// Supprime définitivement un utilisateur de la base de données
  /// Réservé aux admins uniquement
  Future<void> deleteEmployee(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print('Erreur suppression employé: $e');
    }
  }

  /// Mise à jour des informations d'un employé
  /// Permet de modifier les données d'un utilisateur existant
  /// Réservé aux admins uniquement
  Future<void> updateEmployee(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Erreur mise à jour employé: $e');
    }
  }

  // ========== GESTION DES CONGÉS ==========

  /// Soumission d'une demande de congé
  /// Permet aux employés de demander des congés avec dates de début et fin
  /// Crée une demande en attente d'approbation admin

  Future<void> submitLeaveRequest(
    DateTime startDate,
    DateTime endDate,
    String reason,
  ) async {
    try {
      // Vérification de l'utilisateur connecté
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Récupération des informations utilisateur
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      UserModel user = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );

      // Génération d'un identifiant unique pour la demande
      String leaveId = DateTime.now().millisecondsSinceEpoch.toString();

      // Création de la demande de congé
      LeaveModel leave = LeaveModel(
        id: leaveId,
        employeeId: currentUser.uid,
        employeeName: user.nom,
        startDate: startDate,
        endDate: endDate,
        requestDate: DateTime.now(),
        reason: reason,
      );

      // Sauvegarde de la demande dans Firestore
      await _firestore.collection('leaves').doc(leaveId).set(leave.toMap());
    } catch (e) {
      print('Erreur demande congé: $e');
    }
  }

  /// Récupération des congés de l'employé connecté
  /// Permet à un employé de voir l'historique de ses demandes de congés
  /// Affiche le statut de chaque demande (en attente, approuvée, refusée)
  Future<List<LeaveModel>> getEmployeeLeaves() async {
    try {
      // Vérification de l'utilisateur connecté
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Requête pour récupérer uniquement les congés de l'utilisateur actuel
      QuerySnapshot snapshot =
          await _firestore
              .collection('leaves')
              .where('employeeId', isEqualTo: currentUser.uid)
              .orderBy(
                'requestDate',
                descending: true,
              ) // Tri par date décroissante
              .get();

      // Conversion en liste d'objets LeaveModel
      return snapshot.docs
          .map((doc) => LeaveModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur récupération congés employé: $e');
      return [];
    }
  }

  /// Récupération de toutes les demandes de congés
  /// Utilisé par les admins pour voir toutes les demandes de tous les employés
  /// Permet la gestion et l'approbation des congés
  Future<List<LeaveModel>> getAllLeaves() async {
    try {
      // Requête pour récupérer toutes les demandes de congés
      QuerySnapshot snapshot =
          await _firestore
              .collection('leaves')
              .orderBy(
                'requestDate',
                descending: true,
              ) // Tri par date décroissante
              .get();

      // Conversion en liste d'objets LeaveModel
      return snapshot.docs
          .map((doc) => LeaveModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur récupération tous congés: $e');
      return [];
    }
  }

  /// Mise à jour du statut d'une demande de congé
  /// Permet aux admins d'approuver ou refuser les demandes de congés
  /// Change le statut de 'pending' vers 'approved' ou 'rejected'
  Future<void> updateLeaveStatus(String leaveId, LeaveStatus status) async {
    try {
      // Mise à jour du statut dans Firestore
      await _firestore.collection('leaves').doc(leaveId).update({
        'status':
            status.toString().split('.').last, // Conversion enum vers string
      });
    } catch (e) {
      print('Erreur mise à jour statut congé: $e');
    }
  }

  // Stream pour écouter les changements en temps réel
  Stream<Map<String, dynamic>> getAttendanceCounterStream() {
    return _firestore
        .collection('counters')
        .doc('attendance_counter')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return snapshot.data() as Map<String, dynamic>;
          }
          return {
            'totalCheckIns': 0,
            'totalCheckOuts': 0,
            'dailyCount': <String, Map<String, int>>{},
          };
        });
  }

  //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$presence
  Future<void> checkIn() async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    // Vérifier si l'employé est en retard
    final isLate = now.hour > 8 || (now.hour == 8 && now.minute > 0);

    // Obtenir les informations de l'utilisateur
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userName = userDoc.data()?['nom'] ?? 'Employé inconnu';

    // Créer ou mettre à jour l'enregistrement de présence
    await _firestore.collection('attendance').doc(uid + dateStr).set({
      'employeeId': uid,
      'employeeName': userName,
      'checkInTime': now,
      'checkOutTime': null,
      'date': today,
      'isLate': isLate,
      'isEarlyDeparture': false,
      'hasAuthorization': false,
      'isOnAuthorization': false,
      'isPermanentDeparture': false,
      'authorizationPeriods': [],
    }, SetOptions(merge: true));

    // Mettre à jour le statut de l'utilisateur
    await _firestore.collection('users').doc(uid).update({'status': 'present'});

    // Si en retard, créer une réclamation
    if (isLate) {
      await _firestore.collection('late_reports').add({
        'employeeId': uid,
        'employeeName': userName,
        'timestamp': now,
        'date': dateStr,
        'minutesLate': (now.hour - 8) * 60 + now.minute,
      });
    }
  }

  Future<void> checkOut({required bool permanent}) async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    final docRef = _firestore.collection('attendance').doc(uid + dateStr);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'checkOutTime': now,
        'isEarlyDeparture': now.hour < 17,
        'isPermanentDeparture': permanent,
      });
    }

    if (permanent) {
      await _firestore.collection('users').doc(uid).update({
        'status': 'absent',
      });
    }
  }

  Future<void> setPermission() async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    final docRef = _firestore.collection('attendance').doc(uid + dateStr);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> authPeriods = List<Map<String, dynamic>>.from(
        data['authorizationPeriods'] ?? [],
      );

      // Ajouter une nouvelle période d'autorisation
      authPeriods.add({
        'start': now,
        'end': null, // Sera mis à jour au retour
      });

      await docRef.update({
        'hasAuthorization': true,
        'isOnAuthorization': true,
        'authorizationPeriods': authPeriods,
      });
    }

    await _firestore.collection('users').doc(uid).update({
      'status': 'permission',
    });
  }

  Future<void> returnFromPermission() async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    final docRef = _firestore.collection('attendance').doc(uid + dateStr);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> authPeriods = List<Map<String, dynamic>>.from(
        data['authorizationPeriods'] ?? [],
      );

      // Mettre à jour la dernière période d'autorisation
      if (authPeriods.isNotEmpty) {
        authPeriods.last['end'] = now;
      }

      await docRef.update({
        'isOnAuthorization': false,
        'authorizationPeriods': authPeriods,
      });
    }

    await _firestore.collection('users').doc(uid).update({'status': 'present'});
  }

  Future<Map<String, dynamic>> getTodayStatus() async {
    final uid = _auth.currentUser!.uid;
    final today = DateTime.now();
    final dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(today.year, today.month, today.day));
    final doc =
        await _firestore.collection('attendance').doc(uid + dateStr).get();

    if (!doc.exists) {
      return {
        'checkIn': false,
        'checkOut': false,
        'isOnAuthorization': false,
        'isPermanentlyOut': false,
      };
    }

    final data = doc.data()!;
    return {
      'checkIn': data['checkInTime'] != null,
      'checkOut': data['checkOutTime'] != null,
      'checkInTime': (data['checkInTime'] as Timestamp?)?.toDate(),
      'checkOutTime': (data['checkOutTime'] as Timestamp?)?.toDate(),
      'isOnAuthorization': data['isOnAuthorization'] ?? false,
      'isPermanentlyOut': data['isPermanentDeparture'] ?? false,
      'workedHours': _calculateHours(data),
    };
  }

  Future<Map<String, dynamic>> calculateWeeklyStats() async {
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    double totalHours = 0;
    int daysPresent = 0;
    int lateCount = 0;

    // Calculer pour chaque jour de la semaine (lundi à vendredi)
    for (int i = 0; i < 5; i++) {
      final day = monday.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(day);

      final doc =
          await _firestore.collection('attendance').doc(uid + dateStr).get();

      if (doc.exists) {
        final data = doc.data()!;
        if (data['checkInTime'] != null) {
          daysPresent++;
          totalHours += _calculateHours(data);

          if (data['isLate'] == true) {
            lateCount++;
          }
        }
      }
    }

    return {
      'totalHours': totalHours,
      'daysPresent': daysPresent,
      'lateCount': lateCount,
    };
  }

  double _calculateHours(Map<String, dynamic> data) {
    if (data['checkInTime'] == null) return 0;

    final checkIn = (data['checkInTime'] as Timestamp).toDate();
    final checkOut =
        data['checkOutTime'] != null
            ? (data['checkOutTime'] as Timestamp).toDate()
            : DateTime.now();

    double totalMinutes = checkOut.difference(checkIn).inMinutes.toDouble();

    // Soustraire les périodes d'autorisation
    final authPeriods = data['authorizationPeriods'] as List<dynamic>? ?? [];
    for (var period in authPeriods) {
      if (period['start'] != null && period['end'] != null) {
        final start = (period['start'] as Timestamp).toDate();
        final end = (period['end'] as Timestamp).toDate();
        totalMinutes -= end.difference(start).inMinutes;
      }
    }

    return totalMinutes / 60.0;
  }

  /// Vérifie si une adresse email existe déjà dans Firestore
  Future<bool> emailExists(String email) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur vérification email: $e');
      return false;
    }
  }
}
