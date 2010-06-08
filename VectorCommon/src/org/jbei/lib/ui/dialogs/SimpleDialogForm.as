package org.jbei.lib.ui.dialogs
{
	import mx.containers.Box;

    /**
     * @author Zinovii Dmytriv
     */
	public class SimpleDialogForm extends Box
	{
		private var _dataObject:Object;
		private var _dialog:SimpleDialog;
		
		// Constructor
		public function SimpleDialogForm()
		{
			super();
		}
		
		// Properties
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
		}
		
		public function get dialog():SimpleDialog
		{
			return _dialog;
		}
		
		public function set dialog(value:SimpleDialog):void
		{
			_dialog = value;
		}
		
		// Public Methods
		public function initialization(dataObject:Object):void
		{
			this._dataObject = dataObject;
			
			// Abstract Method
		}
	}
}
