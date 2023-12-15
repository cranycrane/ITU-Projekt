import 'dart:io';

class UserProfile {
  int userId;
  String firstName;
  String lastName;
  String? profileImage;
  File? imageFile;
  bool? hasPsychologist;

  UserProfile(
      {required this.userId,
      this.firstName = '',
      this.lastName = '',
      this.profileImage,
      this.hasPsychologist});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        userId: json['userId'],
        firstName: json['firstName'] ?? 'Jan',
        lastName: json['lastName'] ?? 'Novák',
        profileImage: json['profileImagePath'],
        hasPsychologist: json['hasPsychologist']);
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': profileImage,
        'hasPsychologist': hasPsychologist
      };
}
