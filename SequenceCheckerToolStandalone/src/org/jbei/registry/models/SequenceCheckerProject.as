package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.SequenceCheckerProject")]
    public class SequenceCheckerProject extends Project
    {
        private var _sequenceCheckerData:SequenceCheckerData;
        
        // Contructor
        public function SequenceCheckerProject(name:String = "", description:String = "", uuid:String = "", ownerName:String = "", ownerEmail:String = "", creationTime:Date = null, modificationTime:Date = null, sequenceCheckerData:SequenceCheckerData = null)
        {
            super(name, description, uuid, ownerName, ownerEmail, creationTime, modificationTime);
            
            _sequenceCheckerData = sequenceCheckerData;
        }
        
        // Properties
        public function get sequenceCheckerData():SequenceCheckerData
        {
            return _sequenceCheckerData;
        }
        
        public function set sequenceCheckerData(value:SequenceCheckerData):void
        {
            _sequenceCheckerData = value;
        }
    }
}