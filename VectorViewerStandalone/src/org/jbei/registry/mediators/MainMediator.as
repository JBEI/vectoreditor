package org.jbei.registry.mediators
{
    import mx.collections.ArrayCollection;
    
    import org.jbei.lib.mappers.ORFMapper;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;
    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class MainMediator extends Mediator
    {
        private const NAME:String = "MainMediator";
        
        // Constructor
        public function MainMediator(viewComponent:Object=null)
        {
            super(NAME, viewComponent);
        }
        
        // Public Methods
        public override function listNotificationInterests():Array
        {
            return [Notifications.APPLICATION_FAILURE
                , Notifications.DATA_FETCHED
                , Notifications.FETCHING_DATA
            ];
        }
        
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.APPLICATION_FAILURE:
                    ApplicationFacade.getInstance().application.disableApplication(notification.getBody() as String);
                    
                    break;
                case Notifications.FETCHING_DATA:
                    Logger.getInstance().info(notification.getBody() as String);
                    
                    ApplicationFacade.getInstance().application.lock();
                    
                    break;
                case Notifications.DATA_FETCHED:
                    ApplicationFacade.getInstance().application.unlock();
                    
                    break;
            }
        }
    }		
}
