package org.jbei.registry.models
{
	import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
	public class FeaturedDNASequence
	{
		private var _sequence:String;
		private var _features:ArrayCollection; /* of DNAFeature */
		private var _accessionNumber:String = "";
		private var _identifier:String = "";
        private var _isCircular:Boolean = true;
        private var _name:String = "";
        private var _canEdit:Boolean = false;
		
		// Constructor
		public function FeaturedDNASequence(name:String = "", sequence:String = "", isCircular:Boolean = true, features:ArrayCollection /* of DNAFeature */ = null)
		{
			super();
			
			_features = features;
			_sequence = sequence;
            _name = name;
            _isCircular = isCircular;
		}
		
		// Properties
		public function get sequence():String
		{
			return _sequence;
		}
		
		public function set sequence(value:String):void
		{
			_sequence = value;
		}
		
        public function get name():String
        {
            return _name;
        }
        
        public function set name(value:String):void
        {
            _name = value;
        }
        
        public function get isCircular():Boolean
        {
            return _isCircular;
        }
        
        public function set isCircular(value:Boolean):void
        {
            _isCircular = value;
        }
        
		public function get features():ArrayCollection /* of DNAFeature */
		{
			return _features;
		}
		
		public function set features(value:ArrayCollection /* of DNAFeature */):void
		{
			_features = value;
		}
		
		public function get accessionNumber():String
		{
			return _accessionNumber;
		}
		
		public function set accessionNumber(value:String):void
		{
			_accessionNumber = value;
		}
		
		public function get identifier():String
		{
			return _identifier;
		}
		
		public function set identifier(value:String):void
		{
			_identifier = value;
		}

        public function get canEdit():Boolean {
            return _canEdit;
        }

        public function set canEdit(canEdit:Boolean):void {
            this._canEdit = canEdit;
        }

        public function toString():String {
            return sequence;
        }
	}
}
