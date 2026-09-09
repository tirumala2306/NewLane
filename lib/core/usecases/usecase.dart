abstract class UseCase<ResultType, Params> {
  Future<ResultType> call(Params params);
}

class NoParams {
  const NoParams();
}
