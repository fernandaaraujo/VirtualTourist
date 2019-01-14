import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIButton!

    let activityIndicator = UIActivityIndicatorView()

    var selectedPin: PinData!
    var photoPin: Pin!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    override func viewDidLoad() {
        super.viewDidLoad()

        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false

        addAnnotation()
        center(map: mapView, on: selectedPin.coordinate)

        getSavedPhotos()
        checkSavedData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    @IBAction func getNewCollection(_ sender: Any) {
        removeSavedPhotos()
        getPhotosFromClient()
    }

    func checkSavedData() {
        if photoPin.photos?.count != 0 {
            newCollectionButton.isEnabled = true
        } else {
            getPhotosFromClient()
        }
    }

    func getPhotosFromClient() {
        FlickrClient().getPhotos() { (success, results, error) in
            if success {
                self.setupUI(haveImages: false, hideLabel: true)
                self.displayActivityIndicator()

                for url in results {
                    let imageData = try? Data(contentsOf: URL(string: url)!)
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = url
                    photo.imageData = imageData

                    self.photoPin.addToPhotos(photo)
                    try? self.dataController.viewContext.save()
                }

                self.removeActivityIndicator()
                self.setupUI(haveImages: true, hideLabel: true)
            } else {
                self.setupUI(haveImages: false, hideLabel: false)
            }
        }
    }

    func getSavedPhotos() {
        let predicate = NSPredicate(format: "pin == %@", self.photoPin)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: self.dataController.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func removeSavedPhotos() {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
            }
        }
    }

    private func addAnnotation() {
        let coordinate = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "Latitude"),
                                                longitude: UserDefaults.standard.double(forKey: "Longitude"))
        selectedPin = PinData(pin: photoPin,
                              coordinate: coordinate)
        self.mapView.addAnnotation(selectedPin)
    }

    private func setupUI(haveImages: Bool, hideLabel: Bool) {
        DispatchQueue.main.async {
            self.noImagesLabel.isHidden = hideLabel
            self.newCollectionButton.isEnabled = haveImages
            self.collectionView.isScrollEnabled = haveImages
        }
    }

    private func displayActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.style = .whiteLarge
            self.activityIndicator.center = self.collectionView.center

            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    private func removeActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
        }
    }
}
