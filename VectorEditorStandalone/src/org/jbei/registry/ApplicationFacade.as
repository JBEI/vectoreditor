package org.jbei.registry
{
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.SequenceProviderEvent;
	import org.jbei.lib.SequenceProviderMemento;
	import org.jbei.lib.data.RestrictionEnzymeGroup;
	import org.jbei.lib.mappers.AAMapper;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.utils.Logger;
	import org.jbei.registry.control.ActionStack;
	import org.jbei.registry.control.ActionStackEvent;
	import org.jbei.registry.control.RestrictionEnzymeGroupManager;
	import org.jbei.registry.mediators.ApplicationMediator;
	import org.jbei.registry.mediators.FindPanelMediator;
	import org.jbei.registry.mediators.MainControlBarMediator;
	import org.jbei.registry.mediators.MainMenuMediator;
	import org.jbei.registry.mediators.StatusBarMediator;
	import org.jbei.registry.models.FeaturedDNASequence;
	import org.jbei.registry.models.UserPreferences;
	import org.jbei.registry.models.UserRestrictionEnzymes;
	import org.jbei.registry.models.VectorEditorProject;
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.jbei.registry.utils.FeaturedDNASequenceUtils;
	import org.jbei.registry.utils.StandaloneUtils;
	import org.jbei.registry.view.ui.ApplicationPanel;
	import org.puremvc.as3.patterns.facade.Facade;

    /**
     * @author Zinovii Dmytriv
     */
	public class ApplicationFacade extends Facade
	{
		private const EXTERNAL_JAVASCIPT_UPDATE_SAVED_BROWSER_TITLE_FUNCTION:String = "updateSavedStateTitle";
		
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
        private var _serviceProxy:RegistryAPIProxy;
        private var _project:VectorEditorProject;
		
        private var actionStack:ActionStack;
        private var entryId:String;
        private var sessionId:String;
        private var projectId:String;
        
		private var browserSavedState:Boolean = true;
        
		// Properties
        public function get project():VectorEditorProject
        {
            return _project;
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
		
        public function get serviceProxy():RegistryAPIProxy
        {
            return _serviceProxy;
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
		
        // Public Methods
        public function initializeControls(applicationPanel:ApplicationPanel):void
        {
            registerMediator(new ApplicationMediator(applicationPanel));
            
            initializeProxy();
            
            // TODO: move this somewhere else
            actionStack = new ActionStack();
            actionStack.addEventListener(ActionStackEvent.ACTION_STACK_CHANGED, onActionStackChanged);
            
            RestrictionEnzymeGroupManager.instance.loadRebaseDatabase();
        }
        
        public function initializeParameters(sessionId:String, entryId:String, projectId:String):void
        {
            CONFIG::standalone {
                updateSequence(StandaloneUtils.standaloneSequence());
                updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
                
                return;
            }
            
            // check session id
            if(!sessionId) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Parameter 'sessionId' is mandatory!");
                
                return;
            }
            
            this.sessionId = sessionId;
            
            Logger.getInstance().info("Session ID: " + sessionId);
            
            CONFIG::registryEdition {
                // if projectId exist then load project else create new empty project
                if(projectId && projectId.length > 0) {
                    Logger.getInstance().info("Project ID: " + projectId);
                    
                    projectId = projectId;
                    
                    serviceProxy.getVectorEditorProject(sessionId, projectId);
                } else {
                    createNewEmptyProject();
                }
                
                return;
            }
            
            CONFIG::entryEdition {
                /*registryServiceProxy.fetchSequence(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
                registryServiceProxy.fetchUserPreferences(ApplicationFacade.getInstance().sessionId);
                registryServiceProxy.fetchUserRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
                registryServiceProxy.hasWritablePermissions(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);*/
                
                return;
            }
        }
        
		public function undo():void {
            actionStack.undo();
        }
        
        public function redo():void {
            actionStack.redo();
        }
        
        public function saveProject():void
        {
            _serviceProxy.saveVectorEditorProject(sessionId, _project);
        }
        
        public function createProject():void
        {
            _serviceProxy.createVectorEditorProject(sessionId, _project);
        }
        
        public function updateProject(newProject:VectorEditorProject):void
        {
            _project = newProject;
            
            sendNotification(Notifications.SEQUENCE_UPDATED);
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
            
            //sendNotification(Notifications.UPDATE_SEQUENCE);
            
            if(ApplicationFacade.getInstance().sequenceProvider.circular) {
                sendNotification(Notifications.SHOW_PIE);
            } else {
                sendNotification(Notifications.SHOW_RAIL);
            }
        }
        
        public function updateBrowserSaveTitleState(isSaved:Boolean):void
        {
            if(isSaved != browserSavedState) {
                browserSavedState = isSaved;
                
                if(ExternalInterface.available) {
                    ExternalInterface.call(EXTERNAL_JAVASCIPT_UPDATE_SAVED_BROWSER_TITLE_FUNCTION, isSaved ? "true" : "false");
                }
            }
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
			actionStack.add(event.data as SequenceProviderMemento);
		}
        
        private function onSequenceProviderChanged(event:SequenceProviderEvent):void
        {
            sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
        }
        
        // Private Methods
        private function initializeProxy():void
        {
            _serviceProxy = new RegistryAPIProxy();
            
            registerProxy(_serviceProxy);
        }
        
        private function createNewEmptyProject():void
        {
            _project = new VectorEditorProject();
            
            sendNotification(Notifications.PROJECT_UPDATED, _project);
        }
        
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
