//
//  ComplicationController.swift
//  TruePassWatchKitApp Extension
//
//  Created by Cliff Panos on 4/15/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        
        //Timeline can go backwards but not forwards
        
        handler([.backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil) //The timelineEndDate should be NOW since True Pass does not look into the future
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        
        let publicPrivacyBehavior = CLKComplicationPrivacyBehavior.showOnLockScreen
        
        handler(publicPrivacyBehavior)
    }
    
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        // Get the complication data from the extension delegate.
        //let myDelegate = WC.ext
        //var data : Dictionary = myDelegate.myComplicationData[complication]!
        
        var entry : CLKComplicationTimelineEntry?
        let now = Date()
        
        // Create the template and timeline entry.
        if complication.family == .modularSmall {
            //let longText = data[ComplicationTextData]
            //let shortText = data[ComplicationShortTextData]
            
            //let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
            //textTemplate.textProvider = CLKSimpleTextProvider(text: longText, shortText: shortText)
            let imageTemplate = CLKComplicationTemplateModularSmallSimpleImage()
            imageTemplate.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "clearIcon"))
            imageTemplate.tintColor = UIColor.TrueColors.lightBlue
            
            // Create the entry.

            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: imageTemplate)
            
        } else {
            // ...configure entries for other complication families.
        }
        
        
        // Call the handler with the current timeline entry
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
