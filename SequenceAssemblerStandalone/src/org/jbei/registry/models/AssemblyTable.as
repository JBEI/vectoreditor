package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.AssemblyTable")]
    public class AssemblyTable
    {
        private var _items:ArrayCollection = new ArrayCollection(); /* of AssemblyBin */
        
        // Contructor
        public function AssemblyTable()
        {
        }
        
        // Properties
        public function get items():ArrayCollection
        {
            return _items;
        }
        
        public function set items(value:ArrayCollection):void
        {
            _items = value;
        }
    }
}