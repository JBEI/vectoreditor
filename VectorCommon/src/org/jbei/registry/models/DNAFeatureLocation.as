package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.vo.DNAFeatureLocation")]
	/**
	 * 
	 * @author Timothy Ham
	 */
	public class DNAFeatureLocation
	{
		private var _genbankStart:int;
		private var _end:int;
		private var _singleResidue:Boolean;
		private var _inBetween:Boolean;
		
		// Constructor
		public function DNAFeatureLocation(genbankStart:int = 0, end:int =0, singleResidue:Boolean = false, inBetween:Boolean = false)
		{
			_genbankStart = genbankStart;
			_end = end;
			_singleResidue = singleResidue;
			_inBetween = inBetween;
		}
		
		// Properties
		public function get genbankStart():int
		{
			return _genbankStart;
		}
		
		public function set genbankStart(genbankStart:int):void
		{
			_genbankStart = genbankStart;
		}
		
		public function get end():int
		{
			return _end;
		}
		
		public function set end(end:int):void
		{
			_end = end;
		}
		
		public function get singleResidue():Boolean
		{
			return _singleResidue;
		}
		
		public function set singleResidue(singleResidue:Boolean):void
		{
			_singleResidue = singleResidue;
		}
		
		public function get inBetween():Boolean
		{
			return _inBetween;
		}
		
		public function set inBetween(inBetween:Boolean):void
		{
			_inBetween = inBetween;
		}			
				
		
	}
}