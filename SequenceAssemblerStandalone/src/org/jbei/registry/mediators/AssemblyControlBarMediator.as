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
            assemblyControlBar.saveButton.addEventListener(MouseEvent.CLICK, onSaveButtonClick);
            assemblyControlBar.copyButton.addEventListener(MouseEvent.CLICK, onCopyButtonClick);
            assemblyControlBar.cutButton.addEventListener(MouseEvent.CLICK, onCutButtonClick);
            assemblyControlBar.pasteButton.addEventListener(MouseEvent.CLICK, onPasteButtonClick);
            assemblyControlBar.undoButton.addEventListener(MouseEvent.CLICK, onUndoButtonClick);
            assemblyControlBar.redoButton.addEventListener(MouseEvent.CLICK, onRedoButtonClick);
            assemblyControlBar.propertiesButton.addEventListener(MouseEvent.CLICK, onPropertiesButtonClick);
        }
        
        // Event Handlers
        private function onSaveButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SAVE_PROJECT);
        }
        
        private function onPropertiesButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
        }
        
        private function onUndoButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_UNDO);
        }
        
        private function onRedoButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_REDO);
        }
        
        private function onCopyButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_COPY);
        }
        
        private function onCutButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_CUT);
        }
        
        private function onPasteButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_PASTE);
        }
        
        private function onRandomizeButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.RANDOMIZE_ASSEMBLY_PROVIDER);
        }
    }
}