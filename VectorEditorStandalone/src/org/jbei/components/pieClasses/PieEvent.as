package org.jbei.components.pieClasses
{
	import org.jbei.components.common.CommonEvent;

	public class PieEvent extends CommonEvent
	{
		public static const BEFORE_UPDATE:String = "beforeUpdate";
		public static const AFTER_UPDATE:String = "afterUpdate";
		
		public static const EDIT_FEATURE:String = "editFeature";
		public static const CREATE_FEATURE:String = "createFeature";
		
		// Contructor
		public function PieEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object = null)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
	}
}
