package org.jbei.bio.data
{
	import mx.collections.ArrayCollection;
	
	public class Feature extends Segment
	{
		// Variables
		private var _type:String;
		private var _notes:Array /* of FeatureNote */;
		private var _strand:int;
		
		// Static Constants
		public static const POSITIVE:int = 1;
		public static const NEGATIVE:int = -1;
		public static const UNKNOWN:int = 0;
		
		// Constructor
		public function Feature(start:int = 0, end:int = 0, type:String = "", strand:int = Feature.UNKNOWN, notes:Array /* of FeatureNote */ = null)
		{
			super(start, end);
			
			_type = type;
			_strand = strand;
			
			_notes = notes;
			if(_notes == null) {
				_notes = new Array();
			}
		}
		
		// Properties
		public function get type():String
		{
			return _type;
		}
		
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get notes():Array /* of FeatureNote */
		{
			return _notes;
		}
		
		public function set notes(value:Array /* of FeatureNote */):void
		{
			_notes = value;
		}
		
		public function get strand():int
		{
			return _strand;
		}
		
		public function set strand(value:int):void
		{
			_strand = value;
		}
		
		public function get label():String
		{
			var result:String = "";
			
			if(notes != null && notes.length > 0) {
				for(var i:int = 0; i < notes.length; i++) {
					var featureNote:FeatureNote = notes[i] as FeatureNote;
					
					if(featureNote.name == "label") {
						result = featureNote.value;
						
						break;
					}
				}
			}
			
			return result;
		}
		
		// Public Methods
		public function clone():Feature
		{
			var clonedFeature:Feature = new Feature(start, end, _type, _strand);
			
			if(_notes && _notes.length > 0) {
				var clonedNotes:Array = new Array();
				
				for(var i:int = 0; i < _notes.length; i++) {
					clonedNotes.push((_notes[i] as FeatureNote).clone());
				}
				
				clonedFeature._notes = clonedNotes;
			}
			
			return clonedFeature;
		}
		
		public function toString():String
		{
			var result:String = _type;
			result += "\n\t\t" + start + ".." + end;
			
			for each (var note:FeatureNote in _notes) {
				result += "\n\t\t/" + note.toString();
			}
			
			return result;
		}
	}
}
