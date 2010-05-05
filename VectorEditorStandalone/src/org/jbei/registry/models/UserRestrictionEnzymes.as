package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.services.blazeds.vo.UserRestrictionEnzymes")]
	public class UserRestrictionEnzymes
	{
		private var _groups:ArrayCollection = new ArrayCollection(); /* of UserRestrictionEnzymeGroup */
		private var _activeEnzymeNames:ArrayCollection = new ArrayCollection(); /* of String */
		
		// Constructor
		public function UserRestrictionEnzymes()
		{
		}
		
		// Properties
		public function get activeEnzymeNames():ArrayCollection /* of String */
		{
			return _activeEnzymeNames;
		}
		
		public function set activeEnzymeNames(value:ArrayCollection /* of String */):void
		{
			_activeEnzymeNames = value;
		}
		
		public function get groups():ArrayCollection /* of UserRestrictionEnzymeGroup */
		{
			return _groups;
		}
		
		public function set groups(value:ArrayCollection /* of UserRestrictionEnzymeGroup */):void
		{
			_groups = value;
		}
	}
}
