package org.jbei.components.common
{
    import flash.events.Event;
    
    /**
     * Common Event for Pie, Rail and SequenceAnnotator components
     * 
     * @author Zinovii Dmytriv
     */
    public class CommonEvent extends Event
    {
        public static const BEFORE_UPDATE:String = "beforeUpdate";
        public static const AFTER_UPDATE:String = "afterUpdate";
        
        public static const EDIT_FEATURE:String = "editFeature";
        public static const REMOVE_FEATURE:String = "removeFeature";
        public static const CREATE_FEATURE:String = "createFeature";
        
        public static const ACTION_MESSAGE:String = "ActionMessage";
        
        public var data:Object;
        
        // Contructor
        /**
        * Contructor
        */
        public function CommonEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null)
        {
            super(type, bubbles, cancelable);
            
            this.data = data;
        }
    }
}
