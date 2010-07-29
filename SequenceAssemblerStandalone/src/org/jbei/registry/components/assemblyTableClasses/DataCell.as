package org.jbei.registry.components.assemblyTableClasses
{
    import org.jbei.registry.models.AssemblyItem;

    /**
     * @author Zinovii Dmytriv
     */
    public class DataCell extends Cell
    {
        private var _assemblyItem:AssemblyItem;
        
        // Contructor
        public function DataCell(column:Column, assemblyItem:AssemblyItem, index:uint)
        {
            super(column, index);
            
            _assemblyItem = assemblyItem;
        }
        
        // Properties
        public function get assemblyItem():AssemblyItem
        {
            return _assemblyItem;
        }
    }
}