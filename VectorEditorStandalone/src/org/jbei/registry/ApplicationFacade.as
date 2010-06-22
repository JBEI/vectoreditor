package org.jbei.registry
{
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.SequenceProviderEvent;
	import org.jbei.lib.SequenceProviderMemento;
	import org.jbei.lib.data.RestrictionEnzymeGroup;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.registry.control.ActionStack;
	import org.jbei.registry.control.ActionStackEvent;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.mediators.ApplicationMediator;
	import org.jbei.registry.mediators.FindPanelMediator;
	import org.jbei.registry.mediators.MainControlBarMediator;
	import org.jbei.registry.mediators.MainMenuMediator;
	import org.jbei.registry.mediators.MainPanelMediator;
	import org.jbei.registry.mediators.StatusBarMediator;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.puremvc.as3.patterns.facade.Facade;

    /**
     * @author Zinovii Dmytriv
     */
	public class ApplicationFacade extends Facade
	{
		private const EXTERNAL_JAVASCIPT_UPDATE_SAVED_BROWSER_TITLE_FUNCTION:String = "updateSavedStateTitle";
		
		private var _application:VectorEditor;
		private var _actionStack:ActionStack;
		private var _entryId:String;
		private var _sessionId:String;
		private var _sequenceProvider:SequenceProvider;
        private var _hasWritablePermissions:Boolean = false;
		private var _sequence:FeaturedDNASequence;
		private var _orfMapper:ORFMapper;
		private var _aaMapper:AAMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
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
		
		public function get sequenceProvider():SequenceProvider
		{
			return _sequenceProvider;
		}
		
		public function set sequenceProvider(value:SequenceProvider):void
		{
			if(_sequenceProvider != value) {
				_sequenceProvider = value;
				
				_sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGING, onSequenceChanging);
			}
		}
		
        public function get registryServiceProxy():RegistryAPIProxy
        {
            return ApplicationFacade.getInstance().retrieveProxy(RegistryAPIProxy.PROXY_NAME) as RegistryAPIProxy;
        }
        
		public function get sequence():FeaturedDNASequence
		{
			return _sequence;
		}
		
		public function get userPreferences():UserPreferences
		{
			return _userPreferences;
		}
		
		public function get orfMapper():ORFMapper
		{
			return _orfMapper;
		}
		
		public function get restrictionEnzymeMapper():RestrictionEnzymeMapper
		{
			return _restrictionEnzymeMapper;
		}
		
		public function get aaMapper():AAMapper
		{
			return _aaMapper;
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
		
        public function get hasWritablePermissions():Boolean
        {
            return _hasWritablePermissions; 
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
            
            // Register Proxy
            registerProxy(new RegistryAPIProxy());
            
            // Register Mediators
            registerMediator(new ApplicationMediator());
            registerMediator(new MainControlBarMediator(_application.mainControlBar));
            registerMediator(new MainMenuMediator(_application.mainMenu));
            registerMediator(new MainPanelMediator(_application.mainPanel));
            registerMediator(new StatusBarMediator(_application.statusBar));
            registerMediator(new FindPanelMediator(_application.findPanel));
            
            RestrictionEnzymeGroupManager.instance.loadRebaseDatabase();
            
            CONFIG::registryEdition {
                registryServiceProxy.fetchSequence(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
                registryServiceProxy.fetchUserPreferences(ApplicationFacade.getInstance().sessionId);
                registryServiceProxy.fetchUserRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
                registryServiceProxy.hasWritablePermissions(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
            }
            
            CONFIG::standalone {
                updateSequence(StandaloneUtils.standaloneSequence());
                updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
            }
            
            CONFIG::toolEdition {
                updateSequence(new FeaturedDNASequence("", "", true, new ArrayCollection()));
                updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
            }
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
		
        public function updateSequence(featuredDNASequence:FeaturedDNASequence):void
        {
            _sequence = featuredDNASequence;
            
            if(featuredDNASequence == null) {
                _sequence = new FeaturedDNASequence("", "", true, new ArrayCollection());
            } else {
                _sequence = featuredDNASequence;
            }
            
            sequenceFetched();
            
            sendNotification(Notifications.LOAD_SEQUENCE);
            
            if(ApplicationFacade.getInstance().sequenceProvider.circular) {
                sendNotification(Notifications.SHOW_PIE);
            } else {
                sendNotification(Notifications.SHOW_RAIL);
            }
            
            ApplicationFacade.getInstance().sequenceInitialized = true;
        }
        
        public function updateUserPreferences(userPreferences:UserPreferences):void
        {
            _userPreferences = userPreferences;
            
            sendNotification(Notifications.USER_PREFERENCES_CHANGED);
        }
        
        public function updateUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
        {
            RestrictionEnzymeGroupManager.instance.loadUserRestrictionEnzymes(userRestrictionEnzymes);
            
            sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
        }
        
        public function updateEntryPermissions(hasWritablePermissions:Boolean):void
        {
            _hasWritablePermissions = hasWritablePermissions;
            
            sendNotification(Notifications.ENTRY_PERMISSIONS_CHANGED);
        }
        
		// Event Handlers
		private function onActionStackChanged(event:ActionStackEvent):void
		{
			sendNotification(Notifications.ACTION_STACK_CHANGED);
		}
		
		private function onSequenceChanging(event:SequenceProviderEvent):void
		{
			_actionStack.add(event.data as SequenceProviderMemento);
		}
        
        private function onSequenceProviderChanged(event:SequenceProviderEvent):void
        {
            sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
        }
        
        // Private Methods
        private function sequenceFetched():void
        {
            sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(_sequence);
            
            sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
            
            var orfMapper:ORFMapper = new ORFMapper(sequenceProvider);
            
            var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
            for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
                restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
            }
            
            var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(sequenceProvider, restrictionEnzymeGroup);
            
            sequenceProvider.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_INITIALIZED));
            
            var aaMapper:AAMapper = new AAMapper(sequenceProvider);
            
            _sequenceProvider = sequenceProvider;
            _orfMapper = orfMapper;
            _restrictionEnzymeMapper = reMapper;
            _aaMapper = aaMapper;
        }
	}
}
