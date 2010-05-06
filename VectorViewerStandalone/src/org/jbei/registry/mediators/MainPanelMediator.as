package org.jbei.registry.mediators
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.jbei.bio.data.Segment;
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.SequenceAnnotator;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.PrintableContent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.utils.Finder;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

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
				, Notifications.SHOW_SEQUENCE
				
				, Notifications.SHOW_FEATURES
				, Notifications.SHOW_CUTSITES
				, Notifications.SHOW_ORFS
				
				, Notifications.COPY
				, Notifications.SELECT_ALL
				
				, Notifications.SELECTION_CHANGED
				, Notifications.CARET_POSITION_CHANGED
				
				, Notifications.FIND
				, Notifications.FIND_NEXT
				, Notifications.HIGHLIGHT
				, Notifications.CLEAR_HIGHLIGHT
				
				, Notifications.SHOW_PROPERTIES_DIALOG
				
				, Notifications.PRINT_CURRENT
				, Notifications.PRINT_PIE
				, Notifications.PRINT_RAIL
				, Notifications.PRINT_SEQUENCE
				
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
				case Notifications.SHOW_SEQUENCE:
					showSequence();
					
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
				case Notifications.CARET_POSITION_CHANGED:
					moveCaretToPosition(notification.getBody() as int);
					
					break;
				case Notifications.SELECTION_CHANGED:
					var selectionArray:Array = notification.getBody() as Array;
					
					select(selectionArray[0], selectionArray[1]);
					
					break;
				case Notifications.COPY:
					copyToClipboard();
					
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
				case Notifications.PRINT_CURRENT:
					if(ApplicationFacade.getInstance().activeSequenceComponent is Pie) {
						sendNotification(Notifications.PRINT_PIE);
					} else if(ApplicationFacade.getInstance().activeSequenceComponent is Rail) {
						sendNotification(Notifications.PRINT_RAIL);
					} else if(ApplicationFacade.getInstance().activeSequenceComponent is SequenceAnnotator) {
						sendNotification(Notifications.PRINT_SEQUENCE);
					}
					
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
			}
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
				ApplicationFacade.getInstance().activeSequenceComponent = pie;
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
		}
		
		private function loadSequence():void
		{
			sequenceAnnotator.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			pie.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			rail.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			
			sequenceAnnotator.orfMapper = ApplicationFacade.getInstance().orfMapper;
			pie.orfMapper = ApplicationFacade.getInstance().orfMapper;
			rail.orfMapper = ApplicationFacade.getInstance().orfMapper;
			
			sequenceAnnotator.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
			pie.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
			rail.restrictionEnzymeMapper = ApplicationFacade.getInstance().restrictionEnzymeMapper;
		}
		
		private function showPie():void
		{
			pie.visible = true;
			pie.includeInLayout = true;
			pie.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.featuredSequence = null;
			
			sequenceAnnotator.visible = false;
			sequenceAnnotator.includeInLayout = false;
			sequenceAnnotator.featuredSequence = null;
			
			ApplicationFacade.getInstance().activeSequenceComponent = pie;
		}
		
		private function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			
			sequenceAnnotator.visible = false;
			sequenceAnnotator.includeInLayout = false;
			sequenceAnnotator.featuredSequence = null;
			
			ApplicationFacade.getInstance().activeSequenceComponent = rail;
		}
		
		private function showSequence():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.featuredSequence = null;
			
			sequenceAnnotator.visible = true;
			sequenceAnnotator.includeInLayout = true;
			sequenceAnnotator.featuredSequence = ApplicationFacade.getInstance().featuredSequence;
			
			ApplicationFacade.getInstance().activeSequenceComponent = sequenceAnnotator;
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
		
		private function copyToClipboard():void
		{
			// Broadcasting COPY event
			ApplicationFacade.getInstance().activeSequenceComponent.dispatchEvent(new Event(Event.COPY, true, true));
		}
		
		private function selectAll():void
		{
			// Broadcasting SELECT_ALL event
			ApplicationFacade.getInstance().activeSequenceComponent.dispatchEvent(new Event(Event.SELECT_ALL, true, true));
		}
		
		private function find(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, ApplicationFacade.getInstance().activeSequenceComponent.caretPosition);
		}
		
		private function findNext(expression:String, dataType:String, searchType:String):void
		{
			findAt(expression, dataType, searchType, ApplicationFacade.getInstance().activeSequenceComponent.caretPosition + 1);
		}
		
		private function findAt(expression:String, dataType:String, searchType:String, position:int):void
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
		
		private function clearHighlight():void
		{
			sequenceAnnotator.highlights = null;
		}
		
		private function highlight(expression:String, dataType:String, searchType:String):void
		{
			var segments:Array = Finder.findAll(ApplicationFacade.getInstance().featuredSequence, expression, dataType, searchType);
			
			sequenceAnnotator.highlights = segments;
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
				mainPanel.printingSequenceAnnotator.readOnly = sequenceAnnotator.readOnly;
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
				mainPanel.printingPie.readOnly = pie.readOnly;
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
				mainPanel.printingRail.readOnly = rail.readOnly;
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
	}
}
