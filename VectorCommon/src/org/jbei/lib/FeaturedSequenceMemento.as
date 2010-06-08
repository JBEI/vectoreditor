package org.jbei.lib
{
    import mx.collections.ArrayCollection;
    
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.bio.sequence.dna.DNASequence;
    import org.jbei.lib.common.IMemento;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class FeaturedSequenceMemento implements IMemento
    {
        private var _name:String;
        private var _circular:Boolean;
        private var _sequence:SymbolList;
        private var _features:ArrayCollection;
        
        // Contructor
        public function FeaturedSequenceMemento(name:String, circular:Boolean, sequence:SymbolList, features:ArrayCollection)
        {
            _name = name;
            _circular = circular;
            _sequence = sequence;
            _features = features;
        }
        
        // Properties
        public function get name():String
        {
            return _name;
        }
        
        public function get circular():Boolean
        {
            return _circular;
        }
        
        public function get sequence():SymbolList
        {
            return _sequence;
        }
        
        public function get features():ArrayCollection
        {
            return _features;
        }
    }
}