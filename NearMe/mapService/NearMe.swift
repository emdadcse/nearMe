//
//  NearMe.swift
//  NearMe
//
//  Created by aliazam on 12/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import MapKit

enum NearMeType: String {
    case restaurants, bus_station, medical, ATM, schools, shopping, police, patrol
}

class NearMe: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let title: String?
    var subtitle: String?
    let nearMeType: NearMeType?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, nearMeType: NearMeType) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.nearMeType = nearMeType
    }
}
