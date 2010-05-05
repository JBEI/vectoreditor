package org.jbei.bio.data
{
	import mx.collections.ArrayCollection;
	
	[RemoteClass(alias="org.jbei.ice.services.blazeds.vo.RestrictionEnzymeGroup")]
	public class RestrictionEnzymeGroup
	{
		private var _enzymes:ArrayCollection /* of RestrictionEnzyme */ = new ArrayCollection();
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
		
		public function get enzymes():ArrayCollection /* of RestrictionEnzyme */
		{
			return _enzymes;
		}
		
		public function set enzymes(value:ArrayCollection /* of RestrictionEnzyme */):void
		{
			_enzymes = value;
		}
		
		// Public Methods
		public function addRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme):void
		{
			if(! _enzymes.contains(restrictionEnzyme)) {
				_enzymes.addItem(restrictionEnzyme);
			} else {
				throw new Error("Duplicate Restriction Enzyme! Restriction Enzyme already in the set!");
			}
		}
		
		public function removeRestrictionEnzyme(restrictionEnzyme:RestrictionEnzyme):void
		{
			if(!_enzymes.contains(restrictionEnzyme)) {
				throw new Error("Can't delete Restriction Enzyme! It doesn't belong to this set!");
			}
			
			_enzymes.removeItemAt(_enzymes.getItemIndex(restrictionEnzyme));
		}
		
		public function removeAll():void
		{
			_enzymes.removeAll();
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
