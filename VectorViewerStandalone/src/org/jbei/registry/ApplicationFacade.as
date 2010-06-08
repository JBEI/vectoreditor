package org.jbei.registry
{
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	
	import org.jbei.components.common.ISequenceComponent;
	import org.jbei.components.common.PrintableContent;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.registry.commands.FetchEntryCommand;
	import org.jbei.registry.commands.FetchSequenceCommand;
	import org.jbei.registry.commands.InitializationCommand;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.jbei.registry.utils.Finder;
	import org.jbei.registry.view.dialogs.PropertiesDialogForm;
	import org.puremvc.as3.patterns.facade.Facade;

    /**
     * @author Zinovii Dmytriv
     */
	public class ApplicationFacade extends Facade
	{
		private var _application:VectorViewer;
		private var _entryId:String;
		private var _sessionId:String;
		private var _sequenceProvider:SequenceProvider;
		private var _entry:Entry;
		private var _sequence:FeaturedDNASequence;
		private var _orfMapper:ORFMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _isReadOnly:Boolean = true;
		private var _sequenceInitialized:Boolean = false;
		private var _activeSequenceComponent:ISequenceComponent = null;
		
		// Properties
		public function get application():VectorViewer
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
		
		public function set sessionId(value:String):void
		{
			_sessionId = value;
		}
		
		public function get sessionId():String
		{
			return _sessionId;
		}
		
		public function get sequenceProvider():SequenceProvider
		{
			return _sequenceProvider;
		}
		
		public function set sequenceProvider(value:SequenceProvider):void
		{
			_sequenceProvider = value;
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
		
		public function get sequenceInitialized():Boolean
		{
			return _sequenceInitialized;
		}
		
		public function set sequenceInitialized(value:Boolean):void
		{
			_sequenceInitialized = value;
		}
		
		public function get activeSequenceComponent():ISequenceComponent
		{
			return _activeSequenceComponent;
		}
		
		public function set activeSequenceComponent(value:ISequenceComponent):void
		{
			_activeSequenceComponent = value;
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
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
			registerCommand(Notifications.FETCH_SEQUENCE, FetchSequenceCommand);
		}
	}
}
