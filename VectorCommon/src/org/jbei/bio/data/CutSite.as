package org.jbei.bio.data
{
	public class CutSite extends Segment
	{
		private var _restrictionEnzyme:RestrictionEnzyme;
		private var _forward:Boolean;
		private var _numCuts:int;
		
		// Constructor
		public function CutSite(restrictionEnzyme:RestrictionEnzyme, start:int, end:int, forward:Boolean = true, numCuts:int = 0)
		{
			super(start, end);
			
			_restrictionEnzyme = restrictionEnzyme;
			_forward = forward;
			_numCuts = numCuts;
		}
		
		// Properties
		public function get restrictionEnzyme():RestrictionEnzyme
		{
			return _restrictionEnzyme;
		}
		
		public function set restrictionEnzyme(value:RestrictionEnzyme):void
		{
			_restrictionEnzyme = value;
		}
		
		public function get forward():Boolean
		{
			return _forward;
		}
		
		public function set forward(value:Boolean):void
		{
			_forward = value;
		}
		
		public function get label():String
		{
			return _restrictionEnzyme.name;
		}
		
		public function get numCuts():int
		{
			return _numCuts;
		}
		
		public function set numCuts(value:int):void
		{
			_numCuts = value;
		}
	}
}
