package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.events.ItemClickEvent;
    
    import org.jbei.registry.Notifications;
    import org.jbei.registry.view.ui.MainControlBar;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class MainControlBarMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "MainControlBarMediator";
        
        private var mainControlBar:MainControlBar;
        
        // Constructor
        public function MainControlBarMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            mainControlBar = viewComponent as MainControlBar;
            
            mainControlBar.saveButton.addEventListener(MouseEvent.CLICK, onSaveButtonClick);
            mainControlBar.importSequenceButton.addEventListener(MouseEvent.CLICK, onImportSequenceButtonClick);
            mainControlBar.propertiesButton.addEventListener(MouseEvent.CLICK, onPropertiesButtonClick);
            mainControlBar.showFeaturesButton.addEventListener(MouseEvent.CLICK, onShowFeaturesButtonClick);
            mainControlBar.viewToggleButtonBar.addEventListener(ItemClickEvent.ITEM_CLICK, onChangeViewButtonClick);
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.SWITCH_TO_PIE_VIEW:
                    updateSequenceViewButtons("pie");
                    
                    break;
                case Notifications.SWITCH_TO_RAIL_VIEW:
                    updateSequenceViewButtons("rail");
                    
                    break;
                case Notifications.SHOW_FEATURES:
                    updateShowFeaturesButton(notification.getBody() as Boolean);
                    
                    break;
                case Notifications.SELECTION_CHANGED:
                    var range:Array = notification.getBody() as Array;
                    
                    if(!range || range.length != 2 || range[0] == -1 || range[1] == -1) {
                        mainControlBar.updateCopyButtonState(false);
                    } else {
                        mainControlBar.updateCopyButtonState(true);
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
        private function onPieButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SWITCH_TO_PIE_VIEW);
        }
        
        private function onRailButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SWITCH_TO_RAIL_VIEW);
        }
        
        private function onSaveButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SAVE_PROJECT);
        }
        
        private function onImportSequenceButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.IMPORT_SEQUENCE);
        }
        
        private function onPropertiesButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SHOW_PROPERTIES_DIALOG);
        }
        
        private function onShowFeaturesButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.SHOW_FEATURES, mainControlBar.showFeaturesButton.selected);
        }
        
        private function onCopy(event:MouseEvent):void
        {
            sendNotification(Notifications.COPY);
        }
        
        private function onChangeViewButtonClick(event:ItemClickEvent):void
        {
            if(event.index == 0) { // Circular View
                sendNotification(Notifications.SWITCH_TO_PIE_VIEW);
            } else if (event.index == 1) { // Linear View
                sendNotification(Notifications.SWITCH_TO_RAIL_VIEW);
            }
        }
        
        // Private Methods
        private function updateSequenceViewButtons(type:String):void
        {
            if(!type || type == "") {
                return;
            }
            
            if(type == "rail") {
                if(mainControlBar.viewToggleButtonBar.selectedIndex != 1) {
                    mainControlBar.viewToggleButtonBar.selectedIndex = 1;
                }
            }
            
            if(type == "pie") {
                if(mainControlBar.viewToggleButtonBar.selectedIndex != 0) {
                    mainControlBar.viewToggleButtonBar.selectedIndex = 0;
                }
            }
        }
        
        private function updateShowFeaturesButton(showFeatures:Boolean):void
        {
            mainControlBar.showFeaturesButton.selected = showFeatures;
        }
    }
}