import 'package:flutter/material.dart';

class DentalService {
  final String id;
  final String name;
  final String description;
  final String duration;
  final String cost;
  final IconData icon;

  const DentalService({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.cost,
    required this.icon,
  });
}

class Dentist {
  final String id;
  final String name;
  final String experience;
  final String specialization;
  final String qualification;
  final IconData avatarIcon;

  const Dentist({
    required this.id,
    required this.name,
    required this.experience,
    required this.specialization,
    required this.qualification,
    required this.avatarIcon,
  });
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
  final String status;

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
  });
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
    ),
    DentalService(
      id: 'cleaning',
      name: 'Teeth Cleaning',
      description:
          'Routine professional prophylaxis removal of plaque, tartar, and surface stains to prevent cavities and periodontal disease.',
      duration: '45 mins to 1 hour',
      cost: 'P600.00 - P1,200.00',
      icon: Icons.clean_hands_rounded,
    ),
    DentalService(
      id: 'whitening',
      name: 'Teeth Whitening',
      description:
          'Cosmetic dental bleaching procedure to lighten teeth and remove discoloration for a brighter and cleaner smile.',
      duration: '1 hour',
      cost: 'P2,000.00 - P3,500.00',
      icon: Icons.auto_awesome_rounded,
    ),
    DentalService(
      id: 'implants',
      name: 'Dental Implants & Restoration',
      description:
          'Surgical placement of artificial tooth roots and crowns to replace missing or severely damaged teeth.',
      duration: '1.5 hours to 3 hours',
      cost: 'P15,000.00 - P25,000.00',
      icon: Icons.healing_rounded,
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
      id: 'dr_jordan',
      name: 'Dr. Michaela Jordan',
      experience: '6 years of experience',
      specialization: 'Orthodontics\nGeneral Dentistry\nCosmetic Dentistry',
      qualification: 'Orthodontics\nGeneral Dentistry\nCosmetic Dentistry',
      avatarIcon: Icons.medical_services_rounded,
    ),
    Dentist(
      id: 'dr_cruz',
      name: 'Dr. Nathaniel Cruz',
      experience: '8 years of experience',
      specialization: 'Endodontics\nRestorative Care\nPediatric Dentistry',
      qualification: 'Doctor of Dental Medicine (DMD)\nEndodontics Specialist',
      avatarIcon: Icons.health_and_safety_rounded,
    ),
  ];

  static const List<AppointmentSlot> availableSlots = [
    AppointmentSlot(
      id: 's1',
      dentistName: 'Dr. Michaela Jordan',
      date: '09/11/2026',
      time: '8:00 AM',
    ),
    AppointmentSlot(
      id: 's2',
      dentistName: 'Dr. Michaela Jordan',
      date: '09/11/2026',
      time: '10:00 AM',
    ),
    AppointmentSlot(
      id: 's3',
      dentistName: 'Dr. Nathaniel Cruz',
      date: '09/11/2026',
      time: '1:00 PM',
    ),
    AppointmentSlot(
      id: 's4',
      dentistName: 'Dr. Nathaniel Cruz',
      date: '09/11/2026',
      time: '7:00 PM',
    ),
    AppointmentSlot(
      id: 's5',
      dentistName: 'Dr. Michaela Jordan',
      date: '09/12/2026',
      time: '9:00 AM',
    ),
    AppointmentSlot(
      id: 's6',
      dentistName: 'Dr. Nathaniel Cruz',
      date: '09/12/2026',
      time: '2:30 PM',
    ),
  ];
}

