package org.jbei.registry.utils
{
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.dna.DNASequence;
    import org.jbei.registry.models.AssemblyBin;
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyProject;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.AssemblyTable;
    import org.jbei.registry.models.FeaturedDNASequence;

    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneUtils
    {
        public static function standaloneAssemblyProject():AssemblyProject
        {
            var promotersBin:AssemblyBin = new AssemblyBin("promoter");
            promotersBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "tatgatgcatgctagctagctagctagctagctac")));
            promotersBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "tatgatgcatgctagctagctagctagctagctactatgatgcatgctagctagctagctagctagctac")));
            promotersBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "gcatgctagctagctagctagtatgatgcatgctagctagctagctagctagctacgcatgctagctagctagctag")));
            
            var rbsBin:AssemblyBin = new AssemblyBin("rbs");
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "tctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "actagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "cctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "gctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "aactagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            rbsBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "ttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            
            var geneBin:AssemblyBin = new AssemblyBin("gene");
            geneBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "ccccttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            geneBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "aaaattctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            
            var terminatorBin:AssemblyBin = new AssemblyBin("terminator");
            terminatorBin.addItem(new AssemblyItem("", new FeaturedDNASequence("", "tttttttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac")));
            
            var assemblyTable:AssemblyTable = new AssemblyTable();
            
            assemblyTable.items.addItem(promotersBin);
            assemblyTable.items.addItem(rbsBin);
            assemblyTable.items.addItem(geneBin);
            assemblyTable.items.addItem(terminatorBin);
            
            var newAssemblyProject:AssemblyProject = new AssemblyProject();
            newAssemblyProject.assemblyTable = assemblyTable;
            
            return newAssemblyProject;
        }
        
        public static function standaloneRandomAssemblyProject():AssemblyProject
        {
            /*var assemblyProvider:AssemblyProvider = new AssemblyProvider();
            
            var maxBins:int = 15;
            
            var numberOfBins:int = 1 + Math.round(Math.random() * maxBins);
            
            var typeKeys:Array = ["general", "promoter", "rbs", "gene", "terminator"];
            var typeValues:Array = ["General", "Promoter", "RBS", "Gene", "Terminator"];
            
            for(var i:int = 0; i < numberOfBins; i++) {
                var typeIndex:int = Math.round(Math.random() * 4);
                
                var newBin:Bin = new Bin(new FeatureType(typeValues[typeIndex], typeKeys[typeIndex]));
                
                var maxItems:int = 15;
                var numberOfItems:int = Math.round(Math.random() * maxItems);
                
                for(var j:int = 0; j < numberOfItems; j++) {
                    newBin.addItem(new AssemblyItem("ccccttctagctagctagctagctagctatatgatgcatgctagctagctagctagctagctactagctagctagctagctagctac"));
                }
                
                assemblyProvider.addBin(newBin);
            }
            
            var newAssemblyProject:AssemblyProject = new AssemblyProject();
            newAssemblyProject.uuid = "asdf";
            newAssemblyProject.assemblyProvider = assemblyProvider;
            
            return newAssemblyProject;*/
            return null;
        }
    }
}