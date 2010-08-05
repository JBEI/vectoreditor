package org.jbei.registry
{
    /**
     * @author Zinovii Dmytriv
     */
	public final class Notifications
	{
        public static const APPLICATION_FAILURE:String = "APPLICATION_FAILURE";
        public static const LOCK:String = "LOCK";
        public static const UNLOCK:String = "UNLOCK";
        
        public static const SWITCH_TO_ASSEMBLY_VIEW:String = "SWITCH_TO_ASSEMBLY_VIEW";
        public static const SWITCH_TO_RESULTS_VIEW:String = "SWITCH_TO_RESULTS_VIEW";
        
        public static const ASSEMBLY_ACTION_MESSAGE:String = "ASSEMBLY_ACTION_MESSAGE";
        public static const RESULTS_ACTION_MESSAGE:String = "RESULTS_ACTION_MESSAGE";
        public static const GLOBAL_ACTION_MESSAGE:String = "GLOBAL_ACTION_MESSAGE";
        
        public static const RANDOMIZE_ASSEMBLY_PROVIDER:String = "RANDOMIZE_ASSEMBLY_PROVIDER";
        public static const RUN_ASSEMBLY:String = "RUN_ASSEMBLY";
        public static const UPDATE_RESULTS_PERMUTATIONS_TABLE:String = "UPDATE_RESULTS_PERMUTATIONS_TABLE";
        
        public static const ASSEMBLY_TABLE_CARET_POSITION_CHANGED:String = "ASSEMBLY_TABLE_CARET_POSITION_CHANGED";
        
        public static const SAVE_PROJECT:String = "SAVE_PROJECT";
        public static const SAVE_AS_PROJECT:String = "SAVE_AS_PROJECT";
        
        public static const ASSEMBLY_UNDO:String = "ASSEMBLY_UNDO";
        public static const ASSEMBLY_REDO:String = "ASSEMBLY_REDO";
        public static const ASSEMBLY_COPY:String = "ASSEMBLY_COPY";
        public static const ASSEMBLY_CUT:String = "ASSEMBLY_CUT";
        public static const ASSEMBLY_PASTE:String = "ASSEMBLY_PASTE";
        public static const ASSEMBLY_SELECT_ALL:String = "ASSEMBLY_SELECT_ALL";
        public static const ASSEMBLY_DELETE:String = "ASSEMBLY_DELETE";
        public static const RESULTS_COPY:String = "RESULTS_COPY";
        
        public static const GO_SUGGEST_FEATURE:String = "GO_SUGGEST_FEATURE";
        public static const GO_REPORT_BUG:String = "GO_REPORT_BUG";
        public static const SHOW_ABOUT_DIALOG:String = "SHOW_ABOUT_DIALOG";
        public static const SHOW_PROPERTIES_DIALOG:String = "SHOW_PROPERTIES_DIALOG";
	}
}