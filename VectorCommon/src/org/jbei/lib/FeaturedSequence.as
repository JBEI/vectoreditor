package org.jbei.lib
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.FeatureNote;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.lib.common.IMemento;
	import org.jbei.lib.common.IOriginator;
	import org.jbei.lib.utils.StringFormatter;
	
	[RemoteClass(alias="org.jbei.lib.FeaturedSequence")]
	public class FeaturedSequence implements IOriginator
	{
		private var _name:String;
		private var _circular:Boolean;
		private var _sequence:DNASequence;
		private var _oppositeSequence:DNASequence;
		private var _features:ArrayCollection /* of Feature */;
		
		private var _manualUpdateStarted:Boolean = false;
		
		private var dispatcher:EventDispatcher = new EventDispatcher();
		
		// Constructor
		public function FeaturedSequence(name:String = null, circular:Boolean = false, sequence:DNASequence = null, oppositeSequence:DNASequence = null, features:ArrayCollection = null)
		{
			super();
			
			_name = name;
			_circular = circular;
			_sequence = sequence;
			_oppositeSequence = oppositeSequence;
			_features = features ? features : new ArrayCollection();
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
		
		public function get circular():Boolean
		{
			return _circular;
		}
		
		public function set circular(value:Boolean):void
		{
			_circular = value;
		}
		
		public function get sequence():DNASequence
		{
			return _sequence;
		}
		
		public function set sequence(value:DNASequence):void
		{
			_sequence = value;
		}
		
		public function get oppositeSequence():DNASequence
		{
			return _oppositeSequence;
		}
		
		public function set oppositeSequence(value:DNASequence):void
		{
			_oppositeSequence = value;
		}
		
		public function get features():ArrayCollection /* of Feature */
		{
			return _features;
		}
		
		public function set features(value:ArrayCollection):void
		{
			_features = value;
		}
		
		[Transient]
		public function get manualUpdateStarted():Boolean
		{
			return _manualUpdateStarted;
		}
		
		// Public Methods: IOriginator implementation
		public function createMemento():IMemento
		{
			var clonedFeatures:ArrayCollection = new ArrayCollection();
			
			if(_features && _features.length > 0) {
				for(var i:int = 0; i < _features.length; i++) {
					clonedFeatures.addItem((_features[i] as Feature).clone());
				}
			}
			
			return new FeaturedSequenceMemento(_name, _circular, new DNASequence(_sequence.sequence, true), new DNASequence(_oppositeSequence.sequence, true), clonedFeatures);
		}
		
		public function setMemento(memento:IMemento):void
		{
			var featuredSequenceMemento:FeaturedSequenceMemento = memento as FeaturedSequenceMemento;
			
			_name = featuredSequenceMemento.name;
			_circular = featuredSequenceMemento.circular;
			_sequence = featuredSequenceMemento.sequence;
			_oppositeSequence = featuredSequenceMemento.oppositeSequence;
			_features = featuredSequenceMemento.features;
			
			dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_SET_MEMENTO));
		}
		
		// Public Methods: EventDispatcher wrapped
		public function addEventListener(type:String, listener:Function):void
		{
			dispatcher.addEventListener(type, listener);
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			dispatcher.removeEventListener(type, listener);
		}
		
		public function dispatchEvent(event:Event):void
		{
			dispatcher.dispatchEvent(event);
		}
		
		// Public Methods
		public function subSequence(start:int, end:int):DNASequence
		{
			var result:DNASequence = null;
			
			if(start < 0 || end < 0 || start > _sequence.length || end > _sequence.length) {
				return result;
			}
			
			if(start > end) {
				result = new DNASequence(_sequence.sequence.substring(start, _sequence.length) + _sequence.sequence.substring(0, end), true);
			} else {
				result = _sequence.subSequence(start, end - start);
			}
			
			return result;
		}
		
		public function subFeaturedSequence(start:int, end:int):FeaturedSequence
		{
			var featuredSubSequence:FeaturedSequence;
			
			if(start < 0 || end < 0 || start > _sequence.length || end > _sequence.length) {
				return featuredSubSequence;
			}
			
			var featuredDNASubSequence:DNASequence = subSequence(start, end);
			var featuredOppositeSubSequence:DNASequence = SequenceUtils.oppositeSequence(featuredDNASubSequence);
			
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
			
			featuredSubSequence = new FeaturedSequence("Dummy", false, featuredDNASubSequence, featuredOppositeSubSequence, subFeatures);
			
			return featuredSubSequence;
		}
		
		public function addFeature(feature:Feature, quiet:Boolean = false):void
		{
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_FEATURE_ADD, createMemento()));
			}
			
			_features.addItem(feature);
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_FEATURE_ADD, feature));
			}
		}
		
		public function addFeatures(featuresToAdd:Array /* of Feature */, quiet:Boolean = false):void
		{
			if(!featuresToAdd || featuresToAdd.length == 0) { return; } 
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_FEATURES_ADD, createMemento()));
			}
			
			for(var i:int = 0; i < featuresToAdd.length; i++) {
				var feature:Feature = featuresToAdd[i] as Feature;
				
				addFeature(feature, true);
			}
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_FEATURES_ADD, features));
			}
		}
		
		public function removeFeature(feature:Feature, quiet:Boolean = false):void
		{
			var index:int = _features.getItemIndex(feature);
			
			if(index >= 0) {
				if(!quiet && !_manualUpdateStarted) {
					dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_FEATURE_REMOVE, createMemento()));
				}
				
				_features.removeItemAt(index);
				
				if(!quiet && !_manualUpdateStarted) {
					dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_FEATURE_REMOVE, feature));
				}
			}
		}
		
		public function removeFeatures(featuresToRemove:Array /* of Feature */, quiet:Boolean = false):void
		{
			if(!featuresToRemove || featuresToRemove.length == 0) { return; } 
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_FEATURES_REMOVE, createMemento()));
			}
			
			for(var i:int = 0; i < featuresToRemove.length; i++) {
				var feature:Feature = featuresToRemove[i] as Feature;
				
				removeFeature(feature, true);
			}
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_FEATURES_REMOVE, features));
			}
		}
		
		public function hasFeature(feature:Feature):Boolean
		{
			return features.contains(feature);
		}
		
		public function insertFeaturedSequence(featuredSequence:FeaturedSequence, position:int, quiet:Boolean = false):void
		{
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_SEQUENCE_INSERT, createMemento()));
			}
			
			insertSequence(new DNASequence(featuredSequence.sequence.sequence), position, true);
			
			for(var z:int = 0; z < featuredSequence.features.length; z++) {
				var insertFeature:Feature = (featuredSequence.features[z] as Feature).clone();
				
				insertFeature.start += position;
				insertFeature.end += position;
				
				addFeature(insertFeature, true);
			}
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_SEQUENCE_INSERT, {featuredSequence : featuredSequence, position : position}));
			}
		}
		
		public function insertSequence(insertSequence:DNASequence, position:int, quiet:Boolean = false):void
		{
			if(position < 0 || position > sequence.length || insertSequence.length == 0) { return };
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_SEQUENCE_INSERT, createMemento()));
			}
			
			_sequence.insert(insertSequence, position);
			
			var insertOpposite:DNASequence = SequenceUtils.oppositeSequence(insertSequence);
			_oppositeSequence.insert(insertOpposite, position);
			
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
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_SEQUENCE_INSERT, {sequence : insertSequence, position : position}));
			}
		}
		
		public function removeSequence(startIndex:int, endIndex:int, quiet:Boolean = false):void
		{
			var sequenceLength:int = _sequence.length;
			
			if(endIndex < 0 || startIndex < 0 || startIndex > sequenceLength || endIndex > sequenceLength || startIndex == endIndex) { return; }
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_SEQUENCE_INSERT, createMemento()));
			}
			
			const DEBUG_MODE:Boolean = false;
			
			var deletions:Array = new Array(); // features marked for deletion
			
			for(var i:int = 0; i < _features.length; i++) {
				var feature:Feature = _features[i];
				
				if(feature.start <= feature.end) { // normal feature
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
						else if(startIndex <= feature.start && feature.end <= (endIndex - 1)) {
							deletions.push(feature);
							if (DEBUG_MODE) trace("case Fn,Sn 3");
						}
							/* Selection inside feature => resize feature
							* |-------------------------------------SSSSSSSSSSSSSSSSSSSSSS---------------------------------------|
							*                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
						else if((startIndex >= feature.start && (endIndex - 1) < feature.end) || (startIndex > feature.start && (endIndex - 1) <= feature.end)) {
							feature.end -= endIndex - startIndex;
							if (DEBUG_MODE) trace("case Fn,Sn 4");
						}
							/* Selection left overlap feature => shift & resize feature
							* |-----------------------------SSSSSSSSSSSSSSSSSSSSS------------------------------------------------|
							*                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
						else if(startIndex < feature.start && feature.start <= (endIndex - 1)) {
							feature.start = startIndex;
							feature.end -= endIndex - startIndex;
							if (DEBUG_MODE) trace("case Fn,Sn 5");
						}
							/* Selection right overlap feature => shift & resize feature
							* |-------------------------------------------------SSSSSSSSSSSSSSSSSSSSS----------------------------|
							*                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
						else if(startIndex <= feature.end && (endIndex - 1) > feature.end) {
							feature.end = startIndex - 1;
							if (DEBUG_MODE) trace("case Fn,Sn 6");
						} else {
							throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.sequence);
						}
					} else { // circular selection
						/* Selection and feature no overlap => shift left
						* |SSSSSSSSSSS-------------------------------------------------------------------------SSSSSSSSSSSSSS|
						*                                  |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                    */
						if(startIndex > feature.end && (endIndex - 1) < feature.start) {
							feature.start -= endIndex;
							feature.end -= endIndex;
							if (DEBUG_MODE) trace("case Fn,Sc 1");
						}
							/* Selection and feature left partial overlap => cut and shift
							* |SSSSSSSSSSSSSSSSSSSS----------------------------------------------------------------SSSSSSSSSSSSSS|
							*             |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                                         */
						else if(startIndex > feature.end && (endIndex - 1) >= feature.start && endIndex < feature.end) {
							feature.start = 0;
							feature.end -= endIndex;
							if (DEBUG_MODE) trace("case Fn,Sc 2");
						}
							/* Selection and feature right partial overlap => cut and shift
							* |SSSSSSSSSSSSSSS--------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSSSS|
							*                                                       |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|               */
						else if(startIndex > feature.start && startIndex <= feature.end && (endIndex - 1) < feature.start) {
							feature.start -= endIndex;
							feature.end -= (feature.end - startIndex + 1) + endIndex;
							if (DEBUG_MODE) trace("case Fn,Sc 3");
						}
							/* Double selection overlap => cut and shift
							* |SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS-----------------SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS|
							*                           |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF|                                          */
						else if(startIndex <= feature.end && (endIndex - 1) >= feature.start) {
							feature.start = 0;
							feature.end -= (feature.end - startIndex + 1) + endIndex;
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
							throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.sequence);
						}
					}
				} else { // circular feature
					if(startIndex < endIndex) { // normal selection
						/* Selection between feature start and end
						* |-------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS------------------------------------------|
						*  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
						if(startIndex > feature.end && (endIndex - 1) < feature.start) {
							feature.start -= endIndex - startIndex;
							if (DEBUG_MODE) trace("case Fc,Sn 1");
						}
							/* Selection inside feature start
							* |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
							*  FFFFFFFFFFFFFFFFFFF|                                               |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
						else if(startIndex > feature.start) {
							if (DEBUG_MODE) trace("case Fc,Sn 2");
						}
							/* Selection inside feature end
							* |--SSSSSSSSSSSSSSSSSS------------------------------------------------------------------------------|
							*  FFFFFFFFFFFFFFFFFFFFFFFFF|                                         |FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  */
						else if((endIndex - 1) < feature.end) {
							feature.start -= endIndex - startIndex;
							feature.end -= endIndex - startIndex;
							if (DEBUG_MODE) trace("case Fc,Sn 3");
						}
							/* Selection in feature start
							* |----------------------------------------------------------------------SSSSSSSSSSSSSSSSSSSSSSSSS---|
							*  FFFFFFFFFFFFFFFFFFF|                                                        |FFFFFFFFFFFFFFFFFFFFF  */
						else if(startIndex > feature.end && startIndex <= feature.start && (endIndex - 1) >= feature.start) {
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
						else if(startIndex <= feature.end && (endIndex - 1) >= feature.end && (endIndex - 1) < feature.start) {
							if(startIndex == 0 && (endIndex - 1) >= feature.end) {
								feature.end = sequence.length - 1 - (endIndex - startIndex);
								feature.start -= endIndex - startIndex;
								if (DEBUG_MODE) trace("case Fc,Sn 5a");
							} else {
								feature.start -= endIndex - startIndex;
								feature.end = startIndex - 1;
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
							throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.sequence);
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
							throw new Error("Unhandled editing case!" + " Selection: [" + startIndex + ", " + endIndex + "], Feature: [" + feature.start + ", " + feature.end + "], Sequence: " + sequence.sequence);
						}
					}
				}
			}
			
			for(var d:int = 0; d < deletions.length; d++) {
				removeFeature(deletions[d] as Feature, true);
			}
			
			if(startIndex > endIndex) {
				_sequence.remove(0, endIndex);
				_oppositeSequence.remove(0, endIndex);
				
				_sequence.remove(startIndex - endIndex, sequenceLength - startIndex);
				_oppositeSequence.remove(startIndex - endIndex, sequenceLength - startIndex);
			} else {
				var removeSequenceLength:int = endIndex - startIndex;
				
				_sequence.remove(startIndex, removeSequenceLength);
				_oppositeSequence.remove(startIndex, removeSequenceLength);
			}
			
			if(!quiet && !_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_SEQUENCE_REMOVE, {position : startIndex, length : length}));
			}
		}
		
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
		
		public function manualUpdateStart():void
		{
			if(!_manualUpdateStarted) {
				_manualUpdateStarted = true;
				
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGING, FeaturedSequenceEvent.KIND_MANUAL_UPDATE, createMemento()));
			}
		}
		
		public function manualUpdateEnd():void
		{
			if(_manualUpdateStarted) {
				dispatcher.dispatchEvent(new FeaturedSequenceEvent(FeaturedSequenceEvent.SEQUENCE_CHANGED, FeaturedSequenceEvent.KIND_MANUAL_UPDATE, null));
				
				_manualUpdateStarted = false;
			}
		}
		
		public function clone():FeaturedSequence
		{
			var clonedFeaturedSequence:FeaturedSequence = new FeaturedSequence(_name, _circular, new DNASequence(_sequence.sequence), new DNASequence(_oppositeSequence.sequence));
			
			if(_features && _features.length > 0) {
				for(var i:int = 0; i < _features.length; i++) {
					clonedFeaturedSequence.addFeature(_features[i], true);
				}
			}
			
			return clonedFeaturedSequence;
		}
		
		public function toString():String
		{
			return _sequence.exportAsText(60, true, true);
		}
		
		public function toGenbank():String
		{
			// TODO: Move this somewhere else
			
			var date:Date = new Date();
			
			var genbankString:String = "";
			
			genbankString += StringFormatter.sprintf("LOCUS       %-21s%7d bp    DNA     %-9s    %s", name.substr(0, 11), sequence.length, (circular ? "circular" : "linear"), getGenbankDate());
			genbankString += StringFormatter.sprintf("\nCOMMENT     This is simplified autogenerated version of genbank file");
			
			if(!features || features.length == 0) { return genbankString; }
			
			genbankString += "\nFEATURES             Location/Qualifiers";
			
			for(var i:int = 0; i < features.length; i++) {
				var feature:Feature = features[i] as Feature;
				
				if(feature.strand == -1) {
					genbankString += StringFormatter.sprintf("\n     %-16scomplement(%d..%d)", feature.type, feature.start + 1, feature.end + 1);
				} else {
					genbankString += StringFormatter.sprintf("\n     %-16s%d..%d", feature.type, feature.start + 1, feature.end + 1);
				}
				
				if(!feature.notes || feature.notes.length == 0) { continue; }
				
				for(var j:int = 0; j < feature.notes.length; j++) {
					var featureNote:FeatureNote = feature.notes[j] as FeatureNote;
					
					genbankString += StringFormatter.sprintf("\n                     /%s=\"%s\"", String(featureNote.name), String(featureNote.value));
				}
			}
			
			genbankString += StringFormatter.sprintf("\nBASE COUNT%9d a %9d c %9d g %9d t ", countNucleotides("A"), countNucleotides("C"), countNucleotides("G"), countNucleotides("T"));
			genbankString += "\nORIGIN";
			
			var rowIndex:int = 1;
			var rowString:String = "";
			var formattedRowString:String = "";
			var currentString:String = sequence.sequence.toLowerCase();
			for(var z:int = 0; z < currentString.length; z++) {
				if((z == 0) || z % 60 == 0) {
					rowIndex = z + 1;
				}
				
				rowString += currentString.charAt(z);
				
				if((z + 1) % 60 == 0) {
					formattedRowString += StringFormatter.sprintf("\n  %7d %s ", rowIndex, rowString);
					rowString = "";
				} else if ((z + 1) % 10 == 0) {
					rowString += " ";
				}
				
				if(z == currentString.length - 1) {
					formattedRowString += StringFormatter.sprintf("\n  %7d %s ", rowIndex, rowString);
				}
			}
			
			genbankString += formattedRowString;
			genbankString += "\n//";
			
			return genbankString;
		}
		
		// Private Methods
		private function getGenbankDate():String
		{
			var result:String;
			
			var date:Date = new Date();
			
			var month:String = "";
			switch(date.month) {
				case 0:
					month = "JAN";
					break;
				case 1:
					month = "FEB";
					break;
				case 2:
					month = "MAR";
					break;
				case 3:
					month = "APR";
					break;
				case 4:
					month = "MAY";
					break;
				case 5:
					month = "JUN";
					break;
				case 6:
					month = "JUL";
					break;
				case 7:
					month = "AUG";
					break;
				case 8:
					month = "SEP";
					break;
				case 9:
					month = "OCT";
					break;
				case 10:
					month = "NOV";
					break;
				case 11:
					month = "DEC";
					break;
				default:
					return result;
					break;
			}
			
			return StringFormatter.sprintf("%02d-%3s-%4d", date.date, month, date.fullYear);
		}
		
		private function countNucleotides(nucleotide:String):int
		{
			var currentSequence:String = sequence.sequence;
			var result:int = 0;
			
			for(var i:int = 0; i < currentSequence.length; i++) {
				if(currentSequence.charAt(i) == nucleotide) {
					result++;
				}
			}
			
			return result;
		}
	}
}
