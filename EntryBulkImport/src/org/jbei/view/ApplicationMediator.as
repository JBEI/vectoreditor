package org.jbei.view
{
	import org.jbei.view.mediators.CancelButtonMediator;
	import org.jbei.view.mediators.FileUploaderMediator;
	import org.jbei.view.mediators.GridRowHeaderColumnHolderMediator;
	import org.jbei.view.mediators.GridColumnHeaderRowMediator;
	import org.jbei.view.mediators.HeaderTextInputMediator;
	import org.jbei.view.mediators.ImportPanelMediator;
	import org.jbei.view.mediators.PartTypeOptionsMediator;
	import org.jbei.view.mediators.SaveButtonMediator;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * Creates mediators for application view component
	 */
	public class ApplicationMediator extends Mediator implements IMediator
	{
		private var app:EntryBulkImport;
		
		public function ApplicationMediator( app:EntryBulkImport )
		{
			this.app = app;
			
			facade.registerMediator( new PartTypeOptionsMediator( app.partOptions ) );
			facade.registerMediator( new ImportPanelMediator( app.importPanel ) );
			facade.registerMediator( new HeaderTextInputMediator( app.headerInput ) );
			facade.registerMediator( new GridColumnHeaderRowMediator( app.columnHeaderRow ) );
			facade.registerMediator( new SaveButtonMediator( app.saveButton ) );
			facade.registerMediator( new CancelButtonMediator( app.cancelButton ) );
			facade.registerMediator( new GridRowHeaderColumnHolderMediator( app.rowHeaderColumn ) );
			facade.registerMediator( new FileUploaderMediator( app.fileUploader ) );
		}
	}
}