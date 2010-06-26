package org.jbei.registry.utils
{
    import org.jbei.registry.models.AssemblyItem;
    import org.jbei.registry.models.AssemblyMatrix;
    import org.jbei.registry.models.Bin;
    import org.jbei.registry.models.FeatureType;

    /**
     * @author Zinovii Dmytriv
     */
    public class StandaloneUtils
    {
        public static function standaloneAssemblyMatrix():AssemblyMatrix
        {
            var assemblyMatrix:AssemblyMatrix = new AssemblyMatrix();
            
            var promotersBin:Bin = new Bin(new FeatureType("Promoters", "promoters"));
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
            
            assemblyMatrix.addBin(promotersBin);
            assemblyMatrix.addBin(rbsBin);
            assemblyMatrix.addBin(geneBin);
            assemblyMatrix.addBin(terminatorBin);
            
            return assemblyMatrix;
        }
    }
}