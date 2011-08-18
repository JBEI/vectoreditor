package org.jbei.view.mediators
{
	import deng.fzip.FZip;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.Notifications;
	import org.jbei.view.EntryType;
	import org.jbei.view.components.FileUploader;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class FileUploaderMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "org.jbei.view.mediators.FileUploaderMediator";
        private var seqZip:FZip;
        private var attZip:FZip;
		
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
			return [ Notifications.PART_TYPE_SELECTION, Notifications.RESET_APP, Notifications.VERIFY ];
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
						case EntryType.PART:
						case EntryType.PLASMID:
						case EntryType.STRAIN:
							this.fileUploader.visible = true;
							break;
						
						case EntryType.ARABIDOPSIS:
							this.fileUploader.visible = false;
							break;
					}
					break;
				
				case Notifications.RESET_APP:
					this.fileUploader.reset();
					break;
				
				case Notifications.VERIFY:
					this.handleVerify(notification);
					break;
			}
		}
		
		protected function handleVerify( notification:INotification ) : void
		{
			var results:Object = notification.getBody();
            var attName:String = results.attachmentFilename;
			var attachmentZipfileBytes:ByteArray = results.attachmentZipfile;
			var seqZipfileBytes:ByteArray = results.sequenceZipfile;
            var seqName:String = results.sequenceFilename;
            
            if( seqZipfileBytes != null )
            {
                var zip:FZip = new FZip();
                zip.addEventListener(Event.COMPLETE, listener);
                zip.loadBytes(seqZipfileBytes);
                function listener(event:Event) : void 
                {
                    fileUploader.sequenceZip = zip;
                    if( seqName != null )
                        fileUploader.setSequenceProgressBar( seqName );
                }
            }            
            
            if( attachmentZipfileBytes != null )
            {
                zip = new FZip();
                zip.addEventListener(Event.COMPLETE, attListener);
                zip.loadBytes(attachmentZipfileBytes);
                function attListener(event:Event) : void
                {
                    fileUploader.attachmentZip = zip;
                    if( attName != null )
                        fileUploader.setAttachmentProgressBar( attName );
                }
            }
		}
	}
}