package org.jbei.model.save
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.registry.Plasmid;
	import org.jbei.view.EntryType;
	
	public class PlasmidSet extends EntrySet
	{
		public function PlasmidSet()
		{
			super( EntryType.PLASMID );
		}
		
		public override function addToSet( obj:Object ) : void 
		{
			_records.addItem( obj as Plasmid );
		}
	}
}