package org.jbei.model.save
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.registry.ArabidopsisSeed;
	import org.jbei.view.EntryType;
	
	public class ArabidopsisSet extends EntrySet
	{
		public function ArabidopsisSet()
		{
			super( EntryType.ARABIDOPSIS );
		}
		
		public override function addToSet( obj:Object ) : void 
		{
			_records.addItem( obj as ArabidopsisSeed );
		}
	}
}