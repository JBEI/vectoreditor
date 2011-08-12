package org.jbei.model.util
{
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

    /**
    * Utility wrapper around attachmentZipfile and sequenceZip file
    */ 
	public class ZipFileUtil
	{
//		private var _file:FileReference;
//		private var _zip:FZip;
        private var _attach:FZip;
        private var _seq:FZip;
		
		public function ZipFileUtil( attachZip:FZip, seqZip:FZip )
		{
//			this._file = zipFile;
//			_zip = new FZip();
//			_zip.loadBytes( this._file.data );
            this._attach = attachZip;
            this._seq = seqZip;
		}     
        
        public function get sequenceZip() : FZip 
        {
            return this._seq;
        }
        
        public function get attachmentZip() : FZip
        {
            return this._attach;
        }
		
//		public function get zipFile() : FileReference
//		{
//			return this._file;
//		}
		
//		public function containsFile( name:String ) : Boolean
//		{
//			// DEBUG
//			for( var i:int=0; i<_zip.getFileCount(); i += 1 )
//			{
//				 var file:FZipFile = _zip.getFileAt( i ) as FZipFile;
//				 if( filename( file.filename ) == name )
//					 return true;
//			}
//			return false;
//			
////			return ( _zip.getFileByName( name ) != null );
//		}
        
        /**
        * @returns true, if the attachment zip file contains a file 
        * with the name passed in the parameter. false otherwise, including
        * cases where the zipfile itself is null
        */ 
        public function containsAttachmentFile( name:String ) : Boolean
        {
            if( this._attach == null || name == null )
                return false;
            
            
            for( var i:uint = 0; i < this._attach.getFileCount(); i += 1 )
            {
                var file:FZipFile = this._attach.getFileAt( i ) as FZipFile;
                if( file == null )
                    continue;
                if( filename( file.filename ) === name )
                    return true;
            }
            return false;
        }
        
        public function containsSequenceFile( name:String) : Boolean
        {
            if( this._seq == null || name == null )
                return false;
            
            for( var i:uint = 0; i < this._seq.getFileCount(); i += 1 )
            {
                var file:FZipFile = this._seq.getFileAt( i ) as FZipFile;
                if( file == null )
                    continue;
                if( filename( file.filename ) === name )
                    return true;
            }
            return false;
        }
        
        /**
        * checks if the file named in the parameter is contained in the
        * sequence zip file and returns it if that is case. Returns null in
        * all other instances
        */ 
        public function fileInSequenceZip( name:String ) : ByteArray 
        {
            if( this._seq == null || name == null )
                return null;
            
            for( var i:int=0; i < this._seq.getFileCount(); i += 1 )
            {
                var file:FZipFile = _seq.getFileAt( i ) as FZipFile;
                if( filename( file.filename ) == name )
                    return file.content;
            }
            return null;
        }
		
        public function fileInAttachmentZip( name:String ) : ByteArray 
        {
            if( this._attach == null || name == null )
                return null;
            
            for( var i:int=0; i < this._attach.getFileCount(); i += 1 )
            {
                var file:FZipFile = _attach.getFileAt( i ) as FZipFile;
                if( filename( file.filename ) == name )
                    return file.content;
            }
            return null;
        }
        
		private function filename( relName:String ) : String
		{
			var index:int = relName.lastIndexOf( "/" );
			if( index == -1)
				return relName;
			
			return relName.substr( index+1, relName.length );
		}
	}
}