import 'package:flutter/material.dart';

class DentalService {
  final String id;
  final String name;
  final String description;
  final String duration;
  final String cost;
  final IconData icon;
  final String? imageAsset;

  const DentalService({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.cost,
    required this.icon,
    this.imageAsset,
  });

  DentalService copyWith({
    String? name,
    String? description,
    String? duration,
    String? cost,
    IconData? icon,
    String? imageAsset,
  }) {
    return DentalService(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      icon: icon ?? this.icon,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}

class Dentist {
  final String id;
  final String name;
  final String experience;
  final String specialization;
  final String qualification;
  final IconData avatarIcon;
  final String? imageAsset;

  const Dentist({
    required this.id,
    required this.name,
    required this.experience,
    required this.specialization,
    required this.qualification,
    required this.avatarIcon,
    this.imageAsset,
  });

  Dentist copyWith({
    String? name,
    String? experience,
    String? specialization,
    String? qualification,
    IconData? avatarIcon,
    String? imageAsset,
  }) {
    return Dentist(
      id: id,
      name: name ?? this.name,
      experience: experience ?? this.experience,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}

class AppointmentSlot {
  final String id;
  final String dentistName;
  final String date;
  final String time;

  const AppointmentSlot({
    required this.id,
    required this.dentistName,
    required this.date,
    required this.time,
  });
}

class AppointmentRecord {
  final String id;
  final String patientName;
  final String serviceName;
  final String dentistName;
  final String date;
  final String time;
  final String contact;
  final String email;
  final String status; // 'Pending', 'Confirmed', 'In Treatment', 'Completed', 'Cancelled'
  final String? notes;

  const AppointmentRecord({
    required this.id,
    required this.patientName,
    required this.serviceName,
    required this.dentistName,
    required this.date,
    required this.time,
    required this.contact,
    required this.email,
    required this.status,
    this.notes,
  });

  AppointmentRecord copyWith({
    String? status,
    String? notes,
    String? date,
    String? time,
  }) {
    return AppointmentRecord(
      id: id,
      patientName: patientName,
      serviceName: serviceName,
      dentistName: dentistName,
      date: date ?? this.date,
      time: time ?? this.time,
      contact: contact,
      email: email,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class PatientProfile {
  final String id;
  final String name;
  final String birthday;
  final String sex;
  final String contact;
  final String email;
  final String bloodType;
  final String allergies;
  final List<String> treatmentHistory;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.birthday,
    required this.sex,
    required this.contact,
    required this.email,
    required this.bloodType,
    required this.allergies,
    required this.treatmentHistory,
  });
}

class PatientNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final bool isRead;
  final String? routeAction;

  const PatientNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.routeAction,
  });

  PatientNotification copyWith({
    bool? isRead,
  }) {
    return PatientNotification(
      id: id,
      title: title,
      message: message,
      timeAgo: timeAgo,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
      routeAction: routeAction,
    );
  }
}

class UserAccount {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String contactNumber;
  final String role; // 'Patient', 'Clinic Staff', 'Administrator'
  final String status; // 'Active', 'Suspended'
  final String registeredDate;

  const UserAccount({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.contactNumber = '0987-654-3210',
    required this.role,
    required this.status,
    required this.registeredDate,
  });

  UserAccount copyWith({
    String? fullName,
    String? email,
    String? contactNumber,
    String? role,
    String? status,
  }) {
    return UserAccount(
      id: id,
      username: username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      registeredDate: registeredDate,
    );
  }
}

// Pre-populated data matching the HCI research document figures
class DentalClinicData {
  static const List<DentalService> services = [
    DentalService(
      id: 'bracing',
      name: 'Dental Bracing',
      description:
          'Orthodontic dental braces align and straighten teeth, help position them with regard to a person\'s bite, and aim to improve dental health.',
      duration: '1 hour to 2 hours',
      cost: 'P500.00 - P800.00',
      icon: Icons.architecture_rounded,
      imageAsset: 'assets/images/services/dental_bracing.png',
    ),
    DentalService(
      id: 'cleaning',
      name: 'Teeth Cleaning',
      description:
          'Routine professional prophylaxis removal of plaque, tartar, and surface stains to prevent cavities and periodontal disease.',
      duration: '45 mins to 1 hour',
      cost: 'P600.00 - P1,200.00',
      icon: Icons.clean_hands_rounded,
      imageAsset: 'assets/images/services/teeth_cleaning.png',
    ),
    DentalService(
      id: 'whitening',
      name: 'Teeth Whitening',
      description:
          'Cosmetic dental bleaching procedure to lighten teeth and remove discoloration for a brighter and cleaner smile.',
      duration: '1 hour',
      cost: 'P2,000.00 - P3,500.00',
      icon: Icons.auto_awesome_rounded,
      imageAsset: 'assets/images/services/teeth_whitening.png',
    ),
    DentalService(
      id: 'implants',
      name: 'Dental Implants & Restoration',
      description:
          'Surgical placement of artificial tooth roots and crowns to replace missing or severely damaged teeth.',
      duration: '1.5 hours to 3 hours',
      cost: 'P15,000.00 - P25,000.00',
      icon: Icons.healing_rounded,
      imageAsset: 'assets/images/services/dental_implants.png',
    ),
  ];

  static const List<Dentist> dentists = [
    Dentist(
      id: 'any',
      name: 'Any Available Dentist',
      experience: 'Assigned on schedule',
      specialization: 'General Dental Practice',
      qualification: 'Licensed Doctor of Dental Medicine (DMD)',
      avatarIcon: Icons.groups_rounded,
    ),
    Dentist(
      id: 'dr_grace',
      name: 'Dr. Grace Cabilles',
      experience: '6 years of experience',
      specialization: 'Orthodontics\nCosmetic Dentistry\nGeneral Dentistry',
      qualification: 'Doctor of Dental Medicine (DMD)\nBoard-Certified Orthodontics Specialist\nFellow, Philippine Dental Association',
      avatarIcon: Icons.medical_services_rounded,
      imageAsset: 'assets/images/dentists/grace_cabilles.png',
    ),
    Dentist(
      id: 'dr_joana',
      name: 'Dr. Joana Plewa',
      experience: '7 years of experience',
      specialization: 'Pediatric Dentistry\nOral Prophylaxis\nRestorative Care',
      qualification: 'Doctor of Dental Medicine (DMD)\nCertified Pediatric Dental Specialist\nPRC Lic. Verified',
      avatarIcon: Icons.health_and_safety_rounded,
      imageAsset: 'assets/images/dentists/joana_plewa.png',
    ),
    Dentist(
      id: 'dr_ryan',
      name: 'Dr. Ryan Luza',
      experience: '8 years of experience',
      specialization: 'Endodontics\nDental Surgery\nProsthodontics',
      qualification: 'Doctor of Dental Medicine (DMD)\nEndodontics & Oral Surgery Specialist\nFellow, International Congress of Oral Implantologists',
      avatarIcon: Icons.masks_rounded,
      imageAsset: 'assets/images/dentists/ryan_luza.png',
    ),
    Dentist(
      id: 'dr_niere',
      name: 'Dr. Niere Lupmac',
      experience: '5 years of experience',
      specialization: 'Periodontics\nTeeth Whitening\nPreventive Dentistry',
      qualification: 'Doctor of Dental Medicine (DMD)\nAesthetic Dentistry Specialist\nPhilippine Dental Association Member',
      avatarIcon: Icons.volunteer_activism_rounded,
      imageAsset: 'assets/images/dentists/niere_lupmac.png',
    ),
  ];

  static const List<AppointmentSlot> availableSlots = [
    AppointmentSlot(
      id: 's1',
      dentistName: 'Dr. Grace Cabilles',
      date: '09/11/2026',
      time: '8:00 AM',
    ),
    AppointmentSlot(
      id: 's2',
      dentistName: 'Dr. Grace Cabilles',
      date: '09/11/2026',
      time: '10:00 AM',
    ),
    AppointmentSlot(
      id: 's3',
      dentistName: 'Dr. Joana Plewa',
      date: '09/11/2026',
      time: '1:00 PM',
    ),
    AppointmentSlot(
      id: 's4',
      dentistName: 'Dr. Ryan Luza',
      date: '09/11/2026',
      time: '3:30 PM',
    ),
    AppointmentSlot(
      id: 's5',
      dentistName: 'Dr. Niere Lupmac',
      date: '09/11/2026',
      time: '5:00 PM',
    ),
    AppointmentSlot(
      id: 's6',
      dentistName: 'Dr. Grace Cabilles',
      date: '09/12/2026',
      time: '9:00 AM',
    ),
    AppointmentSlot(
      id: 's7',
      dentistName: 'Dr. Joana Plewa',
      date: '09/12/2026',
      time: '11:00 AM',
    ),
    AppointmentSlot(
      id: 's8',
      dentistName: 'Dr. Ryan Luza',
      date: '09/12/2026',
      time: '2:00 PM',
    ),
    AppointmentSlot(
      id: 's9',
      dentistName: 'Dr. Niere Lupmac',
      date: '09/12/2026',
      time: '4:00 PM',
    ),
  ];

  static const List<PatientProfile> samplePatients = [
    PatientProfile(
      id: 'p_1',
      name: 'Lupogan, Kim Macpao',
      birthday: '05/15/2005',
      sex: 'Female',
      contact: '0987654321',
      email: 'kim@gmail.com',
      bloodType: 'O+',
      allergies: 'None reported',
      treatmentHistory: [
        '08/15/2026 - Comprehensive Teeth Cleaning',
        '09/11/2026 - Dental Bracing Consultation & Setup',
      ],
    ),
    PatientProfile(
      id: 'p_2',
      name: 'Reloba, Joen Paul',
      birthday: '11/20/1998',
      sex: 'Male',
      contact: '0912345678',
      email: 'joen@gmail.com',
      bloodType: 'A+',
      allergies: 'Penicillin sensitivity',
      treatmentHistory: [
        '07/10/2026 - Dental Checkup & X-Ray',
        '08/04/2026 - Teeth Whitening (Session 1)',
      ],
    ),
    PatientProfile(
      id: 'p_3',
      name: 'Santos, Maria Elena',
      birthday: '03/08/1962',
      sex: 'Female',
      contact: '0922888999',
      email: 'maria.santos@gmail.com',
      bloodType: 'B+',
      allergies: 'Latex sensitivity (use nitrile gloves)',
      treatmentHistory: [
        '06/22/2026 - Tooth Extraction (Molar #18)',
        '07/30/2026 - Dental Implant Consultation',
      ],
    ),
  ];

  static const List<UserAccount> sampleUsers = [
    UserAccount(
      id: 'u_1',
      username: 'kim_lupogan',
      fullName: 'Lupogan, Kim Macpao',
      email: 'kim@gmail.com',
      contactNumber: '0987-654-3210',
      role: 'Patient',
      status: 'Active',
      registeredDate: '08/01/2026',
    ),
    UserAccount(
      id: 'u_2',
      username: 'joen_reloba',
      fullName: 'Reloba, Joen Paul',
      email: 'joen@gmail.com',
      contactNumber: '0912-345-6789',
      role: 'Patient',
      status: 'Active',
      registeredDate: '08/10/2026',
    ),
    UserAccount(
      id: 'u_3',
      username: 'maria_santos',
      fullName: 'Santos, Maria Elena',
      email: 'maria.santos@gmail.com',
      contactNumber: '0922-888-9999',
      role: 'Patient',
      status: 'Active',
      registeredDate: '07/15/2026',
    ),
    UserAccount(
      id: 'u_4',
      username: 'receptionist_feiah',
      fullName: 'Feiah O. Macalde (Clinic Front Desk)',
      email: 'desk@denticare.clinic',
      contactNumber: '0917-800-4321',
      role: 'Clinic Staff',
      status: 'Active',
      registeredDate: '05/01/2026',
    ),
    UserAccount(
      id: 'u_5',
      username: 'admin_kj',
      fullName: 'KJ M. Lupogan (System Administrator)',
      email: 'admin@denticare.clinic',
      contactNumber: '0919-555-1234',
      role: 'Administrator',
      status: 'Active',
      registeredDate: '01/10/2026',
    ),
  ];

  static List<PatientNotification> sampleNotifications = [
    const PatientNotification(
      id: 'notif_1',
      title: 'Appointment Approved',
      message:
          'Your appointment for Dental Bracing on 09/11/2026 at 8:00 AM has been confirmed by Dr. Grace Cabilles.',
      timeAgo: '5m ago',
      icon: Icons.check_circle_rounded,
      color: Color(0xFF10B981),
      isRead: false,
      routeAction: 'bookings',
    ),
    const PatientNotification(
      id: 'notif_2',
      title: 'Dental Chair Ready',
      message:
          'Dental Chair #1 is sanitized and ready for your procedure. Please approach the clinic reception.',
      timeAgo: '25m ago',
      icon: Icons.chair_rounded,
      color: Color(0xFFF59E0B),
      isRead: false,
    ),
    const PatientNotification(
      id: 'notif_3',
      title: 'Appointment Reminder',
      message:
          'Reminder: You have a scheduled appointment tomorrow at 8:00 AM. Please arrive 10 minutes early.',
      timeAgo: 'Yesterday',
      icon: Icons.access_time_filled_rounded,
      color: Color(0xFF2563EB),
      isRead: true,
      routeAction: 'bookings',
    ),
    const PatientNotification(
      id: 'notif_4',
      title: 'Post-Treatment Care Note',
      message:
          'Avoid extremely hot or sugary drinks for the next 48 hours for best whitening results.',
      timeAgo: '3d ago',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF0D9488),
      isRead: true,
    ),
  ];
}
