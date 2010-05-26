package org.jbei.bio.utils
{
    /**
     * @author Zinovii Dmytriv
     */
    public class TemperatureCalculator
    {
        public static const TABLE_BRESLAUER:String = "breslauer";
        public static const TABLE_SUGIMOTO:String = "sugimoto";
        public static const TABLE_UNIFIED:String = "unified";
        
        private static const A:Number = -10.8; // helix initiation for deltaS
        private static const R:Number = 1.987; // Gas Constant (cal/(K*mol))
        private static const C:Number = 0.5e-6; // Oligo concentration. 0.5uM is typical for PCR
        private static const Na:Number = 50e-3; // Monovalent salt conc. 50mM is typical for PCR
        
        public static function calculateTemperature(sequence:String, type:String = TABLE_BRESLAUER):Number
        {
            var sequenceLength:int = sequence.length;
            
            if(sequenceLength == 0) {
                return 0;
            }
            
            var deltaHTable:Vector.<Number> = getDeltaHTable(type);
            var deltaSTable:Vector.<Number> = getDeltaSTable(type);
            
            var neighbors:Vector.<int> = new Vector.<int>(); // list goes in this order: aa, at, ac, ag, tt, ta, tc, tg, cc, ca, ct, cg, gg, ga gt, gc
            
            neighbors.push(calculateReps(sequence, "aa"));
            neighbors.push(calculateNumberOfOccurances(sequence, "at"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ac"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ag"));
            
            neighbors.push(calculateReps(sequence, "tt"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ta"));
            neighbors.push(calculateNumberOfOccurances(sequence, "tc"));
            neighbors.push(calculateNumberOfOccurances(sequence, "tg"));
            
            neighbors.push(calculateReps(sequence, "cc"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ca"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ct"));
            neighbors.push(calculateNumberOfOccurances(sequence, "cg"));
            
            neighbors.push(calculateReps(sequence, "gg"));
            neighbors.push(calculateNumberOfOccurances(sequence, "ga"));
            neighbors.push(calculateNumberOfOccurances(sequence, "gt"));
            neighbors.push(calculateNumberOfOccurances(sequence, "gc"));
            
            var sumDeltaH:Number = 0.0;
            var sumDeltaS:Number = 0.0;
            
            for(var i:int = 0; i < 16; i++) {
                sumDeltaH = sumDeltaH + neighbors[i] * deltaHTable[i];
                sumDeltaS = sumDeltaS + neighbors[i] * deltaSTable[i];
            }
            
            var temperature:Number = ((-1000.0 * sumDeltaH) / (A + -sumDeltaS + R * Math.log(C / 4.0))) - 273.15 + 16.6 * Math.LOG10E * Math.log(Na);
            
            if(temperature < 0) {
                return 0;
            }
            
            return temperature;
        }
        
        private static function getDeltaHTable(type:String):Vector.<Number> {
            if(type == TABLE_BRESLAUER) {
                return Vector.<Number>([9.1, 8.6, 6.5, 7.8, 9.1, 6.0, 5.6, 5.8, 11.0, 5.8, 7.8, 11.9, 11.0, 5.6, 6.5, 11.1]);
            } else if(type == TABLE_SUGIMOTO) {
                return Vector.<Number>([8.0, 5.6, 6.5, 7.8, 8.0, 5.6, 5.6, 5.8, 10.9, 8.2, 6.6, 11.8, 10.9, 6.6, 9.4, 11.9]);
            } else if(type == TABLE_UNIFIED) {
                return Vector.<Number>([7.9, 7.2, 8.4, 7.8, 7.9, 7.2, 8.2, 8.5, 8.0, 8.5, 7.8, 10.6, 8.0, 8.2, 8.4, 9.8]);
            } else {
                return null;
            }
        }
        
        private static function getDeltaSTable(type:String):Vector.<Number> {
            if(type == TABLE_BRESLAUER) {
                return Vector.<Number>([24.0, 23.9, 17.3, 20.8, 24.0, 16.9, 13.5, 12.9, 26.6, 12.9, 20.8, 27.8, 26.6, 13.5, 17.3, 26.7]);
            } else if(type == TABLE_SUGIMOTO) {
                return Vector.<Number>([21.9, 15.2, 17.3, 20.8, 21.9, 15.2, 13.5, 12.9, 28.4, 25.5, 23.5, 29.0, 28.4, 16.4, 25.5, 29.0]);
            } else if(type == TABLE_UNIFIED) {
                return Vector.<Number>([22.2, 20.4, 22.4, 21.0, 22.2, 21.3, 22.2, 22.7, 19.9, 22.7, 21.0, 27.2, 19.9, 22.2, 22.4, 24.4]);
            } else {
                return null;
            }
        }
        
        /* like string.count, but find repeating sequences so that
        repcount("aaaaaa","aa") will return 5 instead of 3.
        USed for counting sequence pairs for melt temp calculation*/
        private static function calculateReps(sequence:String, target:String):int
        {
            var sequenceLength:int = sequence.length;
            
            if(sequenceLength == 0) {
                return 0;
            }
            
            var numFound:int = 0;
            var seqoffset:int = 0; // search offset for finding multiple matches
            
            while(true) {
                var foundseq:int = sequence.indexOf(target, seqoffset);
                
                if(foundseq == -1) {
                    break;
                }
                
                seqoffset = foundseq + 1;
                numFound++;
                
                if (seqoffset > sequenceLength) {
                    break;
                }
            }
            
            return numFound;
        }
        
        private static function calculateNumberOfOccurances(sequence:String, target:String):int
        {
            var sequenceLength:int = sequence.length;
            
            if(sequenceLength == 0) {
                return 0;
            }
            
            var numberFound:int = sequence.split(target).length - 1;
            
            return numberFound;
        }
    }
}