package org.jbei
{
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.FeaturedSequenceMemento;
	import org.jbei.registry.control.ActionStack;
	import org.jbei.registry.control.ActionStackEvent;
	import org.jbei.registry.control.FetchEntryCommand;
	import org.jbei.registry.control.FetchUserPreferencesCommand;
	import org.jbei.registry.control.FetchUserRestrictionEnzymesCommand;
	import org.jbei.registry.control.InitializationCommand;
	import org.puremvc.as3.patterns.facade.Facade;

	public class ApplicationFacade extends Facade
	{
		public static const INITIALIZATION:String = "Initialization";
		public static const APPLICATION_FAILURE:String = "ApplicationFailure";
		public static const ACTION_STACK_CHANGED:String = "ActionStackChanged";
		public static const SELECTION_CHANGED:String = "SelectionChanged";
		public static const CARET_POSITION_CHANGED:String = "CaretPositionChanged";
		
		public static const FETCHING_DATA:String = "FetchingData";
		public static const DATA_FETCHED:String = "DataFetched";
		
		public static const FETCH_USER_PREFERENCES:String = "FetchPreferences";
		public static const USER_PREFERENCES_FETCHED:String = "UserPreferencesFetched";
		public static const USER_PREFERENCES_CHANGED:String = "UserPreferencesChanged";
		public static const FETCH_USER_RESTRICTION_ENZYMES:String = "FetchRestrictionEnzymes";
		public static const USER_RESTRICTION_ENZYMES_FETCHED:String = "UserRestrictionEnzymesFetched";
		public static const USER_RESTRICTION_ENZYMES_CHANGED:String = "UserRestrictionEnzymesChanged"
		public static const FETCH_ENTRY:String = "FetchEntry";
		public static const ENTRY_FETCHED:String = "EntryFetched";
		
		public static const UNDO:String = "Undo";
		public static const REDO:String = "Redo";
		public static const COPY:String = "Copy";
		public static const CUT:String = "Cut";
		public static const PASTE:String = "Paste";
		public static const SHOW_SELECTION_BY_RANGE_DIALOG:String = "ShowSelectByRangeDialog";
		public static const SELECT_ALL:String = "SelectAll";
		
		public static const SHOW_FEATURES:String = "ShowFeatures";
		public static const SHOW_CUTSITES:String = "ShowCutSites";
		public static const SHOW_ORFS:String = "ShowORFs";
		public static const SHOW_COMPLEMENTARY:String = "ShowComplementary";
		public static const SHOW_AA1:String = "ShowAA1";
		public static const SHOW_AA3:String = "ShowAA3";
		public static const SHOW_SPACES:String = "ShowSpaces";
		public static const SHOW_FEATURE_LABELS:String = "ShowFeatureLabels";
		public static const SHOW_CUT_SITE_LABELS:String = "ShowCutSiteLabels";
		
		public static const SHOW_PREFERENCES_DIALOG:String = "ShowPreferencesDialog";
		public static const SHOW_ABOUT_DIALOG:String = "ShowAboutDialog";
		public static const SHOW_CREATE_NEW_FEATURE_DIALOG:String = "ShowCreateNewFeatureDialog";
		public static const SHOW_RESTRICTION_ENZYMES_MANAGER_DIALOG:String = "ShowRestrictionEnzymesManagerDialog";
		public static const SHOW_FEATURES_DIALOG:String = "ShowFeaturesDialog";
		
		private var _application:VectorEditor;
		private var _actionStack:ActionStack;
		private var _entryId:String;
		private var _serverURL:String;
		private var _featuredSequence:FeaturedSequence;
		
		// Properties
		public function get application():VectorEditor
		{
			return _application;
		}
		
		public function get entryId():String
		{
			return _entryId;
		}
		
		public function set entryId(value:String):void
		{
			_entryId = value;
		}
		
		public function get serverURL():String
		{
			return _serverURL;
		}
		
		public function set serverURL(value:String):void
		{
			_serverURL = value;
		}
		
		public function get actionStack():ActionStack
		{
			return _actionStack;
		}
		
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			if(_featuredSequence != value) {
				_featuredSequence = value;
				
				_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGING, onSequenceChanging);
			}
		}
		
		// Public Methods
		public static function getInstance():ApplicationFacade
		{
			if(instance == null) {
				instance = new ApplicationFacade();
			}
			
			return instance as ApplicationFacade;
		}
		
		public function initializeApplication(application:VectorEditor):void
		{
			_application = application;
			
			_actionStack = new ActionStack();
			_actionStack.addEventListener(ActionStackEvent.ACTION_STACK_CHANGED, onActionStackChanged);
		}
		
		// Protected Methods
		protected override function initializeController():void
		{
			super.initializeController();
			
			registerCommand(INITIALIZATION, InitializationCommand);
			registerCommand(FETCH_ENTRY, FetchEntryCommand);
			registerCommand(FETCH_USER_PREFERENCES, FetchUserPreferencesCommand);
			registerCommand(FETCH_USER_RESTRICTION_ENZYMES, FetchUserRestrictionEnzymesCommand);
		}
		
		// Private Methods
		private function onSequenceChanging(event:FeaturedSequenceEvent):void
		{
			_actionStack.add(event.data as FeaturedSequenceMemento);
		}
		
		private function onActionStackChanged(event:ActionStackEvent):void
		{
			sendNotification(ApplicationFacade.ACTION_STACK_CHANGED);
		}
	}
}
