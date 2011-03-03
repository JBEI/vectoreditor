package org.jbei.model
{
	import mx.collections.ArrayCollection;
	
	import org.jbei.view.EntryType;

	public class EntryTypeField
	{
		private var _name:String; 
		private var _required:Boolean;
		
		public function EntryTypeField( field:EntryTypeField, name:String, required:Boolean, validation:Function=null )
		{
			this._name = name;
			this._required = required;
		}
		
		public function get name() : String
		{
			return this._name;			
		}
		
		public function get required() : Boolean
		{
			return this._required;
		}
	}
}