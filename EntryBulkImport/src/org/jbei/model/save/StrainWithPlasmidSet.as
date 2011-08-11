package org.jbei.model.save
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.jbei.model.StrainWithPlasmid;
	import org.jbei.model.registry.Plasmid;
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
			if( obj is StrainWithPlasmid )
			{
				var record:StrainWithPlasmid = obj as StrainWithPlasmid;
				this._records.addItem( record );
				return;
			}
			
			if( obj is ArrayCollection ) 
			{
				var collection:ArrayCollection = obj as ArrayCollection;
				var strain:Strain = collection.getItemAt( 0 ) as Strain;
				var plasmid:Plasmid = collection.getItemAt( 1 ) as Plasmid;
				var newRecord:StrainWithPlasmid = new StrainWithPlasmid( strain, plasmid );
				this._records.addItem( newRecord );
			}
		}
	}
}