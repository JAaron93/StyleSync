import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stylesync/core/storage/secure_storage_service.dart';
import 'package:stylesync/core/storage/secure_storage_service_impl.dart';
import 'package:test/test.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageServiceImpl(
      storage: mockStorage,
      backend: SecureStorageBackend.hardwareBacked,
    );
  });

  group('SecureStorageServiceImpl', () {
    test('write calls storage.write', () async {
      when(mockStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).thenAnswer((_) async => {});

      await service.write('test_key', 'test_value');

      verify(mockStorage.write(
        key: 'test_key',
        value: 'test_value',
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).called(1);
    });

    test('read calls storage.read', () async {
      when(mockStorage.read(
        key: anyNamed('key'),
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).thenAnswer((_) async => 'retrieved_value');

      final result = await service.read('test_key');

      expect(result, 'retrieved_value');
      verify(mockStorage.read(
        key: 'test_key',
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).called(1);
    });

    test('delete calls storage.delete', () async {
      when(mockStorage.delete(
        key: anyNamed('key'),
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).thenAnswer((_) async => {});

      await service.delete('test_key');

      verify(mockStorage.delete(
        key: 'test_key',
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).called(1);
    });

    test('deleteAll calls storage.deleteAll', () async {
      when(mockStorage.deleteAll(
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).thenAnswer((_) async => {});

      await service.deleteAll();

      verify(mockStorage.deleteAll(
        iOptions: anyNamed('iOptions'),
        aOptions: anyNamed('aOptions'),
        lOptions: anyNamed('lOptions'),
        webOptions: anyNamed('webOptions'),
        mOptions: anyNamed('mOptions'),
        wOptions: anyNamed('wOptions'),
      )).called(1);
    });
  });
}
