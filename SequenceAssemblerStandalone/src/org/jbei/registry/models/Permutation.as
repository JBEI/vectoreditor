package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.Permutation")]
    public class Permutation
    {
        private var _items:ArrayCollection /* of AssemblyItem */ = new ArrayCollection();
        
        // Constructor
        public function Permutation()
        {
        }
        
        // Properties
        public function get items():ArrayCollection /* of AssemblyItem */
        {
            return _items;
        }
        
        public function set items(value:ArrayCollection /* of AssemblyItem */):void
        {
            _items = value;
        }
        
        // Public Methods
        public function addAssemblyItem(assemblyItem:AssemblyItem):void
        {
            _items.addItem(assemblyItem);
        }
        
        public function clone():Permutation
        {
            var clonedPermutation:Permutation = new Permutation();
            
            if(_items.length > 0) {
                for(var i:int = 0; i < _items.length; i++) {
                    clonedPermutation.addAssemblyItem(_items[i]);
                }
            }
            
            return clonedPermutation;
        }
    }
}