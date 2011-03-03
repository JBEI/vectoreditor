package org.jbei.model
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
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
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.PartSet;
	import org.jbei.model.save.PlasmidSet;
	import org.jbei.model.save.StrainSet;
	import org.jbei.model.save.StrainWithPlasmidSet;
	import org.jbei.model.util.EntryFieldUtils;
	import org.jbei.model.util.ZipFileUtil;
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
		
		public function RegistryAPIProxy()
		{
			super( NAME );
			init();
		}
		
		public function submitForSave( set:EntrySet ) : void
		{
			var sessionId:String = ApplicationFacade.getInstance().sessionId;
			_saveRemainder = set.entries.length;
			_failureCount = 0;
			
			switch( set.type )
			{
				case EntryType.STRAIN_WITH_PLASMID:
					var strainWithPlasmidSet:StrainWithPlasmidSet = set as StrainWithPlasmidSet;
					this.saveStrainWithPlasmids( sessionId, strainWithPlasmidSet );
					break;
				
				case EntryType.ARABIDOPSIS:
					var seedSet:ArabidopsisSet = set as ArabidopsisSet;
					this.saveArabidopsis( sessionId, seedSet );
					break;
				
				case EntryType.PART:
					var partSet:PartSet = set as PartSet;
					this.saveParts( sessionId, partSet );
					break;
				
				case EntryType.PLASMID:
					var plasmidSet:PlasmidSet = set as PlasmidSet;
					this.savePlasmids( sessionId, plasmidSet );
					break;
				
				case EntryType.STRAIN:
					var strainSet:StrainSet = set as StrainSet;
					this.saveStrains( sessionId, strainSet );
					break;
			}
		}
		
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
		}
		
		private function redirect( event:CloseEvent ) : void
		{
			if( this._redirectURL )
				navigateToURL( new URLRequest( this._redirectURL + "/folders" ), "_self" );
			else
				sendNotification( Notifications.RESET_APP );
		}
		
		public function loadParts() : void
		{
			var arrayCollection:ArrayCollection = new ArrayCollection();
			arrayCollection.addItem( EntryType.STRAIN );
			arrayCollection.addItem( EntryType.PLASMID );
			arrayCollection.addItem( EntryType.STRAIN_WITH_PLASMID );
			arrayCollection.addItem( EntryType.PART );
			arrayCollection.addItem( EntryType.ARABIDOPSIS );
			
			sendNotification( Notifications.PART_TYPES_AVAILABLE, arrayCollection );
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
		
		public function loadEntryFields( type:EntryType ) : void
		{
			var entryFields:EntryFields = EntryFieldsFactory.fieldsForType( type );
			sendNotification( Notifications.PART_TYPE_FIELDS_LOADED, entryFields );
		}
		
		private function onSaveFailure( event:FaultEvent ) : void
		{
			trace( "entries save failed: " + event.fault ); 
			Alert.show( "Server error saving entries: " + event.fault.faultString, "Entry Save", Alert.OK );
		}
		
		private function onEntrySave( event:ResultEvent ) : void
		{
			this._saveRemainder -= 1;
			trace( "now left with " + _saveRemainder + " to save." );
			
			var ret:Entry = event.result as Entry;	 // TODO : collect?
			if( ret == null )
				_failureCount += 1;
				
			// feedback
			if( this._saveRemainder == 0 )
			{
				if( _failureCount > 0 )
				{
					trace( "There appears to be a problem saving the entries. " );
					Alert.show( "There appears to be a problem saving " + _failureCount + " of the entries. Please contact your administrator", "Save",  Alert.OK );
				}
				else
				{
					Alert.show( "Entries saved successfully", "Save",  Alert.OK, null, redirect );
				}
			}
		}
		
		private function init() : void
		{
			_remote = new RemoteObject( ApplicationFacade.REMOTE_SERVICE_NAME );
			
			// retrieving the unique values
			_remote.getUniqueOriginOfReplications.addEventListener( ResultEvent.RESULT, uniqueOrigins );
			_remote.getUniqueSelectionMarkers.addEventListener( ResultEvent.RESULT, uniqueMarkers );
			_remote.getUniquePromoters.addEventListener( ResultEvent.RESULT, uniquePromoters );
			
			_remote.getUniqueOriginOfReplications();
			_remote.getUniquePromoters();
			_remote.getUniqueSelectionMarkers();
			
			var url:String = FlexGlobals.topLevelApplication.url;
			_redirectURL = ( url.substr(0, url.indexOf( "/", 8 ) ) );
			
			// events listeners for remote
			_remote.saveEntry.addEventListener( "fault", onSaveFailure ); 
			_remote.saveEntry.addEventListener( ResultEvent.RESULT, onEntrySave );
		}
		
		// catch-all for all auto-complete data
		// checks to ensure that the needed ones are loaded and then sends a notification
		private function autoCompleteData() : void
		{
			if( this._uniquePromoters != null && this._uniqueOriginReplications != null
				&& this._uniqueSelectionMarkers != null )
			{
				sendNotification( Notifications.AUTO_COMPLETE_DATA );
			}
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