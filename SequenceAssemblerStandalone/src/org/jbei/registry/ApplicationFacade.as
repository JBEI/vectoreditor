package org.jbei.registry
{
    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.lib.ActionStack;
    import org.jbei.registry.lib.ActionStackEvent;
    import org.jbei.registry.mediators.ApplicationMediator;
    import org.jbei.registry.mediators.AssemblyPanelMediator;
    import org.jbei.registry.mediators.AssemblyStatusBarMediator;
    import org.jbei.registry.mediators.ResultsPanelMediator;
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.AssemblyProviderEvent;
    import org.jbei.registry.models.AssemblyProviderMemento;
    import org.jbei.registry.models.PermutationSet;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    import org.jbei.registry.utils.AssemblyTableUtils;
    import org.jbei.registry.utils.StandaloneAPIProxy;
    import org.jbei.registry.utils.StandaloneUtils;
    import org.jbei.registry.view.ui.MainPanel;
    import org.jbei.registry.view.ui.assembly.AssemblyStatusBar;
    import org.puremvc.as3.patterns.facade.Facade;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ApplicationFacade extends Facade
    {
        private var initialized:Boolean = false;
        
        private var _project:AssemblyProject;
        private var _assemblyProvider:AssemblyProvider;
        private var _resultPermutations:PermutationSet;
        private var _sessionId:String;
        private var _projectId:String;
        private var _serviceProxy:RegistryAPIProxy;
        private var _actionStack:ActionStack;
        
        // Constructor
        public function ApplicationFacade()
        {
            super();
            
            CONFIG::registryEdition {
                loadProject(new AssemblyProject());
            }
            
            CONFIG::standalone {
                loadProject(StandaloneUtils.standaloneAssemblyProject());
            }
        }
        
        // Properties
        public function get project():AssemblyProject
        {
            return _project;
        }
        
        public function get assemblyProvider():AssemblyProvider
        {
            return _assemblyProvider;
        }
        
        public function get sessionId():String
        {
            return _sessionId;
        }
        
        public function set sessionId(value:String):void
        {
            _sessionId = value;
        }
        
        public function get projectId():String
        {
            return _projectId;
        }
        
        public function get resultPermutations():PermutationSet
        {
            return _resultPermutations;
        }
        
        public function set resultPermutations(value:PermutationSet):void
        {
            _resultPermutations = value;
        }
        
        public function get serviceProxy():RegistryAPIProxy
        {
            return _serviceProxy;
        }
        
        public function set serviceProxy(value:RegistryAPIProxy):void
        {
            _serviceProxy = value;
        }
        
        public function get actionStack():ActionStack
        {
            return _actionStack;
        }
        
        // System Methods
        public static function getInstance():ApplicationFacade
        {
            if(instance == null) {
                instance = new ApplicationFacade();
            }
            
            return instance as ApplicationFacade;
        }
        
        // Public Methods
        public function initialize(mainPanel:MainPanel):void
        {
            _actionStack = new ActionStack();
            _actionStack.addEventListener(ActionStackEvent.ACTION_STACK_CHANGED, onActionStackChanged);
            
            registerMediator(new ApplicationMediator(mainPanel));
            registerMediator(new ResultsPanelMediator(mainPanel.resultsPanel));
            registerMediator(new AssemblyPanelMediator(mainPanel.assemblyPanel));
            
            CONFIG::registryEdition {
                _serviceProxy = new RegistryAPIProxy();
            }
            
            CONFIG::standalone {
                _serviceProxy = new StandaloneAPIProxy();
            }
            
            registerProxy(_serviceProxy);
            
            initialized = true;
            
            Logger.getInstance().info("Application initialized");
            
            sendNotification(Notifications.SWITCH_TO_ASSEMBLY_VIEW);
        }
        
        public function fetchProject(projectId:String):void
        {
            _projectId = projectId;
            
            _serviceProxy.getAssemblyProject(_sessionId, _projectId);
        }
        
        public function loadProject(assemblyProject:AssemblyProject):void
        {
            _project = assemblyProject;
            
            if(_project && _project.assemblyTable) {
                loadAssemblyProvider(AssemblyTableUtils.assemblyTableToAssemblyProvider(_project.assemblyTable));
            }
        }
        
        // Event Handlers
        private function onAssemblyProviderChanged(event:AssemblyProviderEvent):void
        {
            sendNotification(Notifications.ASSEMBLY_PROVIDER_CHANGED);
        }
        
        private function onAssemblyProviderChanging(event:AssemblyProviderEvent):void
        {
            var memento:AssemblyProviderMemento = event.data as AssemblyProviderMemento;
            
            if(memento) {
                _actionStack.add(memento);
            }
        }
        
        private function onActionStackChanged(event:ActionStackEvent):void
        {
            sendNotification(Notifications.ACTION_STACK_CHANGED);
        }
        
        // Private Methods
        private function loadAssemblyProvider(assemblyProvider:AssemblyProvider):void
        {
            _assemblyProvider = assemblyProvider;
            
            if(_assemblyProvider) {
                _assemblyProvider.addEventListener(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGED, onAssemblyProviderChanged);
                _assemblyProvider.addEventListener(AssemblyProviderEvent.ASSEMBLY_PROVIDER_CHANGING, onAssemblyProviderChanging);
                
                sendNotification(Notifications.ASSEMBLY_PROVIDER_CHANGED);
            }
        }
    }
}