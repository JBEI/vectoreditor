package org.jbei.view.components
{
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
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
		
		private var _browseButton:Button;
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
			this._browseButton.addEventListener( MouseEvent.CLICK, browseClick );
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
		
		// events listeners
		private function browseClick( event:MouseEvent ) : void
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
			if( !this._browseButton )
			{				
				this._browseButton = new Button();
				this._browseButton.label = "Select Sequence Zip File";
				this._browseButton.width = 180;
				this._browseButton.height = 25;
				this._browseButton.x = 30;
				this._browseButton.y = 330;
			
				this.addChild( this._browseButton );
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
		
		public function get sequenceFile() : FileReference
		{
			return this.seqZipFile;
		}
		
		public function get attachmentFile() : FileReference
		{
			return this.attachZipFile;
		}
		
		private function ioErrorHandler( event:IOErrorEvent ) : void 
		{
			trace( "ERROR : " + event );
		}
		
		private function seqSelectHandler( event:Event ) : void
		{
			var file:FileReference = FileReference( event.target );
			trace( "Sequence Select Handler: name=" + file.name );
			var fileName:String = ( file.name.length <= 19 ) ? file.name : (file.name.slice(0, 16 ) + "...");
			
			try
			{
				this._seqProgressBar.maximum = file.size;
				this._seqProgressBar.label = fileName + ": %3%%";
				this._seqProgressBar.toolTip = file.name;
				file.load();
			}
			catch( err:Error )
			{
				trace( err.message );
				this._seqProgressBar.label = err.message;
			}
			this._seqProgressBar.visible = true;
		}
		
		private function attachSelectHandler( event:Event ) : void
		{
			var file:FileReference = FileReference( event.target );
			trace( "Attachment Select Handler: name=" + file.name );
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
				trace( err.message );
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
			trace( "Sequence Complete Handler: " + event );
		}
		
		private function attachCompleteHandler( event:Event ) : void  
		{
			trace( "Attachment Complete Handler: " + event );
		}
	}
}