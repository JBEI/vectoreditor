package org.jbei.controller
{
    import org.jbei.ApplicationFacade;
    import org.jbei.model.BulkImportVerifierProxy;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

    /**
    * @author Hector Plahar
    * SimpleCommand for registering proxies that are associated with retreiving 
    * bulk import data
    */ 
        
    public class ImportDataCommand extends SimpleCommand
    {
        override public function execute( notification : INotification ) : void
        {
            var sid:String = ApplicationFacade.getInstance().sessionId;
            facade.registerProxy( new BulkImportVerifierProxy( sid ) );
        }
    }
}