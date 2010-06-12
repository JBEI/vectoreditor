package org.jbei.lib.mappers
{
    import org.jbei.bio.enzymes.RestrictionCutSite;
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.data.DigestionSequence;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;

    /**
     * @author Zinovii Dmytriv
     */
    public class DigestionCutter
    {
        private const DEBUG_MODE:Boolean = true;
        
        public static const MATCH_NONE:String = "None";
        public static const MATCH_NORMAL_ONLY:String = "NormalOnly";
        public static const MATCH_REVCOM_ONLY:String = "RevComOnly";
        public static const MATCH_BOTH:String = "Both";
        
        private static const OVERHANG_NONE:String = "None";
        private static const OVERHANG_TOP:String = "Top";
        private static const OVERHANG_BOTTOM:String = "Bottom";
        
        private var sequenceProvider:SequenceProvider;
        private var start:int;
        private var end:int;
        private var digestionSequence:DigestionSequence;
        private var restrictionEnzymeMapper:RestrictionEnzymeMapper;
        
        private var _matchType:String = MATCH_NONE;
        
        private var destinationStartCutSite:RestrictionCutSite = null;
        private var destinationEndCutSite:RestrictionCutSite = null;
        private var destinationOverhangStartType:String = OVERHANG_NONE;
        private var destinationOverhangEndType:String = OVERHANG_NONE;
        private var destinationOverhangStartSequence:String;
        private var destinationOverhangEndSequence:String;
        
        private var sourceSequence:String;
        private var sourceRevComSequence:String;
        private var sourceOverhangStartType:String = OVERHANG_NONE;
        private var sourceOverhangEndType:String = OVERHANG_NONE;
        private var sourceOverhangStartSequence:String;
        private var sourceOverhangEndSequence:String;
        private var pasteSequenceProvider:SequenceProvider;
        
        // Constructor
        public function DigestionCutter(sequenceProvider:SequenceProvider, start:int, end:int, digestionSequence:DigestionSequence, restrictionEnzymeMapper:RestrictionEnzymeMapper):void
        {
            this.sequenceProvider = sequenceProvider;
            this.start = start;
            this.end = end;
            this.digestionSequence = digestionSequence;
            this.restrictionEnzymeMapper = restrictionEnzymeMapper;
            
            initializeSource();
            initializeDestination();
            
            calculateMatchingType();
        }
        
        // Properties
        public function get matchType():String
        {
            return _matchType;
        }
        
        // Public Methods
        public function digest(type:String):void
        {
            if(!(type == MATCH_NORMAL_ONLY || type == MATCH_REVCOM_ONLY)) {
                throw new Error("Invalid digestion type! Should be '" + MATCH_NORMAL_ONLY +  "' or '" + MATCH_REVCOM_ONLY + "'");
            }
            
            if(type == MATCH_REVCOM_ONLY) {
                pasteSequenceProvider.reverseComplementSequence();
            }
            
            var startPosition:int = destinationStartCutSite.start;
            var endPosition:int = destinationStartCutSite.end + destinationStartCutSite.restrictionEnzyme.dsForward;
            
            if(destinationStartCutSite.restrictionEnzyme.dsForward > destinationStartCutSite.restrictionEnzyme.dsReverse) {
                startPosition = destinationStartCutSite.start + destinationStartCutSite.restrictionEnzyme.dsReverse;
            } else if(destinationStartCutSite.restrictionEnzyme.dsForward < destinationStartCutSite.restrictionEnzyme.dsReverse) {
                startPosition = destinationStartCutSite.start + destinationStartCutSite.restrictionEnzyme.dsForward;
            } else {
                startPosition = destinationStartCutSite.start + destinationStartCutSite.restrictionEnzyme.dsForward;
            }
            
            if(destinationEndCutSite.restrictionEnzyme.dsForward > destinationEndCutSite.restrictionEnzyme.dsReverse) {
                endPosition = destinationEndCutSite.start + destinationEndCutSite.restrictionEnzyme.dsForward;
            } else if(destinationEndCutSite.restrictionEnzyme.dsForward < destinationEndCutSite.restrictionEnzyme.dsReverse) {
                endPosition = destinationEndCutSite.start + destinationEndCutSite.restrictionEnzyme.dsReverse;
            } else {
                endPosition = destinationEndCutSite.start + destinationEndCutSite.restrictionEnzyme.dsReverse;
            }
            
            sequenceProvider.manualUpdateStart();
            sequenceProvider.removeSequence(startPosition, endPosition);
            sequenceProvider.insertSequenceProvider(pasteSequenceProvider, startPosition);
            sequenceProvider.manualUpdateEnd();
        }
        
        // Private Methods
        private function calculateMatchingType():void
        {
            var normalMatch:Boolean = hasNormalMatch();
            var revComMatch:Boolean = hasRevComMatch();
            
            if(normalMatch && revComMatch) {
                _matchType = MATCH_BOTH;
            } else if (normalMatch && !revComMatch) {
                _matchType = MATCH_NORMAL_ONLY;
            } else if (!normalMatch && revComMatch) {
                _matchType = MATCH_REVCOM_ONLY;
            } else {
                _matchType = MATCH_NONE;
            }
        }
        
        private function initializeSource():void
        {
            sourceSequence = digestionSequence.sequenceProvider.sequence.seqString();
            sourceRevComSequence = digestionSequence.sequenceProvider.getComplementSequence().seqString();
            
            var pastableStartIndex:int = digestionSequence.startRestrictionEnzyme.dsForward;
            var pastableEndIndex:int = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse;
            
            if(digestionSequence.startRestrictionEnzyme.dsForward < digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = OVERHANG_TOP;
                sourceOverhangStartSequence = sourceSequence.substring(digestionSequence.startRestrictionEnzyme.dsForward, digestionSequence.startRestrictionEnzyme.dsReverse);
                pastableStartIndex = digestionSequence.startRestrictionEnzyme.dsForward;
            } else if(digestionSequence.startRestrictionEnzyme.dsForward > digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = OVERHANG_BOTTOM;
                sourceOverhangStartSequence = sourceRevComSequence.substring(digestionSequence.startRestrictionEnzyme.dsForward, digestionSequence.startRestrictionEnzyme.dsReverse);
                pastableStartIndex = digestionSequence.startRestrictionEnzyme.dsReverse;
            } else {
                sourceOverhangStartType = OVERHANG_NONE;
                sourceOverhangStartSequence = "";
            }
            
            if(digestionSequence.endRestrictionEnzyme.dsForward < digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = OVERHANG_BOTTOM;
                sourceOverhangEndSequence = sourceRevComSequence.substring(digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward, digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse);
                pastableEndIndex = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse;
            } else if(digestionSequence.endRestrictionEnzyme.dsForward > digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = OVERHANG_TOP;
                sourceOverhangEndSequence = sourceSequence.substring(digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward, digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse);
                pastableEndIndex = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward;
            } else {
                sourceOverhangEndType = OVERHANG_NONE;
                sourceOverhangEndSequence = "";
            }
            
            pasteSequenceProvider = digestionSequence.sequenceProvider.subSequenceProvider(pastableStartIndex, pastableEndIndex);
            
            if(DEBUG_MODE) {
                trace("--------------------------------------------------------------");
                trace("Source:");
                trace(digestionSequence.startRestrictionEnzyme.name + ": " + sourceOverhangStartType + ", " + sourceOverhangStartSequence);
                trace(digestionSequence.endRestrictionEnzyme.name + ": " + sourceOverhangEndType + ", " + sourceOverhangEndSequence);
                trace(pasteSequenceProvider.sequence.seqString());
            }
        }
        
        private function initializeDestination():void
        {
            destinationStartCutSite = null;
            destinationEndCutSite = null;
            
            for(var i:int = 0; i < restrictionEnzymeMapper.cutSites.length; i++) {
                var cutSite:RestrictionCutSite = restrictionEnzymeMapper.cutSites.getItemAt(i) as RestrictionCutSite;
                
                if(start == cutSite.start) {
                    destinationStartCutSite = cutSite;
                }
                
                if(end == cutSite.end + 1) {
                    destinationEndCutSite = cutSite;
                }
                
                if(destinationStartCutSite && destinationEndCutSite) {
                    break;
                }
            }
            
            if(!destinationStartCutSite || !destinationEndCutSite) {
                throw new Error("This should never happen!");
            }
            
            var destinationSequence:String = (start > end) ? (sequenceProvider.sequence.subList(0, end).seqString() + sequenceProvider.sequence.subList(start, sequenceProvider.sequence.length).seqString()) : sequenceProvider.sequence.subList(start, end).seqString();
            var destinationRevComSequence:String = (start > end) ? (sequenceProvider.getComplementSequence().subList(0, end).seqString() + sequenceProvider.getComplementSequence().subList(start, sequenceProvider.getComplementSequence().length).seqString()) : sequenceProvider.getComplementSequence().subList(start, end).seqString();
            
            if(destinationStartCutSite.restrictionEnzyme.dsForward < destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartSequence = destinationRevComSequence.substring(destinationStartCutSite.restrictionEnzyme.dsForward, destinationStartCutSite.restrictionEnzyme.dsReverse);
                
                destinationOverhangStartType = OVERHANG_BOTTOM;
            } else if(destinationStartCutSite.restrictionEnzyme.dsForward > destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartSequence = destinationSequence.substring(destinationStartCutSite.restrictionEnzyme.dsReverse, destinationStartCutSite.restrictionEnzyme.dsForward);
                
                destinationOverhangStartType = OVERHANG_TOP;
            } else {
                destinationOverhangStartType = OVERHANG_NONE;
                destinationOverhangStartSequence = "";
            }
            
            var rePosition:int = destinationEndCutSite.start - destinationStartCutSite.start;
            
            if(destinationEndCutSite.restrictionEnzyme.dsForward < destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndSequence = destinationSequence.substring(rePosition + destinationEndCutSite.restrictionEnzyme.dsForward, rePosition + destinationEndCutSite.restrictionEnzyme.dsReverse);
                destinationOverhangEndType = OVERHANG_TOP;
            } else if(destinationEndCutSite.restrictionEnzyme.dsForward > destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndSequence = destinationRevComSequence.substring(rePosition + destinationEndCutSite.restrictionEnzyme.dsForward, rePosition + destinationEndCutSite.restrictionEnzyme.dsReverse);
                destinationOverhangEndType = OVERHANG_BOTTOM;
            } else {
                destinationOverhangEndType = OVERHANG_NONE;
                destinationOverhangEndSequence = "";
            }
            
            if(DEBUG_MODE) {
                trace("--------------------------------------------------------------");
                trace("Destination:");
                trace(destinationStartCutSite.restrictionEnzyme.name + ": " + destinationOverhangStartType + ", " + destinationOverhangStartSequence);
                trace(destinationStartCutSite.restrictionEnzyme.name + ": " + destinationOverhangEndType + ", " + destinationOverhangEndSequence);
            }
        }
        
        private function hasNormalMatch():Boolean
        {
            // Trying to much overhang by shape
            var matchByShapeStart:Boolean = false;
            var matchByShapeEnd:Boolean = false;
            
            if((sourceOverhangStartType == OVERHANG_TOP && destinationOverhangStartType == OVERHANG_BOTTOM)
                || (sourceOverhangStartType == OVERHANG_BOTTOM && destinationOverhangStartType == OVERHANG_TOP)
                || (sourceOverhangStartType == OVERHANG_NONE && destinationOverhangStartType == OVERHANG_NONE)
            ) {
                matchByShapeStart = true;
            }
            
            if(matchByShapeStart 
                && ((sourceOverhangEndType == OVERHANG_TOP && destinationOverhangEndType == OVERHANG_BOTTOM)
                    ||  (sourceOverhangEndType == OVERHANG_BOTTOM && destinationOverhangEndType == OVERHANG_TOP)
                    ||  (sourceOverhangEndType == OVERHANG_NONE && destinationOverhangEndType == OVERHANG_NONE))
            ) {
                matchByShapeEnd = true;
            }
            
            if(!matchByShapeStart || !matchByShapeEnd) {
                return false;
            }
            
            // Trying to much overhang by length
            if(sourceOverhangStartSequence.length != destinationOverhangStartSequence.length
                || sourceOverhangEndSequence.length != destinationOverhangEndSequence.length) {
                
                return false;
            }
            
            // Trying to much overhang by sequence
            if(sourceOverhangStartType == OVERHANG_TOP || sourceOverhangStartType == OVERHANG_BOTTOM) {
                var complement1:String = DNATools.complement(DNATools.createDNA(destinationOverhangStartSequence)).seqString();
                
                if(sourceOverhangStartSequence != complement1) {
                    return false;
                }
            }
            
            if(sourceOverhangEndType == OVERHANG_TOP || sourceOverhangEndType == OVERHANG_BOTTOM) {
                var complement2:String = DNATools.complement(DNATools.createDNA(destinationOverhangEndSequence)).seqString();
                
                if(sourceOverhangEndSequence != complement2) {
                    return false;
                }
            }
            
            return true;
        }
        
        private function hasRevComMatch():Boolean
        {
            // Trying to much overhang by shape
            var matchByShapeStart:Boolean = false;
            var matchByShapeEnd:Boolean = false;
            
            if((sourceOverhangEndType == OVERHANG_TOP && destinationOverhangStartType == OVERHANG_TOP)
                || (sourceOverhangEndType == OVERHANG_BOTTOM && destinationOverhangStartType == OVERHANG_BOTTOM)
                || (sourceOverhangEndType == OVERHANG_NONE && destinationOverhangStartType == OVERHANG_NONE)
            ) {
                matchByShapeStart = true;
            }
            
            if(matchByShapeStart 
                && ((sourceOverhangStartType == OVERHANG_TOP && destinationOverhangEndType == OVERHANG_TOP)
                    ||  (sourceOverhangStartType == OVERHANG_BOTTOM && destinationOverhangEndType == OVERHANG_BOTTOM)
                    ||  (sourceOverhangStartType == OVERHANG_NONE && destinationOverhangEndType == OVERHANG_NONE))
            ) {
                matchByShapeEnd = true;
            }
            
            if(!matchByShapeStart || !matchByShapeEnd) {
                return false;
            }
            
            // Trying to much overhang by length
            if(sourceOverhangEndSequence.length != destinationOverhangStartSequence.length
                || sourceOverhangStartSequence.length != destinationOverhangEndSequence.length) {
                
                return false;
            }
            
            // Trying to much overhang by sequence
            if(sourceOverhangStartType == OVERHANG_TOP || sourceOverhangStartType == OVERHANG_BOTTOM) {
                if(sourceOverhangStartSequence != destinationOverhangEndSequence) {
                    return false;
                }
            }
            
            if(sourceOverhangEndType == OVERHANG_TOP || sourceOverhangEndType == OVERHANG_BOTTOM) {
                if(sourceOverhangEndSequence != destinationOverhangStartSequence) {
                    return false;
                }
            }
            
            return true;
        }
    }
}