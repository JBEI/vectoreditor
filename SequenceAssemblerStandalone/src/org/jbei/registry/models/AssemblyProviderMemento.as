package org.jbei.registry.models
{
    import org.jbei.registry.lib.IMemento;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class AssemblyProviderMemento implements IMemento
    {
        public var bins:Vector.<Bin>;
        
        // Constructor
        public function AssemblyProviderMemento(bins:Vector.<Bin>)
        {
            this.bins = bins;
        }
    }
}