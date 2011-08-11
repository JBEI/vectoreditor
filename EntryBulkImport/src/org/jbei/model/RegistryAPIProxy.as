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
					var seedSet:ArabidopsisSet = set as ArabidopsisSet;
					this.saveArabidopsis( _sessionId, seedSet );
					break;
				
				case EntryType.PART:
					var partSet:PartSet = set as PartSet;
					this.saveParts( _sessionId, partSet );
					break;
				
				case EntryType.PLASMID:
					var plasmidSet:PlasmidSet = set as PlasmidSet;
					this.savePlasmids( _sessionId, plasmidSet );
					break;
				
				case EntryType.STRAIN:
					var strainSet:StrainSet = set as StrainSet;
					this.saveStrains( _sessionId, strainSet );
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
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
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
			
			var seqZipName:String = ( set.sequenceZipfile == null ) ? null : set.sequenceZipfile.name;
			var attachZipName:String = ( set.attachmentZipfile == null ) ? null : set.attachmentZipfile.name;
			var seqZipFile:ByteArray = ( set.sequenceZipfile == null ) ? null : set.sequenceZipfile.data; 
			var attZipfile:ByteArray = ( set.attachmentZipfile == null ) ? null : set.attachmentZipfile.data;
			
			_remote.saveEntries( _sessionId, primaryData, secondaryData, seqZipFile, attZipfile, seqZipName, attachZipName );
		}
		
		private function redirectAfterSave() : void
		{
			if( this._redirectURL )
				navigateToURL( new URLRequest( this._redirectURL + "/admin/bulk_import" ), "_self" );
			else
			{
				Alert.show( "Entries Submitted For Save" );
				sendNotification( Notifications.RESET_APP );
			}
		}
		
		// Instead of one at a time, send a bulk like with the bulk save
		private function saveArabidopsis( sessionId:String, set:ArabidopsisSet ) : void
		{
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var seed:ArabidopsisSeed = set.entries.getItemAt( i ) as ArabidopsisSeed;
				var seedSequence:ByteArray = ( !seed.sequence || !seqZipUtil ) ? null : seqZipUtil.file( seed.sequence.filename );
				var seedAttachment:ByteArray = ( !seed.attachment || !attachZipUtil ) ? null : attachZipUtil.file( seed.attachment.fileName );
				
				var attFilename:String = seed.attachment == null ? null : seed.attachment.fileName;
				_remote.saveEntry( sessionId, seed, seedSequence, seedAttachment, attFilename );
			}
			
			// redirect
			redirectAfterSave();
		}
		
		private function saveParts( sessionId:String, set:PartSet ) : void
		{
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var part:Part = set.entries.getItemAt( i ) as Part;
				var partSequence:ByteArray = ( !part.sequence || !seqZipUtil ) ? null : seqZipUtil.file( part.sequence.filename );
				var partAttachment:ByteArray = ( !part.attachment || !attachZipUtil ) ? null : attachZipUtil.file( part.attachment.fileName );
				
				var attFilename:String = part.attachment == null ? null : part.attachment.fileName;
				_remote.saveEntry( sessionId, part, partSequence, partAttachment, attFilename );
			}
		}
		
		private function savePlasmids( sessionId:String, set:PlasmidSet ) : void
		{
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var plasmid:Plasmid = set.entries.getItemAt( i ) as Plasmid;
				var plasmidSequence:ByteArray = ( !plasmid.sequence || !seqZipUtil ) ? null : seqZipUtil.file( plasmid.sequence.filename );
				var plasmidAttachment:ByteArray = ( !plasmid.attachment || !attachZipUtil ) ? null : attachZipUtil.file( plasmid.attachment.fileName );
				
				var attFilename:String = plasmid.attachment == null ? null : plasmid.attachment.fileName;
				_remote.saveEntry( sessionId, plasmid, plasmidSequence, plasmidAttachment, attFilename );
			}
			
			redirectAfterSave();
		}
		
		private function saveStrains( sessionId:String, set:StrainSet ) : void
		{
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var strain:Strain = set.entries.getItemAt( i ) as Strain;
				var strainSequence:ByteArray = ( !strain.sequence || !seqZipUtil ) ? null : seqZipUtil.file( strain.sequence.filename );
				var strainAttachment:ByteArray = ( !strain.attachment || !attachZipUtil ) ? null : attachZipUtil.file( strain.attachment.fileName );
				
				var attFilename:String = strain.attachment == null ? null : strain.attachment.fileName;
				_remote.saveEntry( sessionId, strain, strainSequence, strainAttachment, attFilename );
			}
			
			redirectAfterSave();
		}
		
		private function saveStrainWithPlasmids( sessionId:String, set:StrainWithPlasmidSet ) : void
		{
			var attachZipUtil:ZipFileUtil = ( !set.attachmentZipfile ) ? null : new ZipFileUtil( set.attachmentZipfile );
			var seqZipUtil:ZipFileUtil = ( !set.sequenceZipfile ) ? null : new ZipFileUtil( set.sequenceZipfile );
			
			for( var i:int = 0; i < set.entries.length; i += 1 )
			{
				var entry:StrainWithPlasmid = set.entries.getItemAt( i ) as StrainWithPlasmid;
				var strain:Strain = entry.strain;				
				var strainSequence:ByteArray = ( !strain.sequence || !seqZipUtil ) ? null : seqZipUtil.file( strain.sequence.filename );
				var strainAttachment:ByteArray = ( !strain.attachment || !attachZipUtil ) ? null : attachZipUtil.file( strain.attachment.fileName );
				var strainAttFilename:String = strain.attachment == null ? null : strain.attachment.fileName;
				
				var plasmid:Plasmid = entry.plasmid;
				var plasmidSequence:ByteArray = ( !plasmid.sequence || !seqZipUtil ) ? null : seqZipUtil.file( plasmid.sequence.filename );
				var plasmidAttachment:ByteArray = ( !plasmid.sequence || !attachZipUtil ) ? null : attachZipUtil.file( plasmid.attachment.fileName );
				var plasmidAttFilename:String = plasmid.attachment == null ? null : plasmid.attachment.fileName;
				
				_remote.saveStrainWithPlasmid( sessionId, strain, plasmid, strainSequence, strainAttachment, 
					strainAttFilename, plasmidSequence, plasmidAttachment, plasmidAttFilename );
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
			Alert.show( event.fault.faultString + "\n\nDetails\n" + event.fault.faultDetail, event.fault.faultCode );
		}
		
		private function onSaveSuccess( event:ResultEvent ) : void
		{
			Alert.show( "Entries have been submitted successfully and are awaiting administrative approval.", "Save",  Alert.OK, null, redirectToFolders );
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