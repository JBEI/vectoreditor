package org.jbei.components.gelDigestClasses
{
    import flash.events.Event;
    
    import org.jbei.bio.sequence.dna.DigestionFragment;
    
    public class BandEvent extends Event
    {
        public static const BAND_SELECTED:String = "bandSelected";
        
        public var digestionFragment:DigestionFragment;
        
        // Constructor
        public function BandEvent(type:String, digestionFragment:DigestionFragment)
        {
            super(type, true, true);
            
            this.digestionFragment = digestionFragment;
        }
    }
}