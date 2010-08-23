package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.TraceData")]
    public class TraceData
    {
        private var _filename:String;
        private var _sequence:String;
        private var _score:int;
        private var _strand:int;
        private var _queryStart:int;
        private var _queryEnd:int;
        private var _subjectStart:int;
        private var _subjectEnd:int;
        private var _queryAlignment:String;
        private var _subjectAlignment:String;
        
        // Contructor
        public function TraceData(filename:String = "", sequence:String = "", score:int = -1, strand:int = -1, queryStart:int = -1, queryEnd:int = -1, subjectStart:int = -1, subjectEnd:int = -1, queryAlignment:String = "", subjectAlignment:String = "")
        {
            _filename = filename;
            _sequence = sequence;
            _score = score;
            _strand = strand;
            _queryStart = queryStart;
            _queryEnd = queryEnd;
            _subjectStart = subjectStart;
            _subjectEnd = subjectEnd;
            _queryAlignment = queryAlignment;
            _subjectAlignment = subjectAlignment;
        }
        
        // Properties
        public function get filename():String
        {
            return _filename;
        }
        
        public function set filename(value:String):void
        {
            _filename = value;
        }
        
        public function get sequence():String
        {
            return _sequence;
        }
        
        public function set sequence(value:String):void
        {
            _sequence = value;
        }
        
        public function get score():int
        {
            return _score;
        }
        
        public function set score(value:int):void
        {
            _score = value;
        }
        
        public function get strand():int
        {
            return _strand;
        }
        
        public function set strand(value:int):void
        {
            _strand = value;
        }
        
        public function get queryStart():int
        {
            return _queryStart;
        }
        
        public function set queryStart(value:int):void
        {
            _queryStart = value;
        }
        
        public function get queryEnd():int
        {
            return _queryEnd;
        }
        
        public function set queryEnd(value:int):void
        {
            _queryEnd = value;
        }
        
        public function get subjectStart():int
        {
            return _subjectStart;
        }
        
        public function set subjectStart(value:int):void
        {
            _subjectStart = value;
        }
        
        public function get subjectEnd():int
        {
            return _subjectEnd;
        }
        
        public function set subjectEnd(value:int):void
        {
            _subjectEnd = value;
        }
        
        public function get queryAlignment():String
        {
            return _queryAlignment;
        }
        
        public function set queryAlignment(value:String):void
        {
            _queryAlignment = value;
        }
        
        public function get subjectAlignment():String
        {
            return _subjectAlignment;
        }
        
        public function set subjectAlignment(value:String):void
        {
            _subjectAlignment = value;
        }
    }
}