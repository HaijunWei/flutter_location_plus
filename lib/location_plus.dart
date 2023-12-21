import 'package:flutter/services.dart';

export 'src/messages.g.dart';

import 'src/messages.g.dart';

const EventChannel _channel = EventChannel('haijunwei/location_plus_event');

extension LocationPlusExt on LocationPlus {
  Stream<Location> get locationUpdated => _channel
      .receiveBroadcastStream()
      .map((dynamic data) => Location.decode(data));
}
