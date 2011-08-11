package org.jbei.view.mediators
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.Notifications;
	import org.jbei.model.BulkImportVerifierProxy;
	import org.jbei.model.RegistryAPIProxy;
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
		
		private function init() : void
		{
			this.partTypeOptions.dataProvider = EntryType.values();		
			
			// check if we are verifying
			if( ApplicationFacade.getInstance().importId != null )
			{
				var proxy:RegistryAPIProxy = facade.retrieveProxy( RegistryAPIProxy.NAME ) as RegistryAPIProxy;
				var importId:String = ApplicationFacade.getInstance().importId;
				proxy.retrieveBulkImportEntryType( importId );
			} 
			else
			{
				this.partTypeOptions.selectedItem = EntryType.STRAIN;
				sendNotification( Notifications.PART_TYPE_SELECTION, partTypeOptions.selectedItem );
			}
		}
		
		protected function get partTypeOptions() : PartTypeOptions
		{
			return viewComponent as PartTypeOptions;
		}
		
		override public function getMediatorName():String
		{
			return NAME;
		}
		
		override public function listNotificationInterests() : Array
		{
			return [ Notifications.PART_TYPE_SELECTION];
		}
		
		override public function handleNotification( notification:INotification ) : void
		{
			switch( notification.getName() )
			{
				case Notifications.PART_TYPE_SELECTION:
					var type:EntryType = notification.getBody() as EntryType;
					this.partTypeOptions.selectedItem = type;
					ApplicationFacade.getInstance().selectedType = type;
					break;
			}
		}
		
		// event handlers
		private function onChange( event:Event ) : void
		{
			sendNotification( Notifications.PART_TYPE_SELECTION, partTypeOptions.selectedItem );
		}
	}
}