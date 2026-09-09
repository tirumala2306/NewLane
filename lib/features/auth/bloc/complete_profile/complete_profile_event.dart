import 'package:equatable/equatable.dart';

sealed class CompleteProfileEvent extends Equatable {
  const CompleteProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class CompleteProfileStarted extends CompleteProfileEvent {
  const CompleteProfileStarted();
}

class CompleteProfileSubmitted extends CompleteProfileEvent {
  const CompleteProfileSubmitted({
    required this.fullName,
    required this.phone,
    required this.jobTitle,
    required this.bio,
    this.instagram = '',
    this.website = '',
    this.specialties = const <String>[],
    this.avatarFilePath,
  });

  final String fullName;
  final String phone;
  final String jobTitle;
  final String bio;
  final String instagram;
  final String website;
  final List<String> specialties;
  final String? avatarFilePath;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    phone,
    jobTitle,
    bio,
    instagram,
    website,
    specialties,
    avatarFilePath,
  ];
}
