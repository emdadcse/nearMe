//
//  ViewController.swift
//  NearMe
//
//  Created by aliazam on 4/3/19.
//  Copyright © 2019 sebpo. All rights reserved.
//

import UIKit
import MapKit

class MainMap_VC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var nearMeView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nearMe_TopConstraint: NSLayoutConstraint!
    
    private var nearMeType: NearMeType?
    private var nearMe = [NearMe]()
    private let mapLocationService = MapLocationService()
    private var mapCenterLocation: CLLocation?
    
    
    private lazy var locationAlert: UIAlertController = {
        let mapAlertController = UIAlertController(title: "Location Authorization", message: "Quest can provide the points of interest based on your current location. To change the location permission please update your Privacy setting.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let settingAction = UIAlertAction(title: "Update Setting", style: .default, handler: { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        mapAlertController.addAction(okAction)
        mapAlertController.addAction(settingAction)
        
        return mapAlertController
    }()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlView.layer.cornerRadius = 5.0
        mapLocationService.delegate = self
        nearMeView.layer.cornerRadius = 8.0
        
        mapCenterLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        
    }
    
    // MARK all action func
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    @IBAction func btnMapStyle(_ sender: UIButton) {
        mapView.mapType = mapView.mapType == .standard ? .satellite : .standard
        
    }
    
    @IBAction func btnNearMe(_ sender: UIButton) {
        
       searchView(shown: true)
        
    }
    @IBAction func btnNearmeClose(_ sender: UIButton) {
        searchView(shown: false)
    }
    
    @IBAction func btnsNearMeButon(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            nearMeType = .restaurants
        case 1:
            nearMeType = .bus_station
        case 2:
            nearMeType = .medical
        case 3:
            nearMeType = .ATM
        case 4:
            nearMeType = .schools
        case 5:
            nearMeType = .shopping
        case 6:
            nearMeType = .police
        case 7:
            nearMeType = .patrol
        default:
            break
        }
        searchNearMe()
    }
    
    
    private func searchNearMe() {
        guard let nearMeType = nearMeType else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NearMeSearchService.poiSearch(for: nearMeType, around: mapView.centerCoordinate) { [weak self] (mapItems) in
            self?.updateSearchResult(with: mapItems)
        }
    }
    
    private func updateSearchResult(with mapItems: [MKMapItem]) {
        nearMe.removeAll()
        
        for mapItem in mapItems {
            if let name = mapItem.name, let address = mapItem.placemark.fullAddress, let nearMeType = nearMeType {
                let poi = NearMe(title: name, subtitle: address, coordinate: mapItem.placemark.coordinate, nearMeType: nearMeType)
                nearMe.append(poi)
            }
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(nearMe)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func searchView(shown: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            let viewHeight = weakSelf.nearMeView.frame.size.height
            
            weakSelf.nearMe_TopConstraint.constant = shown
                ? -1 * viewHeight
                : 0
            
            weakSelf.view.layoutIfNeeded()
        }
    }
    
    private func closeSlideView() {
        searchView(shown: false)
    }
    private func centerMap(to nearMe: NearMe) {
        setMapRegion(center: CLLocation(latitude: nearMe.coordinate.latitude, longitude: nearMe.coordinate.longitude))
        closeSlideView()
    }
}

// MARK: MapLocationServiceDelegete

extension MainMap_VC: MapLocationServiceDelegete {
    func authorizationDenided() {
        DispatchQueue.main.async {[weak self] in
            guard let weakSelf = self else {return}
            weakSelf.present(weakSelf.locationAlert, animated: true, completion: nil)
        }
    }
    
    func setMapRegion(center: CLLocation) {
        let mapRegion = MKCoordinateRegion(center: center.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    
}

extension MainMap_VC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearMe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult", for: indexPath)
        let poi = nearMe[indexPath.row]
        cell.textLabel?.text = poi.title
        cell.detailTextLabel?.text = poi.subtitle
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poi = nearMe[indexPath.row]
        mapView.addAnnotation(poi)
        centerMap(to: poi)
    }
    
    
}

// MARK: - MKMapViewDelegate

extension MainMap_VC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let nearMeType = nearMeType {
            let newCenterLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
            if let prevMapCenterLocation = mapCenterLocation {
                // Refresh the POI search if center moves 500 m from previous center
                if newCenterLocation.distance(from: prevMapCenterLocation) > 500 {
                    mapCenterLocation = newCenterLocation
                    searchNearMe()
                }
            }
        }
    }
}
