package org.jbei.model.fields
{
	import flash.net.FileReference;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.registry.Attachment;
	import org.jbei.model.registry.EntryFundingSource;
	import org.jbei.model.registry.FundingSource;
	import org.jbei.model.registry.Link;
	import org.jbei.model.registry.Name;
	import org.jbei.model.registry.Part;
	import org.jbei.model.registry.Sequence;
	import org.jbei.model.save.EntrySet;
	import org.jbei.model.save.PartSet;
	import org.jbei.model.util.ZipFileUtil;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRow;
	
	public class PartFields implements EntryFields
	{
		public static const PRINCIPAL_INVESTIGATOR:EntryTypeField = new EntryTypeField( PRINCIPAL_INVESTIGATOR, "Principal Investigator", true ); 		
		public static const FUNDING_SOURCE:EntryTypeField = new EntryTypeField( FUNDING_SOURCE, "Funding Source", false );
		public static const INTELLECTUAL_PROP_INFO:EntryTypeField = new EntryTypeField( INTELLECTUAL_PROP_INFO, "Intellectual Property", false );
		public static const BIO_SAFETY_LEVEL:EntryTypeField = new EntryTypeField( BIO_SAFETY_LEVEL, "Bio Safety Level", true );
		public static const NAME:EntryTypeField = new EntryTypeField( NAME, "Name", true ); 
		public static const ALIAS:EntryTypeField = new EntryTypeField( ALIAS, "Alias", false );		
		public static const KEYWORDS:EntryTypeField = new EntryTypeField( KEYWORDS, "Keywords", false );		
		public static const SUMMARY:EntryTypeField = new EntryTypeField( SUMMARY, "Summary", true ); 
		public static const NOTES:EntryTypeField = new EntryTypeField( NOTES, "Notes", false ); 
		public static const REFERENCES:EntryTypeField = new EntryTypeField( REFERENCES, "References", false );
		public static const LINKS:EntryTypeField = new EntryTypeField( LINKS, "Links", false );
		public static const STATUS:EntryTypeField = new EntryTypeField( STATUS, "Status", true );
		public static const SEQUENCE_FILENAME:EntryTypeField = new EntryTypeField( SEQUENCE_FILENAME, "Sequence FileName", false ); 
		public static const ATTACHMENT_FILENAME:EntryTypeField = new EntryTypeField( ATTACHMENT_FILENAME, "Attachment FileName", false );
		
		private var _fields:ArrayCollection;
		private var _seqZip:ZipFileUtil;
		private var _errors:ArrayCollection;
		private var _set:PartSet;
		
		public function get entrySet() : EntrySet
		{		
			return this._set;
		}
		
		public function set sequenceZipFile( file:FileReference ) : void
		{
			_seqZip = new ZipFileUtil( file );
		}
		
		public function set attachmentZipFile( file:FileReference ) : void
		{
		}
		
		public function get errors() : ArrayCollection
		{
			return _errors;
		}
		
		public function PartFields()
		{
			_errors = new ArrayCollection();
			_fields = new ArrayCollection();
			_set = new PartSet();
			
			_fields.addItem( PRINCIPAL_INVESTIGATOR );
			_fields.addItem( FUNDING_SOURCE );
			_fields.addItem( INTELLECTUAL_PROP_INFO );
			_fields.addItem( BIO_SAFETY_LEVEL );
			_fields.addItem( NAME );
			_fields.addItem( ALIAS );
			_fields.addItem( KEYWORDS );
			_fields.addItem( SUMMARY );
			_fields.addItem( NOTES );
			_fields.addItem( REFERENCES );
			_fields.addItem( LINKS );
			_fields.addItem( STATUS );
			_fields.addItem( SEQUENCE_FILENAME );
			_fields.addItem( ATTACHMENT_FILENAME );	
		}
		
		public function extractFromRow( row:GridRow ) : Object
		{
			this._errors.removeAll();
			
			var results:ArrayCollection = new ArrayCollection();
			var part:Part = new Part();
			part.packageFormat = "Raw";
			
			for( var j:int = 0; j < this._fields.length; j += 1 )
			{
				var field:EntryTypeField = fields.getItemAt( j ) as EntryTypeField;
				var cell:GridCell = row.cellAt( j );
				var value:String = cell.text;
				
				if( value.length == 0 )
				{
					if( field.required )
					{
						this._errors.addItem( new FieldCellError( cell, field.name + " is required and cannot be empty." ) );
					}
					continue;
				}
				else 
				{
					extractField( field, cell, part );
				}
			}
			
			return part;
		}
		
		private function createFundingSources( part:Part ) : void
		{
			if( part.entryFundingSources && part.entryFundingSources.length > 0 )
				return;
			
			var sources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
			var fundingSource:FundingSource = new FundingSource();
			fundingSource.fundingSource = "";
			var newEntryFundingSource:EntryFundingSource = new EntryFundingSource();
			newEntryFundingSource.fundingSource = fundingSource;
			newEntryFundingSource.entry = part;
			sources.addItem( newEntryFundingSource );
			part.entryFundingSources = sources;
		}
		
		private function extractField( field:EntryTypeField, cell:GridCell, part:Part ) : void
		{
			var value:String = cell.text;
			
			switch( field )
			{
				case PRINCIPAL_INVESTIGATOR:
					createFundingSources( part );
					var source:EntryFundingSource = part.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					source.fundingSource.principalInvestigator = value;
					break;
				
				case FUNDING_SOURCE:
					createFundingSources( part );
					var entrySource:EntryFundingSource = part.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					entrySource.fundingSource.fundingSource = value;
					break;
				
				case INTELLECTUAL_PROP_INFO:
					part.intellectualProperty = value;
					break;
				
				case BIO_SAFETY_LEVEL:
					if( isNaN( Number( value ) ) )
					{
						this._errors.addItem( new FieldCellError( cell, "Value must be '1' or '2'" ) );
						break;
					}
					else
					{
						var num:int = parseInt( value );
						if( num < 1 || num > 2 )
						{
							this._errors.addItem( new FieldCellError( cell, "Value must be '1' or '2'" ) );
							break;
						}
						part.bioSafetyLevel = num;
					}
					break;
				
				case NAME:
					var result:ArrayCollection = new ArrayCollection(); // <Name>
					var names:Array = value.split( /\s*, +\s*/ );
					for( var i:int = 0; i < names.length; i += 1 )
					{
						var nameStr:String = names[i];
						var name:Name = new Name();
						name.name = nameStr;
						result.addItem( name );
					}
					
					part.names = result;
					break;
				
				case ALIAS:
					part.alias = value;
					break;
				
				case KEYWORDS:
					part.keywords = value;
					break; 
				
				case SUMMARY:
					part.shortDescription = value;
					break;
				
				case NOTES:
					part.longDescription = value;
					break;
				
				case REFERENCES:
					part.references = value;
					break;
				
				case LINKS:
					var result2:ArrayCollection = new ArrayCollection(); // <Link>
					var links:Array = value.split( /\s*,+\s*/ );
					for( var linkIter:int = 0; linkIter < links.length; linkIter += 1 )
					{
						var linkStr:String = links[linkIter];
						var link:Link = new Link();
						link.link = linkStr;
						result2.addItem( link );
					}
					part.links = result2;
					break;
				
				case STATUS:
					var comp:String = value.toLowerCase();
					// TODO : "magic" strings
					if( comp == "complete" || comp == "in progress" || comp == "planned" )
						part.status = comp;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;
				
				case SEQUENCE_FILENAME:
					if( !this._seqZip && value.length > 0 )
						this._errors.addItem( new FieldCellError( cell, "Please upload sequence zip archive!" ) );
					else if( value.length > 0 && ( this._seqZip && !this._seqZip.containsFile( value ) ) )
						this._errors.addItem( new FieldCellError( cell, "File with name " + value + " not found in zip archive!" ) );
					else
					{
						var seq:Sequence = new Sequence();
						seq.filename = value;
						seq.sequenceUser = value;
						part.sequence = seq;
					}
					break;
				
				case ATTACHMENT_FILENAME:
					var attachment:Attachment = new Attachment();
					attachment.fileName = value;
					attachment.entry = part;
					part.attachment = attachment;
					break;
			}
		}
		
		public function get fields():ArrayCollection
		{
			return _fields;
		}
	}
}
