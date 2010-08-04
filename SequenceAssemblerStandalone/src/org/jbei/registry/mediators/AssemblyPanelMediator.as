package org.jbei.registry.mediators
{
    import flash.events.MouseEvent;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.assembly.AssemblyPanel;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyPanelMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyPanelMediator";
        
        private var assemblyPanel:AssemblyPanel;
        
        // Constructor
        public function AssemblyPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyPanel = viewComponent as AssemblyPanel;
            
            ApplicationFacade.getInstance().registerMediator(new AssemblyMenuMediator(assemblyPanel.assemblyMenu));
            ApplicationFacade.getInstance().registerMediator(new AssemblyControlBarMediator(assemblyPanel.assemblyControlBar));
            ApplicationFacade.getInstance().registerMediator(new AssemblyContentPanelMediator(assemblyPanel.assemblyContentPanel));
            ApplicationFacade.getInstance().registerMediator(new AssemblyStatusBarMediator(assemblyPanel.assemblyStatusBar));
        }
    }
}