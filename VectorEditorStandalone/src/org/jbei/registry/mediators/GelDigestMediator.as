package org.jbei.registry.mediators
{
    import flash.display.FrameLabel;
    import flash.events.MouseEvent;
    
    import mx.controls.List;
    
    import org.jbei.bio.sequence.dna.DigestionFragment;
    import org.jbei.components.gelDigestClasses.BandEvent;
    import org.jbei.registry.view.dialogs.gelDigest.GelDigestSimulation;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    public class GelDigestMediator extends Mediator
    {
        public static const NAME:String = "GelDigestMediator";
        
        private var gelDigest:GelDigestSimulation;
        
        // Constructor
        public function GelDigestMediator(viewComponent:Object=null)
        {
            super(NAME, viewComponent);
            
            gelDigest = viewComponent as GelDigestSimulation;
            gelDigest.addEventListener(BandEvent.BAND_SELECTED, onBandSelected);
        }
        
        // Public Methods
        public override function listNotificationInterests():Array
        {
            return []; // doesn't need to respond to any notifications
        }
        
        public override function handleNotification(notification:INotification):void
        {
            //nothing to do
        }
        
        // Event Handlers
        private function onBandSelected(event:BandEvent):void
        {
            trace(event.digestionFragment.startRE ? event.digestionFragment.startRE.name : "-", event.digestionFragment.endRE ? event.digestionFragment.endRE.name : "-");
            // TODO: highlight the band
            // TODO: select the fragment from fragment lengths list
            // TODO: send selection changed notification to facade
        }
            
    }
}