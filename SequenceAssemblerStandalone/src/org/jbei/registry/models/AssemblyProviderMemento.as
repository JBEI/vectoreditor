package org.jbei.registry.models
{
    import org.jbei.registry.lib.IMemento;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProviderMemento implements IMemento
    {
        public var bins:Vector.<AssemblyBin>;
        
        // Constructor
        public function AssemblyProviderMemento(bins:Vector.<AssemblyBin>)
        {
            this.bins = bins;
        }
    }
}