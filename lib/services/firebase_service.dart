import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/dental_data.dart';

/// Central Firebase Firestore & Authentication Service for DentiCare.
class DentiFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static CollectionReference get usersCollection =>
      _firestore.collection('users');
  static CollectionReference get appointmentsCollection =>
      _firestore.collection('appointments');
  static CollectionReference get dentistsCollection =>
      _firestore.collection('dentists');
  static CollectionReference get servicesCollection =>
      _firestore.collection('services');

  // Current authenticated user
  static User? get currentUser => _auth.currentUser;

  // -------------------------------------------------------------
  // AUTHENTICATION
  // -------------------------------------------------------------

  /// Register patient with Firebase Auth and save user profile to Firestore.
  static Future<UserAccount?> registerPatient({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String contactNumber,
    String? birthday,
    String? sex,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) return null;

      final userAccount = UserAccount(
        id: user.uid,
        username: username.trim(),
        fullName: fullName.trim(),
        email: email.trim(),
        contactNumber: contactNumber.trim(),
        role: 'Patient',
        status: 'Active',
        registeredDate: DateTime.now().toString().split(' ')[0],
      );

      await usersCollection.doc(user.uid).set({
        'id': userAccount.id,
        'username': userAccount.username,
        'fullName': userAccount.fullName,
        'email': userAccount.email,
        'contactNumber': userAccount.contactNumber,
        'birthday': birthday ?? '',
        'sex': sex ?? '',
        'role': userAccount.role,
        'status': userAccount.status,
        'registeredDate': userAccount.registeredDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userAccount;
    } catch (e) {
      debugPrint('Firebase registration error: $e');
      rethrow;
    }
  }

  /// Sign in user with username or email & password.
  static Future<UserAccount?> loginUser({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      String email = usernameOrEmail.trim();

      // If user typed a username (doesn't contain '@'), look up their email in Firestore
      if (!email.contains('@')) {
        final query = await usersCollection
            .where('username', isEqualTo: usernameOrEmail.trim())
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final data = query.docs.first.data() as Map<String, dynamic>;
          email = data['email'] ?? email;
        }
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) return null;

      final doc = await usersCollection.doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserAccount(
          id: data['id'] ?? user.uid,
          username: data['username'] ?? '',
          fullName: data['fullName'] ?? '',
          email: data['email'] ?? user.email ?? '',
          contactNumber: data['contactNumber'] ?? '',
          role: data['role'] ?? 'Patient',
          status: data['status'] ?? 'Active',
          registeredDate: data['registeredDate'] ?? '',
        );
      } else {
        return UserAccount(
          id: user.uid,
          username: user.email?.split('@')[0] ?? 'User',
          fullName: user.displayName ?? 'Patient',
          email: user.email ?? '',
          contactNumber: '',
          role: 'Patient',
          status: 'Active',
          registeredDate: DateTime.now().toString().split(' ')[0],
        );
      }
    } catch (e) {
      debugPrint('Firebase login error: $e');
      rethrow;
    }
  }

  /// Sign out current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // -------------------------------------------------------------
  // APPOINTMENTS
  // -------------------------------------------------------------

  /// Stream of appointments ordered by date.
  static Stream<List<AppointmentRecord>> getAppointmentsStream() {
    return appointmentsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<AppointmentRecord>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppointmentRecord(
          id: doc.id,
          patientName: data['patientName'] ?? '',
          serviceName: data['serviceName'] ?? '',
          dentistName: data['dentistName'] ?? '',
          date: data['date'] ?? '',
          time: data['time'] ?? '',
          contact: data['contact'] ?? '',
          email: data['email'] ?? '',
          status: data['status'] ?? 'Confirmed',
          notes: data['notes'] ?? '',
        );
      }).toList();
    });
  }

  /// Create a new appointment in Firestore.
  static Future<void> createAppointment(AppointmentRecord appointment) async {
    try {
      await appointmentsCollection.doc(appointment.id).set({
        'id': appointment.id,
        'patientName': appointment.patientName,
        'serviceName': appointment.serviceName,
        'dentistName': appointment.dentistName,
        'date': appointment.date,
        'time': appointment.time,
        'contact': appointment.contact,
        'email': appointment.email,
        'status': appointment.status,
        'notes': appointment.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      rethrow;
    }
  }
}

