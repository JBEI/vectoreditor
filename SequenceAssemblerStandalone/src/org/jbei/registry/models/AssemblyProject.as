package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.AssemblyProject")]
    public class AssemblyProject extends Project
    {
        private var _assemblyTable:AssemblyTable;
        
        // Contructor
        public function AssemblyProject(name:String = "", description:String = "", uuid:String = "", ownerName:String = "", ownerEmail:String = "", creationTime:Date = null, modificationTime:Date = null, assemblyTable:AssemblyTable = null)
        {
            super(name, description, uuid, ownerName, ownerEmail, creationTime, modificationTime);
            
            _assemblyTable = assemblyTable;
        }
        
        // Properties
        public function get assemblyTable():AssemblyTable
        {
            return _assemblyTable;
        }
        
        public function set assemblyTable(value:AssemblyTable):void
        {
            _assemblyTable = value;
        }
    }
}