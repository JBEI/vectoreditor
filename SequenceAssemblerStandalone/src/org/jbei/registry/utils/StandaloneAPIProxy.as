package org.jbei.registry.utils
{
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.proxies.AbstractServiceProxy;
    import org.jbei.registry.proxies.RegistryAPIProxy;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneAPIProxy extends RegistryAPIProxy
    {
        // Constructor
        public function StandaloneAPIProxy()
        {
            super();
        }
        
        // Public Methods
        public override function createAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            trace("created project");
            
            project.uuid = "asdf";
            project.ownerEmail = "zdmytriv@lbl.gov";
            project.ownerName = "Zinovii Dmytriv";
            project.creationTime = new Date();
            project.modificationTime = new Date();
        }
        
        public override function getAssemblyProject(sessionId:String, projectId:String):void
        {
            trace("fetched project");
        }
        
        public override function saveAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            project.modificationTime = new Date();
            
            trace("saved project");
        }
        
        public override function assembleAssemblyProject(sessionId:String, project:AssemblyProject):void
        {
            trace("assemble project");
        }
    }
}