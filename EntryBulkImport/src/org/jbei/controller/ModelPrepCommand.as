package org.jbei.controller
{
	import org.jbei.model.PasteEventProxy;
	import org.jbei.model.RegistryAPIProxy;
	import org.jbei.model.ValueExtractorProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * Simple command for preparing the model
	 * on application startup. creates (and registers)
	 * proxies with the model
	 */ 
	public class ModelPrepCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new RegistryAPIProxy() );
			facade.registerProxy( new PasteEventProxy() );
			facade.registerProxy( new ValueExtractorProxy() );
		}
	}
}