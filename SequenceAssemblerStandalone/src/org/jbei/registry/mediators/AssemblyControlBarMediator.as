package org.jbei.registry.mediators
{
    import flash.events.MouseEvent;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.assembly.AssemblyControlBar;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyControlBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyControlBarMediator";
        
        private var assemblyControlBar:AssemblyControlBar;
        
        // Constructor
        public function AssemblyControlBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyControlBar = viewComponent as AssemblyControlBar;
            
            assemblyControlBar.randomizeButton.addEventListener(MouseEvent.CLICK, onRandomizeButtonClick);
        }
        
        // Event Handlers
        private function onRandomizeButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.RANDOMIZE_ASSEMBLY_PROVIDER);
        }
    }
}