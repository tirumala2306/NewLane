import 'package:newlane/features/auth/domain/entities/complete_profile_result.dart';

class CompleteProfileModel {
  const CompleteProfileModel({required this.message});

  factory CompleteProfileModel.fromEnvelope({required String message}) {
    return CompleteProfileModel(message: message);
  }

  final String message;

  CompleteProfileResult toEntity() {
    return CompleteProfileResult(message: message);
  }
}
