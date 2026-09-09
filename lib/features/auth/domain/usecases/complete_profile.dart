import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/auth/domain/entities/complete_profile_result.dart';
import 'package:newlane/features/auth/repositories/auth_repository.dart';

class CompleteProfile
    implements UseCase<Result<CompleteProfileResult>, CompleteProfileParams> {
  const CompleteProfile(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<CompleteProfileResult>> call(CompleteProfileParams params) {
    return _repository.completeProfile(
      fullName: params.fullName,
      phone: params.phone, 
      jobTitle: params.jobTitle,
      bio: params.bio,
      instagram: params.instagram,
      website: params.website,
      specialties: params.specialties,
      avatarFilePath: params.avatarFilePath,
    );
  }
}

class CompleteProfileParams extends Equatable {
  const CompleteProfileParams({
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
