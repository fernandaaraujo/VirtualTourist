import Foundation
import MapKit

func center(map: MKMapView, on location: CLLocationCoordinate2D) {
    let regionRadius: CLLocationDistance = 2500000
    let coordinateRegion = MKCoordinateRegion(center: location,
                                              latitudinalMeters: regionRadius * 2.0,
                                              longitudinalMeters: regionRadius * 2.0)
    map.setRegion(coordinateRegion, animated: true)
}

func synchronizeLocation(with coordinate: CLLocationCoordinate2D) {
    UserDefaults.standard.set(coordinate.latitude, forKey: "Latitude")
    UserDefaults.standard.set(coordinate.longitude, forKey: "Longitude")
    UserDefaults.standard.synchronize()
}
