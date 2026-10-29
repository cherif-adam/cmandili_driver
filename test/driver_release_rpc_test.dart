import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// "Je ne peux pas livrer" goes through the database function
/// driver_release_order. The app may not write the withdrawal on the order
/// itself (the orders guards refuse it), nor record a driver_relay
/// settlement: every new settlement is credited to the wallet at once, and
/// the partial trip is a request the admin settles.
void main() {
  final src = File('lib/features/orders/presentation/order_tracking_screen.dart')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');

  test('the withdrawal calls driver_release_order with the order and the reason', () {
    expect(src, contains("rpc('driver_release_order'"));
    expect(src, contains("'p_order_id': widget.orderId"));
    expect(src, contains("'p_reason': reason"));
    expect(src, contains("result == 'not_assigned'"));
  });

  test('the app no longer writes the withdrawal or a relay settlement itself', () {
    expect(src, isNot(contains("'driver_id': null")));
    expect(src, isNot(contains("'driver_relay'")));
    expect(src, isNot(contains("from('settlements')")));
  });
}
