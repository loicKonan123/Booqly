import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super(message: 'Session expirée. Veuillez vous reconnecter.');
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'Vérifiez votre connexion internet.');
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  const ValidationFailure({required this.errors})
      : super(message: 'Données invalides.');
}
