package org.jbei.bio.data
{
	[RemoteClass(alias="org.jbei.ice.bio.enzymes.RestrictionEnzyme")]
	public class RestrictionEnzyme
	{
		private var _name:String;
		private var _site:String;
		private var _cutType:int;
		private var _forwardRegex:String;
		private var _reverseRegex:String;
		private var _dsForward:int;
		private var _dsReverse:int;
		private var _usForward:int;
		private var _usReverse:int;
		private var _dsCutType:int;
		private var _usCutType:int;
	    
		// Constructor
		public function RestrictionEnzyme()
		{
			_name = name;
			_site = site;
			_cutType = cutType;
			_forwardRegex = forwardRegex;
			_reverseRegex = reverseRegex;
			_dsForward = dsForward;
			_dsReverse = dsReverse;
			_usForward = usForward;
			_usReverse = usReverse;
			_dsCutType = dsCutType;
			_usCutType = usCutType;
		}
		
		// Properties
		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void	
		{
			_name = value;
		}
		
		public function get site():String
		{
			return _site;
		}
		
		public function set site(value:String):void	
		{
			_site = value;
		}
		
		public function get cutType():int
		{
			return _cutType;
		}
		
		public function set cutType(value:int):void	
		{
			_cutType = value;
		}
		
		public function get forwardRegex():String
		{
			return _forwardRegex;
		}
		
		public function set forwardRegex(value:String):void	
		{
			_forwardRegex = value;
		}
		
		public function get reverseRegex():String
		{
			return _reverseRegex;
		}
		
		public function set reverseRegex(value:String):void	
		{
			_reverseRegex = value;
		}
		
		public function get dsForward():int
		{
			return _dsForward;
		}
		
		public function set dsForward(value:int):void	
		{
			_dsForward = value;
		}
		
		public function get dsReverse():int
		{
			return _dsReverse;
		}
		
		public function set dsReverse(value:int):void	
		{
			_dsReverse = value;
		}
		
		public function get usForward():int
		{
			return _usForward;
		}
		
		public function set usForward(value:int):void	
		{
			_usForward = value;
		}
		
		public function get usReverse():int
		{
			return _usReverse;
		}
		
		public function set usReverse(value:int):void	
		{
			_usReverse = value;
		}
		
		public function get dsCutType():int
		{
			return _dsCutType;
		}
		
		public function set dsCutType(value:int):void	
		{
			_dsCutType = value;
		}
		
		public function get usCutType():int
		{
			return _usCutType;
		}
		
		public function set usCutType(value:int):void	
		{
			_usCutType = value;
		}
		
		// Public Methods
		public function isPalindromic():Boolean
		{
			//GTGCAG = CTGCAC
			return _forwardRegex == _reverseRegex;
		}
	}
}
