package org.jbei.registry
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.mappers.TraceMapper;
	import org.jbei.registry.commands.FetchEntryCommand;
	import org.jbei.registry.commands.FetchSequenceCommand;
	import org.jbei.registry.commands.FetchTracesCommand;
	import org.jbei.registry.commands.InitializationCommand;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade
	{
		private var _application:SequenceChecker;
		private var _entryId:String;
		private var _entry:Entry;
		private var _sequence:FeaturedDNASequence;
		private var _sessionId:String;
		private var _featuredSequence:FeaturedSequence;
		private var _traces:ArrayCollection;
		private var _traceMapper:TraceMapper;
		
		// Properties
		public function get application():SequenceChecker
		{
			return _application;
		}
		
		public function get registryServiceProxy():RegistryAPIProxy
		{
			return ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
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
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			_featuredSequence = value;
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function set entry(value:Entry):void
		{
			_entry = value;
		}
		
		public function get sequence():FeaturedDNASequence
		{
			return _sequence;
		}
		
		public function set sequence(value:FeaturedDNASequence):void
		{
			_sequence = value;
		}
		
		public function get traces():ArrayCollection
		{
			return _traces;
		}
		
		public function set traces(value:ArrayCollection):void
		{
			_traces = value;
		}
		
		public function get traceMapper():TraceMapper
		{
			return _traceMapper;
		}
		
		public function set traceMapper(value:TraceMapper):void
		{
			_traceMapper = value;
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
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
			registerCommand(Notifications.FETCH_SEQUENCE, FetchSequenceCommand);
			registerCommand(Notifications.FETCH_TRACES, FetchTracesCommand);
		}
	}
}
