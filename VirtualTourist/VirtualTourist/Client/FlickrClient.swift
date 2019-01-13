import Foundation
import UIKit
import CoreData

class FlickrClient {
    var dataController: DataController!

    func getPhotos(completionHandler: @escaping (_ success: Bool, _ results: [String], _ error: String?) -> Void) {
        let parameters = getPhotosParameters()

        getFlickrData(parameters) { (success, results, error) in
            if success {
                completionHandler(true, results, nil)
            } else {
                completionHandler(false, [], error)
            }
        }
    }

    private func getFlickrData(_ parameters: [String:AnyObject], completionHandler: @escaping (_ success: Bool, _ results: [String], _ error: String?) -> Void) {
        let url = getUrlFrom(parameters: parameters)
        let request = URLRequest(url: url)

        let _ = taskForGETMethod(request) { (results, error) in
            guard (error == nil) else {
                completionHandler(false, [], error)
                return
            }
            
            guard let status = results?[FlickrConstants.ResponseKeys.status] as? String, status == FlickrConstants.ResponseValues.ok else {
                completionHandler(false, [], "Flickr API returned an error.")
                return
            }

            guard let photosDictionary = results?[FlickrConstants.ResponseKeys.photos] as? [String:AnyObject] else {
                completionHandler(false, [], "Cannot find keys '\(FlickrConstants.ResponseKeys.photos)'")
                return
            }

            guard let totalPages = photosDictionary[FlickrConstants.ResponseKeys.pages] as? Int else {
                completionHandler(false, [], "Cannot find key '\(FlickrConstants.ResponseKeys.pages)'")
                return
            }

            let pageLimit = min(totalPages, 40)
            let randomPage = self.getRandomNumberFrom(parameter: pageLimit) + 1
            
            self.getRandomFlickrData(parameters, pageNumber: randomPage) { (success, results, error) in
                if success {
                    completionHandler(true, results, nil)
                } else {
                    completionHandler(false, [], error)
                }
            }
        }
    }

    private func getRandomFlickrData(_ parameters: [String:AnyObject], pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ results: [String], _ error: String?) -> Void) {
        var parametersWithPageNumber = parameters
        parametersWithPageNumber[FlickrConstants.Keys.page] = pageNumber as AnyObject?

        let url = getUrlFrom(parameters: parametersWithPageNumber)
        let request = URLRequest(url: url)

        let _ = taskForGETMethod(request) { (results, error) in
            guard let status = results?[FlickrConstants.ResponseKeys.status] as? String, status == FlickrConstants.ResponseValues.ok else {
                completionHandler(false, [], "Flickr API returned an error.")
                return
            }

            guard let photosDictionary = results?[FlickrConstants.ResponseKeys.photos] as? [String:AnyObject] else {
                completionHandler(false, [], "Cannot find key '\(FlickrConstants.ResponseKeys.photos)'")
                return
            }

            guard let photosArray = photosDictionary[FlickrConstants.ResponseKeys.photo] as? [[String:AnyObject]] else {
                completionHandler(false, [], "Cannot find key '\(FlickrConstants.ResponseKeys.photo)'")
                return
            }

            guard photosArray.count != 0 else {
                completionHandler(false, [], "No Photos Found. Search Again.")
                return
            }

            var randomPhotoIndex = photosArray.count <= 21 ? 0 : self.getRandomNumberFrom(parameter: photosArray.count)
            randomPhotoIndex = randomPhotoIndex > 21 ? (randomPhotoIndex - 21) : randomPhotoIndex

            let photosToShow = min(photosArray.count, 21)
            var photoIndex = 0
            var urls = [String]()

            while photoIndex != photosToShow {
                var photo = photosArray[randomPhotoIndex + photoIndex] as [String:AnyObject]

                guard let imageUrl = photo[FlickrConstants.ResponseKeys.extras] as? String else {
                    completionHandler(false, [], "Cannot find key '\(FlickrConstants.ResponseKeys.extras)'")
                    return
                }

                urls.append(imageUrl)
                photoIndex += 1
            }

            completionHandler(true, urls, nil)
        }
    }

    private func taskForGETMethod(_ request: URLRequest, completionHandlerForGET: @escaping (_ result: [String:AnyObject]?, _ error: String?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            guard (error == nil) else {
                completionHandlerForGET([:], "There was an error with your request: \(String(describing: error))")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGET(nil, "Your request returned a status code other than 2xx!")
                return
            }

            guard let data = data else {
                completionHandlerForGET(nil, "No data was returned by the request!")
                return
            }

            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                completionHandlerForGET(nil, "Could not parse the data as JSON: '\(data)'")
                return
            }

            completionHandlerForGET(parsedResult, nil)
        }

        task.resume()
        return task
    }

    private func getPhotosParameters() -> [String:AnyObject] {
        return [FlickrConstants.Keys.method: FlickrConstants.Values.searchMethod as AnyObject,
                FlickrConstants.Keys.apiKey: FlickrConstants.API.key as AnyObject,
                FlickrConstants.Keys.boundingBox: bboxString() as AnyObject,
                FlickrConstants.Keys.safeSearch: FlickrConstants.Values.safeSearch as AnyObject,
                FlickrConstants.Keys.extras: FlickrConstants.Values.extras as AnyObject,
                FlickrConstants.Keys.format: FlickrConstants.Values.format as AnyObject,
                FlickrConstants.Keys.noJsonCallback: FlickrConstants.Values.noJsonCallback as AnyObject]
    }

    private func bboxString() -> String {
        let latitude = UserDefaults.standard.double(forKey: "Latitude")
        let longitude = UserDefaults.standard.double(forKey: "Longitude")
        let minLongitude = max(longitude - FlickrConstants.BBox.halfWidth, FlickrConstants.BBox.longitutdeRange.0)
        let minLatitude = max(latitude - FlickrConstants.BBox.halfHeight, FlickrConstants.BBox.longitutdeRange.0)
        let maxLongitude = min(longitude + FlickrConstants.BBox.halfWidth, FlickrConstants.BBox.longitutdeRange.1)
        let maxLatitude = min(latitude + FlickrConstants.BBox.halfHeight, FlickrConstants.BBox.longitutdeRange.1)

        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }

    private func getRandomNumberFrom(parameter: Int) -> Int {
        return Int(arc4random_uniform(UInt32(parameter)))
    }

    private func getUrlFrom(parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()

        components.scheme = FlickrConstants.API.scheme
        components.host = FlickrConstants.API.host
        components.path = FlickrConstants.API.path
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
}
