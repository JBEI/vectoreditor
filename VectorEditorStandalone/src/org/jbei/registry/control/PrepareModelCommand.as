package org.jbei.registry.control
{
	import org.jbei.registry.model.EntriesProxy;
	import org.jbei.registry.model.UserPreferencesProxy;
	import org.jbei.registry.model.UserRestrictionEnzymesProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class PrepareModelCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			facade.registerProxy(new UserPreferencesProxy());
			facade.registerProxy(new UserRestrictionEnzymesProxy());
			facade.registerProxy(new EntriesProxy());
		}
	}
}
