import Flutter
import UIKit
import CoreLocation

public class LocationPlusPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, LocationPlus, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager?
    private var eventSink: FlutterEventSink?
    private var singleLocationManagers: [SingleLocationManager] = []
    
    init(channel: FlutterEventChannel) {
        super.init()
        channel.setStreamHandler(self)
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterEventChannel(name: "haijunwei/location_plus_event", binaryMessenger: registrar.messenger())
        let instance = LocationPlusPlugin(channel: channel)
        registrar.publish(instance)
        LocationPlusSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func startUpdatingLocation() throws {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() throws {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
    
    func reverseGeo(location: Location, completion: @escaping (Result<[Placemark], Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: { placemarks, error in
            if let e = error {
                completion(.failure(e))
                return
            }
            let list = placemarks?.map {
                Placemark(
                    name: $0.name ?? "",
                    thoroughfare: $0.thoroughfare ?? "",
                    subThoroughfare: $0.subThoroughfare ?? "",
                    locality: $0.locality ?? "",
                    subLocality: $0.subLocality ?? "",
                    administrativeArea: $0.administrativeArea ?? "",
                    country: $0.country ?? ""
                )
            }
            completion(.success(list ?? []))
        })
    }
    
    func requestSingleLocation(completion: @escaping (Result<Location, Error>) -> Void) {
        let manager = SingleLocationManager(callback: completion, onDone: { [weak self] m in
            self?.singleLocationManagers.removeAll(where: { $0 === m })
        })
        manager.startUpdatingLocation()
        singleLocationManagers.append(manager);
    }
    
    
    // - MARK: CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l = locations.first else { return }
        eventSink?([l.coordinate.latitude, l.coordinate.longitude])
    }
}


class SingleLocationManager: NSObject, CLLocationManagerDelegate {
    private let callback: (Result<Location, Error>) -> Void
    private let onDone: (SingleLocationManager) -> Void
    private let locationManager: CLLocationManager
    
    init(callback: @escaping (Result<Location, Error>) -> Void, onDone: @escaping (SingleLocationManager) -> Void) {
        self.callback = callback
        self.onDone = onDone
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // - MARK: CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let l = locations.first else { return }
        locationManager.stopUpdatingLocation()
        callback(.success(Location(latitude: l.coordinate.latitude, longitude: l.coordinate.longitude)))
        onDone(self)
    }
}
