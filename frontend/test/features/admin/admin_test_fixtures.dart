import 'package:frontend/features/admin/models/admin_adoption_application.dart';
import 'package:frontend/features/admin/models/admin_user_summary.dart';
import 'package:frontend/features/pets/models/pet.dart';

const pendingPet = Pet(
  id: 10,
  name: 'Buddy',
  species: 'dog',
  breed: 'Mixed',
  age: 2,
  gender: 'male',
  size: 'medium',
  energyLevel: 'high',
  status: 'available',
  categoryId: 1,
  ownerId: 2,
  isApproved: false,
  description: 'Friendly dog',
);

const pendingApplication = AdminAdoptionApplication(
  id: 21,
  userId: 3,
  petId: 10,
  status: 'pending',
  applicantName: 'Test User',
  applicantEmail: 'test@example.com',
  petName: 'Buddy',
);

const approvedApplication = AdminAdoptionApplication(
  id: 20,
  userId: 3,
  petId: 10,
  status: 'approved',
  applicantName: 'Test User',
  applicantEmail: 'test@example.com',
  petName: 'Buddy',
);

const adminUser = AdminUserSummary(
  id: 1,
  username: 'admin',
  email: 'admin@example.com',
  fullName: 'Admin User',
  role: 'admin',
);

const regularUser = AdminUserSummary(
  id: 2,
  username: 'member',
  email: 'member@example.com',
  fullName: 'Regular User',
  role: 'user',
);
