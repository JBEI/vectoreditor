package org.jbei.model.fields
{
    public class StatusField
    {
        private static var _complete:String = "complete";
        private static var _in_progress:String = "in progress";
        private static var _planned:String = "planned";
        
        public static function get COMPLETE() : String
        {
            return _complete;
        }
        
        public static function get IN_PROGRESS() : String
        {
            return _in_progress;
        }
        
        public static function get PLANNED() : String
        {
            return _planned;
        }
        
        public static function isValid( name:String ) : Boolean
        {
            if( name == null )
                return false;
         
            name = name.toLowerCase();
            return name == COMPLETE || name == IN_PROGRESS || name == PLANNED;
        }
    }
}