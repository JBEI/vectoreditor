package org.jbei.registry.utils
{
    import org.jbei.registry.models.AssemblyBin;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.AssemblyTable;

    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyTableUtils
    {
        public static function assemblyTableToAssemblyProvider(assemblyTable:AssemblyTable):AssemblyProvider
        {
            var assemblyProvider:AssemblyProvider = new AssemblyProvider();
            
            if(assemblyTable && assemblyTable.items) {
                for(var i:int = 0; i < assemblyTable.items.length; i++) {
                    assemblyProvider.addBin(assemblyTable.items[i] as AssemblyBin, true);
                }
            }
            
            return assemblyProvider;
        }
        
        public static function assemblyProviderToAssemblyTable(assemblyProvider:AssemblyProvider):AssemblyTable
        {
            var assemblyTable:AssemblyTable = new AssemblyTable();
            
            if(assemblyProvider && assemblyProvider.bins) {
                for(var i:int = 0; i < assemblyProvider.bins.length; i++) {
                    assemblyTable.items.addItem(assemblyProvider.bins[i]);
                }
            }
            
            return assemblyTable;
        }
    }
}