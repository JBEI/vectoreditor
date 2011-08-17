package org.jbei.model.save
{
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.EntryType;

	public class EntrySet
	{
		private var _type:EntryType;
		private var _errMsg:String;
		
        protected var _seqName:String;
        protected var _attName:String;
        
        private var _zipUtil:ZipFileUtil;
		
		protected var _records:ArrayCollection = new ArrayCollection; // <? implements Entry>
        
        public function EntrySet( type:EntryType ) 
        {
            this._type = type;
        }        
        
        public function get zipFileUtil() : ZipFileUtil
        {
            return this._zipUtil;
        }
        
        public function set zipFileUtil( zip:ZipFileUtil ) : void
        {
            this._zipUtil = zip;
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