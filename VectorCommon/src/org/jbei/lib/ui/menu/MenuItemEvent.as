package org.jbei.lib.ui.menu
{
	import flash.events.Event;

	public class MenuItemEvent extends Event
	{
		public var menuItem:MenuItem;
		
		// Constructor
		public function MenuItemEvent(type:String, menuItem:MenuItem, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.menuItem = menuItem;
		}
	}
}
