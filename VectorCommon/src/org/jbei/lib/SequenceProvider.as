package org.jbei.lib
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.collections.ArrayCollection;
    
    import org.jbei.bio.parsers.GenbankFeatureElement;
    import org.jbei.bio.parsers.GenbankFeatureQualifier;
    import org.jbei.bio.parsers.GenbankFileModel;
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.bio.sequence.dna.Feature;
    import org.jbei.bio.sequence.dna.FeatureNote;
    import org.jbei.lib.common.IMemento;
    import org.jbei.lib.common.IOriginator;
    import org.jbei.registry.models.DNAFeature;
    import org.jbei.registry.models.DNAFeatureNote;
    import org.jbei.registry.models.FeaturedDNASequence;
    
    [RemoteClass(alias="org.jbei.lib.SequenceProvider")]
    /**
    * Sequence provider. Main class that feeds Pie, Rail and SequenceAnnotator components.
    * 
    * <pre>
    * Usage:
    * 
    * var dnaSequence:SymbolList = DNATools.createDNA("atctgctcgtcgtagtcagctagtcgatcgatgctagctacatctgctcgtcgtagtcagctagtcgatcgatgctagctacatctgctcgtcgtagtcagctagtcgatcgatgctagctac");
    * var sequenceProvider:SequenceProvider = new SequenceProvider("test", true, dnaSequence);
    * </pre>
    * 
    * @author Zinovii Dmytriv
    */
    public class SequenceProvider implements IOriginator
    {
        private var _name:String;
        private var _circular:Boolean;
        private var _sequence:SymbolList;
        private var _complementSequence:SymbolList;
        private var _reverseComplementSequence:SymbolList;
        private var _features:ArrayCollection /* of Feature */;
        
        private var _manualUpdateStarted:Boolean = false;
        private var needsRecalculateComplementSequence:Boolean = true;
        private var needsRecalculateReverseComplementSequence:Boolean = true;
        
        private var dispatcher:EventDispatcher = new EventDispatcher();
        
        // Constructor
        /**
        * Contructor
        */
        public function SequenceProvider(name:String = null, circular:Boolean = false, sequence:SymbolList = null, features:ArrayCollection = null)
        {
            super();
            
            _name = name;
            _circular = circular;
            _sequence = sequence;
            _features = features ? features : new ArrayCollection();
        }
        
        // Properties
        /**
        * Sequence name
        */
        public function get name():String
        {
            return _name;
        }
        
        public function set name(value:String):void
        {
            manualUpdateStart();
            _name = value;
            manualUpdateEnd();
        }
        
        /**
         * Is circular
         */
        public function get circular():Boolean
        {
            return _circular;
        }
        
        public function set circular(value:Boolean):void
        {
            manualUpdateStart();
            _circular = value;
            manualUpdateEnd();
        }
        
        /**
         * DNA sequence
         */
        public function get sequence():SymbolList
        {
            return _sequence;
        }
        
        public function set sequence(value:SymbolList):void
        {
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            _sequence = value;
        }
        
        /**
         * List of features
         */
        public function get features():ArrayCollection /* of Feature */
        {
            return _features;
        }
        
        public function set features(value:ArrayCollection):void
        {
            _features = value;
        }
        
        [Transient]
        /**
         * @private
         */
        public function get manualUpdateStarted():Boolean
        {
            return _manualUpdateStarted;
        }
        
        // Public Methods: IOriginator implementation
        /**
         * @private
         */
        public function createMemento():IMemento
        {
            var clonedFeatures:ArrayCollection = new ArrayCollection();
            
            if(_features && _features.length > 0) {
                for(var i:int = 0; i < _features.length; i++) {
                    clonedFeatures.addItem((_features[i] as Feature).clone());
                }
            }
            
            return new SequenceProviderMemento(_name, _circular, DNATools.createDNA(_sequence.seqString()), clonedFeatures);
        }
        
        /**
         * @private
         */
        public function setMemento(memento:IMemento):void
        {
            var sequenceProviderMemento:SequenceProviderMemento = memento as SequenceProviderMemento;
            
            _name = sequenceProviderMemento.name;
            _circular = sequenceProviderMemento.circular;
            _sequence = sequenceProviderMemento.sequence;
            _features = sequenceProviderMemento.features;
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_SET_MEMENTO));
        }
        
        // Public Methods: EventDispatcher wrapped
        /**
         * @private
         * 
         * Wrapper classes for EventDispatcher
         */
        public function addEventListener(type:String, listener:Function):void
        {
            dispatcher.addEventListener(type, listener);
        }
        
        /**
         * @private
         * 
         * Wrapper classes for EventDispatcher
         */
        public function removeEventListener(type:String, listener:Function):void
        {
            dispatcher.removeEventListener(type, listener);
        }
        
        /**
         * @private
         * 
         * Wrapper classes for EventDispatcher
         */
        public function dispatchEvent(event:Event):void
        {
            dispatcher.dispatchEvent(event);
        }
        
        // Public Methods
        /**
         * Generates complement sequence
         */
        public function getComplementSequence():SymbolList
        {
            updateComplementSequence();
            
            return _complementSequence;
        }
        
        /**
         * Generates reverce complement sequence
         */
        public function getReverseComplementSequence():SymbolList
        {
            updateReverseComplementSequence();
            
            return _reverseComplementSequence;
        }
        
        /**
         * Sub sequence by range
         * 
         * @param start Range start
         * @param end Range end
         */
        public function subSequence(start:int, end:int):SymbolList
        {
            var result:SymbolList = null;
            
            if(start < 0 || end < 0 || start > _sequence.length || end > _sequence.length) {
                return result;
            }
            
            if(start > end) {
                result = DNATools.createDNA(_sequence.subList(start, _sequence.length).seqString() + _sequence.subList(0, end).seqString());
            } else {
                result = _sequence.subList(start, end);
            }
            
            return result;
        }
        
        /**
         * Sub sequence provider by range
         * 
         * @param start Range start
         * @param end Range end
         */
        public function subSequenceProvider(start:int, end:int):SequenceProvider
        {
            var featuredSubSequence:SequenceProvider;
            
            if(start < 0 || end < 0 || start > _sequence.length || end > _sequence.length) {
                return featuredSubSequence;
            }
            
            var featuredSubSymbolList:SymbolList = subSequence(start, end);
            
            var subFeatures:ArrayCollection = new ArrayCollection();
            
            for(var i:int = 0; i < features.length; i++) {
                var feature:Feature = features[i] as Feature;
                
                if(start < end && feature.start <= feature.end) {
                    if(start <= feature.start && end > feature.end) {
                        var clonedFeature1:Feature = feature.clone();
                        
                        clonedFeature1.start -= start;
                        clonedFeature1.end -= start;
                        
                        subFeatures.addItem(clonedFeature1);
                    }
                } else if(start > end && feature.start >= feature.end) {
                    if(start <= feature.start && end > feature.end) {
                        var clonedFeature2:Feature = feature.clone();
                        
                        clonedFeature2.start -= start;
                        clonedFeature2.end = _sequence.length + feature.end - start;
                        
                        subFeatures.addItem(clonedFeature2);
                    }
                } else if(start > end && feature.start <= feature.end) {
                    if(start <= feature.start) {
                        var clonedFeature3:Feature = feature.clone();
                        
                        clonedFeature3.start -= start;
                        clonedFeature3.end -= start;
                        
                        subFeatures.addItem(clonedFeature3);
                    } else if(end > feature.end) {
                        var clonedFeature4:Feature = feature.clone();
                        
                        clonedFeature4.start += sequence.length - start;
                        clonedFeature4.end += sequence.length - start;
                        
                        subFeatures.addItem(clonedFeature4);
                    }
                }
            }
            
            featuredSubSequence = new SequenceProvider("Dummy", false, featuredSubSymbolList, subFeatures);
            
            return featuredSubSequence;
        }
        
        /**
         * Adds feature to sequence provider
         * 
         * @param feature Feature to add
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function addFeature(feature:Feature, quiet:Boolean = false):void
        {
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_FEATURE_ADD, createMemento()));
            }
            
            _features.addItem(feature);
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_FEATURE_ADD, feature));
            }
        }
        
        /**
         * Adds list of features to sequence provider
         * 
         * @param featuresToAdd List of features to add
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function addFeatures(featuresToAdd:Array /* of Feature */, quiet:Boolean = false):void
        {
            if(!featuresToAdd || featuresToAdd.length == 0) { return; } 
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_FEATURES_ADD, createMemento()));
            }
            
            for(var i:int = 0; i < featuresToAdd.length; i++) {
                var feature:Feature = featuresToAdd[i] as Feature;
                
                addFeature(feature, true);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_FEATURES_ADD, features));
            }
        }
        
        /**
         * Removes feature from sequence provider
         * 
         * @param feature Feature to remove
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function removeFeature(feature:Feature, quiet:Boolean = false):void
        {
            var index:int = _features.getItemIndex(feature);
            
            if(index >= 0) {
                if(!quiet && !_manualUpdateStarted) {
                    dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_FEATURE_REMOVE, createMemento()));
                }
                
                _features.removeItemAt(index);
                
                if(!quiet && !_manualUpdateStarted) {
                    dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_FEATURE_REMOVE, feature));
                }
            }
        }
        
        /**
         * Remove list of features to sequence provider
         * 
         * @param featuresToRemove List of features to remove
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function removeFeatures(featuresToRemove:Array /* of Feature */, quiet:Boolean = false):void
        {
            if(!featuresToRemove || featuresToRemove.length == 0) { return; } 
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_FEATURES_REMOVE, createMemento()));
            }
            
            for(var i:int = 0; i < featuresToRemove.length; i++) {
                var feature:Feature = featuresToRemove[i] as Feature;
                
                removeFeature(feature, true);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_FEATURES_REMOVE, features));
            }
        }
        
        /**
         * Check if sequenceProvider has feature
         * 
         * @param feature Feature existance to check
         */
        public function hasFeature(feature:Feature):Boolean
        {
            return features.contains(feature);
        }
        
        /**
         * Insert another sequence provider at position. This method is used on sequence paste
         * 
         * @param sequenceProvider SequenceProvider to insert
         * @param position Position where to insert
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function insertSequenceProvider(sequenceProvider:SequenceProvider, position:int, quiet:Boolean = false):void
        {
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_SEQUENCE_INSERT, createMemento()));
            }
            
            insertSequence(sequenceProvider.sequence, position, true);
            
            for(var z:int = 0; z < sequenceProvider.features.length; z++) {
                var insertFeature:Feature = (sequenceProvider.features[z] as Feature).clone();
                
                insertFeature.start += position;
                insertFeature.end += position;
                
                addFeature(insertFeature, true);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_SEQUENCE_INSERT, {sequenceProvider : sequenceProvider, position : position}));
            }
        }
        
        /**
         * Insert another sequence at position. This method is used on sequence paste
         * 
         * @param insertSequence SymbolList to insert
         * @param position Position where to insert
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function insertSequence(insertSequence:SymbolList, position:int, quiet:Boolean = false):void
        {
            if(position < 0 || position > sequence.length || insertSequence.length == 0) { return };
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_SEQUENCE_INSERT, createMemento()));
            }
            
            _sequence.insertSymbols(position, insertSequence);
            
            var insertionSequenceLength:int = insertSequence.length;
            
            for(var i:int; i < _features.length; i++) {
                var feature:Feature = _features[i];
                
                if(feature.start > feature.end) { // circular feature case
                    if(feature.end < position && feature.start > position) { // beetwen start and end
                        feature.start += insertionSequenceLength;
                    } else if (feature.end >= position) {
                        feature.end += insertionSequenceLength;
                        feature.start += insertionSequenceLength;
                    }
                } else {
                    if(feature.start < position && feature.end < position) { // completely before insertion point
                    } else if(feature.start > position && feature.end > position) { // completely after insertion point
                        feature.start += insertionSequenceLength;
                        feature.end += insertionSequenceLength;
                    } else {
                        feature.end += insertionSequenceLength;
                    }
                }
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_SEQUENCE_INSERT, {sequence : insertSequence, position : position}));
            }
        }
        
        /**
         * Remove sequence in range
         * 
         * @param startIndex Range start 
         * @param endIndex Range end 
         * @param quiet When true not SequenceProviderEvent will be dispatched
         */
        public function removeSequence(startIndex:int, endIndex:int, quiet:Boolean = false):void
        {
            var sequenceLength:int = _sequence.length;
            
            if(endIndex < 0 || startIndex < 0 || startIndex > sequenceLength || endIndex > sequenceLength || startIndex == endIndex) { return; }
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_SEQUENCE_INSERT, createMemento()));
            }
            
            const DEBUG_MODE:Boolean = true;
            
            var deletions:Array = new Array(); // features marked for deletion
            
            for(var i:int = 0; i < _features.length; i++) {
                var feature:Feature = _features[i];
                
                if(feature.start < feature.end) { // normal feature
                    if(startIndex < endIndex) { // normal selection
                        /* Selection before feature => feature shift left
                        * |-----SSSSSSSSSSSSSSSSSSSSSSSSS--------------------------------------------------------------------|
                        *                                     |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                 */
                        if(startIndex < feature.start && (endIndex - 1) < feature.start) {
                            feature.start -= endIndex - startIndex;
                            feature.end -= endIndex - startIndex;
                            if (DEBUG_MODE) trace("case Fn,Sn 1");
                        }
                            /* Selection after feature => no action
                            * |-------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS------------|
                            *        |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                                              */
                        else if(startIndex > feature.end) {
                            if (DEBUG_MODE) trace("case Fn,Sn 2");
                        }
                            /* Selection cover feature => remove feature
                            * |-----------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS-----------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(startIndex <= feature.start && feature.end <= (endIndex)) {
                            deletions.push(feature);
                            if (DEBUG_MODE) trace("case Fn,Sn 3");
                        }
                            /* Selection inside feature => resize feature
                            * |-------------------------------------SSSSSSSSSSSSSSSSSSSSSS---------------------------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(((startIndex >= feature.start) && ((endIndex) <= feature.end))) {
                            feature.end -= endIndex - startIndex;
                            if (DEBUG_MODE) trace("case Fn,Sn 4");
                        }
                            /* Selection left overlap feature => shift & resize feature
                            * |-----------------------------SSSSSSSSSSSSSSSSSSSSS------------------------------------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(startIndex < feature.start && feature.start < (endIndex)) {
                            feature.start = startIndex;
                            feature.end -= endIndex - startIndex;
                            if (DEBUG_MODE) trace("case Fn,Sn 5");
                        }
                            /* Selection right overlap feature => shift & resize feature
                            * |-------------------------------------------------SSSSSSSSSSSSSSSSSSSSS----------------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(startIndex < feature.end && (endIndex) > feature.end) {
                            feature.end = startIndex;
                            if (DEBUG_MODE) trace("case Fn,Sn 6");
                        } else {
                            throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.seqString());
                        }
                    } else { // circular selection
                        /* Selection and feature no overlap => shift left
                        * |SSSSSSSSSSS-------------------------------------------------------------------------SSSSSSSSSSSSSS|
                        *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        if(startIndex > feature.end && (endIndex) <= feature.start) {
                            feature.start -= endIndex;
                            feature.end -= endIndex;
                            if (DEBUG_MODE) trace("case Fn,Sc 1");
                        }
                            /* Selection and feature left partial overlap => cut and shift
                            * |SSSSSSSSSSSSSSSSSSSS----------------------------------------------------------------SSSSSSSSSSSSSS|
                            *             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                                         */
                        else if(startIndex > feature.end && (endIndex) > feature.start && endIndex <= feature.end) {
                            feature.start = 0;
                            feature.end -= endIndex;
                            if (DEBUG_MODE) trace("case Fn,Sc 2");
                        }
                            /* Selection and feature right partial overlap => cut and shift
                            * |SSSSSSSSSSSSSSS--------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *                                                       |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|               */
                        else if(startIndex > feature.start && startIndex < feature.end && (endIndex) < feature.start) {
                            feature.start -= endIndex;
                            feature.end -= (feature.end - startIndex) + endIndex;
                            if (DEBUG_MODE) trace("case Fn,Sc 3");
                        }
                            /* Double selection overlap => cut and shift
                            * |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS-----------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *                           |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                          */
                        else if(startIndex < feature.end && (endIndex) > feature.start) {
                            feature.start = 0;
                            feature.end -= (feature.end - startIndex) + endIndex;
                            if (DEBUG_MODE) trace("case Fn,Sc 3");
                        }
                            /* Complete left cover => remove feature
                            * |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS------------------------------SSSSSSSSSSSSSSSSSSSSS|
                            *             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                                        */
                        else if(endIndex >= feature.end) {
                            deletions.push(feature);
                            if (DEBUG_MODE) trace("case Fn,Sc 4");
                        }
                            /* Complete right cover => remove feature
                            * |SSSSSSSSSSS---------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *                                                     |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|               */
                        else if(startIndex <= feature.start) {
                            deletions.push(feature);
                            if (DEBUG_MODE) trace("case Fn,Sc 5");
                        } else {
                            throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.seqString());
                        }
                    }
                } else { // circular feature
                    if(startIndex < endIndex) { // normal selection
                        /* Selection between feature start and end
                        * |-------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS------------------------------------------|
                        *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        if(startIndex >= feature.end && (endIndex) <= feature.start) {
                            feature.start -= endIndex - startIndex;
                            if (DEBUG_MODE) trace("case Fc,Sn 1");
                        }
                            /* Selection inside feature start
                            * |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex >= feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sn 2");
                        }
                            /* Selection inside feature end
                            * |--SSSSSSSSSSSSSSSSSS------------------------------------------------------------------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if((endIndex) <= feature.end) {
                            feature.start -= endIndex - startIndex;
                            feature.end -= endIndex - startIndex;
                            if (DEBUG_MODE) trace("case Fc,Sn 3");
                        }
                            /* Selection in feature start
                            * |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
                            *  FFFFFFFFFFFFFFFFFFF|                                                        |FFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex >= feature.end && startIndex <= feature.start && (endIndex) > feature.start) {
                            if(endIndex - 1 == sequence.length - 1) {
                                feature.start = 0;
                                if (DEBUG_MODE) trace("case Fc,Sn 4a");
                            } else {
                                feature.start = startIndex;
                                if (DEBUG_MODE) trace("case Fc,Sn 4b");
                            }
                        }
                            /* Selection in feature end
                            * |--SSSSSSSSSSSSSSSSSSSSSSSSSSSSS-------------------------------------------------------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex < feature.end && (endIndex) >= feature.end && (endIndex) <= feature.start) {
                            if(startIndex == 0 && (endIndex) >= feature.end) {
                                feature.end = sequence.length - (endIndex - startIndex);
                                feature.start -= endIndex - startIndex;
                                if (DEBUG_MODE) trace("case Fc,Sn 5a");
                            } else {
                                feature.start -= endIndex - startIndex;
                                feature.end = startIndex;
                                if (DEBUG_MODE) trace("case Fc,Sn 5b");
                            }
                        }
                            /* Double ends selection
                            * |------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS---------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.end && feature.start <= endIndex - 1) {
                            if(startIndex == 0 && endIndex == sequenceLength) {
                                deletions.push(feature);
                            } else if(endIndex == sequence.length) {
                                feature.start = 0;
                                feature.end = startIndex - 1;
                                
                                if (DEBUG_MODE) trace("case Fc,Sn 6a");
                            } else if(startIndex == 0) {
                                feature.start = 0;
                                feature.end = sequence.length - endIndex - 1;
                                
                                if (DEBUG_MODE) trace("case Fc,Sn 6b");
                            } else {
                                feature.start = startIndex;
                                feature.end = startIndex - 1;
                                
                                if (DEBUG_MODE) trace("case Fc,Sn 6c");
                            }
                        } else {
                            throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.seqString());
                        }
                    } else { // circular selection
                        /* Selection inside feature
                        * |SSSSSSSSSSSSSSSSS--------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS|
                        *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        if(startIndex > feature.start && (endIndex - 1) < feature.end) {
                            if (DEBUG_MODE) trace("case Fc,Sc 1");
                            
                            feature.start -= endIndex;
                            feature.end -= endIndex;
                        }
                            /* Selection end overlap
                            * |SSSSSSSSSSSSSSSSSSSSSS---------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex - 1 >= feature.end && startIndex > feature.start && (endIndex - 1) < feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 2");
                            
                            feature.start -= endIndex;
                            feature.end = startIndex - 1 - endIndex;
                        }
                            /* Selection start overlap
                            * |SSSSSSSSSSSSSSSSS-----------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.start && feature.end > (endIndex - 1) && startIndex > feature.end) {
                            if (DEBUG_MODE) trace("case Fc,Sc 3");
                            
                            feature.start = 0;
                            feature.end -= endIndex;
                        }
                            /* Selection inside feature
                            * |SSSSSSSSSSSSSSSSSSSSSSS-----------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex - 1 >= feature.end && startIndex <= feature.start && endIndex - 1 < feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 4");
                            
                            deletions.push(feature);
                        }
                            /* Selection double end right overlap
                            * |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS----------------------------SSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex - 1 >= feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 5");
                            
                            feature.start = 0;
                            feature.end = startIndex - endIndex - 1;
                        }
                            /* Selection double end left overlap
                            * |SSSSSSSSSSS---------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                        |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.end) {
                            if (DEBUG_MODE) trace("case Fc,Sc 6");
                            
                            feature.start = 0;
                            feature.end = startIndex - endIndex - 1;
                        }
                        else {
                            throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.seqString());
                        }
                    }
                }
            }
            
            for(var d:int = 0; d < deletions.length; d++) {
                removeFeature(deletions[d] as Feature, true);
            }
            
            if(startIndex > endIndex) {
                _sequence.deleteSymbols(0, endIndex);
                
                _sequence.deleteSymbols(startIndex - endIndex, sequenceLength - startIndex);
            } else {
                var removeSequenceLength:int = endIndex - startIndex;
                
                _sequence.deleteSymbols(startIndex, removeSequenceLength);
            }
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_SEQUENCE_REMOVE, {position : startIndex, length : length}));
            }
        }
        
        /**
        * Get list of features in range
        * 
        * @return List of features
        */
        public function featuresByRange(start:int, end:int):Array /* of Feature */
        {
            var result:Array = new Array();
            
            for(var i:int = 0; i < features.length; i++) {
                var feature:Feature = features[i] as Feature;
                
                if(start < end) {
                    if(feature.start <= feature.end) {
                        if(feature.start < end && feature.end >= start) {
                            result.push(feature);
                        }
                    } else {
                        if(start < feature.end || end > feature.start) {
                            result.push(feature);
                        }
                    }
                } else {
                    if(feature.start <= feature.end) {
                        if(feature.start >= end && feature.end < start) {
                        } else {
                            result.push(feature);
                        }
                    } else {
                        result.push(feature);
                    }
                }
            }
            
            return result;
        }
        
        /**
         * Get list of features at position
         * 
         * @return List of features
         */
        public function featuresAt(position:int):Array /* of Feature */
        {
            var result:Array = new Array();
            
            for(var i:int = 0; i < features.length; i++) {
                var feature:Feature = features[i] as Feature;
                
                if(feature.start <= feature.end) {
                    if(feature.start < position && feature.end > position) {
                        result.push(feature);
                    }
                } else {
                    if(feature.start < position || feature.end > position) {
                        result.push(feature);
                    }
                }
            }
            
            return result;
        }
        
        /**
         * Use this method for manually operate sequence changing state.
         * 
         * <pre>
         * Usage:
         * 
         * sequenceProvider.manualUpdateStart();
         * sequenceProvider.addFeature(feature1);
         * sequenceProvider.addFeature(feature2);
         * sequenceProvider.addFeature(feature3);
         * sequenceProvider.removeFeature(feature4);
         * sequenceProvider.manualUpdateEnd(); // only here SequenceProviderEvent.SEQUENCE_CHANGED will be trigered.
         * </pre>
         */
        public function manualUpdateStart():void
        {
            if(!_manualUpdateStarted) {
                _manualUpdateStarted = true;
                
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_MANUAL_UPDATE, createMemento()));
            }
        }
        
        /**
        * @see manualUpdateStart
        */
        public function manualUpdateEnd():void
        {
            if(_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGED, SequenceProviderEvent.KIND_MANUAL_UPDATE, null));
                
                _manualUpdateStarted = false;
            }
        }
        
        /**
        * Clone sequence provider
        */
        public function clone():SequenceProvider
        {
            var clonedSequenceProvider:SequenceProvider = new SequenceProvider(_name, _circular, DNATools.createDNA(_sequence.seqString()));
            
            if(_features && _features.length > 0) {
                for(var i:int = 0; i < _features.length; i++) {
                    clonedSequenceProvider.addFeature(_features[i], true);
                }
            }
            
            return clonedSequenceProvider;
        }
        
        /**
         * Reverse sequence
         */
        public static function reverseSequence(inputSequenceProvider:SequenceProvider):SequenceProvider
        {
            var revComSequence:SymbolList = DNATools.reverseComplement(inputSequenceProvider.sequence);
            
            var reverseSequenceProvider:SequenceProvider = new SequenceProvider(inputSequenceProvider.name, inputSequenceProvider.circular, revComSequence);
            
            var seqLength:int = inputSequenceProvider.sequence.length;
            
            for(var i:int = 0; i < inputSequenceProvider.features.length; i++) {
                var reverseFeature:Feature = (inputSequenceProvider.features.getItemAt(i) as Feature).clone();
                reverseFeature.strand = -reverseFeature.strand;
                
                var oldStart:int = reverseFeature.start;
                var oldEnd:int = reverseFeature.end;
                
                reverseFeature.start = seqLength - oldEnd - 1;
                reverseFeature.end = seqLength - oldStart - 1;
                
                reverseSequenceProvider.addFeature(reverseFeature, true);
            }
            
            return reverseSequenceProvider;
        }
        
        /**
         * Reverse complement sequence
         */
        public function reverseComplementSequence():void
        {
            manualUpdateStart();
            
            var revComSequence:SymbolList = DNATools.reverseComplement(_sequence);
            _sequence = revComSequence;
            
            var seqLength:int = _sequence.length;
            for(var i:int = 0; i < _features.length; i++) {
                var reverseFeature:Feature = (_features.getItemAt(i) as Feature);
                reverseFeature.strand = -reverseFeature.strand;
                
                var oldStart:int = reverseFeature.start;
                var oldEnd:int = reverseFeature.end;
                
                reverseFeature.start = seqLength - oldEnd - 1;
                reverseFeature.end = seqLength - oldStart - 1;
            }
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            manualUpdateEnd();
        }
        
        /**
         * Rebase sequence. Rotate sequence to new position.
         */
        public function rebaseSequence(rebasePosition:int):void
        {
            var seqLength:int = _sequence.length;
            
            if(rebasePosition == 0 || seqLength == 0 || rebasePosition == seqLength) {
                return; // nothing to rebase;
            }
            
            if(rebasePosition > seqLength) {
                throw new Error("Invaid rebase position: " + rebasePosition);
            }
            
            manualUpdateStart();
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            // rebase sequence
            var tmpSequence:SymbolList = _sequence.subList(0, rebasePosition);
            _sequence.deleteSymbols(0, rebasePosition);
            _sequence.addSymbols(tmpSequence);
            
            // rebase features
            if(_features && _features.length > 0) {
                for(var i:int = 0; i < _features.length; i++) {
                    var feature:Feature = _features.getItemAt(i) as Feature;
                    
                    var start:int = feature.start - rebasePosition;
                    var end:int = feature.end - rebasePosition;
                    
                    if(start < 0) {
                        start = seqLength - (-start);
                    }
                    
                    if(end < 0) {
                        end = seqLength - (-end);
                    }
                    
                    feature.start = start;
                    feature.end = end;
                }
            }
            
            manualUpdateEnd();
        }
        
        /**
        * suitable for generating genbank file
        */
        public function toGenbankFileModel():GenbankFileModel{
            var result:GenbankFileModel = new GenbankFileModel();
            result.locus.locusName = this.name;
            result.locus.linear = !this.circular;
            result.locus.naType = "DNA";
            result.locus.strandType = "ds";
            result.locus.date = new Date();
            result.origin.sequence = this.sequence.toString();
            
            var seqProviderFeature:Feature;
            var feature:GenbankFeatureElement;
            var tempQualifier:GenbankFeatureQualifier;
            for (var i:int = 0; i < this.features.length; i++) {
                seqProviderFeature = this.features[i] as Feature;
                feature = new GenbankFeatureElement();
                feature.genbankStart = seqProviderFeature.start + 1;
                feature.end = seqProviderFeature.end;
                feature.strand = seqProviderFeature.strand;
                feature.key = seqProviderFeature.type;
                tempQualifier = new GenbankFeatureQualifier();
                tempQualifier.quoted = true;
                tempQualifier.name = "label";
                tempQualifier.value = seqProviderFeature.name;
                feature.featureQualifiers.push(tempQualifier);
                for (var j:int = 0; j < seqProviderFeature.notes.length; j++) {
                    tempQualifier = new GenbankFeatureQualifier();
                    tempQualifier.quoted = true;
                    tempQualifier.name = seqProviderFeature.notes[j].name;
                    tempQualifier.value = seqProviderFeature.notes[j].value;
                    feature.featureQualifiers.push(tempQualifier);
                }
                result.features.features.push(feature);
            }
            
            return result;
        }
        
        public function fromGenbankFileModel(genbankFileModel:GenbankFileModel):FeaturedDNASequence
        {

            var result:FeaturedDNASequence = new FeaturedDNASequence();
            result.features = new ArrayCollection(); /* of DNAFeatures */
            result.name = genbankFileModel.locus.locusName;
            result.isCircular = !genbankFileModel.locus.linear;
            result.sequence = DNATools.createDNA(genbankFileModel.origin.sequence).toString();
            
            
            var genbankFeatures:Vector.<GenbankFeatureElement> = genbankFileModel.features.features;
            var dnaFeature:DNAFeature;
            for (var i:int = 0; i < genbankFeatures.length; i++) {
                dnaFeature = new DNAFeature();
                dnaFeature.genbankStart = genbankFeatures[i].genbankStart;
                dnaFeature.end = genbankFeatures[i].end;
                dnaFeature.type = genbankFeatures[i].key;
                dnaFeature.strand = genbankFeatures[i].strand;
                
                dnaFeature.notes = new ArrayCollection(); /* of DNAFeatureNote */
                for (var j:int = 0; j < genbankFeatures[i].featureQualifiers.length; j++) {
                    if (genbankFeatures[i].featureQualifiers[j].name == "label") {
                        dnaFeature.name = genbankFeatures[i].featureQualifiers[j].value;
                    } else {
                        dnaFeature.notes.addItem(new DNAFeatureNote(genbankFeatures[i].featureQualifiers[j].name, genbankFeatures[i].featureQualifiers[j].value));
                    }
                }
                if (dnaFeature.name == null) {
                    dnaFeature.name = "unknown";
                }
                result.features.addItem(dnaFeature);            
            }
            
            return result;
        }

        // Private Methods
        private function updateComplementSequence():void
        {
            if(needsRecalculateComplementSequence) {
                _complementSequence = DNATools.complement(_sequence);
                
                needsRecalculateComplementSequence = false;
            }
        }
        
        private function updateReverseComplementSequence():void
        {
            if(needsRecalculateReverseComplementSequence) {
                _reverseComplementSequence = DNATools.reverseComplement(_sequence);
                
                needsRecalculateReverseComplementSequence = false;
            }
        }
    }
}
