package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Link")]
	public class Link
	{
		private var _url:String;
		private var _link:String;
		private var _entry:Entry;
		
		// Constructor
		public function Link(url:String = null, link:String = null)	
		{
			_url = url;
			_link = link;
		}
		
		// Properties
		public function get url():String	
		{
			return _url;
		}
		
		public function set url(value:String):void	
		{
			_url = value;
		}
		
		public function get link():String	
		{
			return _link;
		}
		
		public function set link(value:String):void	
		{
			_link = value;
		}
		
		public function get entry():Entry
		{
			return _entry;
		}
		
		public function set entry(value:Entry):void	
		{
			_entry = value;
		}
		
		// Public Methods
		public function toString():String
		{
			return _link;
		}
	}
}
