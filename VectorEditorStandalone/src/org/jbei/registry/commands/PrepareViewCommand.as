package org.jbei.registry.commands
{
	import org.jbei.registry.mediators.FindPanelMediator;
	import org.jbei.registry.mediators.GenbankPropertyTabMediator;
	import org.jbei.registry.mediators.MainControlBarMediator;
	import org.jbei.registry.mediators.MainMenuMediator;
	import org.jbei.registry.mediators.MainPanelMediator;
	import org.jbei.registry.mediators.StatusBarMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class PrepareViewCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			var application:VectorEditor = notification.getBody() as VectorEditor;
			
			facade.registerMediator(new MainControlBarMediator(application.mainControlBar));
			facade.registerMediator(new MainMenuMediator(application.mainMenu));
			facade.registerMediator(new MainPanelMediator(application.mainPanel));
			facade.registerMediator(new StatusBarMediator(application.statusBar));
			facade.registerMediator(new FindPanelMediator(application.findPanel));
		}
	}
}
