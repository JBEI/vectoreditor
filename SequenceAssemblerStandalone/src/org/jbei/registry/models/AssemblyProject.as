package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProject
    {
        private var _name:String;
        private var _description:String;
        private var _uuid:String;
        private var _ownerName:String;
        private var _ownerEmail:String;
        private var _assemblyProvider:AssemblyProvider;
        private var _creationTime:Date;
        private var _modificationTime:Date;
        
        // Contructor
        public function AssemblyProject(name:String = "", description:String = "", uuid:String = "", ownerName:String = "", ownerEmail:String = "", assemblyProvider:AssemblyProvider = null, creationTime:Date = null, modificationTime:Date = null)
        {
            _name = name;
            _description = description;
            _uuid = uuid;
            _ownerName = ownerName;
            _ownerEmail = ownerEmail;
            _assemblyProvider = assemblyProvider;
            _creationTime = creationTime;
            _modificationTime = modificationTime;
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
        
        public function get description():String
        {
            return _description;
        }
        
        public function set description(value:String):void
        {
            _description = value;
        }
        
        public function get uuid():String
        {
            return _uuid;
        }
        
        public function set uuid(value:String):void
        {
            _uuid = value;
        }
        
        public function get ownerName():String
        {
            return _ownerName;
        }
        
        public function set ownerName(value:String):void
        {
            _ownerName = value;
        }
        
        public function get ownerEmail():String
        {
            return _ownerEmail;
        }
        
        public function set ownerEmail(value:String):void
        {
            _ownerEmail = value;
        }
        
        public function get assemblyProvider():AssemblyProvider
        {
            return _assemblyProvider;
        }
        
        public function set assemblyProvider(value:AssemblyProvider):void
        {
            _assemblyProvider = value;
        }
        
        public function get creationTime():Date
        {
            return _creationTime;
        }
        
        public function set creationTime(value:Date):void
        {
            _creationTime = value;
        }
        
        public function get modificationTime():Date
        {
            return _modificationTime;
        }
        
        public function set modificationTime(value:Date):void
        {
            _modificationTime = value;
        }
    }
}