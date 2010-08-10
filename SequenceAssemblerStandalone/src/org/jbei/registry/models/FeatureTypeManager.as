package org.jbei.registry.models
{
    import flash.utils.Dictionary;

    /**
     * @author Zinovii Dmytriv
     */
    public class FeatureTypeManager
    {
        private var _types:Dictionary = new Dictionary();
        
        private static var _instance:FeatureTypeManager = null;
        
        // Contructor
        public function FeatureTypeManager()
        {
            if(_instance) {
                throw new Error("This is Singleton class. Use FeatureTypeManager.instance");
            }
            
            initializeTypes();
        }
        
        // Properties
        public final function get types():Dictionary
        {
            return _types;
        }
        
        // Public Methods
        public static function get instance():FeatureTypeManager
        {
            if(!_instance) {
                _instance = new FeatureTypeManager();
            }
            
            return _instance;
        }
        
        public function nameByKey(key:String):String
        {
            return _types[key];
        }
        
        // Private Methods
        private function initializeTypes():void
        {
            _types["general"] = "General";
            _types["gene"] = "Gene";
            _types["promoter"] = "Promoter";
            _types["terminator"] = "Terminator";
            _types["rbs"] = "RBS";
        }
    }
}