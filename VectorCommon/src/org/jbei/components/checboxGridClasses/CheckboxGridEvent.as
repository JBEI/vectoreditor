package org.jbei.components.checboxGridClasses
{
    import flash.events.Event;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class CheckboxGridEvent extends Event
    {
        public static const CHECKBOX_SELECTION_CHANGED:String = "checkboxSelectionChanged";
        
        // Constructor
        public function CheckboxGridEvent(type:String)
        {
            super(type, false, false);
        }
    }
}