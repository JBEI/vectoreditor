package org.jbei.lib.ui.dialogs
{
	import mx.containers.Box;

    /**
     * @author Zinovii Dmytriv
     */
	public class AbstractDialogForm extends Box
	{
		private var _dataObject:Object;
		private var _isValid:Boolean = false;
		private var _dialog:ModalDialog;
		
		// Constructor
		public function AbstractDialogForm()
		{
			super();
		}
		
		// Properties
		public function get isValid():Boolean
		{
			return _isValid;
		}
		
		public function set isValid(value:Boolean):void
		{
			_isValid = value;
		}
		
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		public function set dataObject(value:Object):void
		{
			_dataObject = value;
		}
		
		public function get dialog():ModalDialog
		{
			return _dialog;
		}
		
		public function set dialog(value:ModalDialog):void
		{
			_dialog = value;
		}
		
		// Public Methods
		public function initialization(dataObject:Object):void
		{
			this._dataObject = dataObject;
			
			// Abstract Method
		}
		
		public function validate():void
		{
			// Abstract Method
			
			_isValid = true;
		}
	}
}
