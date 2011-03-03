package org.jbei.model.save
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.registry.Part;
	import org.jbei.view.EntryType;
	
	public class PartSet extends EntrySet
	{
		public function PartSet()
		{
			super( EntryType.PART );
		}
		
		public override function addToSet( obj:Object ) : void 
		{
			_records.addItem( obj as Part );
		}
	}
}