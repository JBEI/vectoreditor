package org.jbei.view.mediators
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	import org.jbei.Notifications;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.PartTypeOptions;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class PartTypeOptionsMediator extends Mediator implements IMediator
	{
		private static const NAME:String = "org.jbei.view.PartTypeOptionsMediator";
		
		public function PartTypeOptionsMediator( viewComponent:PartTypeOptions )
		{
			super( NAME, viewComponent );
			this.init();
			
			this.partTypeOptions.addEventListener( Event.CHANGE, onChange );
		}
		
		protected function get partTypeOptions() : PartTypeOptions
		{
			return viewComponent as PartTypeOptions;
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		private function init() : void
		{
			var arrayCollection:ArrayCollection = new ArrayCollection();
			arrayCollection.addItem( EntryType.STRAIN );
			arrayCollection.addItem( EntryType.PLASMID );
			arrayCollection.addItem( EntryType.STRAIN_WITH_PLASMID );
			arrayCollection.addItem( EntryType.PART );
			arrayCollection.addItem( EntryType.ARABIDOPSIS );
			this.partTypeOptions.dataProvider = arrayCollection;			
		}
		
		// event handlers
		private function onChange( event:Event ) : void
		{
			sendNotification( Notifications.PART_TYPE_SELECTION, partTypeOptions.selectedItem );
		}
	}
}