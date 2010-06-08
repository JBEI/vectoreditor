package org.jbei.bio.data
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.enzymes.RestrictionEnzyme;
	
	[RemoteClass(alias="org.jbei.ice.services.blazeds.vo.RestrictionEnzymeGroup")]
	public class RestrictionEnzymeGroup
	{
		private var _enzymes:Vector.<RestrictionEnzyme> /* of RestrictionEnzyme */ = new Vector.<RestrictionEnzyme>();
		private var _name:String;
		
		// Constructor
		public function RestrictionEnzymeGroup(name:String = "")
		{
			_name = name;
		}
		
		// Properties
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get enzymes():Vector.<RestrictionEnzyme> /* of RestrictionEnzyme */
		{
			return _enzymes;
		}
		
		public function set enzymes(value:Vector.<RestrictionEnzyme> /* of RestrictionEnzyme */):void
		{
			_enzymes = value;
		}
		
		// Public Methods
		public function addRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme):void
		{
			if(_enzymes.indexOf(restrictionEnzyme) == -1) {
				_enzymes.push(restrictionEnzyme);
			} else {
				throw new Error("Duplicate Restriction Enzyme! Restriction Enzyme already in the set!");
			}
		}
		
		public function removeRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme):void
		{
            var index:int = _enzymes.indexOf(restrictionEnzyme);
            
            if(index == -1) {
				throw new Error("Can't delete Restriction Enzyme! It doesn't belong to this set!");
			}
			
			_enzymes.splice(index, 1);
		}
		
		public function hasEnzyme(restrictionEnzyme:RestrictionEnzyme):Boolean
		{
			var result:Boolean = false;
			
			for(var i:int = 0; i < enzymes.length; i++) {
				if(enzymes[i] == restrictionEnzyme) {
					result = true;
					break;
				}
			}
			
			return result;
		}
		
		public function getRestrictionEnzyme(index:int):RestrictionEnzyme
		{
			if(index < 0 || index >= enzymes.length) {
				throw new Error("Index is out of bound!");
			}
			
			return enzymes[index] as RestrictionEnzyme;
		}
	}
}
