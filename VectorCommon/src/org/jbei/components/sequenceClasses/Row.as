package org.jbei.components.sequenceClasses
{
	import flash.geom.Rectangle;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class Row
	{
		private var _rowData:RowData;
		private var _metrics:Rectangle;
		private var _sequenceMetrics:Rectangle;
		private var _index:int;
		
		// Constructor
		public function Row(index:int, rowData:RowData)
		{
			_index = index;
			_rowData = rowData;
		}
		
		// Properties
		public function get index():int
		{
			return _index;
		}
		
		public function get rowData():RowData
		{
			return _rowData;
		}
		
		public function get metrics():Rectangle
		{
			return _metrics;
		}
		
		public function set metrics(value:Rectangle):void
		{
			_metrics = value;
		}
		
		public function get sequenceMetrics():Rectangle
		{
			return _sequenceMetrics;
		}
		
		public function set sequenceMetrics(value:Rectangle):void
		{
			_sequenceMetrics = value;
		}
	}
}
