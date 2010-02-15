package org.jbei.registry.control
{
	import org.jbei.registry.view.FindPanelMediator;
	import org.jbei.registry.view.MainControlBarMediator;
	import org.jbei.registry.view.MainPanelMediator;
	import org.jbei.registry.view.StatusBarMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class PrepareViewCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			var application:VectorViewer = notification.getBody() as VectorViewer;
			
			facade.registerMediator(new MainControlBarMediator(application.mainControlBar));
			facade.registerMediator(new MainPanelMediator(application.mainPanel));
			facade.registerMediator(new StatusBarMediator(application.statusBar));
			facade.registerMediator(new FindPanelMediator(application.findPanel));
		}
	}
}
