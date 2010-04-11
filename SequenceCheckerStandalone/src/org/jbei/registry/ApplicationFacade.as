package org.jbei.registry
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.components.Pie;
	import org.jbei.components.Rail;
	import org.jbei.components.common.ISequenceComponent;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.mappers.TraceMapper;
	import org.jbei.registry.commands.FetchEntryCommand;
	import org.jbei.registry.commands.FetchSequenceCommand;
	import org.jbei.registry.commands.FetchTracesCommand;
	import org.jbei.registry.commands.InitializationCommand;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.Plasmid;
	import org.jbei.registry.models.Sequence;
	import org.jbei.registry.models.SequenceFeature;
	import org.jbei.registry.proxies.EntriesServiceProxy;
	import org.jbei.registry.proxies.TraceAlignmentServiceProxy;
	import org.jbei.registry.view.ui.MainPanel;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade
	{
		private var _application:SequenceChecker;
		private var _entryId:String;
		private var _sessionId:String;
		private var _activeSequenceComponent:ISequenceComponent;
		
		private var controlsInitialized:Boolean = false;
		
		private var mainPanel:MainPanel;
		private var pie:Pie;
		private var rail:Rail;
		
		private var _featuredSequence:FeaturedSequence;
		private var _traces:ArrayCollection;
		
		// Properties
		public function get application():SequenceChecker
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
		
		public function get sessionId():String
		{
			return _sessionId;
		}
		
		public function set sessionId(value:String):void
		{
			_sessionId = value;
		}
		
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function get traces():ArrayCollection
		{
			return _traces;
		}
		
		// System Public Methods
		public static function getInstance():ApplicationFacade
		{
			if(instance == null) {
				instance = new ApplicationFacade();
			}
			
			return instance as ApplicationFacade;
		}
		
		public function initializeApplication(application:SequenceChecker):void
		{
			_application = application;
		}
		
		public function initializeControls(mainPanel:MainPanel):void
		{
			if(! controlsInitialized) {
				this.mainPanel = mainPanel;
				
				pie = mainPanel.pie;
				rail = mainPanel.rail;
				
				controlsInitialized = true;
				_activeSequenceComponent = pie;
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
			
			_activeSequenceComponent = pie;
		}
		
		public function showRail():void
		{
			pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.featuredSequence = featuredSequence;
			
			_activeSequenceComponent = rail;
		}
		
		public function displayFeatures(showFeatures:Boolean):void
		{
			pie.showFeatures = showFeatures;
			rail.showFeatures = showFeatures;
		}
		
		public function sequenceFetched():void
		{
			var sequence:Sequence = (ApplicationFacade.getInstance().retrieveProxy(EntriesServiceProxy.NAME) as EntriesServiceProxy).sequence;
			var entry:Entry = (ApplicationFacade.getInstance().retrieveProxy(EntriesServiceProxy.NAME) as EntriesServiceProxy).entry;
			
			_featuredSequence = sequenceToFeaturedSequence(entry, sequence);
			
			featuredSequence.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_INITIALIZED));
			
			pie.featuredSequence = featuredSequence;
			rail.featuredSequence = featuredSequence;
			
			if(featuredSequence.circular) {
				sendNotification(Notifications.SHOW_PIE);
			} else {
				sendNotification(Notifications.SHOW_RAIL);
			}
		}
		
		public function tracesFetched():void
		{
			var traceAlignmentServiceProxy:TraceAlignmentServiceProxy = (ApplicationFacade.getInstance().retrieveProxy(TraceAlignmentServiceProxy.NAME) as TraceAlignmentServiceProxy);
			
			_traces = traceAlignmentServiceProxy.traces;
			
			var traceMapper:TraceMapper = new TraceMapper(featuredSequence, _traces);
			
			pie.traceMapper = traceMapper;
			rail.traceMapper = traceMapper;
		}
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
			registerCommand(Notifications.FETCH_SEQUENCE, FetchSequenceCommand);
			registerCommand(Notifications.FETCH_TRACES, FetchTracesCommand);
		}
		
		// Private Methods
		private function sequenceToFeaturedSequence(entry:Entry, sequence:Sequence): FeaturedSequence
		{
			var sequence:Sequence = sequence;
			
			if(!sequence) {
				sequence = new Sequence();
			}
			
			var dnaSequence:DNASequence = new DNASequence(sequence.sequence);
			
			var featuredSequence:FeaturedSequence = new FeaturedSequence(entry.combinedName(), ((entry is Plasmid) ? (entry as Plasmid).circular : false), dnaSequence, SequenceUtils.oppositeSequence(dnaSequence));
			
			//featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
			
			if(sequence.sequenceFeatures && sequence.sequenceFeatures.length > 0) {
				var features:Array = new Array();
				
				for(var i:int = 0; i < sequence.sequenceFeatures.length; i++) {
					var sequenceFeature:SequenceFeature = sequence.sequenceFeatures[i] as SequenceFeature;
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