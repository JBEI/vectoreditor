package org.jbei.model.fields
{
	import flash.net.FileReference;
	import flash.profiler.showRedrawRegions;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DateField;
	
	import org.jbei.model.EntryTypeField;
	import org.jbei.model.registry.ArabidopsisSeed;
	import org.jbei.model.registry.EntryFundingSource;
	import org.jbei.model.registry.FundingSource;
	import org.jbei.model.registry.Link;
	import org.jbei.model.registry.Name;
	import org.jbei.model.save.ArabidopsisSet;
	import org.jbei.model.save.EntrySet;
	import org.jbei.view.components.GridCell;
	import org.jbei.view.components.GridRow;
	
	/**
	 * Fields required for the arabidopsis seed entry type
	 */
	public class ArabidopsisFields implements EntryFields
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
		public static const HOMOZYGOSITY:EntryTypeField = new EntryTypeField( HOMOZYGOSITY, "Homozygosity", false ); 
		public static const ECOTYPE:EntryTypeField = new EntryTypeField( ECOTYPE, "Ecotype", false ); 
		public static const HARVEST_DATE:EntryTypeField = new EntryTypeField( HARVEST_DATE, "Harvest Data", false ); 
		public static const GENERATION:EntryTypeField = new EntryTypeField( GENERATION, "Generation", true );
		public static const PLANT_TYPE:EntryTypeField = new EntryTypeField( PLANT_TYPE, "Plant Type", true );
		public static const PARENTS:EntryTypeField = new EntryTypeField( PARENTS, "Parents", false );
		
		private var _fields:ArrayCollection;
		private var _errors:ArrayCollection;
		private var generationValues:Array = [ "M0", "M1", "M2", "T1", "T2", "T3", "T4", "T5" ];
		private var plantTypes:Array = [  "EMS", "OVER_EXPRESSION", "RNAI", "REPORTER", "T_DNA", "OTHER" ];
		private var _set:ArabidopsisSet;
		
		public function set sequenceZipFile( file:FileReference ) : void
		{
		}
		
		public function set attachmentZipFile( file:FileReference ) : void
		{
		}
		
		public function get entrySet() : EntrySet
		{		
			return this._set;
		}
		
		public function get errors() : ArrayCollection
		{
			return this._errors;
		}
		
		public function ArabidopsisFields()
		{
			_fields = new ArrayCollection();
			_errors = new ArrayCollection();
			_set = new ArabidopsisSet();
			
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
			_fields.addItem( HOMOZYGOSITY );
			_fields.addItem( ECOTYPE );
			_fields.addItem( HARVEST_DATE );
			_fields.addItem( GENERATION );
			_fields.addItem( PLANT_TYPE );
			_fields.addItem( PARENTS );
		}
		
		public function extractFromRow( row:GridRow ) : Object
		{
			this._errors.removeAll();
			var results:ArrayCollection = new ArrayCollection();
			var seed:ArabidopsisSeed = new ArabidopsisSeed();
			seed.generation = "";
			seed.homozygosity = "";
			seed.ecotype = "";
			seed.parents = "";
			seed.plantType = "";
			
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
					extractField( field, cell, seed );
				}
			}
			
			return seed;
		}
		
		public function setToRow( currentRowIndex:int, row:GridRow ) : Boolean 
		{
			var seed:ArabidopsisSeed = this.entrySet.entries.getItemAt( 0 ) as ArabidopsisSeed;
			
			for( var j:int = 0; j < this._fields.length; j += 1 )
			{
				var field:EntryTypeField = fields.getItemAt( j ) as EntryTypeField;
				var cell:GridCell = row.cellAt( j );
				
				switch( field )
				{
					case PRINCIPAL_INVESTIGATOR:	
						if( seed.entryFundingSources == null || seed.entryFundingSources.length == 0 )
							break;
						
						var source:EntryFundingSource = seed.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
						cell.text = source.fundingSource.principalInvestigator;
						break;
					
					case FUNDING_SOURCE:
						if( seed.entryFundingSources == null || seed.entryFundingSources.length == 0 )
							break;
						
						var entrySource:EntryFundingSource = seed.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
						cell.text = entrySource.fundingSource.fundingSource;
						break;
					
					case INTELLECTUAL_PROP_INFO:
						cell.text = seed.intellectualProperty;
						break;
					
					case BIO_SAFETY_LEVEL:
						cell.text = String(seed.bioSafetyLevel);
						break;
					
					case NAME:
						var names:ArrayCollection = seed.links;
						if( names == null || names.length == 0 )
							break;
						
						var namesStr:String = "";
						for( var i:int; i < names.length; i ++ )
						{
							var name:Name = names.getItemAt( i ) as Name;
							namesStr += name.name;
							if( i < names.length - 1 )
								namesStr += ",";
						}
						cell.text = namesStr;
						break;
					
					case ALIAS:
						cell.text = seed.alias;
						break;
					
					case KEYWORDS:
						cell.text = seed.keywords;
						break; 
					
					case SUMMARY:
						cell.text = seed.shortDescription;
						break;
					
					case NOTES:
						cell.text = seed.longDescription;
						break;
					
					case REFERENCES:
						cell.text = seed.references;
						break;
					
					case LINKS:
						var links:ArrayCollection = seed.links;
						if( links == null || links.length == 0 )
							break;
						
						var linkStr:String = "";
						for( var l:int; l < links.length; l ++ )
						{
							var link:Link = links.getItemAt( l ) as Link;
							linkStr += link.link;
							if( l < links.length - 1 )
								linkStr += ",";
						}
						cell.text = linkStr;
						break;
					
					case STATUS:
						cell.text = seed.status;
						break;
					
					case HOMOZYGOSITY:
						cell.text = seed.homozygosity;
						break;
					
					case ECOTYPE:
						cell.text = seed.ecotype;
						break;
					
					case PARENTS:
						cell.text = seed.parents;
						break;
					
					case HARVEST_DATE:
						cell.text = String(seed.harvestDate);
						break;
					
					case GENERATION:
						cell.text = seed.generation;
						break;
					
					case PLANT_TYPE:
						cell.text = seed.plantType;
						break;
				}
			}
			return true;
		}
		
		// no sequences for arabidopsis
		public function get sequences() : ArrayCollection
		{
			return null;
		}
		
		public function get attachments() : ArrayCollection
		{
			return null;
		}
		
		private function createFundingSources( seed:ArabidopsisSeed ) : void
		{
			if( seed.entryFundingSources && seed.entryFundingSources.length > 0 )
				return;
			
			var sources:ArrayCollection = new ArrayCollection();				// <EntryFundingSource>
			var fundingSource:FundingSource = new FundingSource();
			fundingSource.fundingSource = "";
			var newEntryFundingSource:EntryFundingSource = new EntryFundingSource();
			newEntryFundingSource.fundingSource = fundingSource;
			newEntryFundingSource.entry = seed;
			sources.addItem( newEntryFundingSource );
			seed.entryFundingSources = sources;
		}
		
		private function extractField( field:EntryTypeField, cell:GridCell, seed:ArabidopsisSeed ) : void
		{
			var value:String = cell.text;
			
			switch( field )
			{
				case PRINCIPAL_INVESTIGATOR:
					createFundingSources( seed );
					var source:EntryFundingSource = seed.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					source.fundingSource.principalInvestigator = value;
					break;
				
				case FUNDING_SOURCE:
					createFundingSources( seed );
					var entrySource:EntryFundingSource = seed.entryFundingSources.getItemAt( 0 ) as EntryFundingSource;
					entrySource.fundingSource.fundingSource = value;
					break;
				
				case INTELLECTUAL_PROP_INFO:
					seed.intellectualProperty = value;
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
						seed.bioSafetyLevel = num;
					}
					break;
				
				case NAME:
					var result:ArrayCollection = new ArrayCollection(); // <Name>
					var names:Array = value.split( /\s*,+\s*/ );
					for( var i:int = 0; i < names.length; i += 1 )
					{
						var nameStr:String = names[i];
						var name:Name = new Name();
						name.entry = seed;
						name.name = nameStr;
						result.addItem( name );
					}
					
					seed.names = result;
					break;
				
				case ALIAS:
					seed.alias = value;
					break;
				
				case KEYWORDS:
					seed.keywords = value;
					break; 
				
				case SUMMARY:
					seed.shortDescription = value;
					break;
				
				case NOTES:
					seed.longDescription = value;
					break;
				
				case REFERENCES:
					seed.references = value;
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
					seed.links = result2;
					break;
				
				case STATUS:
					var comp:String = value.toLowerCase();
					// TODO : "magic" strings
					if( comp == "complete" || comp == "in progress" || comp == "planned" )
						seed.status = comp;
					else
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of [Complete, In Progress, Planned]" ) );
					break;
				
				case HOMOZYGOSITY:
					seed.homozygosity = value;
					break;
				
				case ECOTYPE:
					seed.ecotype = value;
					break;
				
				case PARENTS:
					seed.parents = value;
					break;
				
				case HARVEST_DATE:
					var format:String = "MM/DD/YYYY";
					var date:Date = DateField.stringToDate( value, format );
					if( date == null )
						this._errors.addItem( new FieldCellError( cell, field.name + "'s format must be " + format ) );
					else
						seed.harvestDate = date;
					break;
				
				case GENERATION:
					var generation:String = value.toUpperCase();
					if( generationValues.indexOf( generation ) == -1 )
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of " + generationValues.join( ", " ) ) );
					else
						seed.generation = generation;
					break;
				
				case PLANT_TYPE:
					var plantType:String = value.toUpperCase();
					if( plantTypes.indexOf( plantType ) == -1 )
						this._errors.addItem( new FieldCellError( cell, field.name + "'s value must be one of " + plantTypes.join( ", " ) ) );
					else
						seed.plantType = plantType;
					break;
			}
		}
		
		public function get fields():ArrayCollection
		{
			return _fields;
		}
	}
}
