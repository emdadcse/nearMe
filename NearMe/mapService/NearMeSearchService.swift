//
//  NearMeSearchService.swift
//  NearMe
//
//  Created by aliazam on 12/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import MapKit

class NearMeSearchService {
    typealias SearchHandler = ([MKMapItem]) -> Void
    static func poiSearch(for nearMeType: NearMeType, around center: CLLocationCoordinate2D, completion: @escaping SearchHandler) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = nearMeType.rawValue
        request.region = region
        
        MKLocalSearch(request: request).start { (response, error) in
            if error != nil {
                return
            }
            
            guard let response = response else { return }
            
            completion(response.mapItems)
        }
    }
}
