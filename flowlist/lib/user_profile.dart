import 'dart:io';

class UserProfile {
  String firstName;
  String lastName;
  File? profileImage;

  UserProfile(
      {required this.firstName,
      required this.lastName,
      required this.profileImage});
}
