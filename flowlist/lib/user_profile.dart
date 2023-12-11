import 'dart:io';

class UserProfile {
  int userId;
  String firstName;
  String lastName;
  String? profileImage;
  File? imageFile;

  UserProfile(
      {required this.userId,
      this.firstName = '',
      this.lastName = '',
      this.profileImage});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImage: json['profileImagePath'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': profileImage,
      };
}
