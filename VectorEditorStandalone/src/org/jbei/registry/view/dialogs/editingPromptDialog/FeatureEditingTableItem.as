package org.jbei.registry.view.dialogs.editingPromptDialog
{
	import flash.events.EventDispatcher;
	
	import org.jbei.bio.data.Feature;
	
	public class FeatureEditingTableItem extends EventDispatcher
	{
		[Bindable]
		public var feature:Feature;
		
		[Bindable]
		public var removeAction:Boolean;
		
		[Bindable]
		public var enabled:Boolean;
		
		[Bindable]
		public var position:String;
		
		// Constructor
		public function FeatureEditingTableItem(feature:Feature, removeAction:Boolean, enabled:Boolean)
		{
			super();
			
			this.feature = feature;
			this.removeAction = removeAction;
			this.enabled = enabled;
			position = feature.start + " - " + feature.end;
		}
	}
}
