package org.jbei.components.common
{
	import flash.events.Event;
	
    /**
     * Editing Event for Pie, Rail and SequenceAnnotator components
     * 
     * @author Zinovii Dmytriv
     */
	public class EditingEvent extends Event
	{
		public static const COMPONENT_SEQUENCE_EDITING:String = "ComponentSequenceEditing";
		
		public static const KIND_INSERT_SEQUENCE:String = "KIND_INSERT_SEQUENCE";
		public static const KIND_INSERT_FEATURED_SEQUENCE:String = "KIND_INSERT_FEATURED_SEQUENCE";
		public static const KIND_DELETE:String = "KIND_DELETE";
		
		public var kind:String;
		public var data:Object;
		
		// Contructor
        /**
         * Contructor
         */
		public function EditingEvent(type:String, kind:String, data:Object)
		{
			super(type, true, true);
			
			this.kind = kind;
			this.data = data;
		}
	}
}
