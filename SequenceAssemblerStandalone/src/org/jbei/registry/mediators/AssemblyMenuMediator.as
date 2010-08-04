package org.jbei.registry.mediators
{
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyMenuMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "AssemblyMenuMediator";
        
        // Constructor
        public function AssemblyMenuMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
        }
    }
}