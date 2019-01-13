import Foundation
import MapKit
import CoreData

class PinData: NSObject, MKAnnotation {
    var pin: Pin
    var coordinate: CLLocationCoordinate2D

    init(pin: Pin, coordinate: CLLocationCoordinate2D){
        self.pin = pin
        self.coordinate = coordinate
    }
}
