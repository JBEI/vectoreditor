package org.jbei.controller
{
    import mx.controls.Alert;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.remoting.RemoteObject;
    
    import org.jbei.ApplicationFacade;
    import org.jbei.Notifications;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.MacroCommand;
    
    /**
     * A macro command that is executed when the application
     * starts. It is setup to respond to the startup notification
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
            
            if( ApplicationFacade.getInstance().importId != null )
                sendNotification( Notifications.RETRIEVE_IMPORT );
        }
    }
}