package org.jbei.registry.components.assemblyTableClasses
{
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.Bin;

    /**
     * @author Zinovii Dmytriv
     */
    public class DataMapper
    {
        private var assemblyProvider:AssemblyProvider;
        
        private var _columns:Vector.<Column> = new Vector.<Column>();
        
        // Constructor
        public function DataMapper()
        {
        }
        
        // Properties
        public function get columns():Vector.<Column>
        {
            return _columns;
        }
        
        // Public Methods
        public function loadAssemblyProvider(assemblyProvider:AssemblyProvider):void
        {
            clear();
            
            if(!assemblyProvider || !assemblyProvider.bins || assemblyProvider.bins.length == 0) {
                assemblyProvider = null;
                
                return;
            }
            
            this.assemblyProvider = assemblyProvider;
            
            if(!assemblyProvider.bins || assemblyProvider.bins.length == 0) {
                return;
            }
            
            var numberOfItemsInBiggestBin:int = 0;
            
            for(var z:int = 0; z < assemblyProvider.bins.length; z++) {
                var bin:Bin = assemblyProvider.bins[z] as Bin;
                
                if(bin.items.length > numberOfItemsInBiggestBin) {
                    numberOfItemsInBiggestBin = bin.items.length;
                }
            }
            
            for(var i:int = 0; i < assemblyProvider.bins.length; i++) {
                var currentBin:Bin = assemblyProvider.bins[i] as Bin;
                var newColumn:Column = new Column(i, currentBin.featureType.name);
                var numberOfItemsInBin:int = currentBin.items.length;
                
                for(var j:int = 0; j < numberOfItemsInBiggestBin + 1; j++) {
                    if(j < numberOfItemsInBin) {
                        var assemblyItem:AssemblyItem = currentBin.items[j] as AssemblyItem;
                        
                        var newDataCell:DataCell = new DataCell(newColumn, assemblyItem.sequence, j);
                        
                        newColumn.addCell(newDataCell);
                    } else {
                        var newNullCell:NullCell = new NullCell(newColumn, j);
                        
                        newColumn.addCell(newNullCell);
                    }
                }
                
                _columns.push(newColumn);
            }
        }
        
        public function getCell(columnIndex:int, rowIndex:int):Cell
        {
            if(columnIndex >= _columns.length) {
                return null;
            }
            
            var currentColumn:Column = _columns[columnIndex];
            
            if(rowIndex >= currentColumn.cells.length) {
                return null;
            }
            
            return currentColumn.cells[rowIndex];
        }
        
        public function getColumn(index:int):Column
        {
            if(index >= _columns.length) {
                return null;
            }
            
            return _columns[index];
        }
        
        // Private Methods
        private function clear():void
        {
            _columns = new Vector.<Column>();
        }
    }
}