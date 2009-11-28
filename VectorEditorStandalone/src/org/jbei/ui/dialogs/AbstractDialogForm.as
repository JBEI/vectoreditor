package org.jbei.ui.dialogs
{
	import mx.containers.Box;

	public class AbstractDialogForm extends Box
	{
		private var _dataObject:Object;
		private var _isValid:Boolean = false;
		
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
