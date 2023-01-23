import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
        
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
        
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
                switch complication.family {
            
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            let image = UIImage(named: "Complication/Modular")
            template.imageProvider = CLKImageProvider(onePieceImage: image!)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
           
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            let image = UIImage(named: "Complication/Utilitarian")
            template.imageProvider = CLKImageProvider(onePieceImage: image!)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            let image = UIImage(named: "Complication/Circular")
            template.imageProvider = CLKImageProvider(onePieceImage: image!)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            
        default:
            handler(nil)
    
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
                handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
                handler(nil)
    }
    
        
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
                handler(nil)
    }
    
}

