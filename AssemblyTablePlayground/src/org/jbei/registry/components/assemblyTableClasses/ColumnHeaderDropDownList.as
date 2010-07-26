package org.jbei.registry.components.assemblyTableClasses
{
    import mx.collections.ArrayCollection;
    import mx.controls.List;
    import mx.core.UIComponent;
    import mx.events.ListEvent;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ColumnHeaderDropDownList extends List
    {
        public static const DEFAULT_LIST_WIDTH:int = 200;
        public static const DEFAULT_LIST_HEIGHT:int = 150;
        
        private var columnHeader:ColumnHeader;
        
        private var types:ArrayCollection;
        
        private var _isOpen:Boolean = false;
        
        // Constructor
        public function ColumnHeaderDropDownList(columnHeader:ColumnHeader)
        {
            super();
            
            this.columnHeader = columnHeader;
            
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
            // TODO: HARDCODED FOR NOW, FIX IT LATER
            
            types = new ArrayCollection();
            
            types.addItem({value : "general", name : "General"});
            types.addItem({value : "promoter", name : "Promoter"});
            types.addItem({value : "rbs", name : "RBS"});
            types.addItem({value : "gene", name : "Gene"});
            types.addItem({value : "terminator", name : "Terminator"});
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