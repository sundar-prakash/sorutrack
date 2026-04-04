import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mock_hydrated_storage.mocks.dart';

@GenerateMocks([Storage])
void mockHydratedStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = MockStorage();
  when(storage.read(any)).thenReturn(null);
  when(storage.write(any, any)).thenAnswer((_) async {});
  when(storage.delete(any)).thenAnswer((_) async {});
  when(storage.clear()).thenAnswer((_) async {});
  HydratedBloc.storage = storage;
}
