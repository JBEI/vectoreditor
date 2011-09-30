package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

	[RemoteClass(alias="org.jbei.ice.lib.vo.DNAFeature")]
    /**
     * @author Zinovii Dmytriv
     */
	public class DNAFeature
	{
		private var _name:String;
		private var _type:String;
		private var _strand:int;
		private var _notes:ArrayCollection /* of DNAFeatureNote */;
		private var _locations:ArrayCollection; /* of DNAFeatureLocation*/
		private var _annotationType:String;
		
		// Contructor
		public function DNAFeature(genbankStart:int = 0, end:int = 0, strand:int = 0, name:String = "", notes:ArrayCollection = null /* of DNAFeatureNote */, type:String = "", annotationType:String = null)
		{
			_strand = strand;
			_name = name;
			_notes = notes;
			_type = type;
			_annotationType = annotationType;
			_locations = new ArrayCollection();
			_locations.addItem(new DNAFeatureLocation(genbankStart, end));
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
		
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get strand():int
		{
			return _strand;
		}
		
		public function set strand(value:int):void
		{
			_strand = value;
		}
		
		public function get notes():ArrayCollection /* of DNAFeatureNote */
		{
			return _notes;
		}
		
		public function set notes(value:ArrayCollection /* of DNAFeatureNote */):void
		{
			_notes = value;
		}
		
		public function get locations():ArrayCollection /* of DNAFeatureLocation*/
		{
			return _locations;
		}
		
		public function set locations(locations:ArrayCollection /* of DNAFeatureLocation*/):void
		{
			_locations = locations;
		}
		
		public function get annotationType():String
		{
			return _annotationType;
		}
		
		public function set annotationType(value:String):void
		{
			_annotationType = value;
		}
	}
}
