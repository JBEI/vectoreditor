package org.jbei.components.sequenceClasses
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.bio.data.ORF;
	import org.jbei.components.common.Alignment;
	
	public class RowMapper
	{
		private var contentHolder:ContentHolder;
		
		private var _rows:Array /* of Row */;
		private var _featureToRowMap:Dictionary; /* of [Feature] = Array(Row, Row, ...) */
		private var _cutSiteToRowMap:Dictionary; /* of [CutSite] = Array(Row, Row, ...) */
		private var _orfToRowMap:Dictionary; /* of [ORF] = Array(Row, Row, ...) */
		private var _showORFs:Boolean = false;
		private var numRows:int = 0;
		
		// Contructor
		public function RowMapper(contentHolder:ContentHolder)
		{
			this.contentHolder = contentHolder;
		}
		
		// Properties
		public function get featureToRowMap():Dictionary
		{
			return _featureToRowMap;
		}
		
		public function get cutSiteToRowMap():Dictionary
		{
			return _cutSiteToRowMap;
		}
		
		public function get orfToRowMap():Dictionary
		{
			return _orfToRowMap;
		}
		
		public function get rows():Array /* of Row */
		{
			return _rows;
		}
		
		// Public Methods
		public function update():void
		{
			_rows = new Array();
			
			numRows = int(Math.ceil(((contentHolder.featuredSequence.sequence.length + 1) / contentHolder.bpPerRow)));
			
			for(var i:int = 0; i < numRows; i++) {
				var start:int = i * contentHolder.bpPerRow;
				var end:int = (i + 1) * contentHolder.bpPerRow - 1;
				
				var sequence:String = contentHolder.featuredSequence.sequence.sequence.substring(start, end + 1);
				var oppositeSequence:String = contentHolder.featuredSequence.oppositeSequence.sequence.substring(start, end + 1);
				
				var row:Row = new Row(i, new RowData(start, end, sequence, oppositeSequence));
				_rows.push(row);
			}
			
			reloadFeatures();
			reloadORFs();
			reloadCutSites();
		}
		
		// Private Methods
		private function reloadFeatures():void
		{
			if(!contentHolder.showFeatures || !contentHolder.featuredSequence.features) { return; }
			
			var rowsFeatures:Array = rowAnnotations(contentHolder.featuredSequence.features);
			
			_featureToRowMap = new Dictionary();
			
			for(var k:int = 0; k < contentHolder.featuredSequence.features.length; k++) {
				var feature:Feature = contentHolder.featuredSequence.features[k];
				
				_featureToRowMap[feature] = null;
			}
			
			for(var i:int = 0; i < numRows; i++) {
				var start:int = i * contentHolder.bpPerRow;
				var end:int = (i + 1) * contentHolder.bpPerRow - 1;
				
				var featuresAlignment:Alignment = new Alignment(rowsFeatures[i] as Array, contentHolder.featuredSequence);
				
				(_rows[i] as Row).rowData.featuresAlignment = featuresAlignment.rows;
				
				var rowOwnedFeatures:Array = rowsFeatures[i] as Array;
				
				if(rowOwnedFeatures == null) { continue; }
				
				for(var j:int = 0; j < rowOwnedFeatures.length; j++) {
					var rowFeature:Feature = rowOwnedFeatures[j] as Feature;
					
					if(!_featureToRowMap[rowFeature]) {
						_featureToRowMap[rowFeature] = new Array();
					}
					
					(_featureToRowMap[rowFeature] as Array).push(i);
				}
			}
		}
		
		private function reloadCutSites():void
		{
			if(!contentHolder.showCutSites || !contentHolder.restrictionEnzymeMapper || !contentHolder.restrictionEnzymeMapper.cutSites) { return; }
			
			_cutSiteToRowMap = new Dictionary();
			
			var rowsCutSites:Array = rowAnnotations(contentHolder.restrictionEnzymeMapper.cutSites);
			
			for(var k:int = 0; k < contentHolder.restrictionEnzymeMapper.cutSites.length; k++) {
				var cutSite:CutSite = contentHolder.restrictionEnzymeMapper.cutSites[k];
				
				_cutSiteToRowMap[cutSite] = null;
			}
			
			for(var i:int = 0; i < numRows; i++) {
				var start:int = i * contentHolder.bpPerRow;
				var end:int = (i + 1) * contentHolder.bpPerRow - 1;
				
				var cutSitesAlignment:Alignment = new Alignment(rowsCutSites[i] as Array, contentHolder.featuredSequence);
				
				(_rows[i] as Row).rowData.cutSitesAlignment = cutSitesAlignment.rows;
				
				var rowOwnedCutSite:Array = rowsCutSites[i] as Array;
				
				if(rowOwnedCutSite == null) { continue; }
				
				for(var j:int = 0; j < rowOwnedCutSite.length; j++) {
					var rowCutSite:CutSite = rowOwnedCutSite[j] as CutSite;
					
					if(!_cutSiteToRowMap[rowCutSite]) {
						_cutSiteToRowMap[rowCutSite] = new Array();
					}
					
					(_cutSiteToRowMap[rowCutSite] as Array).push(i);
				}
			}
		}
		
		private function reloadORFs():void
		{
			if(!contentHolder.showORFs || !contentHolder.orfMapper || ! contentHolder.orfMapper.orfs) { return; }
			
			_orfToRowMap = new Dictionary();
			
			var rowsOrfs:Array = rowAnnotations(contentHolder.orfMapper.orfs);
			
			for(var k:int = 0; k < contentHolder.orfMapper.orfs.length; k++) {
				var orf:ORF = contentHolder.orfMapper.orfs[k];
				
				_orfToRowMap[orf] = null;
			}
			
			for(var i:int = 0; i < numRows; i++) {
				var start:int = i * contentHolder.bpPerRow;
				var end:int = (i + 1) * contentHolder.bpPerRow - 1;
				
				var orfsAlignment:Alignment = new Alignment(rowsOrfs[i] as Array, contentHolder.featuredSequence);
				
				(_rows[i] as Row).rowData.orfAlignment = orfsAlignment.rows;
				
				var rowOwnedOrfs:Array = rowsOrfs[i] as Array;
				
				if(rowOwnedOrfs == null) { continue; }
				
				for(var j:int = 0; j < rowOwnedOrfs.length; j++) {
					var rowORF:ORF = rowOwnedOrfs[j] as ORF;
					
					if(!_orfToRowMap[rowORF]) {
						_orfToRowMap[rowORF] = new Array();
					}
					
					(_orfToRowMap[rowORF] as Array).push(i);
				}
			}
		}
		
		private function rowAnnotations(annotations:ArrayCollection /* IAnnotation */):Array /* of Array of IAnnotation */
		{
			var rows:Array = new Array();
			
			var numRows:int = int(Math.ceil((contentHolder.featuredSequence.sequence.length / contentHolder.bpPerRow)));
			
			if(annotations != null) {
				for(var j:int = 0; j < numRows; j++) {
					rows.push(new Array());
				}
				
				var numberOfItems:int = annotations.length;
				for(var i:int = 0; i < numberOfItems; i++) {
					var annotation:IAnnotation = annotations[i] as IAnnotation;
					
					if(annotation.start > annotation.end) {
						var rowStartIndex1:int = int(annotation.start / contentHolder.bpPerRow);
						var rowEndIndex1:int = int((contentHolder.featuredSequence.sequence.length - 1) / contentHolder.bpPerRow);
						
						var rowStartIndex2:int = 0;
						var rowEndIndex2:int = int(annotation.end / contentHolder.bpPerRow);
						
						for(var z1:int = rowStartIndex1; z1 < rowEndIndex1 + 1; z1++) {
							(rows[z1] as Array).push(annotation);
						}
						
						for(var z2:int = rowStartIndex2; z2 < rowEndIndex2 + 1; z2++) {
							(rows[z2] as Array).push(annotation);
						}
					} else {
						var rowStartIndex:int = int(annotation.start / contentHolder.bpPerRow);
						var rowEndIndex:int = int(annotation.end / contentHolder.bpPerRow);
						
						for(var z:int = rowStartIndex; z < rowEndIndex + 1; z++) {
							(rows[z] as Array).push(annotation);
						}
					}
				}
			}
			
			return rows;
		}
	}
}
