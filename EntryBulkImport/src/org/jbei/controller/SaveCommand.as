package org.jbei.controller
{
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.jbei.Notifications;
	import org.jbei.model.RegistryAPIProxy;
	import org.jbei.model.SaveWrapper;
	import org.jbei.model.save.EntrySet;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class SaveCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var entrySet:EntrySet = notification.getBody() as EntrySet;
			if( entrySet.recordCount == 0 )
			{
				Alert.show( "No records retrieved for save!", "Save Error", Alert.OK );
				return;
			}
			
			var proxy:RegistryAPIProxy = facade.retrieveProxy( RegistryAPIProxy.NAME ) as RegistryAPIProxy;	
			proxy.submitForSave( entrySet );
		}
	}
}