import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmandili_driver/core/permissions/location_disclosure_screen.dart';
import 'package:cmandili_driver/l10n/app_localizations.dart';

/// Google Play: the driver reads what the location is for, in the app, before
/// Android's prompt; and only "while using the app" is asked, because the GPS
/// runs in a foreground service of type location started from the open app.
void main() {
  group('the explanation shown before the location prompt', () {
    Future<bool?> openAndTap(WidgetTester tester, String locale, String button) async {
      bool? result;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const LocationDisclosureScreen()),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final l = await AppLocalizations.delegate.load(Locale(locale));
      for (final text in [
        l.locationDisclosureTitle,
        l.locationDisclosureIntro,
        l.locationDisclosureUseOffers,
        l.locationDisclosureUseTracking,
        l.locationDisclosureUseProof,
        l.locationDisclosureStop,
      ]) {
        expect(find.text(text), findsOneWidget, reason: '$locale: "$text" not shown');
      }
      await tester.tap(find.text(button == 'continue' ? l.locationDisclosureContinue : l.locationDisclosureNotNow));
      await tester.pumpAndSettle();
      return result;
    }

    for (final locale in ['fr', 'en', 'ar']) {
      testWidgets('$locale: Continue lets the prompt come', (tester) async {
        expect(await openAndTap(tester, locale, 'continue'), isTrue);
      });
      testWidgets('$locale: Not now asks Android nothing', (tester) async {
        expect(await openAndTap(tester, locale, 'not now'), isFalse);
      });
    }
  });

  group('what the app may ask', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    test('no background location in the manifest; the foreground service keeps type location', () {
      expect(manifest.contains('uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"'), isFalse);
      expect(manifest.contains('android.permission.FOREGROUND_SERVICE_LOCATION'), isTrue);
      expect(manifest.contains('android:foregroundServiceType="location"'), isTrue);
    });

    test("Android's location prompt is only reached through LocationDisclosure", () {
      final direct = <String>[];
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final s = f.readAsStringSync();
        if (s.contains('Geolocator.requestPermission(') &&
            !f.path.replaceAll('\\', '/').endsWith('core/permissions/location_disclosure.dart')) {
          direct.add(f.path);
        }
        if (s.contains('Permission.locationAlways')) direct.add('${f.path} (locationAlways)');
      }
      expect(direct, isEmpty);
    });
  });
}
