package org.jbei.controller
{
	import org.jbei.view.ApplicationMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * Simple command executed at application startup for 
	 * preparing the view. create and registers the
	 * main application mediator (which in turn registers
	 * the remaining mediators)
	 */ 
	public class ViewPrepCommand extends SimpleCommand
	{
		override public function execute( notification:INotification ):void
		{
			var app:EntryBulkImport = notification.getBody() as EntryBulkImport;
			facade.registerMediator( new ApplicationMediator( app ) );
		}
	}
}