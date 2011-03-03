package org.jbei.view.mediators
{
	import flash.net.FileReference;
	
	import org.jbei.Notifications;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.FileUploader;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class FileUploaderMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "org.jbei.view.mediators.FileUploaderMediator";
		
		public function FileUploaderMediator( uploader:FileUploader )
		{
			super( NAME, uploader );
			uploader.visible = false;
		}
		
		public function get fileUploader() : FileUploader
		{
			return this.viewComponent as FileUploader;
		}
		
		override public function listNotificationInterests():Array
		{
			return [ Notifications.PART_TYPE_SELECTION, Notifications.RESET_APP ];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch( notification.getName() )
			{
				case Notifications.PART_TYPE_SELECTION:
					var selected:EntryType = notification.getBody() as EntryType;
					switch( selected )
					{
						case EntryType.STRAIN_WITH_PLASMID:
							this.fileUploader.visible = true;
							break;
						
						case EntryType.PART:
							this.fileUploader.visible = true;
							break;
						
						case EntryType.PLASMID:
							this.fileUploader.visible = true;
							break;
						
						case EntryType.STRAIN:
							this.fileUploader.visible = true;
							break;
						
						case EntryType.PART:
							this.fileUploader.visible = false;
							break;
						
						case EntryType.ARABIDOPSIS:
							this.fileUploader.visible = false;
							break;
					}
					break;
				
				case Notifications.RESET_APP:
					this.fileUploader.reset();
					break;
			}
		}
		
		public function attachmentFile() : FileReference 
		{
			return this.fileUploader.attachmentFile;
		}
		
		public function uploadedFile() : FileReference
		{
			return this.fileUploader.sequenceFile;
		}
	}
}