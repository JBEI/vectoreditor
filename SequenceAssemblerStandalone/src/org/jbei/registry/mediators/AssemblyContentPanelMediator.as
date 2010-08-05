package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.TextInput;
    import mx.utils.StringUtil;
    
    import org.jbei.components.assemblyTableClasses.CaretEvent;
    import org.jbei.components.assemblyTableClasses.Cell;
    import org.jbei.components.assemblyTableClasses.DataCell;
    import org.jbei.components.assemblyTableClasses.SelectionEvent;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
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
        private var selectedCell:Cell;
        private var focusSelectedCell:Cell;
        private var selectedCellData:String;
        private var currentCellData:String;
        
        // Constructor
        public function AssemblyContentPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyContentPanel = viewComponent as AssemblyContentPanel;
            
            assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().project.assemblyProvider;
            assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().project.assemblyProvider;
            
            assemblyContentPanel.assemblyTable.addEventListener(CaretEvent.CARET_CHANGED, onAssemblyTableCaretChange);
            assemblyContentPanel.assemblyTable.addEventListener(SelectionEvent.SELECTION_CHANGED, onAssemblyTableSelectionChanged);
            assemblyContentPanel.runButton.addEventListener(MouseEvent.CLICK, onRunButtonMouseClick);
            assemblyContentPanel.propertiesSequenceTextArea.addEventListener(FocusEvent.FOCUS_IN, onPropertiesTextAreaFocusIn);
            assemblyContentPanel.propertiesSequenceTextArea.addEventListener(FocusEvent.FOCUS_OUT, onPropertiesTextAreaFocusOut);
            assemblyContentPanel.propertiesSequenceTextArea.addEventListener(Event.CHANGE, onPropertiesTextAreaChange);
            
            // TODO: Refactor this
            var algorithms:ArrayCollection = new ArrayCollection([{label:"Johnny 5", data:"j5"}]);
            assemblyContentPanel.algorithmsComboBox.dataProvider = algorithms;
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.RANDOMIZE_ASSEMBLY_PROVIDER:
                    ApplicationFacade.getInstance().project = StandaloneUtils.standaloneRandomAssemblyProject();
                    
                    assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().project.assemblyProvider;
                    assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().project.assemblyProvider;
                    
                    break;
                case Notifications.ASSEMBLY_COPY:
                    // Broadcasting COPY event
                    assemblyContentPanel.assemblyTable.dispatchEvent(new Event(Event.COPY, true, true));
                    
                    break;
                case Notifications.ASSEMBLY_CUT:
                    // Broadcasting COPY event
                    assemblyContentPanel.assemblyTable.dispatchEvent(new Event(Event.CUT, true, true));
                    
                    break;
                case Notifications.ASSEMBLY_PASTE:
                    Alert.show("To use the Paste command in this browser, please press Ctrl+V.");
                    
                    break;
                case Notifications.ASSEMBLY_DELETE:
                    assemblyContentPanel.assemblyTable.deleteSelected();
                    
                    break;
                case Notifications.ASSEMBLY_SELECT_ALL:
                    assemblyContentPanel.assemblyTable.selectAll();
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [Notifications.RANDOMIZE_ASSEMBLY_PROVIDER
                , Notifications.ASSEMBLY_COPY
                , Notifications.ASSEMBLY_CUT
                , Notifications.ASSEMBLY_PASTE
                , Notifications.ASSEMBLY_SELECT_ALL
                , Notifications.ASSEMBLY_DELETE];
        }
        
        // Event Handler
        private function onRunButtonMouseClick(event:MouseEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_ACTION_MESSAGE, "Building permutation set ...");
            sendNotification(Notifications.RUN_ASSEMBLY);
        }
        
        private function onAssemblyTableCaretChange(event:CaretEvent):void
        {
            selectedCell = event.cell;
            
            if(selectedCell is DataCell) {
                assemblyContentPanel.propertiesSequenceTextArea.text = (selectedCell as DataCell).assemblyItem.sequence;
            } else {
                assemblyContentPanel.propertiesSequenceTextArea.text = "";
            }
            
            sendNotification(Notifications.ASSEMBLY_TABLE_CARET_POSITION_CHANGED, selectedCell);
        }
        
        private function onAssemblyTableSelectionChanged(event:SelectionEvent):void
        {
            // Not implemented yet
        }
        
        private function onPropertiesTextAreaFocusIn(event:FocusEvent):void
        {
            if(!selectedCell || !(selectedCell is Cell)) {
                focusSelectedCell = null;
                
                return;
            }
            
            focusSelectedCell = selectedCell;
            
            if(focusSelectedCell is DataCell) {
                selectedCellData = (focusSelectedCell as DataCell).assemblyItem.sequence;
            } else {
                selectedCellData = "";
            }
        }
        
        private function onPropertiesTextAreaFocusOut(event:FocusEvent):void
        {
            if(!focusSelectedCell || currentCellData == null) {
                return;
            }
            
            var assemblyProvider:AssemblyProvider = ApplicationFacade.getInstance().project.assemblyProvider;
            
            if(focusSelectedCell is DataCell) {
                var selectedDataCell:DataCell = focusSelectedCell as DataCell;
                
                if(selectedCellData != currentCellData) {
                    assemblyProvider.updateAssemblyItem(selectedDataCell.assemblyItem, StringUtil.trim(currentCellData));
                }
            } else if(focusSelectedCell is Cell) {
                var cellData:String = StringUtil.trim(currentCellData);
                
                if(cellData != "") {
                    assemblyProvider.addAssemblyItem(assemblyProvider.bins[focusSelectedCell.column.index], new AssemblyItem(cellData));
                }
            }
            
            currentCellData = null;
            focusSelectedCell = null;
            selectedCellData = null;
        }
        
        private function onPropertiesTextAreaChange(event:Event):void
        {
            currentCellData = assemblyContentPanel.propertiesSequenceTextArea.text;
        }
    }
}