package org.jbei.model.fields
{
	import mx.controls.Alert;
	
	import org.jbei.view.EntryType;

	/**
	 * Factory for returning the various fields for each entry type
	 */
	public class EntryFieldsFactory
	{
		public static function fieldsForType( type:EntryType ) : EntryFields
		{
			switch( type )
			{
				case EntryType.STRAIN:
					return new StrainFields();
					
				case EntryType.PLASMID:
					return new PlasmidFields();
					
				case EntryType.PART:
					return new PartFields();
					
				case EntryType.ARABIDOPSIS:
					return new ArabidopsisFields();
					
				case EntryType.STRAIN_WITH_PLASMID:
					return new StrainWithPlasmidFields();
			}
			Alert.show( "Attempting to retrieve fields to a null entry type" );
			return null;
		}
	}
}