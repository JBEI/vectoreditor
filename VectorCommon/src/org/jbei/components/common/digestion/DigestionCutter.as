package org.jbei.components.common.digestion
{
    import org.jbei.bio.data.CutSite;
    import org.jbei.bio.data.RestrictionEnzyme;
    import org.jbei.lib.FeaturedSequence;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;

    /**
     * @author Zinovii Dmytriv
     */
    public class DigestionCutter
    {
        public static function digestSequence(featuredSequence:FeaturedSequence, start:int, end:int, digestionSequence:DigestionSequence, restrictionEnzymeMapper:RestrictionEnzymeMapper):void
        {
            // Process source digestion sequence
            var sourceSequence:String = digestionSequence.featuredSequence.sequence.sequence;
            
            var sourceOverhangStartSequence:String = getStartOverhang(sourceSequence, digestionSequence.startRestrictionEnzyme, digestionSequence.startRelativePosition);
            var sourceOverhangStartType:int = 0; // 0 - None, 1 - Top, 2 - Bottom
            var sourceOverhangEndSequence:String = getEndOverhang(sourceSequence, digestionSequence.endRestrictionEnzyme, digestionSequence.endRelativePosition);
            var sourceOverhangEndType:int = 0; // 0 - None, 1 - Top, 2 - Bottom
            
            if(digestionSequence.startRestrictionEnzyme.dsForward < digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = 1; // 1 - Top
            } else if(digestionSequence.startRestrictionEnzyme.dsForward > digestionSequence.startRestrictionEnzyme.dsReverse) {
                sourceOverhangStartType = 2; // 2 - Bottom
            }
            
            if(digestionSequence.endRestrictionEnzyme.dsForward < digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = 2; // 2 - Bottom
            } else if(digestionSequence.endRestrictionEnzyme.dsForward > digestionSequence.endRestrictionEnzyme.dsReverse) {
                sourceOverhangEndType = 1; // 1 - Top
            }
            
            // Process destination digestion sequence
            var destinationStartCutSite:CutSite = null;
            var destinationEndCutSite:CutSite = null;
            
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
            
            var destinationOverhangStartSequence:String = getStartOverhang(destinationSequence, destinationStartCutSite.restrictionEnzyme, 0);
            var destinationOverhangStartType:int = 0; // 0 - None, 1 - Top, 2 - Bottom
            var destinationOverhangEndSequence:String = getEndOverhang(destinationSequence, destinationEndCutSite.restrictionEnzyme, destinationEndCutSite.start - destinationStartCutSite.start);
            var destinationOverhangEndType:int = 0; // 0 - None, 1 - Top, 2 - Bottom
            
            if(destinationStartCutSite.restrictionEnzyme.dsForward < destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartType = 2; // Bottom
            } else if(destinationStartCutSite.restrictionEnzyme.dsForward > destinationStartCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangStartType = 1; // Top
            }
            
            if(destinationEndCutSite.restrictionEnzyme.dsForward < destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndType = 1; // Top
            } else if(destinationEndCutSite.restrictionEnzyme.dsForward > destinationEndCutSite.restrictionEnzyme.dsReverse) {
                destinationOverhangEndType = 2; // Bottom
            }
            
            // Trying to much by shape
            var matchByShapeStart:Boolean = false;
            var matchByShapeEnd:Boolean = false;
            
            var isReverseOverhang:Boolean = false;
            
            if((sourceOverhangStartType == 1 && destinationOverhangStartType == 2)
                || (sourceOverhangStartType == 2 && destinationOverhangStartType == 1)
                || (sourceOverhangStartType == 0 && destinationOverhangStartType == 0)
            ) {
                matchByShapeStart = true;
            }
            
            if(matchByShapeStart 
                && ((sourceOverhangEndType == 1 && destinationOverhangEndType == 2)
                    ||  (sourceOverhangEndType == 2 && destinationOverhangEndType == 1)
                    ||  (sourceOverhangEndType == 0 && destinationOverhangEndType == 0))
            ) {
                matchByShapeEnd = true;
            }
            
            if(!matchByShapeStart && !matchByShapeEnd) {
                if(sourceOverhangStartType == destinationOverhangStartType && sourceOverhangEndType == destinationOverhangStartType) {
                    matchByShapeStart = true;
                    matchByShapeEnd = true;
                    isReverseOverhang = true;
                }
            }
            
            if(!matchByShapeStart || !matchByShapeEnd) {
                trace("DOESN'T MATCH BY SHAPE!");
                return;
            }
            
            // Trying to much overhang by length
            if(sourceOverhangStartSequence.length != destinationOverhangStartSequence.length
                || sourceOverhangEndSequence.length != destinationOverhangEndSequence.length) {
                
                trace("DOESN'T MATCH BY OVERHANG LENGTH!");
                return;
            }
            
            // Trying to much overhang ends by sequences
            var matchBySequence:Boolean = false;
            
            if(!isReverseOverhang) {
                if(sourceOverhangStartSequence == destinationOverhangStartSequence && sourceOverhangEndSequence == destinationOverhangEndSequence) {
                    matchBySequence = true;
                }
            } else {
                trace("Implement this!");
            }
            
            featuredSequence.removeSequence(start, end, true);
            featuredSequence.insertFeaturedSequence(digestionSequence.featuredSequence, start);
            
            trace("Done!");
        }
        
        private static function getStartOverhang(sequence:String, restrictionEnzyme:RestrictionEnzyme, position:int):String
        {
            var result:String = "";
            
            if(restrictionEnzyme.dsForward < restrictionEnzyme.dsReverse) {
                result = sequence.substring(restrictionEnzyme.dsForward, restrictionEnzyme.dsReverse);
            } else if (restrictionEnzyme.dsForward > restrictionEnzyme.dsReverse) {
                result = sequence.substring(restrictionEnzyme.dsReverse, restrictionEnzyme.dsForward);
            }
            
            return result;
        }
        
        private static function getEndOverhang(sequence:String, restrictionEnzyme:RestrictionEnzyme, position:int):String
        {
            var result:String = "";
            
            if(restrictionEnzyme.dsForward < restrictionEnzyme.dsReverse) {
                result = sequence.substring(position + restrictionEnzyme.dsReverse, position + restrictionEnzyme.dsForward);
            } else if (restrictionEnzyme.dsForward > restrictionEnzyme.dsReverse) {
                result = sequence.substring(position + restrictionEnzyme.dsForward, position + restrictionEnzyme.dsReverse);
            }
            
            return result;
        }
    }
}