package org.jbei.registry
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.jbei.bio.parsers.GenbankFormat;
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
	import org.jbei.registry.proxies.ConvertSBOLGenbankProxy;
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
        
        private var _convertSBOLXMLRPCServerLocation:String = "http://j5.jbei.org"; // these are default values
        private var _convertSBOLXMLRPCServicePath:String = "/j5bin/j5_xml_rpc.pl"; // will be reset if passed in through flashvars 
		
        private var actionStack:ActionStack;
        private var entryId:String;
        private var sessionId:String;
        private var projectId:String;
        private var saveSequenceContent:String;
        private var saveSequenceExtension:String;
        
        private var _applicationInitialized:Boolean = false;
        
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
        
        public function get applicationInitialized():Boolean
        {
            return _applicationInitialized;
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
        
        public function get isUndoStackEmpty():Boolean
        {
            return actionStack.undoStackIsEmpty;
        }
        
        public function get isRedoStackEmpty():Boolean
        {
            return actionStack.redoStackIsEmpty;
        }
        
        public function get convertSBOLXMLRPCServerLocation():String
        {
            return _convertSBOLXMLRPCServerLocation;
        }
        
        public function set convertSBOLXMLRPCServerLocation(value:String):void
        {
            _convertSBOLXMLRPCServerLocation = value;
        }
        
        public function get convertSBOLXMLRPCServicePath():String
        {
            return _convertSBOLXMLRPCServicePath;
        }
        
        public function set convertSBOLXMLRPCServicePath(value:String):void
        {
            _convertSBOLXMLRPCServicePath = value;
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
                initializeStandaloneApplication();
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
                    
                    this.projectId = projectId;
                }
                
                initializeRegistryEditionApplication();
                
                return;
            }
            
            CONFIG::entryEdition {
                // if projectId exist then load project else create new empty project
                if(entryId && entryId.length > 0) {
                    Logger.getInstance().info("Entry ID: " + entryId);
                    
                    this.entryId = entryId;
                }
                
                initializeEntryEditionApplication();
                
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
            _project.featuredDNASequence = FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(_sequenceProvider);
            
            _serviceProxy.saveVectorEditorProject(sessionId, _project);
        }
        
        public function createProject():void
        {
            _project.featuredDNASequence = FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(_sequenceProvider);
            
            _serviceProxy.createVectorEditorProject(sessionId, _project);
        }
        
        public function updateProject(newProject:VectorEditorProject):void
        {
            _project = newProject;
            
            sendNotification(Notifications.SEQUENCE_UPDATED, _project.featuredDNASequence);
            
            CONFIG::standalone {
                return;
            }
            
            if(! _applicationInitialized) {
                serviceProxy.fetchUserPreferences(sessionId);
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
            
            loadSequence();
            
            if(ApplicationFacade.getInstance().sequenceProvider.circular) {
                sendNotification(Notifications.SHOW_PIE);
            } else {
                sendNotification(Notifications.SHOW_RAIL);
            }
            
            CONFIG::standalone {
                return;
            }
            
            if(! _applicationInitialized) {
                serviceProxy.fetchUserPreferences(sessionId);
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
        
        public function saveUserPreferences(userPreferences:UserPreferences):void
        {
            CONFIG::standalone{
                return;
            }
            serviceProxy.saveUserPreferences(sessionId, userPreferences);
        }
        
        public function updateUserPreferences(userPreferences:UserPreferences):void
        {
            _userPreferences = userPreferences;
            
            sendNotification(Notifications.USER_PREFERENCES_CHANGED);
            
            CONFIG::standalone {
                return;
            }
            
            if(! _applicationInitialized) {
                serviceProxy.fetchUserRestrictionEnzymes(sessionId);
            }
        }
        
        public function saveUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
        {
            serviceProxy.saveUserRestrictionEnzymes(sessionId, userRestrictionEnzymes);
        }
        
        public function updateUserRestrictionEnzymes(userRestrictionEnzymes:UserRestrictionEnzymes):void
        {
            RestrictionEnzymeGroupManager.instance.loadUserRestrictionEnzymes(userRestrictionEnzymes);
            
            sendNotification(Notifications.USER_RESTRICTION_ENZYMES_CHANGED);
            
            CONFIG::entryEdition {
                if(! _applicationInitialized && entryId && entryId.length > 0) {
                    serviceProxy.hasWritablePermissions(sessionId, entryId);
                }
            }
            
            _applicationInitialized = true;
        }
        
        public function updateEntryPermissions(hasWritablePermissions:Boolean):void
        {
            _hasWritablePermissions = hasWritablePermissions;
            
            sendNotification(Notifications.PERMISSIONS_FETCHED);
        }
        
        public function importSequence(data:String):void
        {
            var featuredDNASequence:FeaturedDNASequence;
            var dataAsXML:XML = new XML(data);
            
            if (dataAsXML.name() != null && dataAsXML.name().toString() == "http://jbei.org/sequence::seq") {
                //try jbei-seq
                featuredDNASequence = sequenceProvider.fromJbeiSeqXml(data);
                if (featuredDNASequence == null || featuredDNASequence.name == null) {
                    Alert.show("Failed to parse sequence file", "Failed to parse");
                    return;
                }
            } else if (dataAsXML.name() != null && dataAsXML.name().toString() == "http://www.w3.org/1999/02/22-rdf-syntax-ns#::RDF") {
                //try SBOL
                sendNotification(Notifications.IMPORT_SBOL_XML, data);
                
                return; //this case is handled differently from the others
            } else {
                //try genbank
                featuredDNASequence = sequenceProvider.fromGenbankFileModel(GenbankFormat.parseGenbankFile(data));
                
                if (featuredDNASequence.name == null) {
                    //try FASTA
                    featuredDNASequence = sequenceProvider.fromFasta(data);
                    if (featuredDNASequence.name == null) {
                        Alert.show("Failed to parse sequence file", "Failed to parse");
                        return;
                    }
                }
            }
            
            sendNotification(Notifications.ACTION_MESSAGE, "Sequence parsed successfully");
            
            sendNotification(Notifications.SEQUENCE_UPDATED, featuredDNASequence);
        }
        
        public function importSequenceViaServer(data:String):void
        {
            serviceProxy.parseSequenceFile(data);
        }
        
        public function generateAndFetchSequence():void
        {
            CONFIG::entryEdition {
                serviceProxy.generateSequence(sessionId, FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(sequenceProvider));
            }
            CONFIG::standalone {
                var result:String = GenbankFormat.generateGenbankFile(sequenceProvider.toGenbankFileModel());
                sendNotification(Notifications.SEQUENCE_GENERATED_AND_FETCHED, result);
            }
        }
        
        public function saveSequence():void
        {
            serviceProxy.saveSequence(sessionId, entryId, FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(sequenceProvider));
        }
        
        public function generateSequence():void
        {
            var fileString:String = GenbankFormat.generateGenbankFile(sequenceProvider.toGenbankFileModel());
            var notificationBody:Object = {fileString:fileString, fileExtension:".gb"};
            sendNotification(Notifications.SEQUENCE_FILE_GENERATED, notificationBody);
        }
        
        public function generateSequenceOnServer():void
        {
            serviceProxy.generateSequenceFile(FeaturedDNASequenceUtils.sequenceProviderToFeaturedDNASequence(sequenceProvider));
        }
        
        public function downloadSequence(content:String, extension:String):void
        {
            saveSequenceContent = content;
            saveSequenceExtension = extension;
            
            if (content == null) {
                Alert.show("Could not generate sequence file for download", "Download error");
                saveSequenceContent = null;
                saveSequenceExtension = null;
                return;
            }
            
            //this is necessary, since the save dialog "may only be invoked upon user interaction"
            Alert.show("Sequence was generated successfully. Press OK button to save it.", "Save sequence", Alert.OK | Alert.CANCEL, null, onSequenceGeneratedAlertClose);
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
        
        private function onSequenceGeneratedAlertClose(event:CloseEvent):void
        {
            if (event.detail == Alert.OK) {
                var fileReference:FileReference = new FileReference();
                fileReference.addEventListener(IOErrorEvent.IO_ERROR, onExportIOSequenceError);
                fileReference.addEventListener(Event.COMPLETE, onExportSequenceComplete);
                fileReference.save(saveSequenceContent, _sequenceProvider.name + saveSequenceExtension);
            }
            
            saveSequenceContent = null;
            saveSequenceExtension = null;
        }
        
        private function onExportSequenceComplete(event:Event):void
        {
            sendNotification(Notifications.ACTION_MESSAGE, "File saved successfully");
        }
        
        private function onExportIOSequenceError(event:Event):void
        {
            Alert.show("Failed to write file!", "Write file error");
        }

        // Private Methods
        private function initializeProxy():void
        {
            _serviceProxy = new RegistryAPIProxy();
            
            registerProxy(_serviceProxy);
            
            registerProxy(new ConvertSBOLGenbankProxy());
        }
        
        private function initializeStandaloneApplication():void
        {
            updateSequence(StandaloneUtils.standaloneSequence());
            updateUserPreferences(StandaloneUtils.standaloneUserPreferences());
        }
        
        private function initializeRegistryEditionApplication():void
        {
            if(projectId && projectId.length > 0) {
                serviceProxy.getVectorEditorProject(sessionId, projectId);
            } else {
                createNewEmptyProject();
            }
        }
        
        private function initializeEntryEditionApplication():void
        {
            if(entryId && entryId.length > 0) {
                serviceProxy.fetchSequence(sessionId, entryId);
            } else {
                createEmptySequence();
            }
            
            /*registryServiceProxy.fetchUserPreferences(ApplicationFacade.getInstance().sessionId);
            registryServiceProxy.fetchUserRestrictionEnzymes(ApplicationFacade.getInstance().sessionId);
            registryServiceProxy.hasWritablePermissions(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);*/
        }
        
        private function createNewEmptyProject():void
        {
            _project = new VectorEditorProject();
            
            sendNotification(Notifications.PROJECT_UPDATED, _project);
        }
        
        private function createEmptySequence():void
        {
            sendNotification(Notifications.SEQUENCE_UPDATED);
        }
        
        private function loadSequence():void
        {
            sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(_sequence);
            
            sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
            
            var orfMapper:ORFMapper = new ORFMapper(sequenceProvider);
            
            var restrictionEnzymeGroup:RestrictionEnzymeGroup = new RestrictionEnzymeGroup("active");
            for(var i:int = 0; i < RestrictionEnzymeGroupManager.instance.activeGroup.length; i++) {
                restrictionEnzymeGroup.addRestrictionEnzyme(RestrictionEnzymeGroupManager.instance.activeGroup[i]);
            }
            
            var reMapper:RestrictionEnzymeMapper = new RestrictionEnzymeMapper(sequenceProvider, restrictionEnzymeGroup);
            
            var aaMapper:AAMapper = new AAMapper(sequenceProvider);
            
            _sequenceProvider = sequenceProvider;
            _orfMapper = orfMapper;
            _restrictionEnzymeMapper = reMapper;
            _aaMapper = aaMapper;
            
            sequenceProvider.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_INITIALIZED));
        }
	}
}
