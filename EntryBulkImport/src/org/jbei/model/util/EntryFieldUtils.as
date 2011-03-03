package org.jbei.model.util
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.RegistryAPIProxy;
	import org.jbei.model.fields.PlasmidFields;
	import org.jbei.model.fields.StrainFields;
	import org.jbei.model.fields.StrainWithPlasmidFields;

	public class EntryFieldUtils
	{
		private static var _selectionMarkers:ArrayCollection;
		private static var _promoters:ArrayCollection;
		private static var _origins:ArrayCollection;
		
		public static function set uniqueOrigins( origins:ArrayCollection ) : void
		{
			_origins = origins;
		}
		
		public static function set uniquePromoters( promoters:ArrayCollection ) : void
		{
			_promoters = promoters;
		}
		
		public static function set uniqueSelectionMarkers( markers:ArrayCollection ) : void
		{
			_selectionMarkers = markers;
		}
		
		public static function autoCompleteDataProvider( entryTypeField:EntryTypeField ) : ArrayCollection
		{
			switch( entryTypeField )
			{
//				case EntryTypeField.SELECTION_MARKERS:
				case StrainFields.SELECTION_MARKERS:
				case PlasmidFields.SELECTION_MARKERS:
				case StrainWithPlasmidFields.PLASMID_SELECTION_MARKERS:
				case StrainWithPlasmidFields.STRAIN_SELECTION_MARKERS:
					return _selectionMarkers;
					
//				case EntryTypeField.ORIGIN_OF_REPLICATION:
				case PlasmidFields.ORIGIN_OF_REPLICATION:
				case StrainWithPlasmidFields.PLASMID_ORIGIN_OF_REPLICATION:
					return _origins;
					
//				case EntryTypeField.PROMOTERS:
				case PlasmidFields.PROMOTERS:
				case StrainWithPlasmidFields.PLASMID_PROMOTERS:
					return _promoters;
			}
			
			return null;
		}
	}
}