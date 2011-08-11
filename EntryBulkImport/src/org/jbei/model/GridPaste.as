package org.jbei.model
{	
	import mx.collections.ArrayCollection;
	
	public class GridPaste
	{
		private var _row:int;
		private var _col:int;
		private var _dist:ArrayCollection;				// of <Array>
		
		public function GridPaste( row:int, col:int )
		{
			this._row = row;
			this._col = col;
		}

		public function set dist( dist:ArrayCollection ) : void
		{
			this._dist = dist;
		}
		
		public function get dist() : ArrayCollection
		{
			return this._dist;
		}
		
		public function get row() : int
		{
			return this._row;
		}
		
		public function get col() : int
		{
			return this._col;
		}
		
	}
}