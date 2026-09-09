import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/create_post/repositories/offices_repository.dart';

class GetOfficeById implements UseCase<Result<Office>, GetOfficeByIdParams> {
  const GetOfficeById(this._repository);

  final OfficesRepository _repository;

  @override
  Future<Result<Office>> call(GetOfficeByIdParams params) {
    return _repository.getOfficeById(params.officeId);
  }
}

class GetOfficeByIdParams extends Equatable {
  const GetOfficeByIdParams(this.officeId);

  final int officeId;

  @override
  List<Object?> get props => <Object?>[officeId];
}
