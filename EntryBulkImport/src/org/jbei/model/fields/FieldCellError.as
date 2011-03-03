package org.jbei.model.fields
{
	import org.jbei.Notifications;
	import org.jbei.view.components.GridCell;

	public class FieldCellError
	{
		private var _cell:GridCell;
		private var _errMsg:String;
		
		public function FieldCellError( cell:GridCell, errMsg:String )
		{
			this._cell = cell;
			this._errMsg = errMsg;
		}
		
		public function get cell() : GridCell
		{
			return this._cell;
		}
		
		public function get errorMessage() : String
		{
			return this._errMsg;
		}
	}
}