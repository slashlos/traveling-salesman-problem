//
//  TravelingSalesmanProblem.swift
//  traveling-salesman-problem
//
//  Created by Carlos Santiago on 1/4/18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Cocoa
import QuickLook
import MapKit

extension NSImage {
	
	func resize(w: Int, h: Int) -> NSImage {
		let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
		let newImage = NSImage(size: destSize)
		newImage.lockFocus()
		self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
				  from: NSMakeRect(0, 0, self.size.width, self.size.height),
				  operation: .sourceOver,
				  fraction: CGFloat(1))
		newImage.unlockFocus()
		newImage.size = destSize
		return NSImage(data: newImage.tiffRepresentation!)!
	}
}

class Document : NSDocument {
    
    var rvc: RouteViewController?
    var rsc: RouteSummaryController?
    
    var transportType: Int = 0
    var routeWeight: Int = 0
    var shouldRequestAlternativRoutes: Bool = true
    var routeCalculationAlgorithm: Int = 0
    var useCurrentTimeAsDepatureTime: Bool = true
    var depatureTime: Date = Date()
    var waypoints: [Any] = []
    
    var departureTime: Date = Date()
    var expectedArivalTime: TimeInterval = 0
    var expectedTravelTime: TimeInterval = 0
    var distance: Double = 0
    var steps: [Any] = []
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

	override func defaultDraftName() -> String {
		return "Traveling Salesman Problem"
	}
	
	var docIconImage: NSImage? {
		get {
			let tmpImage = NSImage.init(named: NSImage.Name(rawValue: "docIcon"))
			let docImage = tmpImage?.resize(w: 32, h: 32)
			return docImage
		}
	}

