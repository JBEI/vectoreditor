package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.AssemblyBin")]
    public class AssemblyBin
    {
        private var _type:String;
        private var _items:ArrayCollection /* of AssemblyItem */ = new ArrayCollection();
        
        // Contructor
        public function AssemblyBin(type:String = "")
        {
            _type = type;
        }
        
        // Properties
        public function get type():String
        {
            return _type;
        }
        
        public function set type(value:String):void
        {
            _type = value;
        }
        
        public function get items():ArrayCollection
        {
            return _items;
        }
        
        public function set items(value:ArrayCollection):void
        {
            _items = value;
        }
        
        // Public Methods
        /*
        * @private
        * */
        public function addItem(item:AssemblyItem):void
        {
            _items.addItem(item);
        }
        
        /*
        * @private
        * */
        public function deleteItem(item:AssemblyItem):void
        {
            var index:int = _items.getItemIndex(item);
            
            if(index >= 0) {
                _items.removeItemAt(index);
            }
        }
        
        public function clone():AssemblyBin
        {
            var clonedAssemblyBin:AssemblyBin = new AssemblyBin(_type);
            
            for(var i:int = 0; i < _items.length; i++) {
                clonedAssemblyBin.addItem(_items[i].clone());
            }
            
            return clonedAssemblyBin;
        }
    }
}