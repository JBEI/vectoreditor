package org.jbei.registry
{
    import org.jbei.lib.utils.Logger;
    import org.jbei.registry.mediators.ApplicationMediator;
    import org.jbei.registry.mediators.AssemblyPanelMediator;
    import org.jbei.registry.mediators.AssemblyStatusBarMediator;
    import org.jbei.registry.mediators.ResultsPanelMediator;
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.PermutationSet;
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
        private var _resultPermutations:PermutationSet;
        private var _sessionId:String;
        
        // Constructor
        public function ApplicationFacade()
        {
            super();
            
            _project = StandaloneUtils.standaloneAssemblyProject();
        }
        
        // Properties
        public function get project():AssemblyProject
        {
            return _project;
        }
        
        public function set project(value:AssemblyProject):void
        {
            _project = value;
        }
        
        public function get sessionId():String
        {
            return _sessionId;
        }
        
        public function set sessionId(value:String):void
        {
            _sessionId = value;
        }
        
        public function get resultPermutations():PermutationSet
        {
            return _resultPermutations;
        }
        
        public function set resultPermutations(value:PermutationSet):void
        {
            _resultPermutations = value;
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
            registerMediator(new ApplicationMediator(mainPanel));
            registerMediator(new ResultsPanelMediator(mainPanel.resultsPanel));
            registerMediator(new AssemblyPanelMediator(mainPanel.assemblyPanel));
            
            initialized = true;
            
            Logger.getInstance().info("Application initialized");
            
            sendNotification(Notifications.SWITCH_TO_ASSEMBLY_VIEW);
        }
    }
}