package org.jbei.registry.models
{
	[RemoteClass(alias="org.jbei.ice.lib.vo.DNAFeatureNote")]
    /**
     * @author Zinovii Dmytriv
     */
	public class DNAFeatureNote
	{
		private var _name:String;
		private var _value:String;
		private var _quoted:Boolean;
        
		public function DNAFeatureNote(name:String = "", aValue:String = "", quoted:Boolean = false)
		{
			_name = name;
			_value = aValue;
            _quoted=quoted;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get value():String
		{
			return _value;
		}
		
		public function set value(aValue:String):void
		{
			_value = aValue;
		}
        
        public function get quoted():Boolean
        {
            return _quoted;
        }
        
        public function set quoted(quoted:Boolean):void
        {
            _quoted = quoted;
        }
	}
}