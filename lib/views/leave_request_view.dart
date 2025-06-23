import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/controllers/employee_controller.dart';
import 'package:myapp/models/leave_model.dart';

class LeaveRequestView extends StatefulWidget {
  
  const LeaveRequestView({super.key});

  @override
  
  _LeaveRequestViewState createState() => _LeaveRequestViewState();
}

class _LeaveRequestViewState extends State<LeaveRequestView> {
  final EmployeeController _employeeController = EmployeeController();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  
  // Variables pour les statistiques
  int _approvedDays = 0;
  int _pendingDays = 0;
  int _totalRequestedDays = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadLeaveStatistics();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Méthode pour charger les statistiques
  Future<void> _loadLeaveStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final approvedDays = await _employeeController.firebaseService.getApprovedLeaveDaysForCurrentYear(user.uid);
        final pendingDays = await _employeeController.firebaseService.getPendingLeaveDaysForCurrentYear(user.uid);
        final totalDays = await _employeeController.firebaseService.getRequestedLeaveDaysForCurrentYear(user.uid);

        setState(() {
          _approvedDays = approvedDays;
          _pendingDays = pendingDays;
          _totalRequestedDays = totalDays;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Erreur chargement statistiques: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  // Méthode helper pour construire les lignes de statistiques
  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value jours',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Demande de Congés', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF3F5044),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: Color(0xFF3F5044),
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Nouvelle Demande',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F5044),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3F5044),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _startDate != null
                                      ? _employeeController.formatDate(
                                        _startDate!,
                                      )
                                      : 'Date de début',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3F5044),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  _endDate != null
                                      ? _employeeController.formatDate(
                                        _endDate!,
                                      )
                                      : 'Date de fin',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Raison de l\'absence',
                      hintText: 'Décrivez brièvement la raison de votre demande de congé...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF3F5044), width: 2),
                      ),
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Color(0xFF3F5044),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Statistiques des congés
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Color(0xFF3F5044),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Statistiques ${DateTime.now().year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F5044),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (_isLoadingStats)
                          Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFF3F5044),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              _buildStatRow('Jours approuvés', _approvedDays, Colors.green),
                              SizedBox(height: 8),
                              _buildStatRow('Jours en attente', _pendingDays, Colors.orange),
                              SizedBox(height: 8),
                              _buildStatRow('Total demandé', _totalRequestedDays, Color(0xFF3F5044)),
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (_totalRequestedDays / 30).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _totalRequestedDays > 30 
                                          ? Colors.red 
                                          : _totalRequestedDays > 25 
                                              ? Colors.orange 
                                              : Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Limite: ${_totalRequestedDays}/30 jours',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _totalRequestedDays > 30 ? Colors.red : Colors.grey[600],
                                  fontWeight: _totalRequestedDays > 30 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3F5044),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Soumission...',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            'Soumettre la demande',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF3F5044)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate != null && picked.isBefore(_startDate!)) {
            _showError('La date de fin doit être après la date de début');
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_startDate == null || _endDate == null) {
      _showError('Veuillez sélectionner les dates de début et de fin');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      _showError('Veuillez indiquer la raison de votre absence');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Vérifier la limite de 30 jours avant de soumettre
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool canRequest = await _employeeController.firebaseService.canRequestLeave(
          user.uid, 
          _startDate!, 
          _endDate!
        );
        
        if (!canRequest) {
          _showError('Cette demande dépasserait la limite de 30 jours par année');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
      }

      bool success = await _employeeController.submitLeaveRequest(
        _startDate!,
        _endDate!,
        _reasonController.text.trim(),
      );

      if (success) {
        setState(() {
          _startDate = null;
          _endDate = null;
          _reasonController.clear();
        });
        
        // Recharger les statistiques après soumission réussie
        _loadLeaveStatistics();
        
        _showSuccess('Demande de congé soumise avec succès');
      } else {
        _showError('Erreur lors de la soumission de la demande');
      }
    } catch (e) {
      _showError('Erreur inattendue : ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}