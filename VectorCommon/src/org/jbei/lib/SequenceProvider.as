package org.jbei.lib
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.collections.ArrayCollection;
    
    import org.jbei.bio.parsers.GenbankFeatureElement;
    import org.jbei.bio.parsers.GenbankFeatureQualifier;
    import org.jbei.bio.parsers.GenbankFileModel;
    import org.jbei.bio.parsers.GenbankLocation;
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.common.Location;
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.bio.sequence.dna.Feature;
    import org.jbei.bio.sequence.dna.FeatureNote;
    import org.jbei.lib.common.IMemento;
    import org.jbei.lib.common.IOriginator;
    import org.jbei.registry.models.DNAFeature;
    import org.jbei.registry.models.DNAFeatureLocation;
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

                if(start < end && feature.start < feature.end) {
                    if(start <= feature.start && end >= feature.end) {
                        var clonedFeature1:Feature = feature.clone();
                        
						clonedFeature1.shift(-start, sequence.length, circular);
                        
                        subFeatures.addItem(clonedFeature1);
                    }
                } else if(start > end && feature.start >= feature.end) {
                    if(start <= feature.start && end >= feature.end) {
                        var clonedFeature2:Feature = feature.clone();
                        
						clonedFeature2.shift(-start, sequence.length, circular);
						
                        subFeatures.addItem(clonedFeature2);
                    }
                } else if(start > end && feature.start <= feature.end) {
                    if(start <= feature.start) {
                        var clonedFeature3:Feature = feature.clone();
                        
						clonedFeature3.shift(-start, sequence.length, circular);
                        
                        subFeatures.addItem(clonedFeature3);
                    } else if(end > feature.end) {
                        var clonedFeature4:Feature = feature.clone();
                        
						clonedFeature4.shift(sequence.length - start, sequence.length, circular);
						
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
                
				insertFeature.shift(position, sequence.length, circular);
                
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
            
			var lengthBefore:int = sequence.length;
            _sequence.insertSymbols(position, insertSequence);
            
            var insertSequenceLength:int = insertSequence.length;
            
            for(var i:int; i < _features.length; i++) {
                var feature:Feature = _features[i];
				feature.insertAt(position, insertSequenceLength, lengthBefore, circular);
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
            var lengthBefore:int = _sequence.length;
            
            if(endIndex < 0 || startIndex < 0 || startIndex > lengthBefore || endIndex > lengthBefore || startIndex == endIndex) { return; }
            
            needsRecalculateComplementSequence = true;
            needsRecalculateReverseComplementSequence = true;
            
            if(!quiet && !_manualUpdateStarted) {
                dispatcher.dispatchEvent(new SequenceProviderEvent(SequenceProviderEvent.SEQUENCE_CHANGING, SequenceProviderEvent.KIND_SEQUENCE_INSERT, createMemento()));
            }
            
            const DEBUG_MODE:Boolean = true;
            
            var deletions:Array = new Array(); // features marked for deletion
			
			var delLength2:int;
			var delLength1:int;
			var delLengthBetween:int;
			var delLengthBefore:int;
			var lengthBefore2:int;
			var lengthBefore3:int;
			var delLengthOutside:int;
			var delLengthInside:int; 
							
            for(var i:int = 0; i < _features.length; i++) {
                var feature:Feature = _features[i];
                
                if(feature.start < feature.end) { // normal feature
                    if(startIndex < endIndex) { // normal selection
                        /* Selection before feature => feature shift left
                        * |-----SSSSSSSSSSSSSSSSSSSSSSSSS--------------------------------------------------------------------|
                        *                                     |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                 */
                        if(startIndex < feature.start && endIndex <= feature.start) {
							feature.deleteAt(startIndex, endIndex - startIndex, lengthBefore, circular);
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
                            feature.deleteAt(startIndex, endIndex - startIndex, lengthBefore, circular);
                            if (DEBUG_MODE) trace("case Fn,Sn 4");
                        }
                            /* Selection left overlap feature => shift & resize feature
                            * |-----------------------------SSSSSSSSSSSSSSSSSSSSS------------------------------------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(startIndex < feature.start && feature.start < (endIndex)) {
							delLengthOutside = feature.start - startIndex;
							delLengthInside = endIndex - feature.start;
							lengthBefore2 = lengthBefore - (feature.start - startIndex);
							feature.deleteAt(startIndex, delLengthOutside, lengthBefore, circular);
							feature.deleteAt(feature.start, delLengthInside, lengthBefore2, circular);
							if (DEBUG_MODE) trace("case Fn,Sn 5");
                        }
                            /* Selection right overlap feature => shift & resize feature
                            * |-------------------------------------------------SSSSSSSSSSSSSSSSSSSSS----------------------------|
                            *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        else if(startIndex < feature.end && (endIndex) > feature.end) {
							feature.deleteAt(startIndex, feature.end - startIndex, lengthBefore, circular);
                            if (DEBUG_MODE) trace("case Fn,Sn 6");
                        } else {
                            throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.seqString());
                        }
                    } else { // circular selection, non circular feature. LengthBefore is irrelevent in all these cases.
                        /* Selection and feature no overlap => shift left
                        * |SSSSSSSSSSS-------------------------------------------------------------------------SSSSSSSSSSSSSS|
                        *                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
                        if(startIndex > feature.end && (endIndex) <= feature.start) {
							feature.shift(-endIndex, lengthBefore, circular); 
                            if (DEBUG_MODE) trace("case Fn,Sc 1");
                        }
                            /* Selection and feature left partial overlap => cut and shift
                            * |SSSSSSSSSSSSSSSSSSSS----------------------------------------------------------------SSSSSSSSSSSSSS|
                            *             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                                         */
                        else if(startIndex > feature.end && (endIndex) > feature.start && endIndex <= feature.end) {
							delLengthOutside = feature.start;
							delLengthInside = endIndex - feature.start;
							feature.deleteAt(0, delLengthOutside, lengthBefore, circular); 
							feature.deleteAt(feature.start, delLengthInside, lengthBefore, circular); 
                            if (DEBUG_MODE) trace("case Fn,Sc 2");
                        }
                            /* Selection and feature right partial overlap => cut and shift
                            * |SSSSSSSSSSSSSSS--------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *                                                       |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|               */
                        else if(startIndex > feature.start && startIndex < feature.end && (endIndex) < feature.start) {
							feature.deleteAt(startIndex, feature.end - startIndex, lengthBefore, circular);
							feature.shift(-endIndex, lengthBefore, circular); 
                            if (DEBUG_MODE) trace("case Fn,Sc 3");
                        }
                            /* Double selection overlap => cut and shift
                            * |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS-----------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *                           |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                          */
                        else if(startIndex < feature.end && (endIndex) > feature.start) {
							feature.deleteAt(startIndex, feature.end - startIndex, lengthBefore, circular);
							feature.deleteAt(feature.start, endIndex - feature.start, lengthBefore, circular);
							feature.shift(feature.start, lengthBefore, circular);
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
                            feature.deleteAt(startIndex, endIndex - startIndex, lengthBefore, circular);
                            if (DEBUG_MODE) trace("case Fc,Sn 1");
                        }
                            /* Selection inside feature start
                            * |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex >= feature.start) {
							feature.deleteAt(startIndex, endIndex - startIndex, lengthBefore, circular);
                            if (DEBUG_MODE) trace("case Fc,Sn 2");
                        }
                            /* Selection inside feature end
                            * |--SSSSSSSSSSSSSSSSSS------------------------------------------------------------------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if((endIndex) <= feature.end) {
							feature.deleteAt(startIndex, endIndex - startIndex, lengthBefore, circular);
                            if (DEBUG_MODE) trace("case Fc,Sn 3");
                        }
                            /* Selection in feature start
                            * |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
                            *  FFFFFFFFFFFFFFFFFFF|                                                        |FFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex >= feature.end && startIndex <= feature.start && (endIndex) > feature.start) {
							delLengthBefore = feature.start - startIndex;
							delLengthInside = endIndex - feature.start;
							lengthBefore2 = lengthBefore - delLengthInside;
							feature.deleteAt(feature.start, delLengthInside, lengthBefore, circular);
							feature.deleteAt(startIndex, delLengthBefore, lengthBefore2, circular);

                            if (DEBUG_MODE) trace("case Fc,Sn 4a");
                            if (DEBUG_MODE) trace("case Fc,Sn 4b");
                        }
                            /* Selection in feature end
                            * |--SSSSSSSSSSSSSSSSSSSSSSSSSSSSS-------------------------------------------------------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex < feature.end && (endIndex) >= feature.end && (endIndex) <= feature.start) {
							delLengthOutside = endIndex - feature.end;
							lengthBefore2 = lengthBefore - (feature.end - startIndex);
							feature.deleteAt(startIndex, feature.end - startIndex, lengthBefore, circular);
							feature.deleteAt(feature.end, delLengthOutside, lengthBefore2, circular);
							
                            if (DEBUG_MODE) trace("case Fc,Sn 5a");
                            if (DEBUG_MODE) trace("case Fc,Sn 5b");
                        }
                            /* Double ends selection
                            * |------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS---------------------|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.end && feature.start <= endIndex - 1) {
							delLengthBetween = feature.start - feature.end;
							delLength1 = feature.end - startIndex;
							delLength2 = endIndex - feature.start;
							
							feature.deleteAt(startIndex, delLength1, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength1;
							feature.deleteAt(feature.end, delLengthBetween, lengthBefore2, circular);
							lengthBefore3 = lengthBefore2 - delLengthBetween;
							feature.deleteAt(feature.start, delLength2, lengthBefore3, circular);

                            if(startIndex == 0 && endIndex == lengthBefore) {
                            } else if(endIndex == sequence.length) {
                                if (DEBUG_MODE) trace("case Fc,Sn 6a");
                            } else if(startIndex == 0) {
                                if (DEBUG_MODE) trace("case Fc,Sn 6b");
                            } else {
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
							delLength1 = endIndex;
							delLength2 = lengthBefore - startIndex;
							feature.deleteAt(startIndex, delLength2, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength2;
                            feature.deleteAt(0, delLength1, lengthBefore2, circular);
                        }
                            /* Selection end overlap
                            * |SSSSSSSSSSSSSSSSSSSSSS---------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex - 1 >= feature.end && startIndex > feature.start && (endIndex - 1) < feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 2");
							delLength1 = feature.end;
							delLength2 = lengthBefore - startIndex;
							delLengthBetween = endIndex - feature.end;
							
							feature.deleteAt(startIndex, delLength2, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength2;
							feature.deleteAt(feature.end, delLengthBetween, lengthBefore2, circular);
							lengthBefore3 = lengthBefore2 - delLengthBetween;
							feature.deleteAt(0, delLength1, lengthBefore3, circular);
                        }
                            /* Selection start overlap
                            * |SSSSSSSSSSSSSSSSS-----------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.start && endIndex < feature.end && startIndex >= feature.end) {
                            if (DEBUG_MODE) trace("case Fc,Sc 3");
							delLengthOutside = feature.start - startIndex;
							delLength2 = lengthBefore - feature.start;
							feature.deleteAt(feature.start, delLength2, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength2;
							feature.deleteAt(startIndex, delLengthOutside, lengthBefore2, circular);
							lengthBefore3 = lengthBefore2 - delLengthOutside;
							feature.deleteAt(0, endIndex, lengthBefore3, circular);
                        }
                            /* Selection inside feature
                            * |SSSSSSSSSSSSSSSSSSSSSSS-----------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex >= feature.end && startIndex <= feature.start && endIndex <= feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 4");
                            deletions.push(feature);
                        }
                            /* Selection double end right overlap
                            * |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS----------------------------SSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFF|             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(endIndex - 1 >= feature.start) {
                            if (DEBUG_MODE) trace("case Fc,Sc 5");
							var delLength2a:int = endIndex - feature.start;
							var delLength2b:int = lengthBefore - startIndex;
							delLengthBetween = feature.start - feature.end;
							delLength1 = feature.end;
							
							feature.deleteAt(0, delLength1, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength1;
							feature.deleteAt(0, delLengthBetween, lengthBefore2, circular);
							lengthBefore3 = lengthBefore2 - delLengthBetween;
							feature.deleteAt(0, delLength2a, lengthBefore3, circular);
							var lengthBefore4:int = lengthBefore3 - delLength2a;
							feature.deleteAt(lengthBefore4 - delLength2b, delLength2b, lengthBefore4, circular);
						}
                            /* Selection double end left overlap
                            * |SSSSSSSSSSS---------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
                            *  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                        |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
                        else if(startIndex <= feature.end) {
                            if (DEBUG_MODE) trace("case Fc,Sc 6");
							var delLength1a:int = endIndex;
							var delLength1b:int = feature.end - startIndex;
							delLengthBetween = feature.start - feature.end;
							
							delLength2 = lengthBefore - feature.start;
							var newCutStart:int = startIndex - endIndex;
							feature.deleteAt(0, delLength1a, lengthBefore, circular);
							lengthBefore2 = lengthBefore - delLength1a;
							feature.deleteAt(newCutStart, delLength1b, lengthBefore2, circular);
							lengthBefore3 = lengthBefore2 - delLength1b;
							feature.deleteAt(feature.end, lengthBefore3 - feature.end, lengthBefore3, circular);
							
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
                
                _sequence.deleteSymbols(startIndex - endIndex, lengthBefore - startIndex);
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
                
				reverseFeature.reverseLocations(reverseFeature.start, seqLength, inputSequenceProvider.circular);
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
				var newStart:int = seqLength - reverseFeature.end - 1;
                reverseFeature.strand = -reverseFeature.strand;
                reverseFeature.reverseLocations(newStart, seqLength, circular);
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
                    
					var shiftBy:int = -rebasePosition;
					feature.shift(shiftBy, seqLength, circular);
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
				feature.featureLocations = new Vector.<GenbankLocation>();
				for (var j:int = 0; j < seqProviderFeature.locations.length; j++) {
					var location:Location = seqProviderFeature.locations[j];
					feature.featureLocations.push(new GenbankLocation(location.start + 1, location.end));
				}
                feature.strand = seqProviderFeature.strand;
                feature.key = seqProviderFeature.type;
                tempQualifier = new GenbankFeatureQualifier();
                tempQualifier.quoted = true;
                tempQualifier.name = "label";
                tempQualifier.value = seqProviderFeature.name;
                feature.featureQualifiers.push(tempQualifier);
				if (seqProviderFeature.notes != null) {
	                for (var k:int = 0; k < seqProviderFeature.notes.length; k++) {
	                    tempQualifier = new GenbankFeatureQualifier();
	                    tempQualifier.quoted = seqProviderFeature.notes[k].quoted;
	                    tempQualifier.name = seqProviderFeature.notes[k].name;
	                    tempQualifier.value = seqProviderFeature.notes[k].value;
	                    feature.featureQualifiers.push(tempQualifier);
	                }
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
				dnaFeature.locations = new ArrayCollection();
				for (var k:int = 0; k < genbankFeatures[i].featureLocations.length; k++) {
					dnaFeature.locations.addItem(new DNAFeatureLocation(genbankFeatures[i].featureLocations[k].genbankStart,
					genbankFeatures[i].featureLocations[k].end));
				}
                dnaFeature.type = genbankFeatures[i].key;
                dnaFeature.strand = genbankFeatures[i].strand;
                
                dnaFeature.notes = new ArrayCollection(); /* of DNAFeatureNote */
                for (var j:int = 0; j < genbankFeatures[i].featureQualifiers.length; j++) {
                    if (genbankFeatures[i].featureQualifiers[j].name == "label") {
                        dnaFeature.name = genbankFeatures[i].featureQualifiers[j].value;
                    } else {
                        dnaFeature.notes.addItem(new DNAFeatureNote(genbankFeatures[i].featureQualifiers[j].name, genbankFeatures[i].featureQualifiers[j].value, genbankFeatures[i].featureQualifiers[j].quoted));
                    }
                }
                if (dnaFeature.name == null) {
                    dnaFeature.name = "unknown";
                }
                result.features.addItem(dnaFeature);            
            }
            
            return result;
        }

        public function fromJbeiSeqXml(jbeiSeq:String):FeaturedDNASequence {
            if (jbeiSeq == null || jbeiSeq == "") {
                return null;
            }
            
            var result:FeaturedDNASequence = new FeaturedDNASequence();
            result.features = new ArrayCollection();
            var xmlData:XML = new XML(jbeiSeq);
            var seq:XMLList = null;
            
            var seqNS:Namespace = xmlData.namespace("seq");
            var name:XMLList = xmlData.seqNS::name;
            var circular:XMLList = xmlData.seqNS::circular;
            var sequence:XMLList = xmlData.seqNS::sequence;
            var sequenceSymbols:SymbolList = DNATools.createDNA(sequence.toString());
            var features:XMLList = xmlData.seqNS::features.seqNS::feature;
            var feature:XML;
            var newDnaFeature:DNAFeature;
            
            var newDnaFeatures:ArrayCollection = new ArrayCollection();
			
            for each (feature in features) {
                var featureNameXml:XMLList = feature.seqNS::label;
				var locations:XMLList = feature.seqNS::location;
				var newLocations:ArrayCollection = new ArrayCollection();
				var location:XML;
				for each (location in locations) {
					var genbankStartXml:XMLList = location.seqNS::genbankStart;
                	var endXml:XMLList =  location.seqNS::end;
					newLocations.addItem(new DNAFeatureLocation(parseInt(genbankStartXml.toString()), parseInt(endXml.toString())));
				}
                var strandXml:XMLList = feature.seqNS::complement;
                var typeXml:XMLList = feature.seqNS::type;
                
                newDnaFeature = new DNAFeature();
                newDnaFeature.name = featureNameXml.toString()
                newDnaFeature.locations = newLocations;
				newDnaFeature.type = typeXml.toString();
                newDnaFeature.strand = (strandXml.toString() == "complement") ? -1: 1;
                
                newDnaFeature.notes = new ArrayCollection();
                
                var attributes:XMLList = feature.seqNS::attribute;
                var attribute:XML;
                var featureNote:DNAFeatureNote;
                for each (attribute in attributes) {
                    var attNameXml:XMLList = attribute.attribute("name");
                    var attQuotedXml:XMLList = attribute.attribute("quoted");
                    featureNote = new DNAFeatureNote(attNameXml.toString(), attribute.toString(), new Boolean(attQuotedXml.toString()));
                    newDnaFeature.notes.addItem(featureNote);
                }
                newDnaFeatures.addItem(newDnaFeature);
                
            }
            result.name = name.toString();
            result.isCircular = (circular.toString() == "true") ? true : false;
            result.sequence = sequenceSymbols.toString();
            
            result.features.addAll(newDnaFeatures);
            
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
