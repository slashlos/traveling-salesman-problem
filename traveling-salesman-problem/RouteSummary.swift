//
//  RouteSummary.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 13/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

class RouteSummary: NSObject,NSCoding {
    let routes: [Route]
    lazy var waypoints: [Waypoint] = {
        guard let start = self.routes.first?.source else {
            return []
        }
        var waypoints = self.routes.map{ $0.source }
        waypoints.append(start)
        return waypoints
    }()
    
    /// summed expected travel time of all routes
    lazy var expectedTravelTime: TimeInterval = {
        return self.routes.reduce(0) { $0 + $1.expectedTravelTime }
    }()
    
    /// summed distance of all routes
    lazy var distance: CLLocationDistance = {
        return self.routes.reduce(0) { $0 + $1.distance }
    }()
    
    init(routes: [Route]) {
        self.routes = routes
    }
    
    // MARK: NSCoding
    convenience init(routes: [Route], waypoints: [Waypoint], expectedTravelTime: TimeInterval, distance: CLLocationDistance) {
        self.init(routes: routes)
        self.waypoints = waypoints
        self.expectedTravelTime = expectedTravelTime
        self.distance = distance
    }
    
    required convenience init(coder decoder: NSCoder) {
        let routes = decoder.decodeObject(forKey: "routes") as! [Route]
        let waypoints = decoder.decodeObject(forKey: "waypoints") as! [Waypoint]
        let expectedTravelTime = decoder.decodeObject(forKey: "expectedTravelTime") as! TimeInterval
        let distance = decoder.decodeObject(forKey: "distance") as! CLLocationDistance
        self.init(routes: routes, waypoints: waypoints, expectedTravelTime: expectedTravelTime, distance: distance)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.routes, forKey: "routes")
        coder.encode(self.waypoints, forKey: "waypoints")
        coder.encode(self.expectedTravelTime, forKey: "expectedTravelTime")
        coder.encode(self.distance, forKey: "distance")
    }
    
    // MARK: Functions
    func routeSteps(for depatureTime: Date, transferTime: TimeInterval) -> [RouteStep] {
        var nextDepatureTime = depatureTime
        let steps = routes.map { (route) -> RouteStep in
            let step = RouteStep(route: route, depatureTime: nextDepatureTime)
            nextDepatureTime = step.arrivalTime.addingTimeInterval(transferTime)
            return step
        }
        return steps
    }
    func expectedArivalTime(for depatureTime: Date) -> Date {
        return depatureTime.addingTimeInterval(expectedTravelTime)
    }
}
