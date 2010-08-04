package org.jbei.registry.mediators
{
    import org.jbei.components.assemblyTableClasses.CaretEvent;
    import org.jbei.components.assemblyTableClasses.DataCell;
    import org.jbei.components.assemblyTableClasses.SelectionEvent;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.utils.StandaloneUtils;
    import org.jbei.registry.view.ui.assembly.AssemblyContentPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyContentPanelMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyContentPanelMediator";
        
        private var assemblyContentPanel:AssemblyContentPanel;
        
        // Constructor
        public function AssemblyContentPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyContentPanel = viewComponent as AssemblyContentPanel;
            
            assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            
            assemblyContentPanel.assemblyTable.addEventListener(CaretEvent.CARET_CHANGED, onAssemblyTableCaretChange);
            assemblyContentPanel.assemblyTable.addEventListener(SelectionEvent.SELECTION_CHANGED, onAssemblyTableSelectionChanged);
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.RANDOMIZE_ASSEMBLY_PROVIDER:
                    ApplicationFacade.getInstance().assemblyProvider = StandaloneUtils.standaloneRandomAssemblyProvider();
                    
                    assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
                    assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [Notifications.RANDOMIZE_ASSEMBLY_PROVIDER];
        }
        
        // Event Handler
        private function onAssemblyTableCaretChange(event:CaretEvent):void
        {
            if(event.cell is DataCell) {
                assemblyContentPanel.propertiesSequenceTextArea.text = (event.cell as DataCell).assemblyItem.sequence;
            } else {
                assemblyContentPanel.propertiesSequenceTextArea.text = "";
            }
        }
        
        private function onAssemblyTableSelectionChanged(event:SelectionEvent):void
        {
            // Not implemented yet
        }
    }
}