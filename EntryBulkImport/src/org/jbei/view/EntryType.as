package org.jbei.view
{
	import mx.collections.ArrayCollection;

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
		
		public static function valueOf( name:String ) : EntryType 
		{
			switch( name.toLowerCase() ) 
			{
				case "strain":
					return  STRAIN;
					
				case "plasmid":
					return PLASMID;
					
				case "part":
					return PART;
					
				case "strain w/ plasmid":
					return STRAIN_WITH_PLASMID;
					
				case "arabidopsis":
					return ARABIDOPSIS;
			}
			
			return null;
		} 
		
		public static function values() : ArrayCollection	// <EntryType> 
		{
			var collection:ArrayCollection = new ArrayCollection();
			collection.addItem( EntryType.STRAIN );
			collection.addItem( EntryType.PLASMID );
			collection.addItem( EntryType.STRAIN_WITH_PLASMID );
			collection.addItem( EntryType.PART );
			collection.addItem( EntryType.ARABIDOPSIS );
			return collection;
		}
	}
}