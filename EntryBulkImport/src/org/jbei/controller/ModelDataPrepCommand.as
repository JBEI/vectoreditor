package org.jbei.controller
{
	import org.jbei.ApplicationFacade;
	import org.jbei.model.RegistryAPIProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author Hector Plahar
	 * 
	 * Simple command for prepping the proxies that pre-load the data
	 * needed for application. e.g. Loading the auto-complete data
	 */
	public class ModelDataPrepCommand extends SimpleCommand
	{	
		override public function execute( notification : INotification ) : void
		{
			var app:EntryBulkImport = notification.getBody() as EntryBulkImport;
			var sid:String = ApplicationFacade.getInstance().sessionId;
			facade.registerProxy( new RegistryAPIProxy( sid, app ) );
		}
	}
}