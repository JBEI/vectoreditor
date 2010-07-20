package org.jbei.registry.components.assemblyTableClasses
{
    /**
     * @author Zinovii Dmytriv
     */
    public class DataCell extends Cell
    {
        private var _data:String;
        
        // Contructor
        public function DataCell(column:Column, data:String, index:uint)
        {
            super(column, index);
            
            _data = data;
        }
        
        // Properties
        public function get data():String
        {
            return _data;
        }
    }
}