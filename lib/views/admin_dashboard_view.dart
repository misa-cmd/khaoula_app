import 'package:flutter/material.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/models/attendance_model.dart';
import 'package:myapp/models/leave_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart'; // pour mapIndexed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/employee_controller.dart';
import 'package:intl/intl.dart';
import 'package:myapp/views/auth_view.dart'; // Vue d'authentification (connexion)


class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  _AdminDashboardViewState createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final FirebaseService _firebaseService = FirebaseService();


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Admin'),
        backgroundColor: Color(0xFF3F5044),
        foregroundColor: Colors.white,
        elevation: 0, // Supprime l'ombre de la barre
        actions: [ // Actions à droite de la barre
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Panneau d\'Administration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildMenuCard(
                    title: 'Consulter Comptes Employés',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EmployeeListView(
                                  firebaseService: _firebaseService,
                                ),
                          ),
                        ),
                  ),
                  _buildMenuCard(
                    title: 'Consulter Congés',
                    icon: Icons.event_available,
                    color: Colors.orange,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => LeaveRequestsView(
                                  firebaseService: _firebaseService,
                                ),
                          ),
                        ),
                  ),
                  _buildMenuCard(
                    title: 'Présence Temps Réel (Check-in/out)',
                    icon: Icons.access_time,
                    color: Colors.purple,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RealTimePresenceView(
                                  firebaseService: _firebaseService,
                                ),
                          ),
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

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Interface pour consulter les comptes employés avec intégration Firebase Service
class EmployeeListView extends StatefulWidget {
  final FirebaseService firebaseService;

  const EmployeeListView({super.key, required this.firebaseService});

