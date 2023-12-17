import 'dart:io';

class UserProfile {
  int userId;
  String firstName;
  String lastName;
  String? profileImage;
  File? imageFile;
  bool? hasPsychologist;
  DateTime? lastRecordDate;
  String? notificationTime;

  UserProfile(
      {required this.userId,
      this.firstName = '',
      this.lastName = '',
      this.profileImage,
      this.hasPsychologist,
      this.lastRecordDate,
      this.notificationTime});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        userId: json['userId'],
        firstName: json['firstName'] ?? 'Jan',
        lastName: json['lastName'] ?? 'Novák',
        profileImage: json['profileImagePath'],
        hasPsychologist: json['hasPsychologist'],
        lastRecordDate: json['lastRecordDate'] != null
            ? DateTime.parse(json['lastRecordDate'])
            : null,
        notificationTime: json['notificationTime']);
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': profileImage,
        'hasPsychologist': hasPsychologist,
        'lastRecordDate': lastRecordDate,
      };
}
