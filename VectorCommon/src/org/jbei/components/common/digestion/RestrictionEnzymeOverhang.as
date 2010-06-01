package org.jbei.components.common.digestion
{
    import org.jbei.bio.data.RestrictionEnzyme;

    /**
     * @author Zinovii Dmytriv
     */
    public class RestrictionEnzymeOverhang
    {
        private var _restrictionEnzyme:RestrictionEnzyme;
        
        // Constructor
        public function RestrictionEnzymeOverhang(restrictionEnzyme:RestrictionEnzyme)
        {
            _restrictionEnzyme = restrictionEnzyme;
        }
        
        // Properties
        public function get restrictionEnzyme():RestrictionEnzyme
        {
            return null;
        }
    }
}