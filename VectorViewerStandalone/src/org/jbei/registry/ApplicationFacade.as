package org.jbei.registry
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.bio.data.RestrictionEnzymeGroup;
	import org.jbei.bio.data.Segment;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.PrintableContent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.registry.control.FetchEntryCommand;
	import org.jbei.registry.control.InitializationCommand;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.Part;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.models.SequenceFeature;
	import org.jbei.registry.models.Strain;
	import org.jbei.registry.proxies.EntriesProxy;
	import org.jbei.registry.utils.Finder;
	import org.jbei.registry.view.dialogs.AboutDialogForm;
	import org.jbei.registry.view.dialogs.PropertiesDialogForm;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade
	{
		private var _application:VectorViewer;
		private var _entryId:String;
		private var _sessionId:String;
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
		public function get application():VectorViewer
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
		
		public function set sessionId(value:String):void
		{
			_sessionId = value;
		}
		
		public function get sessionId():String
		{
			return _sessionId;
		}
		
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			if(_featuredSequence != value) {
				_featuredSequence = value;
				
				//_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGING, onSequenceChanging);
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
		
		public function initializeApplication(application:VectorViewer):void
		{
			_application = application;
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
			
			sequenceAnnotator.visible = false;
			sequenceAnnotator.includeInLayout = false;
			sequenceAnnotator.featuredSequence = null;
		}
		
		public function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.featuredSequence = featuredSequence;
			
			sequenceAnnotator.visible = false;
			sequenceAnnotator.includeInLayout = false;
			sequenceAnnotator.featuredSequence = null;
		}
		
		public function showSequence():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.featuredSequence = null;
			
			sequenceAnnotator.visible = true;
			sequenceAnnotator.includeInLayout = true;
			sequenceAnnotator.featuredSequence = featuredSequence;
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
		
		public function showPropertiesDialog():void
		{
			var propertiesDialog:SimpleDialog = new SimpleDialog(mainPanel, PropertiesDialogForm);
			propertiesDialog.title = "Properties";
			propertiesDialog.open();
		}
		
		public function showAboutDialog():void
		{
			var aboutDialog:SimpleDialog = new SimpleDialog(mainPanel, AboutDialogForm);
			aboutDialog.title = "About";
			aboutDialog.open();
		}
		
		public function copyToClipboard():void
		{
			// Broadcasting COPY event
			sequenceAnnotator.dispatchEvent(new Event(Event.COPY, true, true));
		}
		
		public function selectAll():void
		{
			// Broadcasting SELECT_ALL event
			sequenceAnnotator.dispatchEvent(new Event(Event.SELECT_ALL, true, true));
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
			var entry:Entry = (ApplicationFacade.getInstance().retrieveProxy(EntriesProxy.NAME) as EntriesProxy).entry;
			
			if(!entry) {
				sendNotification(Notifications.APPLICATION_FAILURE, "Entry is null");
				
				return;
			}
			
			var featuredSequence:FeaturedSequence;
			if(entry.recordType == "plasmid") {
				featuredSequence = plasmidToFeaturedSequence(entry as Plasmid);
			} else if (entry.recordType == "strain") {
				featuredSequence = strainToFeaturedSequence(entry as Strain);
			} else if (entry.recordType == "part") {
				featuredSequence = partToFeaturedSequence(entry as Part);
			}
			
			var orfMapper:ORFMapper = new ORFMapper(featuredSequence);
			
			var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
			for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
			restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
			}
			
			var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(featuredSequence, restrictionEnzymeGroup);
			
			ApplicationFacade.getInstance().entry = entry;
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
		}
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
		}
		
		// Private Methods
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			sendNotification(Notifications.FEATURED_SEQUENCE_CHANGED, event.data, event.kind);
		}
		
		private function onSelectionChanged(event:SelectionEvent):void
		{
			sendNotification(Notifications.SELECTION_CHANGED, [event.start, event.end]);
		}
		
		private function onCaretPositionChanged(event:CaretEvent):void
		{
			sendNotification(Notifications.CARET_POSITION_CHANGED, event.position);
		}
		
		private function initializeEventHandlers():void
		{
			sequenceAnnotator.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
			pie.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
			rail.addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
			
			sequenceAnnotator.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
			pie.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
			rail.addEventListener(CaretEvent.CARET_POSITION_CHANGED, onCaretPositionChanged);
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
			// TODO refactor this method
			
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
		
		private function strainToFeaturedSequence(strain:Strain):FeaturedSequence
		{
			// TODO refactor this method
			
			var dnaSequence:DNASequence = new DNASequence(strain.sequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(strain.combinedName(), false, dnaSequence, SequenceUtils.oppositeSequence(dnaSequence));
			
			featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
			
			if(strain.sequence.sequenceFeatures && strain.sequence.sequenceFeatures.length > 0) {
				var features:Array = new Array();
				for(var i:int = 0; i < strain.sequence.sequenceFeatures.length; i++) {
					var sequenceFeature:SequenceFeature = strain.sequence.sequenceFeatures[i] as SequenceFeature;
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
		
		private function partToFeaturedSequence(part:Part):FeaturedSequence
		{
			// TODO refactor this method
			
			var dnaSequence:DNASequence = new DNASequence(part.sequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(part.combinedName(), false, dnaSequence, SequenceUtils.oppositeSequence(dnaSequence));
			
			featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
			
			if(part.sequence.sequenceFeatures && part.sequence.sequenceFeatures.length > 0) {
				var features:Array = new Array();
				for(var i:int = 0; i < part.sequence.sequenceFeatures.length; i++) {
					var sequenceFeature:SequenceFeature = part.sequence.sequenceFeatures[i] as SequenceFeature;
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
