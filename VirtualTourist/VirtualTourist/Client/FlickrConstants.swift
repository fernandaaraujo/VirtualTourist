import Foundation
import UIKit

struct FlickrConstants {
    struct API {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
        static let key = "f9d0262f06a020df2e458a3d7c4b07a2"
    }

    struct BBox {
        static let halfWidth = 1.0
        static let halfHeight = 1.0
        static let latitudeRange = (-90.0, 90.0)
        static let longitutdeRange = (-180.0, 180.0)
    }

    struct Keys {
        static let method = "method"
        static let apiKey = "api_key"
        static let boundingBox = "bbox"
        static let safeSearch = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let noJsonCallback = "nojsoncallback"
        static let page = "page"
        static let perPage = "per_page"
    }

    struct Values {
        static let searchMethod = "flickr.photos.search"
        static let safeSearch = "1"
        static let extras = "url_m"
        static let format = "json"
        static let noJsonCallback = "1"
    }

    struct ResponseKeys {
        static let status = "stat"
        static let photos = "photos"
        static let pages = "pages"
        static let photo = "photo"
        static let extras = "url_m"
    }

    struct ResponseValues {
        static let ok = "ok"
    }
}
