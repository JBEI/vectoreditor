package org.jbei.registry
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.bio.data.Segment;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.CommonEvent;
	import org.jbei.components.common.EditingEvent;
	import org.jbei.components.common.PrintableContent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.AAMapper;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.FeaturedSequenceMemento;
	import org.jbei.lib.ORFMapper;
	import org.jbei.lib.RestrictionEnzymeMapper;
	import org.jbei.lib.ui.dialogs.ModalDialog;
	import org.jbei.lib.ui.dialogs.ModalDialogEvent;
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.registry.control.ActionStack;
	import org.jbei.registry.control.ActionStackEvent;
	import org.jbei.registry.control.FetchEntryCommand;
	import org.jbei.registry.control.FetchUserPreferencesCommand;
	import org.jbei.registry.control.FetchUserRestrictionEnzymesCommand;
	import org.jbei.registry.control.InitializationCommand;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.model.EntriesProxy;
	import org.jbei.registry.model.UserPreferencesProxy;
	import org.jbei.registry.model.vo.Entry;
	import org.jbei.registry.model.vo.Plasmid;
	import org.jbei.registry.model.vo.RestrictionEnzymeGroup;
	import org.jbei.registry.model.vo.SequenceFeature;
	import org.jbei.registry.model.vo.UserPreferences;
	import org.jbei.registry.utils.Finder;
	import org.jbei.registry.view.dialogs.AboutDialogForm;
	import org.jbei.registry.view.dialogs.FeatureDialogForm;
	import org.jbei.registry.view.dialogs.GoToDialogForm;
	import org.jbei.registry.view.dialogs.PreferencesDialogForm;
	import org.jbei.registry.view.dialogs.PropertiesDialogForm;
	import org.jbei.registry.view.dialogs.RestrictionEnzymeManagerForm;
	import org.jbei.registry.view.dialogs.SelectDialogForm;
	import org.jbei.registry.view.dialogs.editingPromptDialog.EditingPromptDialogForm;
	import org.jbei.registry.view.ui.MainPanel;
	import org.jbei.utils.SystemUtils;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade
	{
		private var _application:VectorEditor;
		private var _actionStack:ActionStack;
		private var _entryId:String;
		private var _serverURL:String;
		private var _featuredSequence:FeaturedSequence;
		private var _entry:Entry;
		private var _orfMapper:ORFMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var controlsInitialized:Boolean = false;
		
		private var sequenceAnnotator:SequenceAnnotator;
		private var pie:Pie;
		private var rail:Rail;
		private var mainPanel:MainPanel;
		
		// Properties
		public function get application():VectorEditor
		{
			return _application;
		}
		
		public function get entryId():String
		{
			return _entryId;
		}
		
		public function set entryId(value:String):void
		{
			_entryId = value;
		}
		
		public function get serverURL():String
		{
			return _serverURL;
		}
		
		public function set serverURL(value:String):void
		{
			_serverURL = value;
		}
		
		public function get actionStack():ActionStack
		{
			return _actionStack;
		}
		
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			if(_featuredSequence != value) {
				_featuredSequence = value;
				
				_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGING, onSequenceChanging);
			}
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function set entry(value:Entry):void
		{
			_entry = value;
		}
		
		public function get orfMapper():ORFMapper
		{
			return _orfMapper;
		}
		
		public function set orfMapper(value:ORFMapper):void
		{
			_orfMapper = value;
		}
		
		public function get restrictionEnzymeMapper():RestrictionEnzymeMapper
		{
			return _restrictionEnzymeMapper;
		}
		
		public function set restrictionEnzymeMapper(value:RestrictionEnzymeMapper):void
		{
			_restrictionEnzymeMapper = value;
		}
		
		// System Public Methods
		public static function getInstance():ApplicationFacade
		{
			if(instance == null) {
				instance = new ApplicationFacade();
			}
			
			return instance as ApplicationFacade;
		}
		
		public function initializeApplication(application:VectorEditor):void
		{
			_application = application;
			
			_actionStack = new ActionStack();
			_actionStack.addEventListener(ActionStackEvent.ACTION_STACK_CHANGED, onActionStackChanged);
		}
		
		public function initializeControls(mainPanel:MainPanel):void
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
		
		// Public Methods
		public function showPie():void
		{
			pie.visible = true;
			pie.includeInLayout = true;
			pie.featuredSequence = featuredSequence;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.featuredSequence = null;
		}
		
		public function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.featuredSequence = featuredSequence;
		}
		
		public function displayFeatures(showFeatures:Boolean):void
		{
			sequenceAnnotator.showFeatures = showFeatures;
			pie.showFeatures = showFeatures;
			rail.showFeatures = showFeatures;
		}
		
		public function displayCutSites(showCutSites:Boolean):void
		{
			sequenceAnnotator.showCutSites = showCutSites;
			pie.showCutSites = showCutSites;
			rail.showCutSites = showCutSites;
		}
		
		public function displayORF(showORFs:Boolean):void
		{
			sequenceAnnotator.showORFs = showORFs;
			pie.showORFs = showORFs;
			rail.showORFs = showORFs;
		}
		
		public function displayComplementarySequence(showComplementarySequence:Boolean):void
		{
			sequenceAnnotator.showComplementarySequence = showComplementarySequence;
		}
		
		public function displayAA1(showAA1:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1 = showAA1;
			sequenceAnnotator.showAminoAcids3 = false;
		}
		
		public function displayAA3(showAA3:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1 = false;
			sequenceAnnotator.showAminoAcids3 = showAA3;
		}
		
		public function displayAA1RevCom(showAA1RevCom:Boolean):void
		{
			sequenceAnnotator.showAminoAcids1RevCom = showAA1RevCom;
		}
		
		public function displaySpaces(showSpaces:Boolean):void
		{
			sequenceAnnotator.showSpaceEvery10Bp = showSpaces;
		}
		
		public function displayFeaturesLabel(showFeatureLabels:Boolean):void
		{
			pie.showFeatureLabels = showFeatureLabels;
			rail.showFeatureLabels = showFeatureLabels;
		}
		
		public function displayCutSitesLabel(showCutSiteLabels:Boolean):void
		{
			pie.showCutSiteLabels = showCutSiteLabels;
			rail.showCutSiteLabels = showCutSiteLabels;
		}
		
		public function moveCaretToPosition(position:int):void
		{
			sequenceAnnotator.caretPosition = position;
			pie.caretPosition = position;
			rail.caretPosition = position;
		}
		
		public function select(start:int, end:int):void
		{
			pie.select(start, end);
			sequenceAnnotator.select(start, end);
			rail.select(start, end);
		}
		
		public function showSelectionDialog():void
		{
			var positions:Array = new Array();
			
			if(sequenceAnnotator && sequenceAnnotator.selectionStart > 0 && sequenceAnnotator.selectionEnd > 0) {
				positions.push(sequenceAnnotator.selectionStart);
				positions.push(sequenceAnnotator.selectionEnd);
			} else {
				positions.push(0);
				positions.push(10);
			}
			
			var selectDialog:ModalDialog = new ModalDialog(mainPanel, SelectDialogForm, positions);
			selectDialog.title = "Select ...";
			selectDialog.open();
			
			selectDialog.addEventListener(ModalDialogEvent.SUBMIT, onSelectDialogSubmit);
		}
		
		public function showPreferencesDialog():void
		{
			var preferencesDialog:ModalDialog = new ModalDialog(mainPanel, PreferencesDialogForm, null);
			preferencesDialog.title = "Preferences";
			preferencesDialog.open();
		}
		
		public function showPropertiesDialog():void
		{
			var propertiesDialog:SimpleDialog = new SimpleDialog(mainPanel, PropertiesDialogForm);
			propertiesDialog.title = "Properties";
			propertiesDialog.open();
		}
		
		public function showCreateNewFeatureDialog():void
		{
			var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, null);
			featureDialog.title = "Create New Feature";
			featureDialog.open();
		}
		
		public function showRestrictionEnzymesManagerDialog():void
		{
			var restrictionEnzymeManagerDialog:ModalDialog = new ModalDialog(mainPanel, RestrictionEnzymeManagerForm, new RestrictionEnzymeGroup("tmp"));
			restrictionEnzymeManagerDialog.title = "Restriction Enzyme Manager";
			restrictionEnzymeManagerDialog.open();
		}
		
		public function showGoToDialog():void
		{
			var gotoDialog:ModalDialog = new ModalDialog(mainPanel, GoToDialogForm, sequenceAnnotator.caretPosition);
			gotoDialog.title = "Go To ...";
			gotoDialog.open();
			
			gotoDialog.addEventListener(ModalDialogEvent.SUBMIT, onGoToDialogSubmit);
		}
		
		public function showAboutDialog():void
		{
			var aboutDialog:SimpleDialog = new SimpleDialog(mainPanel, AboutDialogForm);
			aboutDialog.title = "About";
			aboutDialog.open();
		}
		
		public function userPreferencesUpdated():void
		{
			var userPreferences:UserPreferences = (ApplicationFacade.getInstance().retrieveProxy(UserPreferencesProxy.NAME) as UserPreferencesProxy).userPreferences;
			
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
		
		public function userRestrictionEnzymesUpdated():void
		{
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
				restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(ApplicationFacade.getInstance().featuredSequence, restrictionEnzymeGroup);
			
			sequenceAnnotator.restrictionEnzymeMapper = reMapper;
			pie.restrictionEnzymeMapper = reMapper;
			rail.restrictionEnzymeMapper = reMapper;
		}
		
		public function copyToClipboard():void
		{
			// Broadcasting COPY event
			sequenceAnnotator.dispatchEvent(new Event(Event.COPY, true, true));
		}
		
		public function cutToClipboard():void
		{
			// Broadcasting CUT event
			sequenceAnnotator.dispatchEvent(new Event(Event.CUT, true, true));
		}
		
		public function pasteFromClipboard():void
		{
			// Broadcasting PASTE event
			//sequenceAnnotator.dispatchEvent(new Event(Event.PASTE, true, true));
			Alert.show("To use the Paste command in this browser, please press Ctrl+V.");
		}
		
		public function selectAll():void
		{
			// Broadcasting SELECT_ALL event
			sequenceAnnotator.dispatchEvent(new Event(Event.SELECT_ALL, true, true));
		}
		
		public function reportBug():void
		{
			goToUrl(Constants.REPORT_BUG_URL);
		}
		
		public function suggestFeature():void
		{
			goToUrl(Constants.SUGGEST_FEATURE_URL);
		}
		
		public function goToUrl(url:String):void
		{
			SystemUtils.goToUrl(url);
		}
		
		public function find(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, sequenceAnnotator.caretPosition);
		}
		
		public function findNext(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, sequenceAnnotator.caretPosition + 1);
		}
		
		public function findAt(expression:String, dataType:String, searchType:String, position:int):void
		{
			var findSegment:Segment = Finder.find(ApplicationFacade.getInstance().featuredSequence, expression, dataType, searchType, position);
			
			if(!findSegment) {
				findSegment = Finder.find(ApplicationFacade.getInstance().featuredSequence, expression, dataType, searchType, 0);
			}
			
			if(findSegment) {
				sequenceAnnotator.select(findSegment.start, findSegment.end);
				pie.select(findSegment.start, findSegment.end);
				rail.select(findSegment.start, findSegment.end);
				
				sequenceAnnotator.caretPosition = findSegment.start;
				pie.caretPosition = findSegment.start;
				rail.caretPosition = findSegment.start;
				
				sendNotification(Notifications.FIND_MATCH_FOUND);
			} else {
				sequenceAnnotator.deselect();
				pie.deselect();
				rail.deselect();
				
				sendNotification(Notifications.FIND_MATCH_NOT_FOUND);
			}
		}
		
		public function clearHighlight():void
		{
			sequenceAnnotator.highlights = null;
		}
		
		public function highlight(expression:String, dataType:String, searchType:String):void
		{
			var segments:Array = Finder.findAll(ApplicationFacade.getInstance().featuredSequence, expression, dataType, searchType);
			
			sequenceAnnotator.highlights = segments;
		}
		
		public function changeSafeEditingStage(safeEditing:Boolean):void
		{
			sequenceAnnotator.safeEditing = safeEditing;
			pie.safeEditing = safeEditing;
			rail.safeEditing = safeEditing;
		}
		
		public function printSequence():void
		{
			mainPanel.callLater(doPrintSequence);
		}
		
		public function printRail():void
		{
			mainPanel.callLater(doPrintRail);
		}
		
		public function printPie():void
		{
			mainPanel.callLater(doPrintPie);
		}
		
		public function entryFetched():void // Make it private
		{
			var plasmid:Plasmid = (ApplicationFacade.getInstance().retrieveProxy(EntriesProxy.NAME) as EntriesProxy).plasmid;
			
			if(!plasmid) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Plasmid is null");
				return;
			}
			
			var featuredSequence:FeaturedSequence = plasmidToFeaturedSequence(plasmid);
			
			var orfMapper:ORFMapper = new ORFMapper(featuredSequence);
			
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
			restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(featuredSequence, restrictionEnzymeGroup);
			
			ApplicationFacade.getInstance().entry = plasmid as Entry;
			ApplicationFacade.getInstance().featuredSequence = featuredSequence;
			ApplicationFacade.getInstance().orfMapper = orfMapper;
			ApplicationFacade.getInstance().restrictionEnzymeMapper = reMapper;
			
			featuredSequence.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_INITIALIZED));
			
			var aaMapper:AAMapper = new AAMapper(featuredSequence);
			sequenceAnnotator.aaMapper = aaMapper;
			
			sequenceAnnotator.featuredSequence = featuredSequence;
			pie.featuredSequence = featuredSequence;
			rail.featuredSequence = featuredSequence;
			
			sequenceAnnotator.orfMapper = orfMapper;
			pie.orfMapper = orfMapper;
			rail.orfMapper = orfMapper;
			
			sequenceAnnotator.restrictionEnzymeMapper = reMapper;
			pie.restrictionEnzymeMapper = reMapper;
			rail.restrictionEnzymeMapper = reMapper;
			
			if(featuredSequence.circular) {
				sendNotification(Notifications.SHOW_PIE);
			} else {
				sendNotification(Notifications.SHOW_RAIL);
			}
			
			sendNotification(Notifications.USER_PREFERENCES_CHANGED);
		}
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
			registerCommand(Notifications.FETCH_USER_PREFERENCES, FetchUserPreferencesCommand);
			registerCommand(Notifications.FETCH_USER_RESTRICTION_ENZYMES, FetchUserRestrictionEnzymesCommand);
		}
		
		// Private Methods
		private function onEditFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Edit Feature";
			featureDialog.open();
		}
		
		private function onRemoveFeature(event:CommonEvent):void
		{
			var feature:Feature = event.data as Feature;
			
			Alert.show("Are you sure you want to remove this feature?", "Remove Feature", Alert.YES | Alert.NO, null, function onRemoveFeatureDialogClose(event:CloseEvent):void
			{
				if (event.detail == Alert.YES) {
					ApplicationFacade.getInstance().featuredSequence.removeFeature(feature);
				}
			});
		}
		
		private function onCreateFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Selected as New Feature";
			featureDialog.open();
		}
		
		private function onGoToDialogSubmit(event:ModalDialogEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, (event.data as int));
			sequenceAnnotator.setFocus();
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			sendNotification(Notifications.FEATURED_SEQUENCE_CHANGED, event.data, event.kind);
		}
		
		private function onEditing(event:EditingEvent):void
		{
			var showDialog:Boolean = false;
			
			var featuredSequence:FeaturedSequence = ApplicationFacade.getInstance().featuredSequence;
			var features:Array;
			
			if(event.kind == EditingEvent.KIND_DELETE) {
				var start:int = (event.data as Array)[0] as int;
				var end:int = (event.data as Array)[1] as int;
				
				features = featuredSequence.featuresByRange(start, end);
				if(features.length > 0) {
					showDialog = true;
				} else {
					featuredSequence.removeSequence(start, end);
					
					sendNotification(Notifications.SELECTION_CHANGED, new Array(-1, -1));
					sendNotification(Notifications.CARET_POSITION_CHANGED, start);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_SEQUENCE) {
				var dnaSequence:DNASequence = (event.data as Array)[0] as DNASequence;
				var position1:int = (event.data as Array)[1] as int;
				
				features = featuredSequence.featuresAt(position1);
				if(features.length > 0) {
					showDialog = true;
				} else {
					featuredSequence.insertSequence(dnaSequence, position1);
					sendNotification(Notifications.CARET_POSITION_CHANGED, position1 + dnaSequence.length);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				var insertFeaturedSequence:FeaturedSequence = (event.data as Array)[0] as FeaturedSequence;
				var position2:int = (event.data as Array)[1] as int;
				
				features = featuredSequence.featuresAt(position2);
				if(features.length > 0) {
					showDialog = true;
				} else {
					featuredSequence.insertFeaturedSequence(insertFeaturedSequence, position2);
					sendNotification(Notifications.CARET_POSITION_CHANGED, position2 + insertFeaturedSequence.sequence.length);
				}
			}
			
			if(showDialog) {
				var editingPromptDialog:ModalDialog = new ModalDialog(mainPanel, EditingPromptDialogForm, new Array(event.kind, event.data));
				
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
				sendNotification(Notifications.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as DNASequence).sequence.length);
			} else if(kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				sendNotification(Notifications.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as FeaturedSequence).sequence.length);
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
		
		private function onSelectDialogSubmit(event:ModalDialogEvent):void
		{
			var selectionArray:Array = event.data as Array;
			
			if(selectionArray.length != 2) { return; }
			
			sendNotification(Notifications.SELECTION_CHANGED, selectionArray);
		}
		
		private function onSequenceChanging(event:FeaturedSequenceEvent):void
		{
			_actionStack.add(event.data as FeaturedSequenceMemento);
		}
		
		private function onActionStackChanged(event:ActionStackEvent):void
		{
			sendNotification(Notifications.ACTION_STACK_CHANGED);
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
		}
		
		private function doPrintSequence():void
		{
			var printJob:FlexPrintJob = new FlexPrintJob();
			
			if (printJob.start()) {
				var printableWidth:Number = printJob.pageWidth;
				var printableHeight:Number = printJob.pageHeight;
				
				mainPanel.printingSequenceAnnotator.featuredSequence = sequenceAnnotator.featuredSequence;
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
				mainPanel.printingSequenceAnnotator.floatingWidth = true;
				mainPanel.printingSequenceAnnotator.width = printableWidth;
				mainPanel.printingSequenceAnnotator.removeMask();
				mainPanel.printingSequenceAnnotator.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingSequenceAnnotator.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().featuredSequence.name, (i + 1) + " / " + printableContent.pages.length);
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
				
				mainPanel.printingPie.featuredSequence = pie.featuredSequence;
				mainPanel.printingPie.restrictionEnzymeMapper = pie.restrictionEnzymeMapper;
				mainPanel.printingPie.orfMapper = pie.orfMapper;
				mainPanel.printingPie.showFeatures = pie.showFeatures;
				mainPanel.printingPie.showFeatureLabels = pie.showFeatureLabels;
				mainPanel.printingPie.showCutSites = pie.showCutSites;
				mainPanel.printingPie.showCutSiteLabels = pie.showCutSiteLabels;
				mainPanel.printingPie.showORFs = pie.showORFs;
				mainPanel.printingPie.labelFontSize = pie.labelFontSize;
				mainPanel.printingPie.width = printableWidth;
				mainPanel.printingPie.removeMask();
				mainPanel.printingPie.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingPie.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().featuredSequence.name, (i + 1) + " / " + printableContent.pages.length);
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
				
				mainPanel.printingRail.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
				mainPanel.printingRail.restrictionEnzymeMapper = rail.restrictionEnzymeMapper;
				mainPanel.printingRail.orfMapper = rail.orfMapper;
				mainPanel.printingRail.showFeatures = rail.showFeatures;
				mainPanel.printingRail.showFeatureLabels = rail.showFeatureLabels;
				mainPanel.printingRail.showCutSites = rail.showCutSites;
				mainPanel.printingRail.showCutSiteLabels = rail.showCutSiteLabels;
				mainPanel.printingRail.showORFs = rail.showORFs;
				mainPanel.printingRail.labelFontSize = rail.labelFontSize;
				mainPanel.printingRail.width = printableWidth;
				mainPanel.printingRail.removeMask();
				mainPanel.printingRail.validateNow();
				
				var printableContent:PrintableContent = mainPanel.printingRail.printingContent(printableWidth, printableHeight - 100); // -100 for page margins
				mainPanel.printView.width = printableWidth;
				mainPanel.printView.height = printableHeight;
				
				if(printableContent.pages.length > 0) {
					for(var i:int = 0; i < printableContent.pages.length; i++) {
						mainPanel.printView.load(printableContent.pages[i] as BitmapData, ApplicationFacade.getInstance().featuredSequence.name, (i + 1) + " / " + printableContent.pages.length);
						printJob.addObject(mainPanel.printView, FlexPrintJobScaleType.NONE);
					}
				}
			}
			
			printJob.send();
		}
		
		private function plasmidToFeaturedSequence(plasmid:Plasmid):FeaturedSequence
		{
			var dnaSequence:DNASequence = new DNASequence(plasmid.sequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(plasmid.combinedName(), plasmid.circular, dnaSequence, SequenceUtils.oppositeSequence(dnaSequence));
			
			featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
			
			if(plasmid.sequence.sequenceFeatures && plasmid.sequence.sequenceFeatures.length > 0) {
			var features:Array = new Array();
			for(var i:int = 0; i < plasmid.sequence.sequenceFeatures.length; i++) {
			var sequenceFeature:SequenceFeature = plasmid.sequence.sequenceFeatures[i] as SequenceFeature;
			var strand:int = sequenceFeature.strand;
			
			var notes:Array = new Array();
			notes.push(new FeatureNote("label", sequenceFeature.feature.name));
			
			var feature:org.jbei.bio.data.Feature = new org.jbei.bio.data.Feature(sequenceFeature.start - 1, sequenceFeature.end - 1, sequenceFeature.feature.genbankType, strand, notes);
			features.push(feature);
			}
			
			featuredSequence.addFeatures(features, true);
			}
			
			return featuredSequence;
		}
	}
}
