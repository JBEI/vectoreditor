package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class Permutation
    {
        private var _items:Vector.<AssemblyItem> = new Vector.<AssemblyItem>();
        
        // Constructor
        public function Permutation()
        {
        }
        
        // Properties
        public function get items():Vector.<AssemblyItem>
        {
            return _items;
        }
        
        // Public Methods
        public function addAssemblyItem(assemblyItem:AssemblyItem):void
        {
            _items.push(assemblyItem);
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