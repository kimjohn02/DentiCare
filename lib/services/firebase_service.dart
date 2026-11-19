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

  /// Seed initial clinic services, dentists, appointments, and users to Firestore.
  static Future<void> seedInitialData() async {
    try {
      final batch = _firestore.batch();

      // 1. Services Collection
      for (final s in DentalClinicData.services) {
        final docRef = servicesCollection.doc(s.id);
        batch.set(docRef, {
          'id': s.id,
          'name': s.name,
          'description': s.description,
          'duration': s.duration,
          'cost': s.cost,
        }, SetOptions(merge: true));
      }

      // 2. Dentists Collection
      for (final d in DentalClinicData.dentists) {
        final docRef = dentistsCollection.doc(d.id);
        batch.set(docRef, {
          'id': d.id,
          'name': d.name,
          'experience': d.experience,
          'specialization': d.specialization,
          'qualification': d.qualification,
        }, SetOptions(merge: true));
      }

      // 3. Appointments Collection
      final initialAppointments = [
        const AppointmentRecord(
          id: 'apt_init_pending',
          patientName: 'Lupogan, Kim Macpao',
          serviceName: 'Dental Bracing',
          dentistName: 'Dr. Grace Cabilles',
          date: '09/11/2026',
          time: '8:00 AM',
          contact: '0987-654-3210',
          email: 'kim@gmail.com',
          status: 'Pending',
          notes: 'New booking via Patient Web Portal',
        ),
        const AppointmentRecord(
          id: 'apt_init_confirmed',
          patientName: 'Cagabhion, Ryza',
          serviceName: 'Teeth Whitening',
          dentistName: 'Dr. Joana Plewa',
          date: '09/11/2026',
          time: '1:00 PM',
          contact: '0912-345-6789',
          email: 'ryza@gmail.com',
          status: 'Confirmed',
          notes: 'Confirmed by clinic reception',
        ),
        const AppointmentRecord(
          id: 'apt_init_completed',
          patientName: 'Nuez, Mark',
          serviceName: 'Teeth Cleaning',
          dentistName: 'Dr. Ryan Luza',
          date: '08/20/2026',
          time: '10:00 AM',
          contact: '0922-888-9999',
          email: 'mark.nuez@gmail.com',
          status: 'Completed',
          notes: 'Routine plaque removal performed',
        ),
      ];

      for (final apt in initialAppointments) {
        final docRef = appointmentsCollection.doc(apt.id);
        batch.set(docRef, {
          'id': apt.id,
          'patientName': apt.patientName,
          'serviceName': apt.serviceName,
          'dentistName': apt.dentistName,
          'date': apt.date,
          'time': apt.time,
          'contact': apt.contact,
          'email': apt.email,
          'status': apt.status,
          'notes': apt.notes,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 4. Users Collection
      for (final u in DentalClinicData.sampleUsers) {
        final docRef = usersCollection.doc(u.id);
        batch.set(docRef, {
          'id': u.id,
          'username': u.username,
          'fullName': u.fullName,
          'email': u.email,
          'contactNumber': u.contactNumber,
          'role': u.role,
          'status': u.status,
          'registeredDate': u.registeredDate,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('Firestore clinic data seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding Firestore data: $e');
      rethrow;
    }
  }

  /// Automatically seed Firestore if appointments collection is empty.
  static Future<void> autoSeedIfEmpty() async {
    try {
      final snap = await appointmentsCollection.limit(1).get();
      if (snap.docs.isEmpty) {
        await seedInitialData();
      }
    } catch (e) {
      debugPrint('Firestore auto-seed notice: $e');
    }
  }
}

