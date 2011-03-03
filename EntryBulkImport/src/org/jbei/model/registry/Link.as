package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Link")]
	public class Link
	{
		private var _id:Number;
		private var _link:String;
		private var _url:String;
		private var _entry:Entry;
		
		public function get id() : Number
		{
			return this._id;
		}
		
		public function set id( id:Number ) : void
		{
			this._id = id;
		}
		
		public function get link() : String
		{
			return this._link;
		}
		
		public function set link( link:String ) : void
		{
			this._link = link;
		}
		
		public function get url() : String
		{
			return this._url;
		}
		
		public function set url( url:String ) : void
		{
			this._url = url;
		}
		
		public function get entry() : Entry
		{
			return this._entry;
		}
		
		public function set entry( entry:Entry ) : void
		{
			this._entry = entry;
		}
	}
}