//
//  WindowController.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 09/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSSearchFieldDelegate {
    
    @IBOutlet weak var searchField: NSSearchField!
    override var document: AnyObject? {
        didSet {
            Swift.print("doc is now \(String(describing: self.document))")
        }
    }
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    @IBAction func didSearch(_ sender: NSSearchField) {
        
    }
    
}
