package org.jbei.registry.utils
{
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.Bin;
    import org.jbei.registry.models.FeatureType;

    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneUtils
    {
        public static function standaloneAssemblyProvider():AssemblyProvider
        {
            var assemblyProvider:AssemblyProvider = new AssemblyProvider();
            
            var promotersBin:Bin = new Bin(new FeatureType("Promoter", "promoter"));
            promotersBin.addItem(new AssemblyItem("tatgatgcatgctagctagctagctagctagctac"));
            promotersBin.addItem(new AssemblyItem("tatgatgcatgctagctagctagctagctagctactatgatgcatgctagctagctagctagctagctac"));
            promotersBin.addItem(new AssemblyItem("gcatgctagctagctagctagtatgatgcatgctagctagctagctagctagctacgcatgctagctagctagctag"));
            
            var rbsBin:Bin = new Bin(new FeatureType("RBS", "rbs"));
            rbsBin.addItem(new AssemblyItem("tctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            rbsBin.addItem(new AssemblyItem("actagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            rbsBin.addItem(new AssemblyItem("cctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            rbsBin.addItem(new AssemblyItem("gctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            rbsBin.addItem(new AssemblyItem("aactagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            rbsBin.addItem(new AssemblyItem("ttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            
            var geneBin:Bin = new Bin(new FeatureType("Gene", "gene"));
            geneBin.addItem(new AssemblyItem("ccccttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            geneBin.addItem(new AssemblyItem("aaaattctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            
            var terminatorBin:Bin = new Bin(new FeatureType("Terminator", "terminator"));
            terminatorBin.addItem(new AssemblyItem("tttttttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
            
            assemblyProvider.addBin(promotersBin);
            assemblyProvider.addBin(rbsBin);
            assemblyProvider.addBin(geneBin);
            assemblyProvider.addBin(terminatorBin);
            
            return assemblyProvider;
        }
        
        public static function standaloneRandomAssemblyProvider():AssemblyProvider
        {
            var assemblyProvider:AssemblyProvider = new AssemblyProvider();
            
            var maxBins:int = 15;
            
            var numberOfBins:int = Math.round(Math.random() * maxBins);
            
            var typeKeys:Array = ["general", "promoter", "rbs", "gene", "terminator"];
            var typeValues:Array = ["General", "Promoter", "RBS", "Gene", "Terminator"];
            
            for(var i:int = 0; i < numberOfBins; i++) {
                var typeIndex:int = Math.round(Math.random() * 3);
                
                var newBin:Bin = new Bin(new FeatureType(typeValues[typeIndex], typeKeys[typeIndex]));
                
                var maxItems:int = 15;
                var numberOfItems:int = Math.round(Math.random() * maxItems);
                
                for(var j:int = 0; j < numberOfItems; j++) {
                    newBin.addItem(new AssemblyItem("ccccttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
                }
                
                assemblyProvider.addBin(newBin);
            }
            
            return assemblyProvider;
        }
    }
}