  @override
  _EmployeeListViewState createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<EmployeeListView> {
  List<UserModel> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      List<UserModel> loadedEmployees =
          await widget.firebaseService.getEmployees();
      setState(() {
        employees = loadedEmployees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du chargement: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comptes Employés'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadEmployees),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : employees.isEmpty
              ? Center(
                child: Text(
                  'Aucun employé trouvé',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  UserModel employee = employees[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        employee.nom,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${employee.email}'),
                          Text('UID Firebase: ${employee.uid}'),
                          Text(
                            'Date création: ${_formatDate(employee.createdAt)}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(employee),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(employee),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(UserModel employee) {
    final TextEditingController nomController = TextEditingController(
      text: employee.nom,
    );
    final TextEditingController emailController = TextEditingController(
      text: employee.email,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Modifier Employé'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'UID Firebase: ${employee.uid}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  UserModel updatedEmployee = UserModel(
                    uid: employee.uid,
                    nom: nomController.text,
                    email: emailController.text,
                    isAdmin: employee.isAdmin,
                    createdAt: employee.createdAt,
                  );

                  await widget.firebaseService.updateEmployee(updatedEmployee);
                  Navigator.pop(context);
                  _loadEmployees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Employé modifié avec succès')),
                  );
                },
                child: Text('Modifier'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(UserModel employee) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Supprimer Employé'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer ${employee.nom} ?\nUID: ${employee.uid}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await widget.firebaseService.deleteEmployee(employee.uid);
                  Navigator.pop(context);
                  _loadEmployees();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Employé supprimé avec succès')),
                  );
                },
                child: Text('Supprimer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}


// Interface pour consulter les demandes de congés avec intégration Firebase Service
class LeaveRequestsView extends StatefulWidget {
  final FirebaseService firebaseService;

  const LeaveRequestsView({super.key, required this.firebaseService});

  @override
  _LeaveRequestsViewState createState() => _LeaveRequestsViewState();
}

class _LeaveRequestsViewState extends State<LeaveRequestsView> {
  List<LeaveModel> leaves = [];
  bool isLoading = true;

  Map<String, Map<String, dynamic>> employeeStats = {};

  Map<String, int> globalStats = {
    'total': 0,
    'accepte': 0,
    'refuse': 0,
    'en_cours': 0,
  };

 @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    try {
      List<LeaveModel> loadedLeaves =
          await widget.firebaseService.getAllLeaves();
      
      setState(() {
        leaves = loadedLeaves;
        isLoading = false;
        _calculateStatistics();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du chargement: $e')));
    }
  }

  void _calculateStatistics() {
    employeeStats.clear();
    globalStats = {'total': 0, 'accepte': 0, 'refuse': 0, 'en_cours': 0};
    
    for (LeaveModel leave in leaves) {
      // Statistiques globales
      globalStats['total'] = globalStats['total']! + 1;
      switch (leave.status) {
        case LeaveStatus.accepte:
          globalStats['accepte'] = globalStats['accepte']! + 1;
          break;
        case LeaveStatus.refuse:
          globalStats['refuse'] = globalStats['refuse']! + 1;
          break;
        case LeaveStatus.en_cours:
          globalStats['en_cours'] = globalStats['en_cours']! + 1;
          break;
      }
      
      // Statistiques par employé
      String employeeKey = leave.employeeId;
      if (!employeeStats.containsKey(employeeKey)) {
        employeeStats[employeeKey] = {
          'name': leave.employeeName,
          'total': 0,
          'accepte': 0,
          'refuse': 0,
          'en_cours': 0,
        };
      }
      
      employeeStats[employeeKey]!['total'] = employeeStats[employeeKey]!['total']! + 1;
      switch (leave.status) {
        case LeaveStatus.accepte:
          employeeStats[employeeKey]!['accepte'] = employeeStats[employeeKey]!['accepte']! + 1;
          break;
        case LeaveStatus.refuse:
          employeeStats[employeeKey]!['refuse'] = employeeStats[employeeKey]!['refuse']! + 1;
          break;
        case LeaveStatus.en_cours:
          employeeStats[employeeKey]!['en_cours'] = employeeStats[employeeKey]!['en_cours']! + 1;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes de Congés'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: _showStatisticsDialog,
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadLeaves),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Carte des statistiques globales
                _buildGlobalStatsCard(),
                // Liste des demandes
                Expanded(
                  child: leaves.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune demande de congé trouvée',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: leaves.length,
                          itemBuilder: (context, index) {
                            LeaveModel leave = leaves[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(leave.status),
                                  child: Icon(Icons.event, color: Colors.white),
                                ),
                                title: Text(
                                  leave.employeeName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('UID: ${leave.employeeId}'),
                                    Text('Du: ${_formatDate(leave.startDate)}'),
                                    Text('Au: ${_formatDate(leave.endDate)}'),
                                    Text(
                                      'Statut: ${_getStatusText(leave.status)}',
                                      style: TextStyle(
                                        color: _getStatusColor(leave.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: leave.status == LeaveStatus.en_cours
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            onPressed: () => _updateLeaveStatus(
                                              leave.id,
                                              LeaveStatus.accepte,
                                              leave.employeeId,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.red),
                                            onPressed: () => _updateLeaveStatus(
                                              leave.id,
                                              LeaveStatus.refuse,
                                              leave.employeeId,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                                children: [
                                  _buildEmployeeStatsCard(leave.employeeId),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGlobalStatsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques Générales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total', globalStats['total']!, Colors.blue),
              ),
              Expanded(
                child: _buildStatItem('Approuvées', globalStats['accepte']!, Colors.green),
              ),
              Expanded(
                child: _buildStatItem('Refusées', globalStats['refuse']!, Colors.red),
              ),
              Expanded(
                child: _buildStatItem('En attente', globalStats['en_cours']!, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeStatsCard(String employeeId) {
    if (!employeeStats.containsKey(employeeId)) return SizedBox.shrink();
    
    Map<String, dynamic> stats = employeeStats[employeeId]!;
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques de ${stats['name']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatItem('Total', stats['total'], Colors.blue),
              ),
              Expanded(
                child: _buildMiniStatItem('✓', stats['accepte'], Colors.green),
              ),
              Expanded(
                child: _buildMiniStatItem('✗', stats['refuse'], Colors.red),
              ),
              Expanded(
                child: _buildMiniStatItem('⏳', stats['en_cours'], Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
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

  Widget _buildMiniStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showStatisticsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Statistiques Détaillées'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Statistiques par Employé',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: employeeStats.length,
                    itemBuilder: (context, index) {
                      String employeeId = employeeStats.keys.elementAt(index);
                      Map<String, dynamic> stats = employeeStats[employeeId]!;
                      return Card(
                        child: ListTile(
                          title: Text(stats['name']),
                          subtitle: Text('UID: $employeeId'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${stats['accepte']}/${stats['total']}'),
                              Text(
                                '${((stats['accepte'] / stats['total']) * 100).toStringAsFixed(1)}%',
                                style: TextStyle(color: Colors.green),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.accepte:
        return Colors.green;
      case LeaveStatus.refuse:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.accepte:
        return 'Approuvé';
      case LeaveStatus.refuse:
        return 'Refusé';
      default:
        return 'En attente';
    }
  }

  void _updateLeaveStatus(String leaveId, LeaveStatus status, String employeeId) async {
    try {
      await widget.firebaseService.updateLeaveStatus(leaveId, status);
      await _loadLeaves(); // Recharge les données pour mettre à jour les statistiques
      
      String statusText = status == LeaveStatus.accepte ? 'approuvée' : 'refusée';
      
      // Affichage des nouvelles statistiques
      Map<String, dynamic>? empStats = employeeStats[employeeId];
      String statsMessage = '';
      if (empStats != null) {
        statsMessage = '\n${empStats['name']}: ${empStats['accepte']} approuvées, ${empStats['refuse']} refusées sur ${empStats['total']} demandes';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande $statusText avec succès$statsMessage'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }
}

//====================precense ===========================================//
class RealTimePresenceView extends StatefulWidget {
  final FirebaseService firebaseService;

  const RealTimePresenceView({super.key, required this.firebaseService});

  @override
  State<RealTimePresenceView> createState() => _RealTimePresenceViewState();
}

class _RealTimePresenceViewState extends State<RealTimePresenceView> {

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'permission':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Présent';
      case 'absent':
        return 'Absent';
      case 'permission':
        return 'En autorisation';
      default:
        return 'Inconnu';
    }
  }

  // Fonction pour formater le nom complet
  String _getFullName(Map<String, dynamic> userData) {
    final firstName = userData['firstName'] ?? userData['prenom'] ?? '';
    final lastName = userData['lastName'] ?? userData['nom'] ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (userData['name'] != null && userData['name'].isNotEmpty) {
      return userData['name'];
    } else {
      return 'Nom non défini';
    }
  }

  // Fonction pour filtrer les utilisateurs (exclure les admins)
  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final role = data['role'] ?? '';
      final isAdmin = data['isAdmin'] ?? false;
      
      // Exclure les utilisateurs qui sont admin
      return role.toLowerCase() != 'admin' && !isAdmin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Présence en temps réel"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec résumé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                
                final allDocs = snapshot.data!.docs;
                final filteredDocs = _filterUsers(allDocs);
                
                final present = filteredDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'present';
                }).length;
                
                final onPermission = filteredDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'permission';
                }).length;
                
                final absent = filteredDocs.length - present - onPermission;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusSummary("Présents", present, Colors.green),
                    _buildStatusSummary("Autorisations", onPermission, Colors.orange),
                    _buildStatusSummary("Absents", absent, Colors.red),
                  ],
                );
              },
            ),
          ),
          
          // Liste des réclamations de retard
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('late_reports')
                .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }
              
              return Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          "Réclamations de retard",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final time = (data['timestamp'] as Timestamp).toDate();
                      final employeeName = data['employeeName'] ?? 'Employé inconnu';
                      return Text(
                        "• $employeeName - Retard à ${DateFormat('HH:mm').format(time)}",
                        style: TextStyle(color: Colors.red[700]),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          
          // Liste des employés
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allDocs = snapshot.data!.docs;
                final filteredDocs = _filterUsers(allDocs);
                
                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun employé trouvé",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final user = filteredDocs[index].data() as Map<String, dynamic>;
                    final status = user['status'] ?? 'absent';
                    final fullName = _getFullName(user);
                    final email = user['email'] ?? 'Email non défini';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          child: Icon(
                            status == 'present' ? Icons.check :
                            status == 'permission' ? Icons.schedule :
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Email: $email"),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.circle,
                          color: _getStatusColor(status),
                          size: 16,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  // Fonction pour déconnecter l'utilisateur
 // Fonction pour déconnecter l'utilisateur

}
  
