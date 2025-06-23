// Modèle représentant un utilisateur (employé ou admin) dans l'application.
class UserModel {
  // Identifiant unique de l'utilisateur (généralement depuis Firebase Auth).
  final String uid;

  // Nom complet de l'utilisateur.
  final String nom;

  // Adresse email de l'utilisateur.
  final String email;

  // Booléen indiquant si l'utilisateur est un administrateur.
  final bool isAdmin;

  // Date de création du compte utilisateur.
  final DateTime createdAt;

  // Constructeur de la classe avec initialisation des champs requis.
  UserModel({
    required this.uid,          // uid est requis.
    required this.nom,          // nom est requis.
    required this.email,        // email est requis.
    this.isAdmin = false,       // Par défaut, l'utilisateur n'est pas admin.
    required this.createdAt,    // La date de création est requise.
  });

  // Méthode pour convertir l'objet en Map (utilisé pour envoyer dans Firestore).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,                             // Identifiant de l'utilisateur.
      'nom': nom,                             // Nom de l'utilisateur.
      'email': email,                         // Email de l'utilisateur.
      'isAdmin': isAdmin,                     // Statut admin ou non.
      'createdAt': createdAt.millisecondsSinceEpoch, // Date convertie en timestamp.
    };
  }

  // Factory pour créer un objet UserModel à partir d'une Map (ex: récupérée depuis Firebase).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',                  // Récupère l'UID ou chaîne vide si null.
      nom: map['nom'] ?? '',                  // Récupère le nom ou chaîne vide si null.
      email: map['email'] ?? '',              // Récupère l'email ou chaîne vide si null.
      isAdmin: map['isAdmin'] ?? false,       // Récupère le statut admin ou false si null.
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0), // Convertit timestamp en DateTime.
    );
  }
}
