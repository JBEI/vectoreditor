package org.jbei.bio.data
{
	import org.jbei.registry.model.vo.RestrictionEnzyme;
	
	public class CutSite implements IAnnotation
	{
		private var _restrictionEnzyme:RestrictionEnzyme;
		private var _start:int;
		private var _end:int;
		private var _forward:Boolean;
		private var _numCuts:int;
		
		// Constructor
		public function CutSite(restrictionEnzyme:RestrictionEnzyme, start:int, end:int, forward:Boolean = true, numCuts:int = 0)
		{
			_restrictionEnzyme = restrictionEnzyme;
			_start = start;
			_end = end;
			_forward = forward;
			_numCuts = numCuts;
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
