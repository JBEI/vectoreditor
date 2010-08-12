package org.jbei.registry.models
{
    import mx.collections.ArrayCollection;

    /**
     * @author Zinovii Dmytriv
     */
    [RemoteClass(alias="org.jbei.ice.lib.vo.PermutationSet")]
    public class PermutationSet
    {
        private var _permutations:ArrayCollection /* of Permutation */ = new ArrayCollection();
        
        // Constructor
        public function PermutationSet()
        {
        }
        
        // Properties
        public function get permutations():ArrayCollection /* of Permutation */
        {
            return _permutations;
        }
        
        public function set permutations(value:ArrayCollection /* of Permutation */):void
        {
            _permutations = value;
        }
        
        // Public Methods
        public function addPermutation(permutation:Permutation):void
        {
            permutations.addItem(permutation);
        }
    }
}