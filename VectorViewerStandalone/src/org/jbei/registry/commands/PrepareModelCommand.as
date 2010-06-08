package org.jbei.registry.commands
{
	import org.jbei.registry.proxies.RegistryAPIProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

    /**
     * @author Zinovii Dmytriv
     */
	public class PrepareModelCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			facade.registerProxy(new RegistryAPIProxy());
		}
	}
}
