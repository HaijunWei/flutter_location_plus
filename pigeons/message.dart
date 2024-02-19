import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  swiftOut: 'ios/Classes/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/haijunwei/location_plus/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.haijunwei.location_plus'),
))
@HostApi()
abstract class LocationPlus {
  void startUpdatingLocation();
  void stopUpdatingLocation();

  @async
  Location requestSingleLocation();
}

class Location {
  Location({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.province,
    required this.city,
    required this.direction,
  });

  final double latitude;
  final double longitude;
  final String country;
  final String province;
  final String city;
  final String direction;
}
