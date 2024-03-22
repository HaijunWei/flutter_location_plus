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
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(l, completionHandler: { [weak self] placemarks, error in
            guard let `self` = self else { return }
            if error != nil { return }
            if let e = placemarks?.first {
                let country = e.country ?? ""
                let province = e.administrativeArea ?? e.locality ?? ""
                let city = e.locality ?? ""
                let direction = e.subLocality ?? ""
                let r =  Location(latitude: l.coordinate.latitude, longitude: l.coordinate.longitude, country: country, province: province, city: city, direction: direction)
                eventSink?(r.toList())
            }
        })
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
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(l, completionHandler: { [weak self] placemarks, error in
            guard let `self` = self else { return }
            if let e = error {
                callback(.failure(e))
                return
            }
            if let e = placemarks?.first {
                let country = e.country ?? ""
                let province = e.administrativeArea ?? e.locality ?? ""
                let city = e.locality ?? ""
                let direction = e.subLocality ?? ""
                let r = Location(latitude: l.coordinate.latitude, longitude: l.coordinate.longitude, country: country, province: province, city: city, direction: direction)
                callback(.success(r))
            } else {
                callback(.failure(LocationError.custom(msg: "反地理编码出错")))
            }
            onDone(self)
        })
    }
}

enum LocationError: LocalizedError {
    case custom(msg: String)
}
