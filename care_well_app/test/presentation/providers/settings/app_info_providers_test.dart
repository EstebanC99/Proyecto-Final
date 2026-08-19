import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('appVersionProvider', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'CareWell',
        packageName: 'com.bubisoft.carewell',
        version: '1.2.0',
        buildNumber: '7',
        buildSignature: '',
      );
    });

    test('devuelve solo la versión del paquete instalado', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(appVersionProvider.future), '1.2.0');
    });
  });
}
