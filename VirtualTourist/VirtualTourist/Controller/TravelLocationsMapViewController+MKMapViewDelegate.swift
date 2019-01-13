import MapKit

extension TravelLocationsMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
        if let annotation = didSelect.annotation as? PinData {
            synchronizeLocation(with: annotation.coordinate)

            let photoAlbumViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController

            photoAlbumViewController.dataController = self.dataController
            photoAlbumViewController.photoPin = annotation.pin

            navigationController?.pushViewController(photoAlbumViewController, animated: true)
        } else {
            fatalError("Error on create annotation object")
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}
