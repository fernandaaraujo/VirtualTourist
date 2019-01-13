import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var pins: [Pin] = []
    var selectedPin: Pin!
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()

        let longGesture = UILongPressGestureRecognizer(target: self, action:
            #selector(longPress(_:)))
        mapView.addGestureRecognizer(longGesture)

        fetchResults()
        addPins()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchResults()
        centerLocation()
    }

     @objc func longPress(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            let touchLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(touchLocation,
                                             toCoordinateFrom: mapView)

            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            pin.creationDate = Date()
            
            try? dataController.viewContext.save()

            addAnnotation(pin: pin)
            synchronizeLocation(with: coordinate)
        }
    }

    func addPins() {
        for pin in pins {
            addAnnotation(pin: pin)
        }
    }

    private func addAnnotation(pin: Pin) {
        let annotation = PinData(pin: pin, coordinate: CLLocationCoordinate2D(latitude: pin.latitude,
                                                                              longitude: pin.longitude))
        self.mapView.addAnnotation(annotation)
    }

    private func fetchResults() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        }
    }

    private func centerLocation() {
        let location = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"),
                                              longitude: UserDefaults.standard.double(forKey: "Longitude"))
        center(map: mapView, on: location)
    }
}
