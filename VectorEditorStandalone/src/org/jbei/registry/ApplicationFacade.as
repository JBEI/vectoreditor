package org.jbei.registry
{
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.FeaturedSequenceMemento;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.registry.commands.FetchEntryCommand;
	import org.jbei.registry.commands.FetchEntryPermissionsCommand;
	import org.jbei.registry.commands.FetchSequenceCommand;
	import org.jbei.registry.commands.FetchUserPreferencesCommand;
	import org.jbei.registry.commands.FetchUserRestrictionEnzymesCommand;
	import org.jbei.registry.commands.InitializationCommand;
	import org.jbei.registry.control.ActionStack;
	import org.jbei.registry.control.ActionStackEvent;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.models.Entry;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade
	{
		private const EXTERNAL_JAVASCIPT_UPDATE_SAVED_BROWSER_TITLE_FUNCTION:String = "updateSavedStateTitle";
		
		private var _application:VectorEditor;
		private var _actionStack:ActionStack;
		private var _entryId:String;
		private var _sessionId:String;
		private var _featuredSequence:FeaturedSequence;
		private var _entry:Entry;
		private var _sequence:FeaturedDNASequence;
		private var _orfMapper:ORFMapper;
		private var _aaMapper:AAMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _isReadOnly:Boolean = true;
		private var _userPreferences:UserPreferences;
		private var _selectionStart:int = -1;
		private var _selectionEnd:int = -1;
		private var _caretPosition:int = -1;
		private var _sequenceInitialized:Boolean = false;
		
		private var browserSavedState:Boolean = true;
		
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
		
		public function set sessionId(value:String):void
		{
			_sessionId = value;
		}
		
		public function get sessionId():String
		{
			return _sessionId;
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
		
		public function get sequence():FeaturedDNASequence
		{
			return _sequence;
		}
		
		public function set sequence(value:FeaturedDNASequence):void
		{
			_sequence = value;
		}
		
		public function get registryServiceProxy():RegistryAPIProxy
		{
			return ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
		}
		
		public function get userPreferences():UserPreferences
		{
			return _userPreferences;
		}
		
		public function set userPreferences(value:UserPreferences):void
		{
			_userPreferences = value;
		}
		
		public function get isReadOnly():Boolean
		{
			return _isReadOnly;
		}
		
		public function set isReadOnly(value:Boolean):void
		{
			_isReadOnly = value;
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
		
		public function get aaMapper():AAMapper
		{
			return _aaMapper;
		}
		
		public function set aaMapper(value:AAMapper):void
		{
			_aaMapper = value;
		}
		
		public function get selectionStart():int
		{
			return _selectionStart;
		}
		
		public function set selectionStart(value:int):void
		{
			_selectionStart = value;
		}
		
		public function get selectionEnd():int
		{
			return _selectionEnd;
		}
		
		public function set selectionEnd(value:int):void
		{
			_selectionEnd = value;
		}
		
		public function get caretPosition():int
		{
			return _caretPosition;
		}
		
		public function set caretPosition(value:int):void
		{
			_caretPosition = value;
		}
		
		public function get sequenceInitialized():Boolean
		{
			return _sequenceInitialized;
		}
		
		public function set sequenceInitialized(value:Boolean):void
		{
			_sequenceInitialized = value;
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
		
		// Public Methods
		public function updateBrowserSaveTitleState(isSaved:Boolean):void
		{
			if(isSaved != browserSavedState) {
				browserSavedState = isSaved;
				
				if(ExternalInterface.available) {
					ExternalInterface.call(EXTERNAL_JAVASCIPT_UPDATE_SAVED_BROWSER_TITLE_FUNCTION, isSaved ? "true" : "false");
				}
			}
		}
		
		public function loadRestrictionEnzymes(rebaseEnzymesCollection:ArrayCollection /* of RestrictionEnzyme */):void
		{
			RestrictionEnzymeGroupManager.instance.loadRebaseDatabase(rebaseEnzymesCollection);
		}
		
		public function loadUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
		{
			RestrictionEnzymeGroupManager.instance.loadUserRestrictionEnzymes(userRestrictionEnzymes);
		}
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(Notifications.INITIALIZATION, InitializationCommand);
			registerCommand(Notifications.FETCH_USER_PREFERENCES, FetchUserPreferencesCommand);
			registerCommand(Notifications.FETCH_USER_RESTRICTION_ENZYMES, FetchUserRestrictionEnzymesCommand);
			registerCommand(Notifications.FETCH_ENTRY, FetchEntryCommand);
			registerCommand(Notifications.FETCH_SEQUENCE, FetchSequenceCommand);
			registerCommand(Notifications.FETCH_ENTRY_PERMISSIONS, FetchEntryPermissionsCommand);
		}
		
		// Private Methods
		private function onActionStackChanged(event:ActionStackEvent):void
		{
			sendNotification(Notifications.ACTION_STACK_CHANGED);
		}
		
		private function onSequenceChanging(event:FeaturedSequenceEvent):void
		{
			_actionStack.add(event.data as FeaturedSequenceMemento);
		}
	}
}
