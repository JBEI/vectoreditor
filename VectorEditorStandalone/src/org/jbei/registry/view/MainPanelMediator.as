package org.jbei.registry.view
{
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.jbei.ApplicationFacade;
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
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.ORFMapper;
	import org.jbei.lib.RestrictionEnzymeMapper;
	import org.jbei.registry.Constants;
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
	import org.jbei.ui.dialogs.ModalDialog;
	import org.jbei.ui.dialogs.ModalDialogEvent;
	import org.jbei.ui.dialogs.SimpleDialog;
	import org.jbei.utils.SystemUtils;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		private var mainPanel:MainPanel;
		private var sequenceAnnotator:SequenceAnnotator;
		private var pie:Pie;
		private var rail:Rail;
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mainPanel = viewComponent as MainPanel;
			
			sequenceAnnotator = mainPanel.sequenceAnnotator;
			pie = mainPanel.pie;
			rail = mainPanel.rail;
			
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
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				  ApplicationFacade.SHOW_RAIL
				, ApplicationFacade.SHOW_PIE
				
				, ApplicationFacade.SHOW_FEATURES
				, ApplicationFacade.SHOW_CUTSITES
				, ApplicationFacade.SHOW_ORFS
				, ApplicationFacade.SHOW_COMPLEMENTARY
				, ApplicationFacade.SHOW_AA1
				, ApplicationFacade.SHOW_AA3
				, ApplicationFacade.SHOW_SPACES
				, ApplicationFacade.SHOW_FEATURE_LABELS
				, ApplicationFacade.SHOW_CUT_SITE_LABELS
				
				, ApplicationFacade.COPY
				, ApplicationFacade.CUT
				, ApplicationFacade.PASTE
				, ApplicationFacade.SHOW_SELECTION_BY_RANGE_DIALOG
				, ApplicationFacade.SELECT_ALL
				
				, ApplicationFacade.SELECTION_CHANGED
				, ApplicationFacade.CARET_POSITION_CHANGED
				, ApplicationFacade.SAFE_EDITING_CHANGED 
				
				, ApplicationFacade.FIND
				, ApplicationFacade.FIND_NEXT
				, ApplicationFacade.HIGHLIGHT
				, ApplicationFacade.CLEAR_HIGHLIGHT
				
				, ApplicationFacade.SHOW_PREFERENCES_DIALOG
				, ApplicationFacade.SHOW_PROPERTIES_DIALOG
				, ApplicationFacade.SHOW_ABOUT_DIALOG
				, ApplicationFacade.SHOW_CREATE_NEW_FEATURE_DIALOG
				, ApplicationFacade.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG
				, ApplicationFacade.SHOW_GOTO_DIALOG
				, ApplicationFacade.GO_REPORT_BUG
				, ApplicationFacade.GO_SUGGEST_FEATURE
				
				, ApplicationFacade.ENTRY_FETCHED
				, ApplicationFacade.USER_PREFERENCES_CHANGED
				, ApplicationFacade.USER_RESTRICTION_ENZYMES_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.SHOW_RAIL:
					pie.visible = false;
					pie.includeInLayout = false;
					pie.featuredSequence = null;
					
					rail.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
					rail.visible = true;
					rail.includeInLayout = true;
					
					break;
				case ApplicationFacade.SHOW_PIE:
					pie.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
					pie.visible = true;
					pie.includeInLayout = true;
					
					rail.featuredSequence = null;
					rail.visible = false;
					rail.includeInLayout = false;
					
					break;
				case ApplicationFacade.SHOW_FEATURES:
					var showFeatures:Boolean = notification.getBody() as Boolean;
					
					sequenceAnnotator.showFeatures = showFeatures;
					pie.showFeatures = showFeatures;
					rail.showFeatures = showFeatures;
					
					break;
				case ApplicationFacade.SHOW_CUTSITES:
					var showCutSites:Boolean = notification.getBody() as Boolean;
					
					sequenceAnnotator.showCutSites = showCutSites;
					pie.showCutSites = showCutSites;
					rail.showCutSites = showCutSites;
					
					break;
				case ApplicationFacade.SHOW_ORFS:
					var showORFs:Boolean = notification.getBody() as Boolean;
					
					sequenceAnnotator.showORFs = showORFs;
					pie.showORFs = showORFs;
					rail.showORFs = showORFs;
					
					break;
				case ApplicationFacade.SHOW_COMPLEMENTARY:
					sequenceAnnotator.showComplementarySequence = notification.getBody() as Boolean;
					
					break;
				case ApplicationFacade.SHOW_AA1:
					sequenceAnnotator.showAminoAcids1 = notification.getBody() as Boolean;
					sequenceAnnotator.showAminoAcids3 = false;
					
					break;
				case ApplicationFacade.SHOW_AA3:
					sequenceAnnotator.showAminoAcids3 = notification.getBody() as Boolean;
					sequenceAnnotator.showAminoAcids1 = false;
					
					break;
				case ApplicationFacade.SHOW_SPACES:
					sequenceAnnotator.showSpaceEvery10Bp = notification.getBody() as Boolean;
					
					break;
				case ApplicationFacade.SHOW_FEATURE_LABELS:
					var showFeatureLabels:Boolean = notification.getBody() as Boolean;
					
					pie.showFeatureLabels = showFeatureLabels;
					rail.showFeatureLabels = showFeatureLabels;
					
					break;
				case ApplicationFacade.SHOW_CUT_SITE_LABELS:
					var showCutSiteLabels:Boolean = notification.getBody() as Boolean;
					
					pie.showCutSiteLabels = showCutSiteLabels;
					rail.showCutSiteLabels = showCutSiteLabels;
					
					break;
				case ApplicationFacade.CARET_POSITION_CHANGED:
					moveCaret(notification.getBody() as int);
					
					break;
				case ApplicationFacade.SELECTION_CHANGED:
					var selectionArray:Array = notification.getBody() as Array;
					
					select(selectionArray[0], selectionArray[1]);
					
					break;
				case ApplicationFacade.ENTRY_FETCHED:
					var plasmid:Plasmid = (ApplicationFacade.getInstance().retrieveProxy(EntriesProxy.NAME) as EntriesProxy).plasmid;
					
					if(!plasmid) {
						sendNotification(ApplicationFacade.APPLICATION_FAILURE, "Plasmid is null");
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
						sendNotification(ApplicationFacade.SHOW_PIE);
					} else {
						sendNotification(ApplicationFacade.SHOW_RAIL);
					}
					
					sendNotification(ApplicationFacade.USER_PREFERENCES_CHANGED);
					
					break;
				case ApplicationFacade.SHOW_SELECTION_BY_RANGE_DIALOG:
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
					break;
				case ApplicationFacade.SHOW_PREFERENCES_DIALOG:
					var preferencesDialog:ModalDialog = new ModalDialog(mainPanel, PreferencesDialogForm, null);
					preferencesDialog.title = "Preferences";
					preferencesDialog.open();
					
					break;
				case ApplicationFacade.SHOW_PROPERTIES_DIALOG:
					var propertiesDialog:SimpleDialog = new SimpleDialog(mainPanel, PropertiesDialogForm);
					propertiesDialog.title = "Properties";
					propertiesDialog.open();
					
					break;
				case ApplicationFacade.SHOW_CREATE_NEW_FEATURE_DIALOG:
					var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, null);
					featureDialog.title = "Create New Feature";
					featureDialog.open();
					
					break;
				case ApplicationFacade.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG:
					var restrictionEnzymeManagerDialog:ModalDialog = new ModalDialog(mainPanel, RestrictionEnzymeManagerForm, new RestrictionEnzymeGroup("tmp"));
					restrictionEnzymeManagerDialog.title = "Restriction Enzyme Manager";
					restrictionEnzymeManagerDialog.open();
					
					break;
				case ApplicationFacade.SHOW_GOTO_DIALOG:
					var gotoDialog:ModalDialog = new ModalDialog(mainPanel, GoToDialogForm, sequenceAnnotator.caretPosition);
					gotoDialog.title = "Go To ...";
					gotoDialog.open();
					
					gotoDialog.addEventListener(ModalDialogEvent.SUBMIT, onGoToDialogSubmit);
					
					break;
				case ApplicationFacade.SHOW_ABOUT_DIALOG:
					var aboutDialog:SimpleDialog = new SimpleDialog(mainPanel, AboutDialogForm);
					aboutDialog.title = "About";
					aboutDialog.open();
					
					break;
				case ApplicationFacade.USER_PREFERENCES_CHANGED:
 					var userPreferences:UserPreferences = (ApplicationFacade.getInstance().retrieveProxy(UserPreferencesProxy.NAME) as UserPreferencesProxy).userPreferences;
					pie.orfMapper.minORFSize = userPreferences.orfMinimumLength;
					
					sequenceAnnotator.orfMapper.minORFSize = userPreferences.orfMinimumLength;
					sequenceAnnotator.sequenceFontSize = userPreferences.sequenceFontSize;
					sequenceAnnotator.bpPerRow = userPreferences.bpPerRow;
					
					break;
				case ApplicationFacade.USER_RESTRICTION_ENZYMES_CHANGED:
					var restrictionEnzymeGroup1:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
					for(var j:int = 0; j < RestrictionEnzymeGroupManager.instance.activeGroup.length; j++) {
						restrictionEnzymeGroup1.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[j]);
					}
					
					var reMapper1:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(ApplicationFacade.getInstance().featuredSequence, restrictionEnzymeGroup1);
					
					sequenceAnnotator.restrictionEnzymeMapper = reMapper1;
					pie.restrictionEnzymeMapper = reMapper1;
					
					break;
				case ApplicationFacade.COPY:
					// Broadcasting COPY event
					sequenceAnnotator.dispatchEvent(new Event(Event.COPY, true, true));
					
					break;
				case ApplicationFacade.CUT:
					// Broadcasting CUT event
					sequenceAnnotator.dispatchEvent(new Event(Event.CUT, true, true));
					
					break;
				case ApplicationFacade.PASTE:
					// Broadcasting PASTE event
					//sequenceAnnotator.dispatchEvent(new Event(Event.PASTE, true, true));
					Alert.show("To use the Paste command in this browser, please press Ctrl+V.");
					
					break;
				case ApplicationFacade.SELECT_ALL:
					// Broadcasting SELECT_ALL event
					sequenceAnnotator.dispatchEvent(new Event(Event.SELECT_ALL, true, true));
					
					break;
				case ApplicationFacade.GO_REPORT_BUG:
					SystemUtils.goToUrl(Constants.REPORT_BUG_URL);
					
					break;
				case ApplicationFacade.GO_SUGGEST_FEATURE:
					SystemUtils.goToUrl(Constants.SUGGEST_FEATURE_URL);
					
					break;
				case ApplicationFacade.FIND:
					var findSegment:Segment = Finder.find(ApplicationFacade.getInstance().featuredSequence, notification.getBody() as String, notification.getType() as String, sequenceAnnotator.caretPosition);
					
					if(!findSegment) {
						findSegment = Finder.find(ApplicationFacade.getInstance().featuredSequence, notification.getBody() as String, notification.getType() as String, 0);
					}
					
					if(findSegment) {
						sequenceAnnotator.select(findSegment.start, findSegment.end);
						pie.select(findSegment.start, findSegment.end);
						rail.select(findSegment.start, findSegment.end);
						
						sequenceAnnotator.caretPosition = findSegment.start;
						pie.caretPosition = findSegment.start;
						rail.caretPosition = findSegment.start;
						
						sendNotification(ApplicationFacade.FIND_MATCH_FOUND);
					} else {
						sequenceAnnotator.deselect();
						pie.deselect();
						rail.deselect();
						
						sendNotification(ApplicationFacade.FIND_MATCH_NOT_FOUND);
					}
					
					break;
				case ApplicationFacade.FIND_NEXT:
					var findNextSegment:Segment = Finder.find(ApplicationFacade.getInstance().featuredSequence, notification.getBody() as String, notification.getType() as String, sequenceAnnotator.caretPosition + 1);
					
					if(!findNextSegment) {
						findNextSegment = Finder.find(ApplicationFacade.getInstance().featuredSequence, notification.getBody() as String, notification.getType() as String, 0);
					}
					
					if(findNextSegment) {
						sequenceAnnotator.select(findNextSegment.start, findNextSegment.end);
						pie.select(findNextSegment.start, findNextSegment.end);
						rail.select(findNextSegment.start, findNextSegment.end);
						
						sequenceAnnotator.caretPosition = findNextSegment.start;
						pie.caretPosition = findNextSegment.start;
						rail.caretPosition = findNextSegment.start;
						
						sendNotification(ApplicationFacade.FIND_MATCH_FOUND);
					} else {
						sequenceAnnotator.deselect();
						pie.deselect();
						rail.deselect();
						
						sendNotification(ApplicationFacade.FIND_MATCH_NOT_FOUND);
					}
					
					break;
				case ApplicationFacade.CLEAR_HIGHLIGHT:
					sequenceAnnotator.highlights = null;
					
					break;
				case ApplicationFacade.HIGHLIGHT:
					var segments:Array = Finder.findAll(ApplicationFacade.getInstance().featuredSequence, notification.getBody() as String, notification.getType() as String);
					
					sequenceAnnotator.highlights = segments;
					
					break;
				case ApplicationFacade.SAFE_EDITING_CHANGED:
					var safeEditing:Boolean = notification.getBody() as Boolean;
					
					sequenceAnnotator.safeEditing = safeEditing;
					pie.safeEditing = safeEditing;
					rail.safeEditing = safeEditing;
					
					break;
			}
		}
		
		private function onSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(ApplicationFacade.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, event.position);
		}
		
		private function onSelectDialogSubmit(event:ModalDialogEvent):void
		{
			var selectionArray:Array = event.data as Array;
			
			if(selectionArray.length != 2) { return; }
			
			sendNotification(ApplicationFacade.SELECTION_CHANGED, selectionArray);
		}
		
		private function select(start:int, end:int):void
		{
			pie.select(start, end);
			sequenceAnnotator.select(start, end);
			rail.select(start, end);
		}
		
		private function moveCaret(position:int):void
		{
			sequenceAnnotator.caretPosition = position;
			pie.caretPosition = position;
			rail.caretPosition = position;
		}
		
		// TODO: Move this method somewhere else
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
			
			featuredSequence.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_INITIALIZED));
			
			return featuredSequence;
		}
		
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
			sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, (event.data as int));
			sequenceAnnotator.setFocus();
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			sendNotification(ApplicationFacade.FEATURED_SEQUENCE_CHANGED, event.data, event.kind);
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
					
					sendNotification(ApplicationFacade.SELECTION_CHANGED, new Array(-1, -1));
					sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, start);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_SEQUENCE) {
				var dnaSequence:DNASequence = (event.data as Array)[0] as DNASequence;
				var position1:int = (event.data as Array)[1] as int;
				
				features = featuredSequence.featuresAt(position1);
				if(features.length > 0) {
					showDialog = true;
				} else {
					featuredSequence.insertSequence(dnaSequence, position1);
					sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, position1 + dnaSequence.length);
				}
			} else if(event.kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				var insertFeaturedSequence:FeaturedSequence = (event.data as Array)[0] as FeaturedSequence;
				var position2:int = (event.data as Array)[1] as int;
				
				features = featuredSequence.featuresAt(position2);
				if(features.length > 0) {
					showDialog = true;
				} else {
					featuredSequence.insertFeaturedSequence(insertFeaturedSequence, position2);
					sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, position2 + insertFeaturedSequence.sequence.length);
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
				sendNotification(ApplicationFacade.SELECTION_CHANGED, new Array(-1, -1));
				sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, data[0] as int);
			} else if(kind == EditingEvent.KIND_INSERT_SEQUENCE) {
				sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as DNASequence).sequence.length);
			} else if(kind == EditingEvent.KIND_INSERT_FEATURED_SEQUENCE) {
				sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, (data[1] as int) + (data[0] as FeaturedSequence).sequence.length);
			}
		}
	}
}
