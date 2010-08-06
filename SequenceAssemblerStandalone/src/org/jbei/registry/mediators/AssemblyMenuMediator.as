package org.jbei.registry.mediators
{
    import org.jbei.lib.ui.menu.MenuItemEvent;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.assembly.AssemblyMenu;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyMenuMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyMenuMediator";
        
        private var assemblyMenu:AssemblyMenu;
        
        // Constructor
        public function AssemblyMenuMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyMenu = viewComponent as AssemblyMenu;
            
            assemblyMenu.addEventListener(AssemblyMenu.SAVE, onSave);
            assemblyMenu.addEventListener(AssemblyMenu.SAVE_AS, onSaveAs);
            assemblyMenu.addEventListener(AssemblyMenu.SHOW_PROPERTIES_DIALOG, onShowPropertiesDialog);
            assemblyMenu.addEventListener(AssemblyMenu.UNDO, onUndo);
            assemblyMenu.addEventListener(AssemblyMenu.REDO, onRedo);
            assemblyMenu.addEventListener(AssemblyMenu.COPY, onCopy);
            assemblyMenu.addEventListener(AssemblyMenu.CUT, onCut);
            assemblyMenu.addEventListener(AssemblyMenu.PASTE, onPaste);
            assemblyMenu.addEventListener(AssemblyMenu.SELECT_ALL, onSelectAll);
            assemblyMenu.addEventListener(AssemblyMenu.DELETE, onDelete);
            assemblyMenu.addEventListener(AssemblyMenu.SHOW_ABOUT_DIALOG, onShowAboutDialog);
            assemblyMenu.addEventListener(AssemblyMenu.GO_SUGGEST_FEATURE_WEB_LINK, onGoSuggestFeatureWebLink);
            assemblyMenu.addEventListener(AssemblyMenu.GO_REPORT_BUG_WEB_LINK, onGoReportBugWebLink);
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.ACTION_STACK_CHANGED:
                    updateUndoRedoMenuItems();
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [Notifications.ACTION_STACK_CHANGED];
        }
        
        // Event Handlers
        private function onSave(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SAVE_PROJECT);
        }
        
        private function onSaveAs(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SAVE_AS_PROJECT);
        }
        
        private function onShowPropertiesDialog(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
        }
        
        private function onUndo(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_UNDO);
        }
        
        private function onRedo(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_REDO);
        }
        
        private function onCopy(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_COPY);
        }
        
        private function onCut(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_CUT);
        }
        
        private function onPaste(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_PASTE);
        }
        
        private function onSelectAll(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_SELECT_ALL);
        }
        
        private function onDelete(event:MenuItemEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_DELETE);
        }
        
        private function onShowAboutDialog(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SHOW_ABOUT_DIALOG);
        }
        
        private function onGoSuggestFeatureWebLink(event:MenuItemEvent):void
        {
            sendNotification(Notifications.GO_SUGGEST_FEATURE);
        }
        
        private function onGoReportBugWebLink(event:MenuItemEvent):void
        {
            sendNotification(Notifications.GO_REPORT_BUG);
        }
        
        // Private Methods
        private function  updateUndoRedoMenuItems():void
        {
            assemblyMenu.updateUndoMenuItem(!ApplicationFacade.getInstance().actionStack.undoStackIsEmpty);
            assemblyMenu.updateRedoMenuItem(!ApplicationFacade.getInstance().actionStack.redoStackIsEmpty);
        }
    }
}