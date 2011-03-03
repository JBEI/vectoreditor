package org.jbei.view
{
	/**
	 * "Enum" for the part types 
	 */
	public class EntryType
	{
		public static const STRAIN:EntryType = new EntryType( STRAIN, "Strain" );
		public static const PLASMID:EntryType = new EntryType( PLASMID, "Plasmid" );
		public static const STRAIN_WITH_PLASMID:EntryType = new EntryType( STRAIN_WITH_PLASMID, "Strain w/ Plasmid" );
		public static const PART:EntryType = new EntryType( PART, "Part" );
		public static const ARABIDOPSIS:EntryType = new EntryType( ARABIDOPSIS, "Arabidopsis" );
		
		private var _name:String;
		
		public function EntryType( entry:EntryType, name:String )
		{
			this._name = name;
		}
		
		public function get name() : String
		{
			return this._name;
		}
	}
}