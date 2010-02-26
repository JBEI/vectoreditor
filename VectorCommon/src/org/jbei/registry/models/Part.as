package org.jbei.registry.models
{
	[Bindable]
	[RemoteClass(alias="org.jbei.ice.lib.models.Part")]
	public class Part extends Entry
	{
		private var _packageFormat:String;
		private var _pkgdDnaFwdHash:String;
		private var _pkgdDnaRevHash:String;
		
		// Properties
		public function get packageFormat():String
		{
			return _packageFormat;
		}
		
		public function set packageFormat(value:String):void	
		{
			_packageFormat = value;
		}
		
		public function get pkgdDnaFwdHash():String
		{
			return _pkgdDnaFwdHash;
		}
		
		public function set pkgdDnaFwdHash(value:String):void	
		{
			_pkgdDnaFwdHash = value;
		}
		
		public function get pkgdDnaRevHash():String
		{
			return _pkgdDnaRevHash;
		}
		
		public function set pkgdDnaRevHash(value:String):void
		{
			_pkgdDnaRevHash = value;
		}
	}
}
