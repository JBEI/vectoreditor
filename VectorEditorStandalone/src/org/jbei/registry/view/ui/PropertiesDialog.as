package org.jbei.registry.view.ui
{
	import flash.display.DisplayObject;
	
	import org.jbei.lib.ui.dialogs.SimpleDialog;
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.mediators.GenbankPropertyTabMediator;
	
	public class PropertiesDialog extends SimpleDialog
	{
		// Constructor
		public function PropertiesDialog(dialogFormClass:Class, activeTabIndex:int = 0, dialogParent:DisplayObject = null)
		{
			super(dialogFormClass, activeTabIndex, dialogParent);
		}
		
		// Protected Methods
		protected override function closeDialog():void
		{
			super.closeDialog();
			
			if(ApplicationFacade.getInstance().hasMediator(GenbankPropertyTabMediator.NAME)) {
				ApplicationFacade.getInstance().removeMediator(GenbankPropertyTabMediator.NAME);
			}
		}
	}
}
