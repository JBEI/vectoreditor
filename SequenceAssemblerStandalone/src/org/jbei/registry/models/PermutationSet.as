package org.jbei.registry.models
{
    /**
     * @author Zinovii Dmytriv
     */
    public class PermutationSet
    {
        private var _permutations:Vector.<Permutation> = new Vector.<Permutation>();
        
        // Constructor
        public function PermutationSet()
        {
        }
        
        // Properties
        public final function get permutations():Vector.<Permutation>
        {
            return _permutations;
        }
        
        // Public Methods
        public function addPermutation(permutation:Permutation):void
        {
            permutations.push(permutation);
        }
    }
}