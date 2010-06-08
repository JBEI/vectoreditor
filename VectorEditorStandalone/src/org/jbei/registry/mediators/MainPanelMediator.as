package org.jbei.registry.mediators
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.bio.sequence.common.SymbolList;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.CommonEvent;
	import org.jbei.components.common.EditingEvent;
	import org.jbei.components.common.PrintableContent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.ui.dialogs.ModalDialog;
	import org.jbei.lib.ui.dialogs.ModalDialogEvent;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.jbei.registry.utils.Finder;
	import org.jbei.registry.view.dialogs.FeatureDialogForm;
	import org.jbei.registry.view.dialogs.editingPromptDialog.EditingPromptDialogForm;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

    /**
     * @author Zinovii Dmytriv
     */
	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		private var sequenceAnnotator:SequenceAnnotator;
		private var pie:Pie;
		private var rail:Rail;
		private var mainPanel:MainPanel;
		
		private var controlsInitialized:Boolean = false;
		private var isSequenceInitialized:Boolean = false;
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			initializeControls(viewComponent as MainPanel);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				  Notifications.SHOW_RAIL
				, Notifications.SHOW_PIE
				
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				, Notifications.SHOW_COMPLEMENTARY
				, Notifications.SHOW_AA1
				, Notifications.SHOW_AA1_REVCOM
				, Notifications.SHOW_AA3
				, Notifications.SHOW_SPACES
				, Notifications.SHOW_FEATURE_LABELS
				, Notifications.SHOW_CUT_SITE_LABELS
				
				, Notifications.COPY
				, Notifications.CUT
				, Notifications.PASTE
				, Notifications.SELECT_ALL
				
				, Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				, Notifications.SAFE_EDITING_CHANGED 
				
				, Notifications.FIND
				, Notifications.FIND_NEXT
				, Notifications.HIGHLIGHT
				, Notifications.CLEAR_HIGHLIGHT
				
				, Notifications.USER_PREFERENCES_CHANGED
				, Notifications.USER_RESTRICTION_ENZYMES_CHANGED
				
				, Notifications.PRINT_PIE
				, Notifications.PRINT_RAIL
				, Notifications.PRINT_SEQUENCE
				
				, Notifications.SAVE_SEQUENCE
				
				, Notifications.LOAD_SEQUENCE
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.LOAD_SEQUENCE:
					loadSequence();
					
					break;
				case Notifications.SHOW_RAIL:
					showRail();
					
					break;
				case Notifications.SHOW_PIE:
					showPie();
					
					break;
				case Notifications.SHOW_FEATURES:
					displayFeatures(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_CUTSITES:
					displayCutSites(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_ORFS:
					displayORF(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_COMPLEMENTARY:
					displayComplementarySequence(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA1:
					displayAA1(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA3:
					displayAA3(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_AA1_REVCOM:
					displayAA1RevCom(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_SPACES:
					displaySpaces(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_FEATURE_LABELS:
					displayFeaturesLabel(notification.getBody() as Boolean);
					
					break;
				case Notifications.SHOW_CUT_SITE_LABELS:
					displayCutSitesLabel(notification.getBody() as Boolean);
					
					break;
				case Notifications.CARET_POSITION_CHANGED:
					moveCaretToPosition(notification.getBody() as int);
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionArray:Array = notification.getBody() as Array;
					
					select(selectionArray[0], selectionArray[1]);
					
					break;
				case Notifications.USER_PREFERENCES_CHANGED:
					userPreferencesUpdated();
					
					break;
				case Notifications.USER_RESTRICTION_ENZYMES_CHANGED:
					userRestrictionEnzymesUpdated();
					
					break;
				case Notifications.COPY:
					copyToClipboard();
					
					break;
				case Notifications.CUT:
					cutToClipboard();
					
					break;
				case Notifications.PASTE:
					pasteFromClipboard();
					
					break;
				case Notifications.SELECT_ALL:
					selectAll();
					
					break;
				case Notifications.FIND:
					var findData:Array = notification.getBody() as Array;
					
					var findExpression:String = findData[0] as String;
					var findDataType:String = findData[1] as String;
					var findSearchType:String = findData[2] as String;
					
					find(findExpression, findDataType, findSearchType);
					
					break;
				case Notifications.FIND_NEXT:
					var findNextData:Array = notification.getBody() as Array;
					
					var findNextExpression:String = findNextData[0] as String;
					var findNextDataType:String = findNextData[1] as String;
					var findNextSearchType:String = findNextData[2] as String;
					
					findNext(findNextExpression, findNextDataType, findNextSearchType);
					
					break;
				case Notifications.CLEAR_HIGHLIGHT:
					clearHighlight();
					
					break;
				case Notifications.HIGHLIGHT:
					var highlightFindData:Array = notification.getBody() as Array;
					
					var highlightExpression:String = highlightFindData[0] as String;
					var highlightDataType:String = highlightFindData[1] as String;
					var highlightSearchType:String = highlightFindData[2] as String;
					
					highlight(highlightExpression, highlightDataType, highlightSearchType);
					
					break;
				case Notifications.SAFE_EDITING_CHANGED:
					changeSafeEditingStage(notification.getBody() as Boolean);
					
					break;
				case Notifications.PRINT_SEQUENCE:
					printSequence();
					
					break;
				case Notifications.PRINT_RAIL:
					printRail();
					
					break;
				case Notifications.PRINT_PIE:
					printPie();
					
					break;
				case Notifications.SAVE_SEQUENCE:
					save();
					
					break;
			}
		}
		
		// Event Handlers
		private function onEditFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Edit Feature";
			featureDialog.open();
		}
		
		private function onRemoveFeature(event:CommonEvent):void
		{
			var feature:Feature = event.data as Feature;
			
			Alert.show("Are you sure you want to remove this feature?", "Remove Feature", Alert.YES | Alert.NO, null, function onRemoveFeatureDialogClose(event:CloseEvent):void
			{
				if (event.detail == Alert.YES) {
					ApplicationFacade.getInstance().sequenceProvider.removeFeature(feature);
				}
			});
		}
		
		private function onCreateFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Selected as New Feature";
			featureDialog.open();
		}
		
		private function onGoToDialogSubmit(event:ModalDialogEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, (event.data as int));
			sequenceAnnotator.setFocus();
		}
		
		private function onEditing(event:EditingEvent):void
		{
			var showDialog:Boolean = false;
			
			var sequenceProvider:SequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			var features:Array;
			
			if(event.kind == EditingEvent.KIND_DELETE) {
				var start:int = (event.data as Array)[0] as int;
				var end:int = (event.data as Array)[1] as int;
				
				features = sequenceProvider.featuresByRange(start, end);
				if(features.length > 0) {
					showDialog = true;
				} else {
                    sequenceProvider.removeSequence(start, end);
					
					sendNotification(Notifications.SELECTION_CHANGED, new Array(-1, -1));
					sendNotification(Notifications.CARET_POSITION_CHANGED, start);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_SEQUENCE) {
				var dnaSequence:SymbolList = (event.data as Array)[0] as SymbolList;
				var position1:int = (event.data as Array)[1] as int;
				
				features = sequenceProvider.featuresAt(position1);
				if(features.length > 0) {
					showDialog = true;
				} else {
                    sequenceProvider.insertSequence(dnaSequence, position1);
					sendNotification(Notifications.CARET_POSITION_CHANGED, position1 + dnaSequence.length);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				var insertSequenceProvider:SequenceProvider = (event.data as Array)[0] as SequenceProvider;
				var position2:int = (event.data as Array)[1] as int;
				
				features = sequenceProvider.featuresAt(position2);
				if(features.length > 0) {
					showDialog = true;
				} else {
                    sequenceProvider.insertSequenceProvider(insertSequenceProvider, position2);
					sendNotification(Notifications.CARET_POSITION_CHANGED, position2 + insertSequenceProvider.sequence.length);
				}
			}
			
			if(showDialog) {
				var editingPromptDialog:ModalDialog = new ModalDialog(EditingPromptDialogForm, new Array(event.kind, event.data));
				
				editingPromptDialog.title = "Editing...";
				editingPromptDialog.open();
				editingPromptDialog.addEventListener(ModalDialogEvent.SUBMIT, onEditingPromptDialogSubmit);
			}
		}
		
		private function onEditingPromptDialogSubmit(event:ModalDialogEvent):void
		{
			var input:Array = event.data as Array;
			var kind:String = input[0] as String;
			var data:Array = input[1] as Array;
			
			if(kind == EditingEvent.KIND_DELETE) {
				sendNotification(Notifications.SELECTION_CHANGED, new Array(-1, -1));
				sendNotification(Notifications.CARET_POSITION_CHANGED, data[0] as int);
			} else if(kind == EditingEvent.KIND_INSERT_SEQUENCE) {
				sendNotification(Notifications.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as DNASequence).length);
			} else if(kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				sendNotification(Notifications.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as SequenceProvider).sequence.length);
			}
		}
		
		private function onSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(Notifications.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, event.position);
		}
		
        private function onActionMessage(event:CommonEvent):void
        {
            sendNotification(Notifications.ACTION_MESSAGE, event.data);
        }
        
        // Private Methods
        private function initializeControls(mainPanel:MainPanel):void
        {
            if(! controlsInitialized) {
                this.mainPanel = mainPanel;
                
                pie = mainPanel.pie;
                rail = mainPanel.rail;
                sequenceAnnotator = mainPanel.sequenceAnnotator;
                
                initializeEventHandlers();
                
                controlsInitialized = true;
            }
        }
        
        private function initializeEventHandlers():void
        {
            sequenceAnnotator.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
            pie.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
            rail.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
            
            sequenceAnnotator.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
            pie.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
            rail.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
            
            sequenceAnnotator.addEventListener(CommonEvent.EDIT_FEATURE, onEditFeature);
            pie.addEventListener(CommonEvent.EDIT_FEATURE, onEditFeature);
            rail.addEventListener(CommonEvent.EDIT_FEATURE, onEditFeature);
            
            sequenceAnnotator.addEventListener(CommonEvent.REMOVE_FEATURE, onRemoveFeature);
            pie.addEventListener(CommonEvent.REMOVE_FEATURE, onRemoveFeature);
            rail.addEventListener(CommonEvent.REMOVE_FEATURE, onRemoveFeature);
            
            sequenceAnnotator.addEventListener(CommonEvent.CREATE_FEATURE, onCreateFeature);
            pie.addEventListener(CommonEvent.CREATE_FEATURE, onCreateFeature);
            rail.addEventListener(CommonEvent.CREATE_FEATURE, onCreateFeature);
            
            sequenceAnnotator.addEventListener(EditingEvent.COMPONENT_SEQUENCE_EDITING, onEditing);
            pie.addEventListener(EditingEvent.COMPONENT_SEQUENCE_EDITING, onEditing);
            rail.addEventListener(EditingEvent.COMPONENT_SEQUENCE_EDITING, onEditing);
            
            sequenceAnnotator.addEventListener(CommonEvent.ACTION_MESSAGE, onActionMessage);
            pie.addEventListener(CommonEvent.ACTION_MESSAGE, onActionMessage);
            rail.addEventListener(CommonEvent.ACTION_MESSAGE, onActionMessage);
        }
        
		public function save():void
		{
			CONFIG::standalone {
				return;
			}
			
			if(!ApplicationFacade.getInstance().isReadOnly) {
				ApplicationFacade.getInstance().registryServiceProxy.saveSequence(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entry.recordId, FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(ApplicationFacade.getInstance().sequenceProvider));
			} else {
				Alert.show("You don't have permissions to save this sequence!");
			}
		}
		
		private function showPie():void
		{
			pie.visible = true;
			pie.includeInLayout = true;
			pie.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.sequenceProvider = null;
		}
		
		private function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.sequenceProvider = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
		}
		
		private function displayFeatures(showFeatures:Boolean):void
		{
			sequenceAnnotator.showFeatures = showFeatures;
			pie.showFeatures = showFeatures;
			rail.showFeatures = showFeatures;
		}
		
		private function displayCutSites(showCutSites:Boolean):void
		{
			sequenceAnnotator.showCutSites = showCutSites;
			pie.showCutSites = showCutSites;
			rail.showCutSites = showCutSites;
		}
		
		private function displayORF(showORFs:Boolean):void
		{
			sequenceAnnotator.showORFs = showORFs;
			pie.showORFs = showORFs;
			rail.showORFs = showORFs;
		}
		
		private function displayComplementarySequence(showComplementarySequence:Boolean):void
		{
			sequenceAnnotator.showComplementarySequence = showComplementarySequence;
		}
		
		private function displayAA1(showAA1:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1 = showAA1;
			sequenceAnnotator.showAminoAcids3 = false;
		}
		
		private function displayAA3(showAA3:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1 = false;
			sequenceAnnotator.showAminoAcids3 = showAA3;
		}
		
		private function displayAA1RevCom(showAA1RevCom:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1RevCom = showAA1RevCom;
		}
		
		private function displaySpaces(showSpaces:Boolean):void
		{
			sequenceAnnotator.showSpaceEvery10Bp = showSpaces;
		}
		
		private function displayFeaturesLabel(showFeatureLabels:Boolean):void
		{
			pie.showFeatureLabels = showFeatureLabels;
			rail.showFeatureLabels = showFeatureLabels;
		}
		
		private function displayCutSitesLabel(showCutSiteLabels:Boolean):void
		{
			pie.showCutSiteLabels = showCutSiteLabels;
			rail.showCutSiteLabels = showCutSiteLabels;
		}
		private function moveCaretToPosition(position:int):void
		{
			sequenceAnnotator.caretPosition = position;
			pie.caretPosition = position;
			rail.caretPosition = position;
			
			ApplicationFacade.getInstance().caretPosition = position;
		}
		
		private function select(start:int, end:int):void
		{
			pie.select(start, end);
			sequenceAnnotator.select(start, end);
			rail.select(start, end);
			
			ApplicationFacade.getInstance().selectionStart = start;
			ApplicationFacade.getInstance().selectionEnd = end;
		}
		
		
		private function copyToClipboard():void
		{
			// Broadcasting COPY event
			sequenceAnnotator.dispatchEvent(new Event(Event.COPY, true, true));
		}
		
		private function cutToClipboard():void
		{
			// Broadcasting CUT event
			sequenceAnnotator.dispatchEvent(new Event(Event.CUT, true, true));
		}
		
		private function pasteFromClipboard():void
		{
			// Broadcasting PASTE event
			//sequenceAnnotator.dispatchEvent(new Event(Event.PASTE, true, true));
			Alert.show("To use the Paste command in this browser, please press Ctrl+V.");
		}
		
		private function selectAll():void
		{
			// Broadcasting SELECT_ALL event
			sequenceAnnotator.dispatchEvent(new Event(Event.SELECT_ALL, true, true));
		}
		
		private function find(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, sequenceAnnotator.caretPosition);
		}
		
		private function findNext(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, sequenceAnnotator.caretPosition + 1);
		}
		
		private function findAt(expression:String, dataType:String, searchType:String, position:int):void
		{
			var findAnnotation:Annotation = Finder.find(ApplicationFacade.getInstance().sequenceProvider, expression, dataType, searchType, position);
			
			if(!findAnnotation) {
				findAnnotation = Finder.find(ApplicationFacade.getInstance().sequenceProvider, expression, dataType, searchType, 0);
			}
			
			if(findAnnotation) {
				sequenceAnnotator.select(findAnnotation.start, findAnnotation.end);
				pie.select(findAnnotation.start, findAnnotation.end);
				rail.select(findAnnotation.start, findAnnotation.end);
				
				sequenceAnnotator.caretPosition = findAnnotation.start;
				pie.caretPosition = findAnnotation.start;
				rail.caretPosition = findAnnotation.start;
				
				sendNotification(Notifications.FIND_MATCH_FOUND);
			} else {
				sequenceAnnotator.deselect();
				pie.deselect();
				rail.deselect();
				
				sendNotification(Notifications.FIND_MATCH_NOT_FOUND);
			}
		}
		
		private function clearHighlight():void
		{
			sequenceAnnotator.highlights = null;
		}
		
		private function highlight(expression:String, dataType:String, searchType:String):void
		{
			var annotations:Array = Finder.findAll(ApplicationFacade.getInstance().sequenceProvider, expression, dataType, searchType);
			
			sequenceAnnotator.highlights = annotations;
		}
		
		private function changeSafeEditingStage(safeEditing:Boolean):void
		{
			sequenceAnnotator.safeEditing = safeEditing;
			pie.safeEditing = safeEditing;
			rail.safeEditing = safeEditing;
		}
		
		private function printSequence():void
		{
			mainPanel.callLater(doPrintSequence);
		}
		
		private function printRail():void
		{
			mainPanel.callLater(doPrintRail);
		}
		
		private function printPie():void
		{
			mainPanel.callLater(doPrintPie);
		}
		
		private function doPrintSequence():void
		{
			var printJob:FlexPrintJob = new FlexPrintJob();
			
			if (printJob.start()) {
				var printableWidth:Number = printJob.pageWidth;
				var printableHeight:Number = printJob.pageHeight;
				
				mainPanel.printingSequenceAnnotator.sequenceProvider = sequenceAnnotator.sequenceProvider;
				mainPanel.printingSequenceAnnotator.restrictionEnzymeMapper = sequenceAnnotator.restrictionEnzymeMapper;
				mainPanel.printingSequenceAnnotator.orfMapper = sequenceAnnotator.orfMapper;
				mainPanel.printingSequenceAnnotator.aaMapper = sequenceAnnotator.aaMapper;
				mainPanel.printingSequenceAnnotator.showFeatures = sequenceAnnotator.showFeatures;
				mainPanel.printingSequenceAnnotator.showCutSites = sequenceAnnotator.showCutSites;
				mainPanel.printingSequenceAnnotator.showORFs = sequenceAnnotator.showORFs;
				mainPanel.printingSequenceAnnotator.showAminoAcids1 = sequenceAnnotator.showAminoAcids1;
				mainPanel.printingSequenceAnnotator.showAminoAcids3 = sequenceAnnotator.showAminoAcids3;
				mainPanel.printingSequenceAnnotator.showAminoAcids1RevCom = sequenceAnnotator.showAminoAcids1RevCom;
				mainPanel.printingSequenceAnnotator.labelFontSize = sequenceAnnotator.labelFontSize;
				mainPanel.printingSequenceAnnotator.sequenceFontSize = sequenceAnnotator.sequenceFontSize;
				mainPanel.printingSequenceAnnotator.showSpaceEvery10Bp = sequenceAnnotator.showSpaceEvery10Bp;
				mainPanel.printingSequenceAnnotator.readOnly = sequenceAnnotator.readOnly;
				mainPanel.printingSequenceAnnotator.floatingWidth = true;
				mainPanel.printingSequenceAnnotator.width = printableWidth;
				mainPanel.printingSequenceAnnotator.removeMask();
				mainPanel.printingSequenceAnnotator.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingSequenceAnnotator.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().sequenceProvider.name, (i + 1) + " / " + printableContent.pages.length);
						printJob.addObject(mainPanel.printView, FlexPrintJobScaleType.NONE);
					}
				}
			}
			
			printJob.send();
		}
		
		private function doPrintPie():void
		{
			var printJob:FlexPrintJob = new FlexPrintJob();
			
			if (printJob.start()) {
				var printableWidth:Number = printJob.pageWidth;
				var printableHeight:Number = printJob.pageHeight;
				
				mainPanel.printingPie.sequenceProvider = pie.sequenceProvider;
				mainPanel.printingPie.restrictionEnzymeMapper = pie.restrictionEnzymeMapper;
				mainPanel.printingPie.orfMapper = pie.orfMapper;
				mainPanel.printingPie.showFeatures = pie.showFeatures;
				mainPanel.printingPie.showFeatureLabels = pie.showFeatureLabels;
				mainPanel.printingPie.showCutSites = pie.showCutSites;
				mainPanel.printingPie.showCutSiteLabels = pie.showCutSiteLabels;
				mainPanel.printingPie.showORFs = pie.showORFs;
				mainPanel.printingPie.labelFontSize = pie.labelFontSize;
				mainPanel.printingPie.readOnly = pie.readOnly;
				mainPanel.printingPie.width = printableWidth;
				mainPanel.printingPie.removeMask();
				mainPanel.printingPie.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingPie.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().sequenceProvider.name, (i + 1) + " / " + printableContent.pages.length);
						printJob.addObject(mainPanel.printView, FlexPrintJobScaleType.NONE);
					}
				}
			}
			
			printJob.send();
		}
		
		private function doPrintRail():void
		{
			var printJob:FlexPrintJob = new FlexPrintJob();
			
			if (printJob.start()) {
				var printableWidth:Number = printJob.pageWidth;
				var printableHeight:Number = printJob.pageHeight;
				
				mainPanel.printingRail.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
				mainPanel.printingRail.restrictionEnzymeMapper = rail.restrictionEnzymeMapper;
				mainPanel.printingRail.orfMapper = rail.orfMapper;
				mainPanel.printingRail.showFeatures = rail.showFeatures;
				mainPanel.printingRail.showFeatureLabels = rail.showFeatureLabels;
				mainPanel.printingRail.showCutSites = rail.showCutSites;
				mainPanel.printingRail.showCutSiteLabels = rail.showCutSiteLabels;
				mainPanel.printingRail.showORFs = rail.showORFs;
				mainPanel.printingRail.labelFontSize = rail.labelFontSize;
				mainPanel.printingRail.readOnly = rail.readOnly;
				mainPanel.printingRail.width = printableWidth;
				mainPanel.printingRail.removeMask();
				mainPanel.printingRail.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingRail.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().sequenceProvider.name, (i + 1) + " / " + printableContent.pages.length);
						printJob.addObject(mainPanel.printView, FlexPrintJobScaleType.NONE);
					}
				}
			}
			
			printJob.send();
		}
		
		private function userPreferencesUpdated():void
		{
			var userPreferences:UserPreferences = ApplicationFacade.getInstance().userPreferences;
			
			pie.orfMapper.minORFSize = userPreferences.orfMinimumLength;
			pie.restrictionEnzymeMapper.maxRestrictionEnzymeCuts = userPreferences.maxResitrictionEnzymesCuts;
			pie.labelFontSize = userPreferences.labelsFontSize;
			
			rail.labelFontSize = userPreferences.labelsFontSize;
			
			sequenceAnnotator.orfMapper.minORFSize = userPreferences.orfMinimumLength;
			sequenceAnnotator.sequenceFontSize = userPreferences.sequenceFontSize;
			sequenceAnnotator.bpPerRow = userPreferences.bpPerRow;
			sequenceAnnotator.floatingWidth = userPreferences.bpPerRow == -1;
			sequenceAnnotator.labelFontSize = userPreferences.labelsFontSize;
		}
		
		private function userRestrictionEnzymesUpdated():void
		{
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
				restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(ApplicationFacade.getInstance().sequenceProvider, restrictionEnzymeGroup);
			
			sequenceAnnotator.restrictionEnzymeMapper = reMapper;
			pie.restrictionEnzymeMapper = reMapper;
			rail.restrictionEnzymeMapper = reMapper;
		}
		
		private function loadSequence():void
		{
			sequenceAnnotator.aaMapper = ApplicationFacade.getInstance().aaMapper;
			
			sequenceAnnotator.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			pie.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			rail.sequenceProvider = ApplicationFacade.getInstance().sequenceProvider;
			
			sequenceAnnotator.orfMapper = ApplicationFacade.getInstance().orfMapper;
			pie.orfMapper = ApplicationFacade.getInstance().orfMapper;
			rail.orfMapper = ApplicationFacade.getInstance().orfMapper;
			
			sequenceAnnotator.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
			pie.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
			rail.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
		}
	}
}
