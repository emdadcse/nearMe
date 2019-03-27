//
//  AddressForAnnotation.swift
//  NearMe
//
//  Created by aliazam on 13/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import MapKit

extension MKPlacemark {
    var fullAddress: String? {
        guard
            let streetNumber = subThoroughfare,
            let streetName = thoroughfare,
            let city = locality,
            let state = administrativeArea,
            let zip = postalCode
            else {
                if let title = title {
                    return "\(title)"
                }
                else {
                    return nil
                }
        }
        let address = "\(streetNumber) \(streetName), \(city), \(state) \(zip)"
        return address
    }
}
