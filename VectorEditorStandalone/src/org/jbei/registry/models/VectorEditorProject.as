package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.VectorEditorProject")]
    public class VectorEditorProject extends Project
    {
        private var _featuredDNASequence:FeaturedDNASequence;
        
        // Contructor
        public function VectorEditorProject(name:String="", description:String="", uuid:String="", ownerName:String="", ownerEmail:String="", creationTime:Date=null, modificationTime:Date=null, featuredDNASequence:FeaturedDNASequence = null)
        {
            super(name, description, uuid, ownerName, ownerEmail, creationTime, modificationTime);
            
            _featuredDNASequence = featuredDNASequence;
        }
        
        // Properties
        public function get featuredDNASequence():FeaturedDNASequence
        {
            return _featuredDNASequence;
        }
        
        public function set featuredDNASequence(value:FeaturedDNASequence):void
        {
            _featuredDNASequence = value;
        }
    }
}