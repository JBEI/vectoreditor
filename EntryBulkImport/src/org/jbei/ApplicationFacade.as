package org.jbei
{
	import mx.controls.Alert;
	
	import org.jbei.controller.CancelCommand;
	import org.jbei.controller.ModelDataPrepCommand;
	import org.jbei.controller.PasteCommand;
	import org.jbei.controller.SaveCommand;
	import org.jbei.controller.StartupCommand;
	import org.jbei.model.RegistryAPIProxy;
	import org.jbei.model.registry.Entry;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.HeaderTextInput;
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const REMOTE_SERVICE_NAME:String = "RegistryAMFAPI";
		
		private var _input:HeaderTextInput;
		private var _sessionId:String;
		private var _importId:String;
		private var _app:EntryBulkImport;
		private var _selected:EntryType;
		
		
		public function get selectedType() : EntryType
		{
			return this._selected;
		}
		
		public function set selectedType( selected:EntryType ) : void
		{
			this._selected = selected;
		}
		
		public function get importId() : String 
		{
			return this._importId;
		}
		
		public function set importId( value:String ) : void
		{
			this._importId = value;
		}
		
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
			
			registerCommand( Notifications.MODEL_DATA_PREP, ModelDataPrepCommand );
			registerCommand( Notifications.START_UP, StartupCommand );
			registerCommand( Notifications.SAVE, SaveCommand );
			registerCommand( Notifications.PASTE, PasteCommand );
			registerCommand( Notifications.CANCEL, CancelCommand );
		}
		
		// start the pureMVC apparatus
		public function startup( app : EntryBulkImport ) : void 
		{
			this._app = app;
//			sendNotification( Notifications.START_UP, app );
			sendNotification( Notifications.MODEL_DATA_PREP, app );
		}
		
		public function get application() : EntryBulkImport
		{
			return this._app;
		}
	}
}