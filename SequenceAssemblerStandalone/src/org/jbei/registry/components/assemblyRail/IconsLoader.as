package org.jbei.registry.components.assemblyRail
{
    import flash.utils.Dictionary;

    /**
     * @author Zinovii Dmytriv
     */
    public class IconsLoader
    {
        [Embed(source="assets/promoter.png")]
        private var promoterIcon:Class;
        
        [Embed(source="assets/gene.png")]
        private var geneIcon:Class;
        
        [Embed(source="assets/rbs.png")]
        private var rbsIcon:Class;
        
        [Embed(source="assets/general.png")]
        private var generalIcon:Class;
        
        [Embed(source="assets/terminator.png")]
        private var terminatorIcon:Class;
        
        private static var _instance:IconsLoader = null;
        
        private var typeMap:Dictionary = new Dictionary();
        
        // Contructor
        public function IconsLoader()
        {
            initializeMap();
        }
        
        // Properties
        public static function get instance():IconsLoader
        {
            if(!_instance) {
                _instance = new IconsLoader();
            }
            
            return _instance
        }
        
        // Public Methods
        public function getIcon(name:String):Class
        {
            return typeMap[name];
        }
        
        // Private Methods
        private function initializeMap():void
        {
            typeMap = new Dictionary();
            
            typeMap["promoter"] = promoterIcon;
            typeMap["gene"] = geneIcon;
            typeMap["general"] = generalIcon;
            typeMap["terminator"] = terminatorIcon;
            typeMap["rbs"] = rbsIcon;
        }
    }
}