package org.jbei
{
	public class Notifications
	{
		// app wide notifications
		public static const START_UP:String = "startUp";
		public static const FAILURE:String = "failure";		
		public static const RESET_APP:String = "resetApplication";
		public static const MODEL_DATA_PREP:String = "prepareModelData";
		public static const ROW_DATA_READY:String = "rowDataReady";
		
		// change in the active grid cell text
		public static const ACTIVE_GRID_CELL_TEXT_CHANGE:String = "activeGridCellTextChange";
		
		// change in the header input text
		public static const HEADER_INPUT_TEXT_CHANGE:String = "headerInputTextChange";
		
		// cell in the grid has been selected
		public static const GRID_CELL_SELECTED:String = "gridCellSelected";
		
		public static const GRID_ROW_SELECTED:String = "gridRowSelected";
		
		// when a scroll occurs in the grid
		public static const HSCROLL:String = "horizontalScroll";
		
		// cancel (typically when the cancel button is clicked)
		public static const CANCEL:String = "cancel";
		
		// save button is clicked
		public static const SAVE_CLICK:String = "saveButtonClicked";
		
		// actually perform the save. send after validation is complete
		public static const SAVE:String = "save";
		
		// save successful
		public static const SAVE_SUCCESS:String = "saveSuccessful";
		
		// sent by the gridholder if no invalid entries are detected
		public static const ALL_ENTRIES_VALID:String = "allEntriesValid";
		
		public static const INVALID_CELL_CONTENT:String = "invalidCellContent";
		
		// item pasted into one of the cells
		public static const PASTE:String = "cellPaste";
		
		// results of a paste available
		public static const PASTE_CELL_DISTRIBUTION:String = "pasteResults";
		
		public static const VSCROLL:String = "verticalScroll";
		
		// a new row is created
		public static const ROW_CREATED:String = "rowCreated";
		
		// auto fill
		public static const AUTO_FILL:String = "autoFill";
		
		//
		// part type selection
		//
		public static const PART_TYPE_SELECTION:String = "partTypeSelection";
		public static const PART_TYPES_LOAD_FAILURE:String = "partTypesLoadFailure";
		public static const PART_TYPE_FIELDS_LOADED:String = "partTypeFieldsLoaded";
		
		// notification for auto-complete data load
		public static const AUTO_COMPLETE_DATA:String = "autoCompleteDataLoaded";
		
		// sent when an import parameter is passed
		public static const VERIFY:String = "verifyData";
	}
}