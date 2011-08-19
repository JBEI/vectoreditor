package org.jbei.model
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.jbei.ApplicationFacade;
	import org.jbei.Notifications;
	import org.jbei.model.fields.EntryFields;
	import org.jbei.model.fields.EntryFieldsFactory;
	import org.jbei.model.registry.ArabidopsisSeed;
	import org.jbei.model.registry.Attachment;
	import org.jbei.model.registry.Entry;
	import org.jbei.model.registry.Part;
	import org.jbei.model.registry.Plasmid;
	import org.jbei.model.registry.Sequence;
	import org.jbei.model.registry.Strain;
	import org.jbei.model.save.ArabidopsisSet;
	import org.jbei.model.save.BulkImportEntryData;
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.PartSet;
	import org.jbei.model.save.PlasmidSet;
	import org.jbei.model.save.StrainSet;
	import org.jbei.model.save.StrainWithPlasmidSet;
	import org.jbei.model.util.EntryFieldUtils;
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.ApplicationMediator;
	import org.jbei.view.EntryType;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * @author Hector Plahar
	 * 
	 * Proxy for loading part types supported for bulk import
	 * and also the fields for each
	 */ 
	public class RegistryAPIProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "org.jbei.model.RegistryAPIProxy";
		
		private var _remote:RemoteObject;
		private var _uniqueOriginReplications:ArrayCollection;
		private var _uniqueSelectionMarkers:ArrayCollection;
		private var _uniquePromoters:ArrayCollection;
		private var _wrapper:SaveWrapper;
		private var _redirectURL:String;
		private var _saveRemainder:Number;
		private var _failureCount:Number;
		private var _sessionId:String;
		private var _app:EntryBulkImport;
		
		public function RegistryAPIProxy( sessionId:String, app:EntryBulkImport )
		{
			super( NAME );
			init();
			this._sessionId = sessionId;
			this._app = app;
		}
		
		/**
		 * Initializes the remote object and add listeners to the remove methods 
		 */
		private function init() : void
		{
			// create url for redirecting
			var url:String = FlexGlobals.topLevelApplication.url;
			_redirectURL = ( url.substr(0, url.indexOf( "/", 8 ) ) );
			
			// for remote method invocations
			_remote = new RemoteObject( ApplicationFacade.REMOTE_SERVICE_NAME );
			
			// listeners for method returns
			_remote.getUniqueOriginOfReplications.addEventListener( ResultEvent.RESULT, uniqueOrigins );
			_remote.getUniqueSelectionMarkers.addEventListener( ResultEvent.RESULT, uniqueMarkers );
			_remote.getUniquePromoters.addEventListener( ResultEvent.RESULT, uniquePromoters );
			_remote.saveEntries.addEventListener( "fault", faultHandler );
			_remote.saveEntries.addEventListener( ResultEvent.RESULT, onSaveSuccess );			
			
			// admin mode method call listeners
			_remote.retrieveBulkImportEntryType.addEventListener( "fault", faultHandler );			
			_remote.retrieveBulkImportEntryType.addEventListener( ResultEvent.RESULT, onBulkTypeRetrieve );			
			
			// actual calls
			_remote.getUniqueOriginOfReplications();
			_remote.getUniquePromoters();
			_remote.getUniqueSelectionMarkers();
		}
		
		public function retrieveBulkImportEntryType( importId:String ) : void 
		{
			_remote.retrieveBulkImportEntryType( _sessionId, importId );
		}
		
        /**
        * Event listener method for bulk import type retrieved from server
        */ 
		public function onBulkTypeRetrieve( event:ResultEvent ) : void
		{
			var result:String = String(event.result);
			var type:EntryType = EntryType.valueOf( result );
			sendNotification( Notifications.PART_TYPE_SELECTION, type );
		}		
		
		protected function verifySave( set:EntrySet ) : void
		{
			switch( set.type )
			{
				case EntryType.STRAIN_WITH_PLASMID:
					var strainWithPlasmidSet:StrainWithPlasmidSet = set as StrainWithPlasmidSet;
					this.saveStrainWithPlasmids( _sessionId, strainWithPlasmidSet );
					break;
				
				case EntryType.ARABIDOPSIS:
				case EntryType.PART:
				case EntryType.PLASMID:
				case EntryType.STRAIN:
                    this.saveEntry( _sessionId, set );
					break;
				
				default:
					Alert.show( "System does not know how to handle entry type " + set.type );
			}
		}
		
		public function submitForSave( set:EntrySet ) : void
		{
			// verification save
			if( ApplicationFacade.getInstance().importId != null )
			{
				this.verifySave( set );
				return;
			}
			
			// regular save
            var zipUtil:ZipFileUtil = set.zipFileUtil;
            
			var primaryData:ArrayCollection = new ArrayCollection(); 
			var secondaryData:ArrayCollection = new ArrayCollection();
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var obj:Object = set.entries.getItemAt( i );
				if( obj is StrainWithPlasmid )
				{
					var strainWithPlasmid:StrainWithPlasmid = obj as StrainWithPlasmid;
					
					// primary
					var strain:Strain = strainWithPlasmid.strain;
					var strainImport:BulkImportEntryData  = new BulkImportEntryData();
					strainImport.entry = strain;
					
					var strainAtt:String = strain.attachment == null ? null : strain.attachment.fileName;
					var strainSeq:String = strain.sequence == null ? null : strain.sequence.filename;
					strainImport.attachmentFilename = strainAtt;
					strainImport.sequenceFilename = strainSeq;
					primaryData.addItem( strainImport );
					
					// secondary
					var plasmid:Plasmid = strainWithPlasmid.plasmid;	
					var plasmidImport:BulkImportEntryData  = new BulkImportEntryData();
					plasmidImport.entry = plasmid;
					
					var plasmidAtt:String = plasmid.attachment == null ? null : plasmid.attachment.fileName;
					var plasmidSeq:String = plasmid.sequence == null ? null : plasmid.sequence.filename;
					plasmidImport.attachmentFilename = plasmidAtt;
					plasmidImport.sequenceFilename = plasmidSeq;
					secondaryData.addItem( plasmidImport );
				} 
				else if( obj is Entry ) 
				{
					var entry:Entry = obj as Entry;
					var bulkImport:BulkImportEntryData  = new BulkImportEntryData();
					bulkImport.entry = entry;
					
					// file names
					var attFilename:String = entry.attachment == null ? null : entry.attachment.fileName;
					var seqFilename:String = entry.sequence == null ? null : entry.sequence.filename;
					bulkImport.attachmentFilename = attFilename;
					bulkImport.sequenceFilename = seqFilename;                    
					primaryData.addItem( bulkImport );
				}
				else 
				{
					trace( "Unknown object type" );
					continue;
				}
			}			
			
			_remote.saveEntries( _sessionId, primaryData, secondaryData, zipUtil.sequenceZipArray, 
                zipUtil.attachmentZipArray, set.sequenceName, set.attachmentName );
		}
		
		private function redirectAfterSave() : void
		{
            Alert.show( "Entries successfully saved. You must manually delete the record.", "Save", Alert.OK, null, redirect );
		}
        
        private function redirect( event:CloseEvent ) : void
        {
            if( _redirectURL )
                navigateToURL( new URLRequest( _redirectURL + "/admin/bulk_import" ), "_self" );
            else
                sendNotification( Notifications.RESET_APP );
        }
		
		// Instead of one at a time, send a bulk like with the bulk save
        private function saveEntry( sessionId:String, set:EntrySet ) : void
        {
            var zip:ZipFileUtil = set.zipFileUtil;
            var sequenceBytes:ByteArray = null;
            var attachmentBytes:ByteArray = null;
            var sequenceName:String = null;
            var attachmentName:String = null;
            
            for( var i:int = 0; i < set.entries.length; i += 1 )
            {
                var entry:Entry = set.entries.getItemAt( i ) as Entry;
                
                // sequence file
                if( entry.sequence ) 
                {
                    sequenceName = entry.sequence.filename;
                    sequenceBytes = zip.fileInSequenceZip( sequenceName );
                }
                
                // attachment file
                if( entry.attachment )
                {
                    attachmentName = entry.attachment.fileName;
                    attachmentBytes = zip.fileInAttachmentZip( attachmentName );
                }
                
                _remote.saveEntry( sessionId, ApplicationFacade.getInstance().importId, entry, attachmentBytes, 
                    attachmentName, sequenceBytes, sequenceName );
            }
            
            // redirect
            redirectAfterSave();
        }
        
		private function saveStrainWithPlasmids( sessionId:String, set:StrainWithPlasmidSet ) : void
		{
            var zip:ZipFileUtil = set.zipFileUtil; 
            var strainSequenceBytes:ByteArray = null;
            var strainSequenceFilename:String = null;
            var strainAttachmentBytes:ByteArray = null;            
            var strainAttachmentFilename:String = null;
            
            var plasmidSequenceBytes:ByteArray = null;
            var plasmidSequenceFilename:String = null;
            var plasmidAttachmentBytes:ByteArray = null;
            var plasmidAttachmentFilename:String = null;
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var entry:StrainWithPlasmid = set.entries.getItemAt( i ) as StrainWithPlasmid;
				var strain:Strain = entry.strain;
                var plasmid:Plasmid = entry.plasmid;
                
                // strain sequence
                if( strain.sequence )
                {
                    strainSequenceFilename = strain.sequence.filename;
                    strainSequenceBytes = zip.fileInSequenceZip( strainSequenceFilename );
                }
                
                // strain attachment
                if( strain.attachment )
                {
                    strainAttachmentFilename = strain.attachment.fileName;
                    strainAttachmentBytes = zip.fileInAttachmentZip( strainAttachmentFilename );
                }
                   
                // plasmid sequence 
                if( plasmid.sequence )
                {
                    plasmidSequenceFilename = plasmid.sequence.filename;
                    plasmidSequenceBytes = zip.fileInSequenceZip( plasmidSequenceFilename );                    
                }
                
                // plasmid attachment
                if( plasmid.attachment )
                {                    
                    plasmidAttachmentFilename = plasmid.attachment.fileName;
                    plasmidAttachmentBytes = zip.fileInAttachmentZip( plasmidAttachmentFilename );
                }
                 
				_remote.saveStrainWithPlasmid( sessionId, ApplicationFacade.getInstance().importId, strain, plasmid, 
                    strainSequenceBytes, strainSequenceFilename, 
                    strainAttachmentBytes, strainAttachmentFilename, plasmidSequenceBytes, plasmidSequenceFilename, 
                    plasmidAttachmentBytes, plasmidAttachmentFilename );
			}
			redirectAfterSave();
		}
		
		private function redirectToFolders( event:CloseEvent ) : void
		{
			// TODO : send a call to send an email to the admin
			if( this._redirectURL )
				navigateToURL( new URLRequest( this._redirectURL + "/folders" ), "_self" );
			else
				sendNotification( Notifications.RESET_APP );
		}
		
		public function getUniqueOriginOfReplications() : ArrayCollection
		{	
			return this._uniqueOriginReplications;
		}
		
		public function getUniqueSelectionMarkers() : ArrayCollection
		{
			return this._uniqueSelectionMarkers;
		}
		
		public function getUniquePromoters() : ArrayCollection
		{
			return this._uniquePromoters;
		}
		
		// catch-all for all auto-complete data
		// checks to ensure that the needed ones are loaded and then sends a notification
		private function autoCompleteData() : void
		{
			if( this._uniquePromoters != null && this._uniqueOriginReplications != null
				&& this._uniqueSelectionMarkers != null )
			{
				sendNotification( Notifications.START_UP, _app );
			}
		}
		
		private function faultHandler( event:FaultEvent ) : void
		{			
			Alert.show( "Error\n\t" + event.fault.faultString + "\nPlease contact your administrator with the following details.\n\nDetails\n\n" + event.fault.faultDetail, event.fault.faultCode );
		}
		
		private function onSaveSuccess( event:ResultEvent ) : void
		{
            var saved:int = event.result as int;
            if( saved == 0 )
                Alert.show( "There was a problem submitting your entries. Please try again or consult your administrater", "Save", Alert.OK );
            else
			    Alert.show( saved + " entries have been submitted successfully.\nOn administrative approval they will show up in your list of entries", "Save",  Alert.OK, null, redirectToFolders );
		}
		
		private function uniquePromoters( event:ResultEvent ) : void
		{			
			this._uniquePromoters = event.result as ArrayCollection;			
			EntryFieldUtils.uniquePromoters = this._uniquePromoters;
			autoCompleteData();
		}
		
		private function uniqueOrigins( event:ResultEvent ) : void
		{
			this._uniqueOriginReplications = event.result as ArrayCollection;
			EntryFieldUtils.uniqueOrigins = this._uniqueOriginReplications; 
			autoCompleteData();
		}
		
		private function uniqueMarkers( event:ResultEvent ) : void
		{
			this._uniqueSelectionMarkers = event.result as ArrayCollection;			
			EntryFieldUtils.uniqueSelectionMarkers = this._uniqueSelectionMarkers; 
			autoCompleteData();
		}
	}
}