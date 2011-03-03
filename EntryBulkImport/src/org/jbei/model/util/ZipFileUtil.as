package org.jbei.model.util
{
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class ZipFileUtil
	{
		private var _file:FileReference;
		private var _zip:FZip;
		
		public function ZipFileUtil( zipFile:FileReference )
		{
			this._file = zipFile;
			_zip = new FZip();
			_zip.loadBytes( this._file.data );
		}
		
		public function get zipFile() : FileReference
		{
			return this._file;
		}
		
		public function containsFile( name:String ) : Boolean
		{
			// DEBUG
			for( var i:int=0; i<_zip.getFileCount(); i += 1 )
			{
				 var file:FZipFile = _zip.getFileAt( i ) as FZipFile;
				 if( filename( file.filename ) == name )
					 return true;
			}
			return false;
			
//			return ( _zip.getFileByName( name ) != null );
		}
		
		public function file( name:String ) : ByteArray
		{
			for( var i:int=0; i<_zip.getFileCount(); i += 1 )
			{
				var file:FZipFile = _zip.getFileAt( i ) as FZipFile;
				if( filename( file.filename ) == name )
					return file.content;
			}
			return null;
		}
		
		private function filename( relName:String ) : String
		{
			var index:int = relName.lastIndexOf( "/" );
			if( index == - 1)
				return relName;
			
			return relName.substr( index+1, relName.length );
		}
	}
}