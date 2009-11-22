package org.jbei.registry.view
{
	import flash.events.Event;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.components.Pie;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.CommonEvent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.components.pieClasses.PieEvent;
	import org.jbei.components.sequenceClasses.SequenceAnnotatorEvent;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.ORFMapper;
	import org.jbei.lib.RestrictionEnzymeMapper;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.model.EntriesProxy;
	import org.jbei.registry.model.UserPreferencesProxy;
	import org.jbei.registry.model.vo.Plasmid;
	import org.jbei.registry.model.vo.RestrictionEnzymeGroup;
	import org.jbei.registry.model.vo.SequenceFeature;
	import org.jbei.registry.model.vo.UserPreferences;
	import org.jbei.registry.view.dialogs.AboutDialogForm;
	import org.jbei.registry.view.dialogs.FeatureDialogForm;
	import org.jbei.registry.view.dialogs.FeaturesDialogForm;
	import org.jbei.registry.view.dialogs.PreferencesDialogForm;
	import org.jbei.registry.view.dialogs.RestrictionEnzymeManagerForm;
	import org.jbei.registry.view.dialogs.SelectDialogForm;
	import org.jbei.registry.view.ui.MainPanel;
	import org.jbei.ui.dialogs.ModalDialog;
	import org.jbei.ui.dialogs.ModalDialogEvent;
	import org.jbei.ui.dialogs.SimpleDialog;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class MainPanelMediator extends Mediator
	{
		private const NAME:String = "MainPanelMediator"
		
		private var mainPanel:MainPanel;
		private var sequenceAnnotator:SequenceAnnotator;
		private var pie:Pie;
		
		// Constructor
		public function MainPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			mainPanel = viewComponent as MainPanel;
			sequenceAnnotator = (viewComponent as MainPanel).sequenceAnnotator;
			pie = (viewComponent as MainPanel).pie;
			
			sequenceAnnotator.addEventListener(SelectionEvent.SELECTION_CHANGED, onSequenceAnnotatorSelectionChanged);
			pie.addEventListener(SelectionEvent.SELECTION_CHANGED, onPieSelectionChanged);
			sequenceAnnotator.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onSequenceAnnotatorCaretPositionChanged);
			pie.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onPieCaretPositionChanged);
			
			sequenceAnnotator.addEventListener(SequenceAnnotatorEvent.EDIT_FEATURE, onSequenceAnnotatorEditFeature);
			pie.addEventListener(PieEvent.EDIT_FEATURE, onSequenceAnnotatorEditFeature);
			sequenceAnnotator.addEventListener(SequenceAnnotatorEvent.CREATE_FEATURE, onSequenceAnnotatorCreateFeature);
			pie.addEventListener(PieEvent.CREATE_FEATURE, onSequenceAnnotatorCreateFeature);
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [ApplicationFacade.SHOW_FEATURES
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
				
				, ApplicationFacade.SHOW_PREFERENCES_DIALOG
				, ApplicationFacade.SHOW_ABOUT_DIALOG
				, ApplicationFacade.SHOW_CREATE_NEW_FEATURE_DIALOG
				, ApplicationFacade.SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG
				, ApplicationFacade.SHOW_FEATURES_DIALOG
				
				, ApplicationFacade.ENTRY_FETCHED
				, ApplicationFacade.USER_PREFERENCES_CHANGED
				, ApplicationFacade.USER_RESTRICTION_ENZYMES_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case ApplicationFacade.SHOW_FEATURES:
					var showFeatures:Boolean = notification.getBody() as Boolean;
					sequenceAnnotator.showFeatures = showFeatures;
					pie.showFeatures = showFeatures;
					break;
				case ApplicationFacade.SHOW_CUTSITES:
					var showCutSites:Boolean = notification.getBody() as Boolean;
					sequenceAnnotator.showCutSites = showCutSites;
					pie.showCutSites = showCutSites;
					break;
				case ApplicationFacade.SHOW_ORFS:
					var showORFs:Boolean = notification.getBody() as Boolean;
					sequenceAnnotator.showORFs = showORFs;
					pie.showORFs = showORFs;
					break;
				case ApplicationFacade.SHOW_COMPLEMENTARY:
					sequenceAnnotator.showComplementarySequence = notification.getBody() as Boolean;
					break;
				case ApplicationFacade.SHOW_AA1:
					sequenceAnnotator.showAminoAcids1 = notification.getBody() as Boolean;
					break;
				case ApplicationFacade.SHOW_AA3:
					sequenceAnnotator.showAminoAcids3 = notification.getBody() as Boolean;
					break;
				case ApplicationFacade.SHOW_SPACES:
					sequenceAnnotator.showSpaceEvery10Bp = notification.getBody() as Boolean;
					break;
				case ApplicationFacade.SHOW_FEATURE_LABELS:
					pie.showFeatureLabels = notification.getBody() as Boolean;
					break;
				case ApplicationFacade.SHOW_CUT_SITE_LABELS:
					pie.showCutSiteLabels = notification.getBody() as Boolean;
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
					ApplicationFacade.getInstance().featuredSequence = featuredSequence;
					
					var orfMapper:ORFMapper = new ORFMapper(featuredSequence);
					
					var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
					for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
						restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
					}
					
					var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(featuredSequence, restrictionEnzymeGroup);
					
					sequenceAnnotator.featuredSequence = featuredSequence;
					pie.featuredSequence = featuredSequence;
					
					sequenceAnnotator.orfMapper = orfMapper;
					pie.orfMapper = orfMapper;
					
					sequenceAnnotator.restrictionEnzymeMapper = reMapper;
					pie.restrictionEnzymeMapper = reMapper;
					
					sendNotification(ApplicationFacade.USER_PREFERENCES_CHANGED);
					
					break;
				case ApplicationFacade.SHOW_SELECTION_BY_RANGE_DIALOG:
					var positions:Array = new Array();
					
					if(sequenceAnnotator && sequenceAnnotator.selectionStart > 0 && sequenceAnnotator.selectionEnd > 0) {
						positions.push(sequenceAnnotator.selectionStart);
						positions.push(sequenceAnnotator.selectionEnd);
					} else {
						positions.push(1);
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
				case ApplicationFacade.SHOW_ABOUT_DIALOG:
					var aboutDialog:SimpleDialog = new SimpleDialog(mainPanel, AboutDialogForm);
					aboutDialog.title = "About";
					aboutDialog.open();
					
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
				case ApplicationFacade.SHOW_FEATURES_DIALOG:
					var featuresDialog:SimpleDialog = new SimpleDialog(mainPanel, FeaturesDialogForm);
					featuresDialog.title = "Features";
					featuresDialog.open();
					
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
					sequenceAnnotator.dispatchEvent(new Event(Event.COPY, true, false));
					
					break;
				case ApplicationFacade.CUT:
					// Broadcasting CUT event
					sequenceAnnotator.dispatchEvent(new Event(Event.CUT, true, false));
					
					break;
				case ApplicationFacade.PASTE:
					// Broadcasting PASTE event
					sequenceAnnotator.dispatchEvent(new Event(Event.PASTE, true, false));
					
					break;
				case ApplicationFacade.SELECT_ALL:
					// Broadcasting SELECT_ALL event
					sequenceAnnotator.dispatchEvent(new Event(Event.SELECT_ALL, true, false));
					
					break;
			}
		}
		
		private function onPieSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(ApplicationFacade.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onSequenceAnnotatorSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(ApplicationFacade.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onPieCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, event.position);
		}
		
		private function onSequenceAnnotatorCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(ApplicationFacade.CARET_POSITION_CHANGED, event.position);
		}
		
		private function onSelectDialogSubmit(event:ModalDialogEvent):void
		{
			var selectionArray:Array = event.data as Array;
			
			if(selectionArray.length != 2 || selectionArray[0] == -1 || selectionArray[1] == -1) { return; }
			
			// Adjusting because featuredSequence starts from 0, but entry from 1 
			selectionArray[0] -= 1;
			selectionArray[1] -= 1;
			
			sendNotification(ApplicationFacade.SELECTION_CHANGED, selectionArray);
		}
		
		private function select(start:int, end:int):void
		{
			pie.select(start, end);
			sequenceAnnotator.select(start, end);
		}
		
		private function moveCaret(position:int):void
		{
			pie.caretPosition = position;
			sequenceAnnotator.caretPosition = position;
		}
		
		// TODO: Move this method somewhere else
		private function plasmidToFeaturedSequence(plasmid:Plasmid):FeaturedSequence
		{
			var dnaSequence:DNASequence = new DNASequence(plasmid.sequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(plasmid.combinedName(), plasmid.circular, dnaSequence, SequenceUtils.oppositeSequence(dnaSequence));
			
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
		
		private function onSequenceAnnotatorEditFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Edit Feature";
			featureDialog.open();
		}
		
		private function onSequenceAnnotatorCreateFeature(event:CommonEvent):void
		{
			var featureDialog:ModalDialog = new ModalDialog(mainPanel, FeatureDialogForm, event.data as Feature);
			featureDialog.title = "Selected as New Feature";
			featureDialog.open();
		}
	}
}
