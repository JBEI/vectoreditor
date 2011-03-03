package org.jbei.model.registry
{
	import org.jbei.view.EntryType;

	[RemoteClass(alias="org.jbei.ice.lib.models.Part")]
	public class Part extends Entry
	{
		private var _packageFormat:String;
		
		public function Part()
		{
			this.recordType = EntryType.PART.name.toLowerCase();
		}
		
		public function get packageFormat() : String
		{
			return this._packageFormat;
		}
		
		public function set packageFormat( format:String ) : void
		{
			this._packageFormat = format;
		}
	}
}