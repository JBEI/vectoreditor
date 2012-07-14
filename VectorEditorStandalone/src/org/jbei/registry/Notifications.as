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
        public static const ACTION_MESSAGE:String = "ActionMessage";
        
		public static const ACTION_STACK_CHANGED:String = "ACTION_STACK_CHANGED";
		public static const SELECTION_CHANGED:String = "SELECTION_CHANGED";
		public static const CARET_POSITION_CHANGED:String = "CARET_POSITION_CHANGED";
		public static const SEQUENCE_PROVIDER_CHANGED:String = "SEQUENCE_PROVIDER_CHANGED";
		public static const SAFE_EDITING_CHANGED:String = "SAFE_EDITING_CHANGED"
		
		public static const USER_PREFERENCES_CHANGED:String = "USER_PREFERENCES_CHANGED";
		public static const USER_RESTRICTION_ENZYMES_CHANGED:String = "USER_RESTRICTION_ENZYMES_CHANGED";
        public static const PERMISSIONS_FETCHED:String = "PERMISSIONS_FETCHED";
		public static const GENERATE_AND_FETCH_SEQUENCE:String = "GENERATE_AND_FETCH_SEQUENCE";
		public static const SEQUENCE_GENERATED_AND_FETCHED:String = "SEQUENCE_GENERATED_AND_FETCHED";
        public static const SEQUENCE_FILE_GENERATED:String = "SEQUENCE_FILE_GENERATED";
		
		public static const UNDO:String = "UNDO";
		public static const REDO:String = "REDO";
		public static const COPY:String = "COPY";
		public static const CUT:String = "CUT";
		public static const PASTE:String = "PASTE";
		public static const SHOW_SELECTION_BY_RANGE_DIALOG:String = "SHOW_SELECTION_BY_RANGE_DIALOG";
		public static const SELECT_ALL:String = "SELECT_ALL";
		
		public static const SHOW_RAIL:String = "SHOW_RAIL";
		public static const SHOW_PIE:String = "SHOW_PIE";
		
		public static const SHOW_FEATURES:String = "SHOW_FEATURES";
		public static const SHOW_CUTSITES:String = "SHOW_CUTSITES";
		public static const SHOW_ORFS:String = "SHOW_ORFS";
		public static const SHOW_COMPLEMENTARY:String = "SHOW_COMPLEMENTARY";
		public static const SHOW_AA1:String = "SHOW_AA1";
		public static const SHOW_AA1_REVCOM:String = "SHOW_AA1_REVCOM";
		public static const SHOW_AA3:String = "SHOW_AA3";
		public static const SHOW_SPACES:String = "SHOW_SPACES";
		public static const SHOW_FEATURE_LABELS:String = "SHOW_FEATURE_LABELS";
		public static const SHOW_CUT_SITE_LABELS:String = "SHOW_CUT_SITE_LABELS";
		
		public static const SHOW_FIND_PANEL:String = "SHOW_FIND_PANEL";
		public static const HIDE_FIND_PANEL:String = "HIDE_FIND_PANEL";
		public static const FIND:String = "FIND";
		public static const FIND_NEXT:String = "FIND_NEXT";
		public static const HIGHLIGHT:String = "HIGHLIGHT";
		public static const CLEAR_HIGHLIGHT:String = "CLEAR_HIGHLIGHT";
		public static const FIND_MATCH_FOUND:String = "FIND_MATCH_FOUND";
		public static const FIND_MATCH_NOT_FOUND:String = "FIND_MATCH_NOT_FOUND";
		
		public static const GO_SUGGEST_FEATURE:String = "GO_SUGGEST_FEATURE";
		public static const GO_REPORT_BUG:String = "GO_REPORT_BUG";
		public static const SHOW_GOTO_DIALOG:String = "SHOW_GOTO_DIALOG";
		public static const SHOW_PREFERENCES_DIALOG:String = "SHOW_PREFERENCES_DIALOG";
		public static const SHOW_PROPERTIES_DIALOG:String = "SHOW_PROPERTIES_DIALOG";
		public static const SHOW_ABOUT_DIALOG:String = "SHOW_ABOUT_DIALOG";
		public static const SHOW_CREATE_NEW_FEATURE_DIALOG:String = "SHOW_CREATE_NEW_FEATURE_DIALOG";
		public static const SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG:String = "SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG";
        public static const SHOW_SIMULATE_DIGESTION_DIALOG:String = "SHOW_SIMULATE_DIGESTION_DIALOG";
        public static const REVERSE_COMPLEMENT_SEQUENCE:String = "REVERSE_COMPLEMENT_SEQUENCE";
		
		public static const PRINT_SEQUENCE:String = "PRINT_SEQUENCE";
		public static const PRINT_RAIL:String = "PRINT_RAIL";
		public static const PRINT_PIE:String = "PRINT_PIE";
        
        public static const SAVE_TO_REGISTRY:String = "SAVE_TO_REGISTRY";
        public static const SAVE_PROJECT:String = "SAVE_PROJECT";
        public static const SAVE_PROJECT_AS:String = "SAVE_PROJECT_AS";
        public static const SHOW_PROJECT_PROPERTIES_DIALOG:String = "SHOW_PROJECT_PROPERTIES_DIALOG";
        public static const PROJECT_UPDATED:String = "PROJECT_UPDATED";
        public static const SEQUENCE_UPDATED:String = "SEQUENCE_UPDATED";
        public static const IMPORT_SEQUENCE:String = "IMPORT_SEQUENCE";
        public static const DOWNLOAD_SEQUENCE:String = "DOWNLOAD_SEQUENCE";
        public static const DOWNLOAD_SBOL:String = "DOWNLOAD_SBOL";
        public static const REBASE_SEQUENCE:String = "REBASE_SEQUENCE";
        public static const IMPORT_SBOL_XML:String = "IMPORT_SBOL_XML";
	}
}