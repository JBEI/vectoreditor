package org.jbei.controller
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.MacroCommand;
	
	/**
	 * A macro command that is executed when the application
	 * starts
	 */ 
	public class StartupCommand extends MacroCommand
	{
		/**
		 * initializes startup by adding commands for preparing
		 * the application model and view. these are executed in
		 * FIFO order
		 */ 
		override protected function initializeMacroCommand():void
		{
			addSubCommand( ModelPrepCommand );
			addSubCommand( ViewPrepCommand );
		}
	}
}