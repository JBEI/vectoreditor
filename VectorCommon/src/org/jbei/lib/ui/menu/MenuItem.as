package org.jbei.lib.ui.menu
{
	[Bindable]
	public class MenuItem
	{
		public var id:String;
		public var label:String;
		public var type:String;
		public var toggled:Boolean;
		public var selected:Boolean;
		public var children:Array;
		public var enabled:Boolean;
		
		// Constructor
		public function MenuItem(id:String, label:String, type:String="", toggled:Boolean = false, selected:Boolean = false, enabled:Boolean = true)
		{
			this.id = id;
			this.label = label;
			this.type = type;
			this.toggled = toggled;
			this.selected = selected;
			this.enabled = enabled;
		}
		
		// Public Methods
		public function addSubItem(menuItem:MenuItem):void
		{
			if(children == null) {
				children = new Array();
			}
			
			children.push(menuItem);
		}
	}
}
