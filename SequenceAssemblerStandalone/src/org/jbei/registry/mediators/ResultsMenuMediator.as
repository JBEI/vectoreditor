package org.jbei.registry.mediators
{
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsMenuMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsMenuMediator";
        
        // Constructor
        public function ResultsMenuMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
        }
    }
}