import 'package:equatable/equatable.dart';
import 'package:newlane/core/errors/result.dart';
import 'package:newlane/core/usecases/usecase.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';
import 'package:newlane/features/create_post/repositories/offices_repository.dart';

class GetOffices implements UseCase<Result<List<Office>>, GetOfficesParams> {
  const GetOffices(this._repository);

  final OfficesRepository _repository;

  @override
  Future<Result<List<Office>>> call(GetOfficesParams params) {
    return _repository.getOffices(search: params.search);
  }
}

class GetOfficesParams extends Equatable {
  const GetOfficesParams({this.search = ''});

  final String search;

  @override
  List<Object?> get props => <Object?>[search];
}
