package org.jbei.registry.components.assemblyTableClasses
{
    import mx.collections.ArrayCollection;
    import mx.controls.List;
    import mx.core.UIComponent;
    import mx.events.ListEvent;
    
    import org.jbei.registry.models.FeatureType;
    import org.jbei.registry.models.FeatureTypeManager;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ColumnHeaderDropDownList extends List
    {
        public static const DEFAULT_LIST_WIDTH:int = 200;
        public static const DEFAULT_LIST_HEIGHT:int = 150;
        public static const SELECTION_COLOR:uint = 0x969DAB;
        public static const ROLL_OVER_COLOR:uint = 0xE0E0E0;
        public static const TEXT_SELECTED_COLOR:uint = 0xFFFFFF;
        
        private var columnHeader:ColumnHeader;
        
        private var types:ArrayCollection;
        
        private var _isOpen:Boolean = false;
        
        // Constructor
        public function ColumnHeaderDropDownList(columnHeader:ColumnHeader)
        {
            super();
            
            this.columnHeader = columnHeader;
            
            setStyle("selectionColor", SELECTION_COLOR);
            setStyle("rollOverColor", ROLL_OVER_COLOR);
            setStyle("textSelectedColor", TEXT_SELECTED_COLOR);
            
            initializeTypes();
            
            height = DEFAULT_LIST_HEIGHT;
            width = DEFAULT_LIST_WIDTH;
            
            labelField = "name";
            dataProvider = types;
            
            focusEnabled = false;
            
            addEventListener(ListEvent.ITEM_CLICK, onItemClick);
        }
        
        // Properties
        public function get isOpen():Boolean
        {
            return _isOpen;
        }
        
        // Public Methods
        public function open(selectedType:String):void
        {
            selectedIndex = getTypeIndex(selectedType);
            
            visible = true;
            
            _isOpen = true;
        }
        
        public function close():void
        {
            visible = false;
            
            _isOpen = false;
        }
        
        // Event Handlers
        private function onItemClick(event:ListEvent):void
        {
            if(event.itemRenderer && event.itemRenderer.data && event.itemRenderer.data['value']) {
                var newValue:String = event.itemRenderer.data['value'] as String;
                
                if(selectedIndex >= 0) {
                    if(newValue != types.getItemAt(selectedIndex)) {
                        columnHeader.changeColumnType(newValue);
                    }
                } else {
                    columnHeader.changeColumnType(newValue);
                }
            }
            
            close();
        }
        
        // Private Methods
        private function initializeTypes():void
        {
            types = new ArrayCollection();
            
            var featureTypes:Vector.<FeatureType> = FeatureTypeManager.instance.featureTypes;
            
            for(var i:int = 0; i < featureTypes.length; i++) {
                var featureType:FeatureType = featureTypes[i] as FeatureType;
                
                types.addItem({value : featureType.key, name : featureType.name});
            }
        }
        
        private function getTypeIndex(type:String):int
        {
            var result:int = -1;
            
            for(var i:int = 0; i < types.length; i++) {
                if(types.getItemAt(i).value == type) {
                    result = i;
                    
                    break;
                }
            }
            
            return result;
        }
    }
}