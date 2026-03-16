import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  // Initialize generated dependencies
  getIt.init();
}

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  Logger get logger => Logger();
}