    override func showWindows() {
        if waypoints.count > 0 {
            rsc?.depatureTime = depatureTime
            rsc?.useCurrentTimeAsDepatureTime = false
            rvc?.transportType = transportType
            rvc?.routeWeight = routeWeight
            rvc?.shouldRequestAlternativRoutes = shouldRequestAlternativRoutes
            rvc?.routeCalculationAlgorithm = routeCalculationAlgorithm
            
            for wp in waypoints {
                let point = wp as! Dictionary<String,Any>
                let location = CLLocationCoordinate2D.init(latitude: point["latitude"]! as! CLLocationDegrees,
                                                           longitude: point["longitude"]! as! CLLocationDegrees)
                let waypoint = Waypoint.init(location: location)
                let placemark = MKPlacemark.init(coordinate: location,
                                                 addressDictionary: point["address"] as? [String : Any])
                waypoint.placemark = placemark

                rvc?.waypointManager.add(waypoint)
            }

            if steps.count > 0 {
                rsc?.routeSteps = []

                for rs in steps {
                    let step = rs as! Dictionary<String,Any>
                    let route = step["route"] as! Dictionary<String,Any>
                    
                    let src = route["source"] as! Dictionary<String,Any>
                    let source = Waypoint.init(location: CLLocationCoordinate2D.init(latitude: src["latitude"]! as! CLLocationDegrees,
                                                                                     longitude: src["longitude"]! as! CLLocationDegrees))
                    source.placemark = MKPlacemark.init(coordinate: source.location, addressDictionary: src["address"] as? [String : Any])
                    
                    let dst = route["destination"] as! Dictionary<String,Any>
                    let destination = Waypoint.init(location: CLLocationCoordinate2D.init(latitude: dst["latitude"]! as! CLLocationDegrees,
                                                                                          longitude: dst["longitude"]! as! CLLocationDegrees))
                    destination.placemark = MKPlacemark.init(coordinate: destination.location, addressDictionary: dst["address"] as? [String : Any])

                    let mkRoute = MKRoute.init()
                    let routeStep = RouteStep.init(route: Route.init(source: source, destination: destination, mkRoute: mkRoute, weightedBy: RouteWeight(rawValue: routeWeight)!),
                                                   depatureTime: step["depatureTime"] as! Date)
                    rsc?.routeSteps.append(routeStep)
                }
            }
            
            rsc?.updateRouteSummary()
            rsc?.useCurrentTimeAsDepatureTime = useCurrentTimeAsDepatureTime
        }
        super.showWindows()
    }
        
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainController")) as! NSWindowController
        self.addWindowController(windowController)
        rvc = windowController.window?.contentViewController as? RouteViewController
        rsc = rvc?.routeSummaryController
    }
    
    override func data(ofType typeName: String) throws -> Data {
        var dict = Dictionary<String,Any>()
        dict["depatureTime"] = rsc?.depatureTime
        dict["useCurrentTimeAsDepatureTime"] = rsc?.useCurrentTimeAsDepatureTime
        dict["transportType"] = rvc?.transportType
        dict["routeWeight"] = rvc?.routeWeight
        dict["shouldRequestAlternativRoutes"] = rvc?.shouldRequestAlternativRoutes
        dict["routeCalculationAlgorithm"] = rvc?.routeCalculationAlgorithm

        var waypoints = [Any]()
        for waypoint in (rsc?.routeSummary?.waypoints)! {
            let point = [ "latitude":waypoint.location.latitude,
                          "longitude":waypoint.location.longitude,
                          "address":waypoint.placemark?.addressDictionary as Any ] as [String : Any]
            waypoints.append(point)
        }
        dict["waypoints"] = waypoints
        
        var steps = [Any]()
        for routeStep: RouteStep in (rsc?.routeSteps)! {
            var step = ["arrivalTime": routeStep.arrivalTime,
                        "depatureTime": routeStep.depatureTime,
                        "distance": routeStep.distance,
                        "expectedTravelTime": routeStep.expectedTravelTime] as [String : Any]
            var route = [String:Any]()
            let source = ["latitude":routeStep.source.location.latitude,
                          "longitude":routeStep.source.location.longitude,
                          "address":routeStep.source.placemark?.addressDictionary as Any ] as [String : Any]
            route["source"] = source
            
            let destination = [ "latitude":routeStep.destination.location.latitude,
                                "longitude":routeStep.destination.location.longitude,
                                "name":routeStep.destination.placemark?.name ?? routeStep.destination.location.formatted,
                                "address":routeStep.destination.placemark?.addressDictionary as Any ] as [String : Any]
            route["destination"] = destination
            
            step["route"] = route
            steps.append(step)
        }
        dict["steps"] = steps
        
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        return data
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String,Any>
        do
        {
            transportType = dict["transportType"] as! Int
            routeWeight = dict["routeWeight"] as! Int
            shouldRequestAlternativRoutes = dict["shouldRequestAlternativRoutes"] as! Bool
            routeCalculationAlgorithm = dict["routeCalculationAlgorithm"] as! Int
            depatureTime = dict["depatureTime"] as! Date
            useCurrentTimeAsDepatureTime = dict["useCurrentTimeAsDepatureTime"] as! Bool
            
            waypoints = (dict["waypoints"] as? [Any])!
            steps = (dict["steps"] as? [Any])!
        }
    }
    
    required init(coder decoder: NSCoder) {
        rsc?.routeSummary = decoder.decodeObject(forKey: "routeSummary") as? RouteSummary
        rsc?.routeSteps = (decoder.decodeObject(forKey: "routeSteps") as? [RouteStep])!
        rsc?.useCurrentTimeAsDepatureTime = decoder.decodeBool(forKey: "useCurrentTimeAsDepatureTime")
        rsc?.depatureTime = decoder.decodeObject(forKey: "depatureTime") as! Date
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(rsc?.routeSummary, forKey: "routeSummary")
        coder.encode(rsc?.routeSteps, forKey: "routeSteps")
        coder.encode(rsc?.useCurrentTimeAsDepatureTime, forKey: "useCurrentTimeAsDepatureTime")
        coder.encode(rsc?.depatureTime, forKey: "departureTime")
        super.encodeRestorableState(with: coder)
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        let data = try self.data(ofType: typeName)
        do
        {
            try data.write(to: url)
            self.updateChangeCount(.changeCleared)
        }
     }
    
    override func read(from url: URL, ofType typeName: String) throws {
        let data = try Data.init(contentsOf: url)
        do
        {
            try self.read(from: data, ofType: typeName)
        }
    }
}
