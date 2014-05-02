package org.jbei.registry
{
    import mx.collections.ArrayCollection;

    import org.jbei.components.common.ISequenceComponent;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.SequenceProviderEvent;
    import org.jbei.lib.data.RestrictionEnzymeGroup;
    import org.jbei.lib.mappers.AAMapper;
    import org.jbei.lib.mappers.ORFMapper;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;
    import org.jbei.registry.control.RestrictionEnzymeGroupManager;
    import org.jbei.registry.mediators.ApplicationMediator;
    import org.jbei.registry.mediators.FindPanelMediator;
    import org.jbei.registry.mediators.MainControlBarMediator;
    import org.jbei.registry.mediators.MainPanelMediator;
    import org.jbei.registry.mediators.StatusBarMediator;
    import org.jbei.registry.models.FeaturedDNASequence;
    import org.jbei.registry.proxies.RESTClientProxy;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    import org.jbei.registry.utils.FeaturedDNASequenceUtils;
    import org.jbei.registry.utils.StandaloneUtils;
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
        private var _sequence:FeaturedDNASequence;
        private var _orfMapper:ORFMapper;
        private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
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

        public function get restServiceProxy():RESTClientProxy
        {
            return ApplicationFacade.getInstance().retrieveProxy(RESTClientProxy.PROXY_NAME) as RESTClientProxy;
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
            
            // Register Proxy
//            registerProxy(new RegistryAPIProxy());
            registerProxy(new RESTClientProxy());
            
            // Register Mediators
            registerMediator(new ApplicationMediator());
            registerMediator(new MainControlBarMediator(_application.mainControlBar));
            registerMediator(new MainPanelMediator(_application.mainPanel));
            registerMediator(new StatusBarMediator(_application.statusBar));
            registerMediator(new FindPanelMediator(_application.findPanel));
            
            RestrictionEnzymeGroupManager.instance.loadRebaseDatabase();
            
            CONFIG::registryEdition {
//                registryServiceProxy.fetchSequence(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
                var entry:int = parseInt(ApplicationFacade.getInstance().entryId);
                restServiceProxy.retrieveSequence(entry, ApplicationFacade.getInstance().sessionId);
            }
            
            CONFIG::standalone {
                updateSequence(StandaloneUtils.standaloneSequence());
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
            
            sequenceInitialized = true;
        }
        
        // Private Methods
        private function onSequenceProviderChanged(event:SequenceProviderEvent):void
        {
            sendNotification(Notifications.SEQUENCE_PROVIDER_CHANGED, event.data, event.kind);
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
        }
    }
}
