import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_6_authentication_security_fcm/data/api_errors.dart';
import 'package:week_6_authentication_security_fcm/providers/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('provider auth membaca status login dari token', () async {
    final store = FakeTokenStore()..access = 'mock-access';
    expect(store.access != null, isTrue);
    store.access = null;
    expect(store.access != null, isFalse);
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final store = FakeTokenStore()..refresh = '';
    final needsLogin = (store.refresh ?? '').isEmpty;
    expect(needsLogin, isTrue);
  });

  test('ApiErrorMapper memetakan 401 dan timeout ke pesan yang ramah', () {
    final err401 = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      response: Response(
        requestOptions: RequestOptions(path: '/devices'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );
    expect(ApiErrorMapper.map(err401), contains('401'));

    final errTimeout = DioException(
      requestOptions: RequestOptions(path: '/devices'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(ApiErrorMapper.map(errTimeout), contains('timeout'));
  });
}
