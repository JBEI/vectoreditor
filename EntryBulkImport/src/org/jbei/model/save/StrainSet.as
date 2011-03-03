package org.jbei.model.save
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.registry.Strain;
	import org.jbei.view.EntryType;

	public class StrainSet extends EntrySet
	{
		public function StrainSet( type:EntryType )
		{
			super( type );
		}
		
		public override function addToSet( obj:Object ) : void 
		{
			_records.addItem( obj as Strain );
		}
	}
}