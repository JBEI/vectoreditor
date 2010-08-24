package org.jbei.registry.mediators
{
    import mx.events.MenuEvent;
    
    import org.jbei.lib.ui.menu.MenuItem;
    import org.jbei.lib.ui.menu.MenuItemEvent;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.MainMenu;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class MainMenuMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "MainMenuMediator";
        
        private var mainMenu:MainMenu;
        
        // Constructor
        public function MainMenuMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            mainMenu = viewComponent as MainMenu;
            
            mainMenu.addEventListener(MainMenu.SAVE, onSave);
            mainMenu.addEventListener(MainMenu.SAVE_AS, onSaveAs);
            mainMenu.addEventListener(MainMenu.IMPORT_SEQUENCE, onImportSequence);
            mainMenu.addEventListener(MainMenu.ADD_TRACE, onAddTrace);
            mainMenu.addEventListener(MainMenu.SHOW_PROPERTIES_DIALOG, onShowProperties);
            mainMenu.addEventListener(MainMenu.COPY, onCopy);
            mainMenu.addEventListener(MainMenu.SELECT_ALL, onSelectAll);
            mainMenu.addEventListener(MainMenu.CIRCULAR_VIEW, onCircularView);
            mainMenu.addEventListener(MainMenu.LINEAR_VIEW, onLinearView);
            mainMenu.addEventListener(MainMenu.SHOW_FEATURES, onShowFeatures);
            mainMenu.addEventListener(MainMenu.GO_REPORT_BUG_WEB_LINK, onGoReportBug);
            mainMenu.addEventListener(MainMenu.GO_SUGGEST_FEATURE_WEB_LINK, onGoSuggestFeature);
            mainMenu.addEventListener(MainMenu.SHOW_ABOUT_DIALOG, onShowAboutDialog);
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.SWITCH_TO_PIE_VIEW:
                    mainMenu.updateSequenceViewType("pie");
                    
                    break;
                case Notifications.SWITCH_TO_RAIL_VIEW:
                    mainMenu.updateSequenceViewType("rail");
                    
                    break;
                case Notifications.SHOW_FEATURES:
                    mainMenu.updateShowFeatures(notification.getBody() as Boolean);
                    
                    break;
                case Notifications.SELECTION_CHANGED:
                    var selectionPositions:Array = notification.getBody() as Array;
                    
                    if(selectionPositions && selectionPositions.length == 2 && selectionPositions[0] > -1 && selectionPositions[1] > -1) {
                        mainMenu.updateCopy(true);
                    } else {
                        mainMenu.updateCopy(false);
                    }
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.SWITCH_TO_PIE_VIEW
                , Notifications.SWITCH_TO_RAIL_VIEW
                , Notifications.SHOW_FEATURES
                , Notifications.SELECTION_CHANGED
            ];
        }
        
        // Event Handlers
        private function onSave(event:MenuItemEvent):void {
            sendNotification(Notifications.SAVE_PROJECT);
        }
        
        private function onSaveAs(event:MenuItemEvent):void {
            sendNotification(Notifications.SAVE_AS_PROJECT);
        }
        
        private function onShowProperties(event:MenuItemEvent):void {
            sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
        }
        
        private function onCopy(event:MenuItemEvent):void {
            sendNotification(Notifications.COPY);
        }
        
        private function onSelectAll(event:MenuItemEvent):void {
            sendNotification(Notifications.SELECT_ALL);
        }
        
        private function onCircularView(event:MenuItemEvent):void {
            sendNotification(Notifications.SWITCH_TO_PIE_VIEW);
        }
        
        private function onLinearView(event:MenuItemEvent):void {
            sendNotification(Notifications.SWITCH_TO_RAIL_VIEW);
        }
        
        private function onGoReportBug(event:MenuItemEvent):void {
            sendNotification(Notifications.GO_REPORT_BUG);
        }
        
        private function onGoSuggestFeature(event:MenuItemEvent):void {
            sendNotification(Notifications.GO_SUGGEST_FEATURE);
        }
        
        private function onShowAboutDialog(event:MenuItemEvent):void {
            sendNotification(Notifications.SHOW_ABOUT_DIALOG);
        }
        
        private function onShowFeatures(event:MenuItemEvent):void
        {
            sendNotification(Notifications.SHOW_FEATURES, (event.menuItem as MenuItem).toggled);
        }
        
        private function onImportSequence(event:MenuItemEvent):void
        {
            sendNotification(Notifications.IMPORT_SEQUENCE);
        }
        
        private function onAddTrace(event:MenuItemEvent):void
        {
            sendNotification(Notifications.IMPORT_TRACE);
        }
    }
}