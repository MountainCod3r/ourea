import 'package:get_it/get_it.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/data/datasource/local_datasource.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/features/project_overview/project_overview/project_overview_bloc.dart';
import 'package:ourea/services/authentication/auth_service.dart';

GetIt locator = GetIt.instance;

void initLocator() {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => OureaLocalDataSource());
  locator.registerLazySingleton(() => OureaRemoteDataSource());
  locator.registerLazySingleton(() => OureaBloc());
}
