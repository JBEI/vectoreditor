package org.jbei.lib.mappers
{
    import org.jbei.bio.data.CutSite;
    import org.jbei.bio.data.RestrictionEnzyme;
    import org.jbei.bio.utils.SequenceUtils;
    import org.jbei.lib.FeaturedSequence;
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
        
        private var featuredSequence:FeaturedSequence;
        private var start:int;
        private var end:int;
        private var digestionSequence:DigestionSequence;
        private var restrictionEnzymeMapper:RestrictionEnzymeMapper;
        
        private var _matchType:String = MATCH_NONE;
        
        private var destinationStartCutSite:CutSite = null;
        private var destinationEndCutSite:CutSite = null;
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
        private var pasteFeaturedSequence:FeaturedSequence;
        
        // Constructor
        public function DigestionCutter(featuredSequence:FeaturedSequence, start:int, end:int, digestionSequence:DigestionSequence, restrictionEnzymeMapper:RestrictionEnzymeMapper):void
        {
            this.featuredSequence = featuredSequence;
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
                throw new Error("Invalid digestion type! Should be 'NormalOnly' or 'RevComOnly'")
            }
            
            var startPosition:int = destinationStartCutSite.start;
            var endPosition:int = destinationStartCutSite.end + destinationStartCutSite.restrictionEnzyme.dsForward;
            
            if(destinationStartCutSite.restrictionEnzyme.dsForward > destinationStartCutSite.restrictionEnzyme.dsReverse) {
                startPosition = destinationStartCutSite.start + destinationStartCutSite.restrictionEnzyme.dsReverse;
            } else if(destinationStartCutSite.restrictionEnzyme.dsForward < destinationStartCutSite.restrictionEnzyme.dsReverse) {
                startPosition = destinationStartCutSite.start + destinationStartCutSite.restrictionEnzyme.dsForward;
            }
            
            if(destinationEndCutSite.restrictionEnzyme.dsForward > destinationEndCutSite.restrictionEnzyme.dsReverse) {
                endPosition = destinationEndCutSite.start + destinationEndCutSite.restrictionEnzyme.dsForward;
            } else if(destinationEndCutSite.restrictionEnzyme.dsForward < destinationEndCutSite.restrictionEnzyme.dsReverse) {
                endPosition = destinationEndCutSite.start + destinationEndCutSite.restrictionEnzyme.dsReverse;
            }
            
            featuredSequence.manualUpdateStart();
            featuredSequence.removeSequence(startPosition, endPosition);
            featuredSequence.insertFeaturedSequence(pasteFeaturedSequence, startPosition);
            featuredSequence.manualUpdateEnd();
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
            sourceSequence = digestionSequence.featuredSequence.sequence.sequence;
            sourceRevComSequence = SequenceUtils.reverseComplement(digestionSequence.featuredSequence.sequence).sequence;
            
            var pastableStartIndex:int = digestionSequence.startRestrictionEnzyme.dsForward;
            var pastableEndIndex:int = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse;
            
            if(digestionSequence.startRestrictionEnzyme.dsForward < digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = OVERHANG_TOP;
                sourceOverhangStartSequence = sourceSequence.substring(digestionSequence.startRestrictionEnzyme.dsForward, digestionSequence.startRestrictionEnzyme.dsReverse);
                pastableStartIndex = digestionSequence.startRestrictionEnzyme.dsForward;
            } else if(digestionSequence.startRestrictionEnzyme.dsForward > digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = OVERHANG_BOTTOM;
                sourceOverhangStartSequence = sourceSequence.substring(digestionSequence.startRestrictionEnzyme.dsForward, digestionSequence.startRestrictionEnzyme.dsReverse);
                pastableStartIndex = digestionSequence.startRestrictionEnzyme.dsReverse;
            }
            
            if(digestionSequence.endRestrictionEnzyme.dsForward < digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = OVERHANG_BOTTOM;
                sourceOverhangEndSequence = sourceSequence.substring(digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward, digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse);
                pastableEndIndex = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse;
            } else if(digestionSequence.endRestrictionEnzyme.dsForward > digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = OVERHANG_TOP;
                sourceOverhangEndSequence = sourceSequence.substring(digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward, digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsReverse);
                pastableEndIndex = digestionSequence.endRelativePosition + digestionSequence.endRestrictionEnzyme.dsForward;
            }
            
            pasteFeaturedSequence = digestionSequence.featuredSequence.subFeaturedSequence(pastableStartIndex, pastableEndIndex);
        }
        
        private function initializeDestination():void
        {
            for(var i:int = 0; i < restrictionEnzymeMapper.cutSites.length; i++) {
                var cutSite:CutSite = restrictionEnzymeMapper.cutSites.getItemAt(i) as CutSite;
                
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
            
            var destinationSequence:String = featuredSequence.sequence.sequence.substring(start, end);
            
            if(destinationStartCutSite.restrictionEnzyme.dsForward < destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartSequence = destinationSequence.substring(destinationStartCutSite.restrictionEnzyme.dsForward, destinationStartCutSite.restrictionEnzyme.dsReverse);
                
                destinationOverhangStartType = OVERHANG_BOTTOM;
            } else if(destinationStartCutSite.restrictionEnzyme.dsForward > destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartSequence = destinationSequence.substring(destinationStartCutSite.restrictionEnzyme.dsReverse, destinationStartCutSite.restrictionEnzyme.dsForward);
                
                destinationOverhangStartType = OVERHANG_TOP;
            }
            
            var rePosition:int = destinationEndCutSite.start - destinationStartCutSite.start;
            
            if(destinationEndCutSite.restrictionEnzyme.dsForward < destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndSequence = destinationSequence.substring(rePosition + destinationEndCutSite.restrictionEnzyme.dsForward, rePosition + destinationEndCutSite.restrictionEnzyme.dsReverse);
                destinationOverhangEndType = OVERHANG_TOP;
            } else if(destinationEndCutSite.restrictionEnzyme.dsForward > destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndSequence = destinationSequence.substring(rePosition + destinationEndCutSite.restrictionEnzyme.dsForward, rePosition + destinationEndCutSite.restrictionEnzyme.dsReverse);
                destinationOverhangEndType = OVERHANG_BOTTOM;
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
            if(sourceOverhangStartSequence == destinationOverhangStartSequence
                && sourceOverhangEndSequence == destinationOverhangEndSequence) {
                
                return true;
            }
            
            return false;
        }
        
        private function hasRevComMatch():Boolean
        {
            // Trying to much overhang by shape
            var matchByShapeStart:Boolean = false;
            var matchByShapeEnd:Boolean = false;
            
            if((sourceOverhangEndType == OVERHANG_TOP && destinationOverhangStartType == OVERHANG_BOTTOM)
                || (sourceOverhangEndType == OVERHANG_BOTTOM && destinationOverhangStartType == OVERHANG_TOP)
                || (sourceOverhangEndType == OVERHANG_NONE && destinationOverhangStartType == OVERHANG_NONE)
            ) {
                matchByShapeStart = true;
            }
            
            if(matchByShapeStart 
                && ((sourceOverhangStartType == OVERHANG_TOP && destinationOverhangEndType == OVERHANG_BOTTOM)
                    ||  (sourceOverhangStartType == OVERHANG_BOTTOM && destinationOverhangEndType == OVERHANG_TOP)
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
            if(sourceOverhangEndSequence == destinationOverhangStartSequence
                && sourceOverhangStartSequence == destinationOverhangEndSequence) {
                
                return true;
            }
            
            return false;
        }
    }
}