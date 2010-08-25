package org.jbei.registry
{
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.mediators.ApplicationMediator;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.models.SequenceCheckerData;
    import org.jbei.registry.models.SequenceCheckerProject;
    import org.jbei.registry.models.TraceData;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.jbei.registry.utils.StandaloneUtils;
    import org.jbei.registry.utils.TraceHelper;
    import org.jbei.registry.view.ui.ApplicationPanel;
    import org.puremvc.as3.patterns.facade.Facade;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ApplicationFacade extends Facade
    {
        private var sessionId:String;
        private var projectId:String;
        private var serviceProxy:RegistryAPIProxy;
        
        private var _project:SequenceCheckerProject;
        private var _sequenceProvider:SequenceProvider;
        private var _traces:ArrayCollection /* of TraceSequence */;
        
        private var numberOfTraceFilesToParse:int = 0;
        
        // Constructor
        public function ApplicationFacade()
        {
            super();
        }
        
        // System Methods
        public static function getInstance():ApplicationFacade
        {
            if(instance == null) {
                instance = new ApplicationFacade();
            }
            
            return instance as ApplicationFacade;
        }
        
        // Properties
        public function get project():SequenceCheckerProject
        {
            return _project;
        }
        
        public final function get sequenceProvider():SequenceProvider
        {
            return _sequenceProvider;
        }
        
        public final function get traces():ArrayCollection /* of TraceData */
        {
            return _traces;
        }
        
        // Public Methods
        public function initializeControls(applicationPanel:ApplicationPanel):void
        {
            registerMediator(new ApplicationMediator(applicationPanel));
            
            initializeProxy();
        }
        
        public function initializeParameters(sessionId:String, projectId:String):void
        {
            CONFIG::standalone {
                updateProject(StandaloneUtils.standaloneSequenceCheckerProject());
                
                return;
            }
            
            // check session id
            if(!sessionId) {
                sendNotification(Notifications.APPLICATION_FAILURE, "Parameter 'sessionId' is mandatory!");
                
                return;
            }
            
            this.sessionId = sessionId;
            
            Logger.getInstance().info("Session ID: " + sessionId);
            
            // if projectId exist then load project else create new empty project
            if(projectId && projectId.length > 0) {
                Logger.getInstance().info("Project ID: " + projectId);
                
                this.projectId = projectId;
                
                serviceProxy.getSequenceCheckerProject(sessionId, projectId);
            } else {
                createNewEmptyProject();
            }
        }
        
        public function saveProject():void
        {
            serviceProxy.saveSequenceCheckerProject(sessionId, _project);
        }
        
        public function createProject():void
        {
            serviceProxy.createSequenceCheckerProject(sessionId, _project);
        }
        
        public function importSequence(data:String):void
        {
            serviceProxy.importSequenceFile(data);
        }
        
        public function parseTraceFile(filename:String, data:ByteArray):void
        {
            serviceProxy.parseTraceFile(filename, data);
        }
        
        public function startTraceFilesParsing(numberOfTraceFiles:int):void
        {
            numberOfTraceFilesToParse = numberOfTraceFiles;
        }
        
        public function endTraceFilesParsing():void
        {
            numberOfTraceFilesToParse = 0;
        }
        
        public function importTrace(traceData:TraceData):void
        {
            if(numberOfTraceFilesToParse == 0) {
                return;
            }
            
            numberOfTraceFilesToParse--;
            
            if(numberOfTraceFilesToParse == 0) {
                endTraceFilesParsing();
                
                if(traceData != null) {
                    addTrace(traceData);
                } else {
                    realignProject();
                }
            } else {
                if(traceData != null) {
                    addTrace(traceData, true);
                }
            }
        }
        
        public function realignProject():void
        {
            serviceProxy.alignSequenceCheckerProject(sessionId, _project);
        }
        
        public function updateProject(newProject:SequenceCheckerProject):void
        {
            _project = newProject;
            
            if(_project.sequenceCheckerData) {
                _sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(_project.sequenceCheckerData.sequence);
                _traces = new ArrayCollection();
                
                // Convert TraceData to TraceSequence
                var traceDatas:ArrayCollection = _project.sequenceCheckerData.traces;
                if(traceDatas && traceDatas.length > 0) {
                    for(var i:int = 0; i < traceDatas.length; i++) {
                        _traces.addItem(TraceHelper.traceDataToTraceSequence(traceDatas.getItemAt(i) as TraceData)); 
                    }
                }
            } else {
                _sequenceProvider = new SequenceProvider("", false, DNATools.createDNA(""), new ArrayCollection());
                _traces = new ArrayCollection();
            }
            
            sendNotification(Notifications.PROJECT_UPDATED, "New project loaded from the server");
        }
        
        public function updateSequence(sequence:FeaturedDNASequence):void
        {
            if(!_project.sequenceCheckerData) {
                _project.sequenceCheckerData = new SequenceCheckerData(sequence, new ArrayCollection());
            } else {
                _project.sequenceCheckerData.sequence = sequence;
            }
            
            realignProject();
        }
        
        public function addTrace(traceData:TraceData, delayRealignment:Boolean = false):void
        {
            if(!_project.sequenceCheckerData) {
                _project.sequenceCheckerData = new SequenceCheckerData(new FeaturedDNASequence(), new ArrayCollection());
                _project.sequenceCheckerData.traces.addItem(traceData);
            } else {
                _project.sequenceCheckerData.traces.addItem(traceData);
            }
            
            if(!delayRealignment) {
                realignProject();
            }
        }
        
        public function removeTrace(traceData:TraceData):void
        {
            if(!_project.sequenceCheckerData || !_project.sequenceCheckerData.traces) {
                return;
            }
            
            var index:int = _project.sequenceCheckerData.traces.getItemIndex(traceData);
            
            if(index >= 0) {
                _project.sequenceCheckerData.traces.removeItemAt(index);
                
                updateProject(_project);
            }
        }
        
        public function getTraceByIndex(index:int):TraceData
        {
            var resultTraceData:TraceData = null;
            
            if(_project.sequenceCheckerData && _project.sequenceCheckerData.traces && index >= 0 && index < _project.sequenceCheckerData.traces.length) {
                resultTraceData = _project.sequenceCheckerData.traces.getItemAt(index) as TraceData;
            }
            
            return resultTraceData;
        }
        
        // Private Methods
        private function initializeProxy():void
        {
            serviceProxy = new RegistryAPIProxy();
            
            registerProxy(serviceProxy);
        }
        
        private function createNewEmptyProject():void
        {
            _project = new SequenceCheckerProject();
            
            sendNotification(Notifications.PROJECT_UPDATED, "New empty project was created");
        }
    }
}