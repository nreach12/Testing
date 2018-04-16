//
//  PlaceMarker.swift
//  Maps
//
//  Created by Nicholas Reach on 4/16/18.
//  Copyright © 2018 Nicholas Reach. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {

    let place: GooglePlace
    
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    
    // 2
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
    
    
}
