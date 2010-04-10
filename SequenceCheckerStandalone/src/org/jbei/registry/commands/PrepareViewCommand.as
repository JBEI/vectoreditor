package org.jbei.registry.commands
{
	import org.jbei.registry.mediators.AlignmentPanelMediator;
	import org.jbei.registry.mediators.MainControlBarMediator;
	import org.jbei.registry.mediators.MainPanelMediator;
	import org.jbei.registry.mediators.StatusBarMediator;
	import org.jbei.registry.mediators.TracesListPanelMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class PrepareViewCommand extends SimpleCommand
	{
		// Public Methods
		public override function execute(notification:INotification):void
		{
			var application:SequenceChecker = notification.getBody() as SequenceChecker;
			
			facade.registerMediator(new MainControlBarMediator(application.mainControlBar));
			facade.registerMediator(new MainPanelMediator(application.mainPanel));
			facade.registerMediator(new StatusBarMediator(application.statusBar));
			facade.registerMediator(new TracesListPanelMediator(application.tracesListPanel));
			facade.registerMediator(new AlignmentPanelMediator(application.alignmentPanel));
		}
	}
}
