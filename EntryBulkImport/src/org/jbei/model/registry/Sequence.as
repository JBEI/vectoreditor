package org.jbei.model.registry
{
	[RemoteClass(alias="org.jbei.ice.lib.models.Sequence")]
	public class Sequence
	{
		private var _sequence:String;
		private var _sequenceUser:String;
		private var _entry:Entry;
		private var _filename:String;

		public function Sequence()
		{
		}
		
		public function get sequence() : String
		{
			return this._sequence;
		}
		
		public function set sequence( sequence:String ) : void
		{
			this._sequence = sequence;
		}
		
		public function get sequenceUser() : String
		{
			return this._sequenceUser;
		}
		
		public function set sequenceUser( user:String ) : void
		{
			this._sequenceUser = user;
		}
		
		public function get filename() : String
		{
			return this._filename;
		}
		
		public function set filename( name:String ) : void
		{
			this._filename = name;
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