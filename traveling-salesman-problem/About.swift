//
//  About.swift
//  Helium
//
//  Created by Carlos D. Santiago on 12/11/17.
//  Copyright © Carlos D. Santiago.  All rights reserved.
//

import Foundation
import AppKit

let kTitleUtility =		16
let	kTitleNormal =		22

extension NSAttributedString {
    class func string(fromAsset: String) -> String {
        let asset = NSDataAsset.init(name: NSDataAsset.Name(rawValue: fromAsset))
        let data = NSData.init(data: (asset?.data)!)
        let text = String.init(data: data as Data, encoding: String.Encoding.utf8)
        
        return text!
    }
}

class AboutBoxController : NSViewController {
	
    @IBOutlet var toggleButton: NSButton!
    @IBOutlet var appNameButton: NSButton!
    @IBOutlet var appNameField: NSTextField!
    @IBOutlet var creditScroll: NSScrollView!
	@IBOutlet var creditsField: NSTextView!
    @IBOutlet var creditsButton: NSButton!
    @IBOutlet var versionButton: NSButton!
    @IBOutlet var creditSeparatorBox: NSBox!
    
    @IBOutlet var hideView: NSView!
    var hideRect: NSRect?
    var origRect: NSRect?
    
    @IBAction func toggleContent(_ sender: Any) {
        // Toggle content visibility
        if let window = self.view.window {
            let oldSize = window.contentView?.bounds.size
            var frame = window.frame
            if toggleButton.state == NSControl.StateValue.off {
                
                frame.origin.y += ((oldSize?.height)! - (hideRect?.size.height)!)
                window.setFrameOrigin(frame.origin)
                window.setContentSize((hideRect?.size)!)
                
                window.showsResizeIndicator = false
                window.minSize = NSMakeSize((hideRect?.size.width)!,(hideRect?.size.height)!+CGFloat(kTitleNormal))
                window.maxSize = window.minSize
                creditScroll.isHidden = true
            }
            else
            {
                let hugeSize = NSMakeSize(CGFloat(Float.greatestFiniteMagnitude), CGFloat(Float.greatestFiniteMagnitude))
                
                frame.origin.y += ((oldSize?.height)! - (origRect?.size.height)!)
                window.setFrameOrigin(frame.origin)
                window.setContentSize((origRect?.size)!)

                window.showsResizeIndicator = true
                window.minSize = NSMakeSize((origRect?.size.width)!,(origRect?.size.height)!+CGFloat(kTitleNormal))
                window.maxSize = hugeSize
                creditScroll.isHidden = false
            }
			showCredits()
        }
    }
    
    static var languageCycle: Int = 0//English, Deustch
    static let languageSuffix = [ "", "_DE", "_ES"]
    internal func showCredits() {
		
        let credits = ["README", "History", "LICENSE"];
        
        if AboutBoxController.creditsState >= AboutBoxController.maxStates
        {
            AboutBoxController.creditsState = 0
        }
        //	Setup our credits; if sender is nil, give 'em long history
        let creditsAsset = String.init(format: "%@%@",
                                       credits[AboutBoxController.creditsState],
                                       AboutBoxController.languageSuffix[AboutBoxController.languageCycle])
        let creditsString = NSAttributedString.string(fromAsset: creditsAsset)
        creditsField.string = creditsString
    }
    
	@IBAction func cycleCredits(_ sender: Any) {

        AboutBoxController.creditsState += 1

        if toggleButton.state == NSControl.StateValue.off {
            if AboutBoxController.creditsState >= AboutBoxController.creditsCount
            {
                AboutBoxController.creditsState = 0
            }
            creditsButton.title = copyrightStrings![AboutBoxController.creditsState % AboutBoxController.creditsCount]
        }
        else
        {
            showCredits()
        }
    }
    
    @IBAction func cycleLanguage(_ sender: Any) {
		
        let infoDictionary = (Bundle.main.infoDictionary)!

        AboutBoxController.languageCycle += 1
        if AboutBoxController.languageCycle >= AboutBoxController.maxLanguages
        {
            AboutBoxController.languageCycle = 0
        }
        Swift.print("language: \(AboutBoxController.languageCycle)")
        let appNameKey = String.init(format: "AppName%@",
                                     AboutBoxController.languageSuffix[AboutBoxController.languageCycle])
        appName = infoDictionary[appNameKey] as? String
        appNameButton.title = appName!
		if toggleButton.state == NSControl.StateValue.on {
			showCredits()
		}
    }
    
    @IBAction func toggleVersion(_ sender: Any) {
        
        AboutBoxController.versionState += 1
        if AboutBoxController.versionState >= AboutBoxController.maxStates
        {
            AboutBoxController.versionState = 0
        }

        let titles = [ versionData, versionLink, versionDate ]
        versionButton.title = titles[AboutBoxController.versionState]!

        let tooltip = [ "version", "build", "timestamp" ]
        versionButton.toolTip = tooltip[AboutBoxController.versionState];
    }

    var versionData: String? = nil
    var versionLink: String? = nil
    var versionDate: String? = nil

    var appName: String? = nil
    var versionString: String? = nil
    var copyrightStrings: [String]? = nil

    static var versionState: Int = 0
    static var creditsState: Int = 0
    static let maxStates: Int = 3
    static let creditsCount: Int = 2// DD, CDS ...
    static let maxLanguages: Int = 3

    override func viewWillAppear() {
        let theWindow = appNameButton.window

        //	We no need no sticking title!
        theWindow?.title = ""

        appNameButton.title = appName!
        versionButton.title = versionData!
        creditsButton.title = copyrightStrings![AboutBoxController.creditsState % AboutBoxController.creditsCount]

        if (appNameButton.window?.isVisible)! {
            creditsField.scroll(NSMakePoint( 0, 0 ))
        }
        // Version criteria to cycle thru
        AboutBoxController.versionState = -1
        toggleVersion(self)

        //  Credit criteria initially hidden
        AboutBoxController.creditsState = 0-1
        toggleButton.state = NSControl.StateValue.off
        cycleCredits(self)
        toggleContent(self)
        
        // Setup the window
        theWindow?.isExcludedFromWindowsMenu = true
        theWindow?.menu = nil
        theWindow?.center()

        //	Show the window
        appNameButton.window?.makeKeyAndOrderFront(self)

    }
    
    override func viewDidLoad() {
        //	Initially don't show history
        toggleButton.state = NSControl.StateValue.off
 
        //	Get the info dictionary (Info.plist)
        let infoDictionary = (Bundle.main.infoDictionary)!

        //	Get the app name field
        appName = infoDictionary[kCFBundleExecutableKey as String] as? String
        
        //	Setup the version to one we constrict
        versionString = String(format:"Version %@",
                               infoDictionary["CFBundleShortVersionString"] as! CVarArg)

        // Version criteria to cycle thru
        self.versionData = versionString;
        self.versionLink = String(format:"Build %@",
                                  infoDictionary["CFBuildNumber"] as! CVarArg)
        self.versionDate = infoDictionary["CFBuildDate"] as? String;

        //  Capture hide and show initial sizes
        hideRect = hideView.frame
        origRect = self.view.frame

        // Setup the copyrights field; each separated by "|"
        copyrightStrings = (infoDictionary["NSHumanReadableCopyright"] as? String)?.components(separatedBy: "|")
        toggleButton.state = NSControl.StateValue.off
    }
    
}
