package org.jbei.model.save
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.view.EntryType;

	public class EntrySet
	{
		private var _type:EntryType;
		private var _errMsg:String;
		
		protected var _seqZip:FZip;
		protected var _attZip:FZip;
        protected var _seqName:String;
        protected var _attName:String;
		
		protected var _records:ArrayCollection = new ArrayCollection; // <? implements Entry>
        
        public function EntrySet( type:EntryType ) 
        {
            this._type = type;
        }        
		
		public function set sequenceZipfile( file:FZip ) : void
		{
			this._seqZip = file;
		}
		
		public function get sequenceZipfile() : FZip
		{
			return this._seqZip;
		}
		
		public function set attachmentZipfile( file:FZip ) : void
		{
			this._attZip = file;
		}	
		
		public function get attachmentZipfile() : FZip
		{
			return this._attZip;
		}
		
        public function get attachmentName() : String 
        {
            return this._attName;
        }
        
        public function set attachmentName( name:String ) : void
        {
            this._attName = name;
        }
        
        public function get sequenceName() : String
        {
            return this._seqName;
        }
        
        public function set sequenceName( name:String ) : void
        {
            this._seqName = name;
        }
		
		public function get type() : EntryType
		{
			return this._type;
		}
		
		public function get recordCount() : Number 
		{ 
			return _records.length; 
		}
		
		public function get entries() : ArrayCollection
		{
			return this._records;
		}
		
		// Override the following functions
		public function addToSet( obj:Object ) : void {}
	}
}