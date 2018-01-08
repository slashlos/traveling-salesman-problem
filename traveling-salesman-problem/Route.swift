//
//  Route.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 08/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

enum RouteWeight {
    case distance
    case time
}

/// A Route describes a possible path from a `Waypoint` to another `Waypoint`.
/// It has a weight which is either the distance or the expected travel time between the two `Waypoint`s determined by the weightedBy property.
/// It can be used as WeightedEdge.
class Route: NSObject,NSCoding {
    let source: Waypoint
    let destination: Waypoint
    fileprivate let mkRoute: MKRoute
    var weightedBy: RouteWeight
    var weight: Double {
        switch weightedBy {
        case .distance: return mkRoute.distance
        case .time: return mkRoute.expectedTravelTime
        }
    }
    init(source: Waypoint, destination: Waypoint, mkRoute: MKRoute, weightedBy: RouteWeight) {
        self.source = source
        self.destination = destination
        self.mkRoute = mkRoute
        self.weightedBy = weightedBy
    }
    var polyline: MKPolyline {
        return mkRoute.polyline
    }
    var transportType: MKDirectionsTransportType {
        return mkRoute.transportType
    }
    var expectedTravelTime: TimeInterval {
        return mkRoute.expectedTravelTime
    }
    var distance: CLLocationDistance {
        return mkRoute.distance
    }
    // MARK: NSCoding
    required convenience init(coder decoder: NSCoder) {
        let source = decoder.decodeObject(forKey: "source") as! Waypoint
        let destination = decoder.decodeObject(forKey: "destination") as! Waypoint
        let mkRoute = decoder.decodeObject(forKey: "mkRoute") as! MKRoute
        let weightedBy = decoder.decodeObject(forKey: "weightedBy") as! RouteWeight
        self.init(source: source, destination: destination, mkRoute: mkRoute, weightedBy: weightedBy)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.source, forKey: "source")
        coder.encode(self.destination, forKey: "destination")
        coder.encode(self.mkRoute, forKey: "mkRoute")
        coder.encode(self.weightedBy, forKey: "weightedBy")
    }
}

extension Double: EdgeWeight {
    static var zero: Double {
        return 0
    }
}


// MARK: - Equatable
extension Route {
    static func ==(lhs: Route, rhs: Route) -> Bool {
        return lhs.mkRoute == rhs.mkRoute
    }
    static func !=(lhs: Route, rhs: Route) -> Bool {
        return lhs.mkRoute != rhs.mkRoute
    }

// MARK: - Hashable
    override var hashValue: Int {
        return mkRoute.hashValue
    }
}

// MARK: - WeightedEdge
extension Route: WeightedEdge {}
