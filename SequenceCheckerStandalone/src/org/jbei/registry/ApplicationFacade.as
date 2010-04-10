package org.jbei.registry
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.components.common.ISequenceComponent;
	import org.jbei.registry.commands.FetchEntryCommand;
	import org.jbei.registry.commands.FetchSequenceCommand;
	import org.jbei.registry.commands.FetchTracesCommand;
	import org.jbei.registry.commands.InitializationCommand;
	import org.jbei.registry.models.Sequence;
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
		
		private var _sequence:Sequence;
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
		
		public function get sequence():Sequence
		{
			return _sequence;
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
				
				//pie = mainPanel.pie;
				//rail = mainPanel.rail;
				
				controlsInitialized = true;
				//_activeSequenceComponent = pie;
			}
		}
		
		// Public Methods
		public function showPie():void
		{
			/*pie.visible = true;
			pie.includeInLayout = true;
			pie.featuredSequence = featuredSequence;
			
			rail.visible = false;
			rail.includeInLayout = false;
			rail.featuredSequence = null;
			
			_activeSequenceComponent = pie;*/
		}
		
		public function showRail():void
		{
			/*pie.visible = false;
			pie.includeInLayout = false;
			pie.featuredSequence = null;
			
			rail.visible = true;
			rail.includeInLayout = true;
			rail.featuredSequence = featuredSequence;
			
			_activeSequenceComponent = rail;*/
		}
		
		public function displayFeatures(showFeatures:Boolean):void
		{
			/*pie.showFeatures = showFeatures;
			rail.showFeatures = showFeatures;*/
		}
		
		public function sequenceFetched():void
		{
			var entriesServiceProxy:EntriesServiceProxy = (ApplicationFacade.getInstance().retrieveProxy(EntriesServiceProxy.NAME) as EntriesServiceProxy);
			
			_sequence = entriesServiceProxy.sequence;
		}
		
		public function tracesFetched():void
		{
			var traceAlignmentServiceProxy:TraceAlignmentServiceProxy = (ApplicationFacade.getInstance().retrieveProxy(TraceAlignmentServiceProxy.NAME) as TraceAlignmentServiceProxy);
			
			_traces = traceAlignmentServiceProxy.traces;
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
	}
}