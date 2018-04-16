//
//  MapViewController.swift
//  Maps
//
//  Created by Nicholas Reach on 4/15/18.
//  Copyright © 2018 Nicholas Reach. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    var searchedTypes = ["Pharmacy", "Doctor", "Grocery Store", "Hospital"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let controller = navigationController.topViewController as? TypesTableViewController else {
                return
        }
        controller.selectedTypes = searchedTypes
        controller.delegate = self
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            // 3
            self.addressLabel.text = lines.joined(separator: "\n")
            
            let labelHeight = self.addressLabel.intrinsicContentSize.height
            self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                bottom: labelHeight, right: 0)
            
            // 4
            UIView.animate(withDuration: 0.25) {
                //2
                
                self.view.layoutIfNeeded()
            
            }
            
        
        }
    }
    
    private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        // 1
        mapView.clear()
        // 2
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                // 3
                let marker = PlaceMarker(place: $0)
                // 4
                marker.map = self.mapView
            }
        }
    }
    
    @IBAction func refreshPlaces(_ sender: Any) {
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.startUpdatingLocation()
        
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
        
        fetchNearbyPlaces(coordinate: location.coordinate)
    }
}
    
    
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        // 1
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        
        // 2
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        
        // 3
        infoView.nameLabel.text = placeMarker.place.name
        
        // 4
        if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "generic")
        }
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}
extension MapViewController: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true)
        
        
        fetchNearbyPlaces(coordinate: mapView.camera.target)

    }
}
