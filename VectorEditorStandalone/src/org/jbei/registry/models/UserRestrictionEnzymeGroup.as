package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.services.blazeds.vo.UserRestrictionEnzymeGroup")]
    /**
     * @author Zinovii Dmytriv
     */
	public class UserRestrictionEnzymeGroup
	{
		private var _groupName:String;
		private var _enzymeNames:ArrayCollection;
		
		// Constructor
		public function UserRestrictionEnzymeGroup(groupName:String = "", enzymeNames:ArrayCollection /* of String */ = null)
		{
			_groupName = groupName;
			_enzymeNames = enzymeNames;
		}
		
		// Properties
		public function get groupName():String
		{
			return _groupName;
		}
		
		public function set groupName(value:String):void
		{
			_groupName = value;
		}
		
		public function get enzymeNames():ArrayCollection
		{
			return _enzymeNames;
		}
		
		public function set enzymeNames(value:ArrayCollection):void
		{
			_enzymeNames = value;
		}
	}
}
