package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.net.FileReference;
    import flash.ui.MouseCursor;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.TextInput;
    import mx.events.CloseEvent;
    import mx.utils.StringUtil;
    
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.dna.DNASequence;
    import org.jbei.components.assemblyTableClasses.CaretEvent;
    import org.jbei.components.assemblyTableClasses.Cell;
    import org.jbei.components.assemblyTableClasses.DataCell;
    import org.jbei.components.assemblyTableClasses.NullCell;
    import org.jbei.components.assemblyTableClasses.SelectionEvent;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.AssemblyBin;
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.FeaturedDNASequence;
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
        private var importSequenceFileReference:FileReference;
        
        // Constructor
        public function AssemblyContentPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            assemblyContentPanel = viewComponent as AssemblyContentPanel;
            
            assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            
            assemblyContentPanel.assemblyTable.addEventListener(CaretEvent.CARET_CHANGED, onAssemblyTableCaretChange);
            assemblyContentPanel.assemblyTable.addEventListener(SelectionEvent.SELECTION_CHANGED, onAssemblyTableSelectionChanged);
            assemblyContentPanel.runButton.addEventListener(MouseEvent.CLICK, onRunButtonMouseClick);
            assemblyContentPanel.propertiesSequenceTextArea.addEventListener(Event.CHANGE, onPropertiesSequenceTextAreaChange);
            assemblyContentPanel.propertiesNameTextInput.addEventListener(Event.CHANGE, onPropertiesNameTextInputChange);
            assemblyContentPanel.updatePropertiesButton.addEventListener(MouseEvent.CLICK, onUpdatePropertiesButtonClick);
            assemblyContentPanel.clearPropertiesButton.addEventListener(MouseEvent.CLICK, onClearPropertiesButtonClick);
            assemblyContentPanel.importPropertiesButton.addEventListener(MouseEvent.CLICK, onImportPropertiesButtonClick);
            
            // TODO: Refactor this
            var algorithms:ArrayCollection = new ArrayCollection([{label:"Johnny 5", data:"j5"}]);
            assemblyContentPanel.algorithmsComboBox.dataProvider = algorithms;
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.RANDOMIZE_ASSEMBLY_PROVIDER:
                    ApplicationFacade.getInstance().loadProject(StandaloneUtils.standaloneRandomAssemblyProject());
                    
                    assemblyContentPanel.assemblyTable.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
                    assemblyContentPanel.assemblyRail.assemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
                    
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
                case Notifications.ASSEMBLY_PROVIDER_CHANGED:
                    var assemblyProvider:AssemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
                    
                    assemblyContentPanel.assemblyTable.assemblyProvider = assemblyProvider;
                    assemblyContentPanel.assemblyRail.assemblyProvider = assemblyProvider;
                    
                    break;
                case Notifications.PARSED_IMPORT_SEQUENCE_FILE:
                    if(selectedCell) {
                        if(notification.getBody() && notification.getBody() is FeaturedDNASequence) {
                            var importedFeaturedDNASequence:FeaturedDNASequence = notification.getBody() as FeaturedDNASequence;
                            
                            if(selectedCell is DataCell) {
                                var selectedAssemblyItem:AssemblyItem = (selectedCell as DataCell).assemblyItem;
                                
                                selectedAssemblyItem.name = importedFeaturedDNASequence.name;
                                selectedAssemblyItem.sequence = importedFeaturedDNASequence;
                            } else if(selectedCell is Cell) {
                                var newAssemblyItem:AssemblyItem = new AssemblyItem(importedFeaturedDNASequence.name, importedFeaturedDNASequence);
                                
                                ApplicationFacade.getInstance().assemblyProvider.addAssemblyItem(ApplicationFacade.getInstance().assemblyProvider.bins[selectedCell.column.index], newAssemblyItem);
                            }
                        } else {
                            Alert.show("Failed to parse! Imported file has unsupported format.", "Failed to parse file!");
                        }
                    }
                    
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
                , Notifications.ASSEMBLY_DELETE
                , Notifications.ASSEMBLY_PROVIDER_CHANGED
                , Notifications.PARSED_IMPORT_SEQUENCE_FILE];
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
                assemblyContentPanel.propertiesNameTextInput.text = (selectedCell as DataCell).assemblyItem.name;
                assemblyContentPanel.propertiesSequenceTextArea.text = (selectedCell as DataCell).assemblyItem.sequence.sequence;
            } else {
                assemblyContentPanel.propertiesNameTextInput.text = "";
                assemblyContentPanel.propertiesSequenceTextArea.text = "";
            }
            
            updateUpdateButtonState(false);
            
            sendNotification(Notifications.ASSEMBLY_TABLE_CARET_POSITION_CHANGED, selectedCell);
        }
        
        private function onAssemblyTableSelectionChanged(event:SelectionEvent):void
        {
            // Not implemented yet
        }
        
        private function onPropertiesNameTextInputChange(event:Event):void
        {
            updateUpdateButtonState(true);
        }
        
        private function onPropertiesSequenceTextAreaChange(event:Event):void
        {
            updateUpdateButtonState(true);
        }
        
        private function onUpdatePropertiesButtonClick(event:MouseEvent):void
        {
            var assemblyProvider:AssemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            
            var currentSequence:String = StringUtil.trim(assemblyContentPanel.propertiesSequenceTextArea.text);
            var currentName:String = StringUtil.trim(assemblyContentPanel.propertiesNameTextInput.text);
            
            if(selectedCell is DataCell) {
                assemblyProvider.updateAssemblyItem((selectedCell as DataCell).assemblyItem, currentName, new FeaturedDNASequence("", currentSequence));
            } else if(selectedCell is Cell) {
                if(currentSequence != "" || currentName != "") {
                    assemblyProvider.addAssemblyItem(assemblyProvider.bins[selectedCell.column.index], new AssemblyItem(currentName, new FeaturedDNASequence("", currentSequence)));
                }
            }
        }
        
        private function onClearPropertiesButtonClick(event:MouseEvent):void
        {
            if(selectedCell is DataCell) {
                Alert.show("Are you sure you want to clear selected item?", "Clear item", Alert.YES | Alert.NO, assemblyContentPanel, onAlertClearItemClose, null, Alert.NO);
            }
        }
        
        private function onImportPropertiesButtonClick(event:MouseEvent):void
        {
            importSequenceFileReference = new FileReference();
            importSequenceFileReference.addEventListener(Event.SELECT, onImportSequenceFileReferenceSelect);
            importSequenceFileReference.addEventListener(Event.COMPLETE, onImportSequenceFileReferenceComplete);
            importSequenceFileReference.addEventListener(IOErrorEvent.IO_ERROR, onImportSequenceFileReferenceLoadError);
            importSequenceFileReference.browse();
        }
        
        private function onImportSequenceFileReferenceSelect(event:Event):void
        {
            importSequenceFileReference.load();
        }
        
        private function onImportSequenceFileReferenceComplete(event:Event):void
        {
            if(importSequenceFileReference.data == null) {
                showFileImportErrorAlert("Empty file!");
                
                return;
            }
            
            ApplicationFacade.getInstance().serviceProxy.parseSequenceFile(importSequenceFileReference.data.toString());
        }
        
        private function onImportSequenceFileReferenceLoadError(event:IOErrorEvent):void
        {
            showFileImportErrorAlert(event.text);
        }
        
        private function onAlertClearItemClose(event:CloseEvent):void
        {
            var assemblyProvider:AssemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            
            if(event.detail == Alert.YES) {
                assemblyProvider.deleteAssemblyItem(assemblyProvider.bins[selectedCell.column.index], (selectedCell as DataCell).assemblyItem);
            }
        }
        
        // Private Methods
        private function updateUpdateButtonState(value:Boolean):void
        {
            if(assemblyContentPanel.updatePropertiesButton.enabled != value) {
                assemblyContentPanel.updatePropertiesButton.enabled = value;
            }
        }
        
        private function showFileImportErrorAlert(message:String):void
        {
            Alert.show("Failed to open file!", message);
        }
    }
}