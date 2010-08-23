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
        public static const SHOW_ACTION_PROGRESSBAR:String = "SHOW_ACTION_PROGRESSBAR";
        public static const HIDE_ACTION_PROGRESSBAR:String = "HIDE_ACTION_PROGRESSBAR";
        
        public static const ACTION_MESSAGE:String = "ACTION_MESSAGE";
        
        public static const SAVE_PROJECT:String = "SAVE_PROJECT";
        public static const SAVE_AS_PROJECT:String = "SAVE_AS_PROJECT";
        public static const IMPORT_SEQUENCE:String = "IMPORT_SEQUENCE";
        public static const IMPORT_TRACE:String = "IMPORT_TRACE";
        public static const REMOVE_TRACE:String = "REMOVE_TRACE";
        
        public static const COPY:String = "COPY";
        public static const SELECT_ALL:String = "SELECT_ALL";
        
        public static const GO_SUGGEST_FEATURE:String = "GO_SUGGEST_FEATURE";
        public static const GO_REPORT_BUG:String = "GO_REPORT_BUG";
        public static const SHOW_ABOUT_DIALOG:String = "SHOW_ABOUT_DIALOG";
        public static const SHOW_PROPERTIES_DIALOG:String = "SHOW_PROPERTIES_DIALOG";
        
        public static const PARSED_IMPORT_SEQUENCE_FILE:String = "PARSED_IMPORT_SEQUENCE_FILE";
        
        public static const PROJECT_UPDATED:String = "PROJECT_UPDATED";
        public static const ALIGN_PROJECT:String = "ALIGN_PROJECT";
        
        public static const SWITCH_TO_PIE_VIEW:String = "SWITCH_TO_PIE_VIEW";
        public static const SWITCH_TO_RAIL_VIEW:String = "SWITCH_TO_RAIL_VIEW";
        
        public static const SELECTION_CHANGED:String = "SELECTION_CHANGED";
        public static const CARET_POSITION_CHANGED:String = "CARET_POSITION_CHANGED";
        public static const SELECTED_TRACE_SEQUENCE_CHANGED:String = "SELECTED_TRACE_SEQUENCE_CHANGED";
        
        public static const SHOW_FEATURES:String = "SHOW_FEATURES";
	}
}