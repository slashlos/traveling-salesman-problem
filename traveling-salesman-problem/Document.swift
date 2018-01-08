//
//  TravelingSalesmanProblem.swift
//  traveling-salesman-problem
//
//  Created by Carlos Santiago on 1/4/18.
//  Copyright © 2018 David Nadoba. All rights reserved.
//

import Cocoa

class Document : NSDocument {
    
    var rsc: RouteSummaryController?

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainController")) as! NSWindowController
        self.addWindowController(windowController)
        let rvc = windowController.window?.contentViewController
        rsc = (rvc as! RouteViewController).routeSummaryController
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
        let dict = NSDictionary.init()
        dict.setValue(rsc?.routeSummary, forKey: "routeSummary")
        dict.setValue(rsc?.routeSteps, forKey: "routeSteps")
        dict.setValue(rsc?.useCurrentTimeAsDepatureTime, forKey: "useCurrentTimeAsDepatureTime")
        dict.setValue(rsc?.depatureTime, forKey: "depatureTime")
        if dict.write(to: url, atomically: true) {
            self.updateChangeCount(.changeCleared)
        }
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        do
        {
            let dict = NSDictionary.init(contentsOf: url)
            rsc?.routeSummary = dict?.value(forKey: "routeSummary") as? RouteSummary
            rsc?.routeSteps = dict?.value(forKey: "routeSteps") as! [RouteStep]
            rsc?.useCurrentTimeAsDepatureTime = ((dict?.value(forKey: "useCurrentTimeAsDepatureTime")) != nil)
            rsc?.depatureTime = dict?.value(forKey: "depatureTime") as! Date
            self.updateChangeCount(.changeCleared)
        }
    }
}
