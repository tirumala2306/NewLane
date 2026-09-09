import 'package:newlane/core/errors/result.dart';
import 'package:newlane/features/create_post/domain/entities/office.dart';

abstract class OfficesRepository {
  Future<Result<List<Office>>> getOffices({String search = ''});

  Future<Result<Office>> getOfficeById(int officeId);
}
