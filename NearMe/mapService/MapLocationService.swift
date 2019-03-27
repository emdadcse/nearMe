//
//  MapLocationService.swift
//  NearMe
//
//  Created by aliazam on 11/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import CoreLocation

protocol MapLocationServiceDelegete: class {
    func authorizationDenided()
    func setMapRegion(center: CLLocation)
}

class MapLocationService:NSObject {
    
    var locationManager = CLLocationManager()
    weak var delegate: MapLocationServiceDelegete?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkDeviceAuthorizationStatus(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            
        case .denied:
            delegate?.authorizationDenided()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
            
        default:
            break
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
}

extension MapLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkDeviceAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        if let location = locations.last {
            delegate?.setMapRegion(center: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
