import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Classes/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcOptions: ObjcOptions(prefix: 'HJ'),
))
@HostApi()
abstract class LocationPlus {
  void startUpdatingLocation();
  void stopUpdatingLocation();

  @async
  Location requestSingleLocation();

  @async
  List<Placemark> reverseGeo(Location location);
}

class Location {
  Location({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class Placemark {
  /// 位置
  final String name;

  /// 街道
  final String thoroughfare;

  /// 子街道
  final String subThoroughfare;

  /// 市
  final String locality;

  /// 区\县
  final String subLocality;

  /// 行政区
  final String administrativeArea;

  /// 国家
  final String country;

  Placemark({
    required this.name,
    required this.thoroughfare,
    required this.subThoroughfare,
    required this.locality,
    required this.subLocality,
    required this.administrativeArea,
    required this.country,
  });
}
