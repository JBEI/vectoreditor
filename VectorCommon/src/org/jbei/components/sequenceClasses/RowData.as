package org.jbei.components.sequenceClasses
{
	public class RowData
	{
		private var _sequence:String;
		private var _oppositeSequence:String;
		private var _start:int;
		private var _end:int;
		private var _featuresAlignment:Array /* of Array of Feature */;
		private var _cutSitesAlignment:Array /* of Array of CutSite */;
		private var _orfAlignment:Array /* of Array of ORF */;
		
		// Constructor
		public function RowData(start:int, end:int, sequence:String, oppositeSequence:String = null, featuresAlignment:Array = null /* of Array of Feature */, cutSitesAlignment:Array  /* of Array of CutSite */ = null, orfAlignment:Array /* of Array of ORF */= null)
		{
			_start = start;
			_end = end;
			_sequence = sequence;
			_oppositeSequence = oppositeSequence;
			_featuresAlignment = featuresAlignment;
			_cutSitesAlignment = cutSitesAlignment;
			_orfAlignment = orfAlignment;
		}
		
		// Properties
		public function get start():int
		{
			return _start;
		}
		
		public function set start(value:int):void
		{
			_start = value;
		}
		
		public function get end():int
		{
			return _end;
		}
		
		public function set end(value:int):void
		{
			_end = value;
		}
		
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void
		{
			_sequence = value;
		}
		
		public function get oppositeSequence():String
		{
			return _oppositeSequence;
		}
		
		public function set oppositeSequence(value:String):void
		{
			_oppositeSequence = value;
		}
		
		public function get featuresAlignment():Array /* of Array of Feature */
		{
			return _featuresAlignment;
		}
		
		public function set featuresAlignment(value:Array /* of Array of Feature */):void
		{
			_featuresAlignment = value;
		}
		
		public function get cutSitesAlignment():Array /* of Array of CutSite */
		{
			return _cutSitesAlignment;
		}
		
		public function set cutSitesAlignment(value:Array /* of Array of CutSite */):void
		{
			_cutSitesAlignment = value;
		}
		
		public function get orfAlignment():Array /* of Array of ORF */
		{
			return _orfAlignment;
		}
		
		public function set orfAlignment(value:Array /* of Array of ORF */):void
		{
			_orfAlignment = value;
		}
	}
}
