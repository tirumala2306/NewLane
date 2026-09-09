import 'package:equatable/equatable.dart';

sealed class RequestAccessEvent extends Equatable {
  const RequestAccessEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class RequestAccessSubmitted extends RequestAccessEvent {
  const RequestAccessSubmitted({
    required this.fullName,
    required this.workEmail,
    required this.brokerageName,
    required this.phone,
    required this.acceptedTerms,
  });

  final String fullName;
  final String workEmail;
  final String brokerageName;
  final String phone;
  final bool acceptedTerms;

  @override
  List<Object?> get props =>
      <Object?>[fullName, workEmail, brokerageName, phone, acceptedTerms];
}
