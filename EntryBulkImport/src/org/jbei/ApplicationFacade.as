package org.jbei
{
	import org.jbei.controller.CancelCommand;
	import org.jbei.controller.EntryFieldsCommand;
	import org.jbei.controller.PasteCommand;
	import org.jbei.controller.SaveCommand;
	import org.jbei.controller.StartupCommand;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.HeaderTextInput;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const REMOTE_SERVICE_NAME:String = "RegistryAMFAPI";
		
		private var _input:HeaderTextInput;
		private var _sessionId:String;
		private var _app:EntryBulkImport;
		
		public function get sessionId() : String
		{
			return this._sessionId;
		}
		
		public function set sessionId( value:String ) : void
		{
			this._sessionId = value;
		}
		
		public static function getInstance() : ApplicationFacade
		{
			if( instance == null )
			{
				instance = new ApplicationFacade();
			}
			return instance as ApplicationFacade;
		}
		
		// register commands with controller
		override protected function initializeController() : void 
		{
			super.initializeController();
			
			registerCommand( Notifications.START_UP, StartupCommand );
			registerCommand( Notifications.PART_TYPE_SELECTION, EntryFieldsCommand );
			registerCommand( Notifications.SAVE, SaveCommand );
			registerCommand( Notifications.PASTE, PasteCommand );
			registerCommand( Notifications.CANCEL, CancelCommand );
		}
		
		// start the pureMVC apparatus
		public function startup( app : EntryBulkImport ) : void 
		{
			this._app = app;
			sendNotification( Notifications.START_UP, app );
			
			// selecting default
			app.partOptions.selectedItem = EntryType.STRAIN;
			sendNotification( Notifications.PART_TYPE_SELECTION, EntryType.STRAIN );
		}
		
		public function get application() : EntryBulkImport
		{
			return this._app;
		}
	}
}