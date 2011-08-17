package org.jbei.view.components
{
	import deng.fzip.FZip;
	
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarDirection;
	import mx.controls.ProgressBarMode;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.Label;
	
	public class FileUploader extends UIComponent 
	{
		private var uploadURL:URLRequest;
		private var seqZipFile:FileReference;
		private var attachZipFile:FileReference;
        
        private var seqZip:FZip;
        private var attZip:FZip;
        private var seqName:String;
        private var attName:String;
		
		private var _seqZipfileButton:Button;
		private var _attachZipFileButton:Button;
		private var _uploadButton:Button;
		private var _attachProgressBar:ProgressBar;
		private var _seqProgressBar:ProgressBar;
		
		public function FileUploader() 
		{
			uploadURL = new URLRequest();
			seqZipFile = new FileReference();
			attachZipFile = new FileReference();
            
			this.createBrowseButtons();
			this.createProgressBars();
			
			// add event listeners
			this._seqZipfileButton.addEventListener( MouseEvent.CLICK, seqFileUploadButtonClick );
			this._attachZipFileButton.addEventListener( MouseEvent.CLICK, attachFilenameClick );
			
			// seq event listeners
			seqZipFile.addEventListener( Event.SELECT, seqSelectHandler );
			seqZipFile.addEventListener( ProgressEvent.PROGRESS, seqProgressHandler );
			seqZipFile.addEventListener( Event.COMPLETE, seqCompleteHandler );
			seqZipFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			
			// attach zip file listeners
			attachZipFile.addEventListener( Event.SELECT, attachSelectHandler );
			attachZipFile.addEventListener( ProgressEvent.PROGRESS, attachProgressHandler );
			attachZipFile.addEventListener( Event.COMPLETE, attachCompleteHandler );
			attachZipFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
		}
		
		public function reset() : void
		{
			if( !this.visible )
				return;
			this.removeChild( this._seqProgressBar );
			this._seqProgressBar = null;
			
			this.removeChild( this._attachProgressBar );
			this._attachProgressBar = null; 
			
			this.createProgressBars();
		}
        
        public function set sequenceZip( seqZip:FZip ) : void
        {
            this.seqZip = seqZip;
        }
        
        public function get sequenceZipFile() : FileReference
        {
            return this.seqZipFile;
        }
        
        public function get attachmentZipFile() : FileReference
        {
            return this.attachZipFile;
        }
        
        public function get sequenceZip() : FZip
        {
            return this.seqZip;
        }
        
        public function get sequenceZipName() : String
        {
            return this.seqName;
        }
        
        public function set attachmentZip( attZip:FZip ) : void
        {
            this.attZip = attZip;
        }
        
        public function get attachmentZip() : FZip
        {
            return this.attZip;
        }
        
        public function get attachmentZipName() : String
        {
            return this.attName; 
        }
		
		// events listeners
		private function seqFileUploadButtonClick( event:MouseEvent ) : void
		{
			seqZipFile.browse();
		}
		
		private function attachFilenameClick( event:MouseEvent ) : void
		{
			attachZipFile.browse();
		}
		
		// create methods
		private function createBrowseButtons() : void
		{
			if( !this._seqZipfileButton )
			{				
				this._seqZipfileButton = new Button();
				this._seqZipfileButton.label = "Select Sequence Zip File";
				this._seqZipfileButton.width = 180;
				this._seqZipfileButton.height = 25;
				this._seqZipfileButton.x = 30;
				this._seqZipfileButton.y = 330;
			
				this.addChild( this._seqZipfileButton );
			}
			
			if( !this._attachZipFileButton )
			{
				this._attachZipFileButton = new Button();
				this._attachZipFileButton.label = "Select Attachment Zip File";
				this._attachZipFileButton.width = 180;
				this._attachZipFileButton.height = 25;
				this._attachZipFileButton.x = 220;
				this._attachZipFileButton.y = 330;
				
				this.addChild( this._attachZipFileButton );
			}
		}
		
		/**
		 * Progress bars for each file upload button
		 */ 
		private function createProgressBars() : void
		{
			if( !this._seqProgressBar )
			{
				this._seqProgressBar = new ProgressBar();
				this._seqProgressBar.x = 30; // 420;
				this._seqProgressBar.y = 356;
				this._seqProgressBar.width = 180;
				this._seqProgressBar.indeterminate = false;
				this._seqProgressBar.visible = true;
				this._seqProgressBar.direction = ProgressBarDirection.RIGHT;
				this._seqProgressBar.mode = ProgressBarMode.MANUAL;
				this._seqProgressBar.minimum = 0;
				this._seqProgressBar.label = "No file selected";
				this._seqProgressBar.setStyle("trackHeight", 6);
				
				this.addChild( this._seqProgressBar );
			}
			
			// attachment progress bar
			if( !this._attachProgressBar )
			{
				this._attachProgressBar = new ProgressBar();
				this._attachProgressBar.x = 220; // 640;
				this._attachProgressBar.y = 356;
				this._attachProgressBar.width = 180;
				this._attachProgressBar.indeterminate = false;
				this._attachProgressBar.visible = true;
				this._attachProgressBar.direction = ProgressBarDirection.RIGHT;
				this._attachProgressBar.mode = ProgressBarMode.MANUAL;
				this._attachProgressBar.minimum = 0;
				this._attachProgressBar.label = "No file selected";
				
				// styles
				this._attachProgressBar.setStyle("barColor", "haloBlue");
//				this._attachProgressBar.setStyle("borderColor", "0xFE0003");
//				this._attachProgressBar.setStyle("trackColors", "[0xE6EEEE,0xE6EEEE]" );
				this._attachProgressBar.setStyle("trackHeight", 6);
				
				this.addChild( this._attachProgressBar );
			}
		}
		
		private function ioErrorHandler( event:IOErrorEvent ) : void 
		{
			Alert.show( "There was an error uploading file.\n\nDetails\n\n" + event, "File upload" );
		}
        
        public function setSequenceProgressBar( fileName:String ) : void
        {
            this._seqProgressBar.label = fileName;
            this._seqProgressBar.toolTip = fileName;
        }
		
		private function seqSelectHandler( event:Event ) : void
		{
			var file:FileReference = FileReference( event.target );
			var fileName:String = ( file.name.length <= 19 ) ? file.name : ( file.name.slice(0, 16 ) + "..." );
			
			try
			{
				this._seqProgressBar.maximum = file.size;
				this._seqProgressBar.label = fileName + ": %3%%";
				this._seqProgressBar.toolTip = file.name;
				file.load();  
			}
			catch( err:Error )
			{
				this._seqProgressBar.label = err.message;
			}
			this._seqProgressBar.visible = true;
		}
		
		private function attachSelectHandler( event:Event ) : void
		{
			var file:FileReference = FileReference( event.target );
			var fileName:String = ( file.name.length <= 19 ) ? file.name : ( file.name.slice( 0, 16 ) + "..." );
			
			try
			{
				this._attachProgressBar.maximum = file.size;
				this._attachProgressBar.label = fileName + ": %3%%";
				this._attachProgressBar.toolTip = file.name;
				file.load();
			}
			catch( err:Error )
			{
				this._attachProgressBar.label = err.message;
			}
			this._attachProgressBar.visible = true;
		}
		
		private function seqProgressHandler( event:ProgressEvent ) : void 
		{
			var file:FileReference = FileReference( event.target );
			this._seqProgressBar.setProgress( event.bytesLoaded, event.bytesTotal );
			trace( "Sequence Progress Handler: name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal );
		}
		
		private function attachProgressHandler( event:ProgressEvent ) : void 
		{
			var file:FileReference = FileReference( event.target );
			this._attachProgressBar.setProgress( event.bytesLoaded, event.bytesTotal );
			trace( "Attachment Progress Handler: name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal );
		}
		
		private function seqCompleteHandler( event:Event ) : void  
		{
            var file:FileReference = FileReference( event.target );
            this.seqZip = new FZip();
            this.seqZip.loadBytes( file.data );
            this.seqName = file.name;
		}
		
		private function attachCompleteHandler( event:Event ) : void  
		{
            var file:FileReference = FileReference( event.target );
            this.attZip = new FZip();
            this.attZip.loadBytes( file.data );
            this.attName = file.name;
		}
	}
}