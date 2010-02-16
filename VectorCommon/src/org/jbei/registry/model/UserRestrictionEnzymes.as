package org.jbei.registry.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.services.blazeds.VectorEditor.vo.UserRestrictionEnzymes")]
	public class UserRestrictionEnzymes
	{
		private var _groups:ArrayCollection = new ArrayCollection(); /* of RestrictionEnzymeGroup */
		private var _activeGroup:ArrayCollection = new ArrayCollection(); /* of RestrictionEnzyme */
		
		// Constructor
		public function UserRestrictionEnzymes()
		{
		}
		
		// Properties
		public function get activeGroup():ArrayCollection /* of RestrictionEnzyme */
		{
			return _activeGroup;
		}
		
		public function set activeGroup(value:ArrayCollection /* of RestrictionEnzyme */):void
		{
			_activeGroup = value;
		}
		
		public function get groups():ArrayCollection /* of RestrictionEnzymeGroup */
		{
			return _groups;
		}
		
		public function set groups(value:ArrayCollection /* of RestrictionEnzymeGroup */):void
		{
			_groups = value;
		}
	}
}
