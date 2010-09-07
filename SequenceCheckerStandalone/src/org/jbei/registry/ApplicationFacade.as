package org.jbei.registry
{
    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;
    
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.SequenceProviderEvent;
    import org.jbei.lib.mappers.TraceMapper;
    import org.jbei.registry.mediators.AlignmentPanelMediator;
    import org.jbei.registry.mediators.ApplicationMediator;
    import org.jbei.registry.mediators.MainControlBarMediator;
    import org.jbei.registry.mediators.MainPanelMediator;
    import org.jbei.registry.mediators.StatusBarMediator;
    import org.jbei.registry.mediators.TracesListPanelMediator;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.models.TraceGridDataItem;
    import org.jbei.registry.models.TraceSequence;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.jbei.registry.utils.StandaloneUtils;
    import org.puremvc.as3.patterns.facade.Facade;
    
    public class ApplicationFacade extends Facade
    {
        private var _application:SequenceChecker;
        private var _entryId:String;
        private var _sequence:FeaturedDNASequence;
        private var _sessionId:String;
        private var _sequenceProvider:SequenceProvider;
        private var _traces:ArrayCollection;
        private var _visibleTracesCollection:ArrayCollection;
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
        
        public function get sequenceProvider():SequenceProvider
        {
            return _sequenceProvider;
        }
        
        public function set sequenceProvider(value:SequenceProvider):void
        {
            _sequenceProvider = value;
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
        
        public function get visibleTracesCollection():ArrayCollection
        {
            return _visibleTracesCollection;
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
            
            // Register Proxy
            registerProxy(new RegistryAPIProxy());
            
            // Register Mediators
            registerMediator(new ApplicationMediator());
            registerMediator(new MainControlBarMediator(_application.mainControlBar));
            registerMediator(new MainPanelMediator(_application.mainPanel));
            registerMediator(new StatusBarMediator(_application.statusBar));
            registerMediator(new TracesListPanelMediator(_application.tracesListPanel));
            registerMediator(new AlignmentPanelMediator(_application.alignmentPanel));
            
            CONFIG::registryEdition {
                registryServiceProxy.fetchSequence(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
                registryServiceProxy.fetchTraces(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
            }
            
            CONFIG::standalone {
                updateSequence(StandaloneUtils.standaloneSequence());
                updateTraces(StandaloneUtils.standaloneTraces());
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
            
            if(ApplicationFacade.getInstance().sequenceProvider.circular) {
                sendNotification(Notifications.SHOW_PIE);
            } else {
                sendNotification(Notifications.SHOW_RAIL);
            }
        }
        
        public function updateTraces(traces:ArrayCollection):void
        {
            _traces = traces;
            
            _visibleTracesCollection = new ArrayCollection();
            _visibleTracesCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onVisibleTracesCollectionChange);
            
            if(_traces != null && _traces.length > 0) {
                for(var i:int = 0; i < _traces.length; i++) {
                    _visibleTracesCollection.addItem(new TraceGridDataItem(_traces.getItemAt(i) as TraceSequence, true));
                }
            }
            
            updateVisibleTraces();
        }
        
        public function updateVisibleTraces():void
        {
            var newTraces:ArrayCollection = new ArrayCollection();
            
            if(_visibleTracesCollection != null && _visibleTracesCollection.length > 0) {
                for(var i:int = 0; i < _visibleTracesCollection.length; i++) {
                    if(_visibleTracesCollection.getItemAt(i).selected) {
                        newTraces.addItem(_visibleTracesCollection.getItemAt(i).traceData);
                    }
                }
            }
            
            traceMapper = new TraceMapper(_sequenceProvider, newTraces);
            
            sendNotification(Notifications.LOAD_SEQUENCE);
            
            sendNotification(Notifications.TRACES_FETCHED);
        }
        
        // Private Methods
        private function onVisibleTracesCollectionChange(event:CollectionEvent):void
        {
            updateVisibleTraces();
        }
        
        private function onSequenceProviderChanged(event:SequenceProviderEvent):void
        {
            sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
        }
        
        private function sequenceFetched():void
        {
            sequenceProvider = FeaturedDNASequenceUtils.featuredDNASequenceToSequenceProvider(_sequence);
            
            sequenceProvider.addEventListener(SequenceProviderEvent.SEQUENCE_CHANGED, onSequenceProviderChanged);
            
            sequenceProvider.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_INITIALIZED));
        }
    }
}
