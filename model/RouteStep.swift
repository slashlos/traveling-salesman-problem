//
//  RouteStep.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 14/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

class RouteStep: NSObject,NSCoding {
    let route: Route
    let depatureTime: Date
    let arrivalTime: Date
    var source: Waypoint {
        return route.source
    }
    var destination: Waypoint {
        return route.destination
    }
    var expectedTravelTime: TimeInterval {
        return route.expectedTravelTime
    }
    var distance: CLLocationDistance {
        return route.distance
    }
    init(route: Route, depatureTime: Date) {
        self.route = route
        self.depatureTime = depatureTime
        self.arrivalTime = depatureTime.addingTimeInterval(route.expectedTravelTime)
    }

    // MARK: NSCoding
    required convenience init(coder decoder: NSCoder) {
        let route = decoder.decodeObject(forKey: "route") as! Route
        let depatureTime = decoder.decodeObject(forKey: "depatureTime") as! Date
        self.init(route: route, depatureTime: depatureTime)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.route, forKey: "route")
        coder.encode(self.depatureTime, forKey: "depatureTime")
    }
}
