package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class FeatureTypeManager
    {
        private static var _instance:FeatureTypeManager;
        
        private var _featureTypes:Vector.<FeatureType> = new Vector.<FeatureType>();
        
        // Constructor
        public function FeatureTypeManager()
        {
            if(_instance != null) {
                throw new Error("This is singleton class. Use 'FeatureTypeManager.instance' to get class instance.");
            }
            
            initializeFeatureTypes();
        }
        
        // Properties
        public static function get instance():FeatureTypeManager
        {
            if(_instance == null) {
                _instance = new FeatureTypeManager();
            }
            
            return _instance;
        }
        
        public final function get featureTypes():Vector.<FeatureType>
        {
            return _featureTypes;
        }
        
        // Private Methods
        private function initializeFeatureTypes():void
        {
            _featureTypes.push(new FeatureType("General", "general"));
            _featureTypes.push(new FeatureType("Promoter", "promoter"));
            _featureTypes.push(new FeatureType("RBS", "rbs"));
            _featureTypes.push(new FeatureType("Gene", "gene"));
            _featureTypes.push(new FeatureType("Terminator", "terminator"));
        }
    }
}