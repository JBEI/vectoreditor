package org.jbei.model.save
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.StrainWithPlasmid;
	import org.jbei.model.registry.Strain;
	import org.jbei.view.EntryType;

	public class StrainWithPlasmidSet extends EntrySet
	{
		public function StrainWithPlasmidSet( type:EntryType )
		{
			super( type );
		}
		
		public override function addToSet( obj:Object ) : void
		{
			var record:StrainWithPlasmid = obj as StrainWithPlasmid;
			this._records.addItem( record );
		}
	}
}