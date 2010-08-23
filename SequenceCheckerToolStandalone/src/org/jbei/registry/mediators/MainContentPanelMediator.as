package org.jbei.registry.mediators
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.StyleSheet;
    
    import mx.collections.ArrayCollection;
    import mx.events.ListEvent;
    
    import org.jbei.components.Pie;
    import org.jbei.components.Rail;
    import org.jbei.components.common.CaretEvent;
    import org.jbei.components.common.ISequenceComponent;
    import org.jbei.components.common.SelectionEvent;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.mappers.TraceMapper;
    import org.jbei.lib.utils.StringFormatter;
    import org.jbei.lib.utils.SystemUtils;
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.TraceSequence;
    import org.jbei.registry.view.ui.MainContentPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class MainContentPanelMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "MainContentPanelMediator";
        private const NUCLEOTIDES_ALIGNMENT_PER_ROW:int = 60;
        
        private var mainContentPanel:MainContentPanel;
        private var activeSequenceComponent:ISequenceComponent;
        private var traces:ArrayCollection; /* TraceSequence */
        
        // Constructor
        public function MainContentPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            mainContentPanel = viewComponent as MainContentPanel;
            
            activeSequenceComponent = mainContentPanel.pieComponent;
            
            mainContentPanel.pieComponent.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
            mainContentPanel.pieComponent.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
            mainContentPanel.railComponent.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
            mainContentPanel.railComponent.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
            mainContentPanel.tracesDataGrid.addEventListener(ListEvent.CHANGE, onTracesDataGridChange);
            mainContentPanel.addTraceButton.addEventListener(MouseEvent.CLICK, onAddTraceButtonClick);
            mainContentPanel.removeTraceButton.addEventListener(MouseEvent.CLICK, onRemoveTraceButtonClick);
            
            var style:StyleSheet = new StyleSheet();
            
            var mismatch:Object = new Object();
            mismatch.color = "#FF0000";
            style.setStyle(".mismatch", mismatch);
            
            mainContentPanel.traceSequenceAlignmentTextArea.styleSheet = style;
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.PROJECT_UPDATED:
                    var currentSequenceProvider:SequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
                    var currentTraces:ArrayCollection = ApplicationFacade.getInstance().traces;
                    
                    mainContentPanel.pieComponent.sequenceProvider = currentSequenceProvider;
                    mainContentPanel.railComponent.sequenceProvider = currentSequenceProvider;
                    
                    var traceMapper:TraceMapper = new TraceMapper(currentSequenceProvider, currentTraces);
                    
                    mainContentPanel.pieComponent.traceMapper = traceMapper;
                    mainContentPanel.railComponent.traceMapper = traceMapper;
                    
                    updateTraces(currentTraces);
                    
                    break;
                case Notifications.COPY:
                    // Broadcasting COPY event
                    if(activeSequenceComponent.sequenceProvider && activeSequenceComponent.sequenceProvider.sequence) {
                        activeSequenceComponent.dispatchEvent(new Event(Event.COPY, true, true));
                    }
                    
                    break;
                case Notifications.SELECT_ALL:
                    if(activeSequenceComponent.sequenceProvider && activeSequenceComponent.sequenceProvider.sequence) {
                        activeSequenceComponent.select(0, activeSequenceComponent.sequenceProvider.sequence.length - 1);
                    }
                    
                    break;
                case Notifications.SWITCH_TO_PIE_VIEW:
                    switchToPieView();
                    
                    break;
                case Notifications.SWITCH_TO_RAIL_VIEW:
                    switchToRailView();
                    
                    break;
                case Notifications.SELECTED_TRACE_SEQUENCE_CHANGED:
                    updateAlignment(notification.getBody() as TraceSequence);
                    updateSelectionForSequenceComponents(notification.getBody() as TraceSequence)
                    
                    break;
                case Notifications.SELECTION_CHANGED:
                    if(notification.getBody() && traces) {
                        var selection:Array = notification.getBody() as Array;
                        
                        for(var i:int = 0; i < traces.length; i++) {
                            var traceSequence:TraceSequence = (traces[i] as TraceSequence);
                            
                            if(traceSequence.traceSequenceAlignment == null) {
                                continue;
                            }
                            
                            if(selection[0] == traceSequence.traceSequenceAlignment.queryStart - 1 && selection[1] == traceSequence.traceSequenceAlignment.queryEnd) {
                                if(mainContentPanel.tracesDataGrid.selectedIndex != i) {
                                    mainContentPanel.tracesDataGrid.selectedIndex = i;
                                    
                                    sendNotification(Notifications.SELECTED_TRACE_SEQUENCE_CHANGED, mainContentPanel);
                                }
                                
                                break;
                            }
                        }
                    }
                    
                    break;
                case Notifications.SHOW_FEATURES:
                    var showFeatures:Boolean = notification.getBody() as Boolean;
                    
                    mainContentPanel.pieComponent.showFeatures = showFeatures;
                    mainContentPanel.railComponent.showFeatures = showFeatures;
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [
                Notifications.PROJECT_UPDATED
                , Notifications.COPY
                , Notifications.SELECT_ALL
                , Notifications.SWITCH_TO_PIE_VIEW
                , Notifications.SWITCH_TO_RAIL_VIEW
                , Notifications.SELECTED_TRACE_SEQUENCE_CHANGED
                , Notifications.SELECTION_CHANGED
                , Notifications.SHOW_FEATURES
            ];
        }
        
        // Event Handlers
        private function onCaretPositionChanged(event:CaretEvent):void
        {
            sendNotification(Notifications.CARET_POSITION_CHANGED, event.position);
        }
        
        private function onSelectionChanged(event:SelectionEvent):void
        {
            sendNotification(Notifications.SELECTION_CHANGED, [event.start, event.end]);
        }

        private function onTracesDataGridChange(event:ListEvent):void
        {
            sendNotification(Notifications.SELECTED_TRACE_SEQUENCE_CHANGED, ((event.itemRenderer.data == null) ? null : (event.itemRenderer.data as TraceSequence)));
        }
        
        private function onAddTraceButtonClick(event:MouseEvent):void
        {
            sendNotification(Notifications.IMPORT_TRACE);
        }
        
        private function onRemoveTraceButtonClick(event:MouseEvent):void
        {
            if(mainContentPanel.tracesDataGrid.selectedIndex >= 0) {
                sendNotification(Notifications.REMOVE_TRACE, mainContentPanel.tracesDataGrid.selectedIndex);
            }
        }
        
        // Private Methods
        private function switchToRailView():void
        {
            if(activeSequenceComponent is Rail) { // already visible rail
                return;
            }
            
            mainContentPanel.pieComponent.visible = false;
            mainContentPanel.pieComponent.includeInLayout = false;
            
            mainContentPanel.railComponent.visible = true;
            mainContentPanel.railComponent.includeInLayout = true;
            
            activeSequenceComponent = mainContentPanel.railComponent;
            
            mainContentPanel.pieComponent.deselect();
            mainContentPanel.railComponent.deselect();
        }
        
        private function switchToPieView():void
        {
            if(activeSequenceComponent is Pie) { // already visible pie
                return;
            }
            
            mainContentPanel.railComponent.visible = false;
            mainContentPanel.railComponent.includeInLayout = false;
            
            mainContentPanel.pieComponent.visible = true;
            mainContentPanel.pieComponent.includeInLayout = true;
            
            activeSequenceComponent = mainContentPanel.pieComponent;
            
            mainContentPanel.pieComponent.deselect();
            mainContentPanel.railComponent.deselect();
        }
        
        private function updateAlignment(traceSequence:TraceSequence):void {
            mainContentPanel.traceSequenceAlignmentTextArea.htmlText = "";
            mainContentPanel.traceSequenceAlignmentTextArea.verticalScrollPosition = 0;
            
            if(traceSequence == null 
                || traceSequence.traceSequenceAlignment == null 
                || traceSequence.traceSequenceAlignment.queryAlignment == null 
                || traceSequence.traceSequenceAlignment.queryAlignment.length == 0) {
                return;
            }
            
            if(traceSequence.traceSequenceAlignment.queryAlignment.length != traceSequence.traceSequenceAlignment.subjectAlignment.length) {
                mainContentPanel.traceSequenceAlignmentTextArea.text = "ERROR: Alignment length doesn't much!";
                
                return;
            }
            
            var subjectAlignmentString:String = traceSequence.traceSequenceAlignment.subjectAlignment.toUpperCase();
            var queryAlignmentString:String = traceSequence.traceSequenceAlignment.queryAlignment.toUpperCase();
            
            var subjectAlignmentLength:int = subjectAlignmentString.length;
            var queryAlignmentLength:int = queryAlignmentString.length;
            
            var numberOfLines:int;
            
            if(subjectAlignmentString.length < NUCLEOTIDES_ALIGNMENT_PER_ROW) {
                numberOfLines = 1;
            } else if(subjectAlignmentString.length % NUCLEOTIDES_ALIGNMENT_PER_ROW == 0) {
                numberOfLines = subjectAlignmentString.length / NUCLEOTIDES_ALIGNMENT_PER_ROW;
            } else {
                numberOfLines = subjectAlignmentString.length / NUCLEOTIDES_ALIGNMENT_PER_ROW + 1;
            }
            
            var output:String = "<font face=\"" + SystemUtils.getSystemMonospaceFontFamily() + "\" size=\"12\" letterspacing=\"1\" kerning=\"0\">";
            
            for(var i:int = 0; i < numberOfLines; i++) {
                var rowStart:int = i * NUCLEOTIDES_ALIGNMENT_PER_ROW;
                var rowEnd:int = ((i + 1) * NUCLEOTIDES_ALIGNMENT_PER_ROW > queryAlignmentLength) ? queryAlignmentLength : ((i + 1) * NUCLEOTIDES_ALIGNMENT_PER_ROW);
                
                var queryRowSequence:String = queryAlignmentString.substring(rowStart, rowEnd);
                var subjectRowSequence:String = subjectAlignmentString.substring(rowStart, rowEnd);
                
                var highlightedQueryRowSequence:String = highlightMismatches(queryRowSequence, subjectRowSequence);
                var highlightedSubjectRowSequence:String = highlightMismatches(subjectRowSequence, queryRowSequence);
                
                if(i == 0) {
                    output += "Expected " + StringFormatter.sprintf("%5d", traceSequence.traceSequenceAlignment.queryStart) + ": ";
                } else {
                    output += "                ";
                }
                
                output += highlightedQueryRowSequence;
                
                if(i == numberOfLines - 1) {
                    output += "   " + traceSequence.traceSequenceAlignment.queryEnd;
                }
                
                output += "\n";
                
                if(i == 0) {
                    output += "Trace    " + StringFormatter.sprintf("%5d", traceSequence.traceSequenceAlignment.subjectStart) + ": ";
                } else {
                    output += "                ";
                }
                
                output += highlightedSubjectRowSequence;
                
                if(i == numberOfLines - 1) {
                    output += "   " + traceSequence.traceSequenceAlignment.subjectEnd;
                }
                
                output += "\n\n";
            }
            
            output += "</font>"
            
            mainContentPanel.traceSequenceAlignmentTextArea.htmlText = output;
        }
        
        private function highlightMismatches(sequence1:String, sequence2:String):String
        {
            var result:String = "";
            
            if(sequence1 == "") {
                return "";
            }
            
            var length:int = sequence1.length;
            
            var isMismatch:Boolean = false;
            for(var i:int = 0; i < length; i++) {
                if(sequence1.charAt(i) == sequence2.charAt(i)) {
                    if(isMismatch) {
                        result += "</span>" + sequence1.charAt(i);
                    } else {
                        result += sequence1.charAt(i);
                    }
                    
                    isMismatch = false;
                } else {
                    if(isMismatch) {
                        result += sequence1.charAt(i);
                    } else {
                        result += "<span class=\"mismatch\">" + sequence1.charAt(i);
                    }
                    
                    isMismatch = true;
                }
            }
            
            if(isMismatch) {
                result += "</span>";
            }
            
            return result;
        }
        
        private function updateTraces(traces:ArrayCollection /* of TraceSequence */):void
        {
            this.traces = traces;
            
            mainContentPanel.tracesDataGrid.dataProvider = this.traces;
        }
        
        private function updateSelectionForSequenceComponents(traceSequence:TraceSequence):void
        {
            if(!traceSequence || !traceSequence.traceSequenceAlignment) {
                return;
            }
            
            activeSequenceComponent.select(traceSequence.traceSequenceAlignment.queryStart, traceSequence.traceSequenceAlignment.queryEnd);
        }
    }
}