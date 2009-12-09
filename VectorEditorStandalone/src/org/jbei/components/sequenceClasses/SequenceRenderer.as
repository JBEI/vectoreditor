package org.jbei.components.sequenceClasses
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.UIComponent;
	
	import org.jbei.bio.data.AminoAcid;
	import org.jbei.bio.utils.AminoAcidsHelper;
	
	public class SequenceRenderer extends UIComponent
	{
		private var contentHolder:ContentHolder;
		
		private var _totalHeight:int = 0;
		private var _totalWidth:int = 0;
		
		private var needsMeasurement:Boolean = false;
		
		// Contructor
		public function SequenceRenderer(contentHolder:ContentHolder)
		{
			super();
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			this.contentHolder = contentHolder;
		}
		
		// Properties
		public function get totalHeight():int
		{
			return _totalHeight;
		}
		
		public function get totalWidth():int
		{
			return _totalWidth;
		}
		
		// Public Methods
		public function update():void
		{
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		// Protected Methods
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				if(contentHolder.featuredSequence) {
					render();
				}
			}
		}
		
		// Private Methods
		private function onRollOver(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.IBEAM;
			
			stage.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function render():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			_totalWidth = 0;
			_totalHeight = 0;
			
			if(! contentHolder.featuredSequence) { return; }
			
			var sequence:String = contentHolder.featuredSequence.sequence.sequence;
			
			var rows:Array = contentHolder.rowMapper.rows as Array /* of Row */;
			
			var sequenceNucleotideMatrix:Matrix = new Matrix();
			for(var i:int = 0; i < rows.length; i++) {
				var row:Row = rows[i] as Row;
				
				var rowX:Number = 0;
				var rowY:Number = _totalHeight;
				
				var sequenceString:String = "";
				sequenceString += renderIndexString(row.rowData.start + 1) + " ";	// Rendering index first 
				
				if(contentHolder.showSpaceEvery10Bp) {
					sequenceString += splitWithSpaces(row.rowData.sequence); // Rendering sequence itself with spaces every 10bp
				} else {
					sequenceString += row.rowData.sequence; // Rendering sequence without spaces every 10bp
				}
				
				var sequenceStringLength:int = sequenceString.length;
				
				// RestrictionEnzymes
				if(contentHolder.showCutSites) {
					if(row.rowData.cutSitesAlignment && row.rowData.cutSitesAlignment.length > 0) {
						_totalHeight += row.rowData.cutSitesAlignment.length * contentHolder.cutSiteTextRenderer.textHeight;
					}
				}
				
				// AminoAcids 3
				if(contentHolder.showAminoAcids3) {
					renderAA(row, true);
				}
				
				// AminoAcids 1
				if(contentHolder.showAminoAcids1) {
					renderAA(row, false);
				}
				
				// ORFs
				if(contentHolder.showORFs && row.rowData.orfAlignment) {
					_totalHeight += row.rowData.orfAlignment.length * 6;
				}
				
				var sequenceX:Number = 6 * contentHolder.sequenceSymbolRenderer.textWidth;
				var sequenceY:Number = _totalHeight;
				
				// Sequence
				for(var j:int = 0; j < sequenceStringLength; j++) {
					var nucleotideSymbolBitmap:BitmapData = contentHolder.sequenceSymbolRenderer.textToBitmap(sequenceString.charAt(j));
					
					var nucleotidesLeftShift:int = j * nucleotideSymbolBitmap.width;
					sequenceNucleotideMatrix.tx += nucleotidesLeftShift;
					sequenceNucleotideMatrix.ty += _totalHeight;
					
					g.beginBitmapFill(nucleotideSymbolBitmap, sequenceNucleotideMatrix, false);
					g.drawRect(nucleotidesLeftShift, _totalHeight, nucleotideSymbolBitmap.width, nucleotideSymbolBitmap.height);
					g.endFill();
					
					sequenceNucleotideMatrix.tx -= nucleotidesLeftShift;
					sequenceNucleotideMatrix.ty -= _totalHeight;
				}
				
				if(_totalWidth < contentHolder.sequenceSymbolRenderer.textWidth * sequenceStringLength) {
					_totalWidth = contentHolder.sequenceSymbolRenderer.textWidth * sequenceStringLength;
				}
				_totalHeight += contentHolder.sequenceSymbolRenderer.textHeight;
				
				var sequenceWidth:Number = sequenceStringLength * contentHolder.sequenceSymbolRenderer.textWidth - sequenceX;
				var sequenceHeight:Number = _totalHeight - sequenceY;
				
				// Complementary Sequence
				if(contentHolder.showComplementary) {
					renderComplementarySequence(row);
					
					sequenceHeight = _totalHeight - sequenceY;
				}
				
				// Features
				if(contentHolder.showFeatures) {
					if(row.rowData.featuresAlignment && row.rowData.featuresAlignment.length > 0) {
						_totalHeight += row.rowData.featuresAlignment.length * (FeatureRenderer.DEFAULT_FEATURE_HEIGHT + FeatureRenderer.DEFAULT_FEATURES_GAP) + 2;
					}
				}
				
				_totalHeight += 3; // to look pretty
				
				var rowWidth:Number = _totalWidth;
				var rowHeight:Number = _totalHeight - rowY;
				
				row.metrics = new Rectangle(rowX, rowY, rowWidth, rowHeight);
				row.sequenceMetrics = new Rectangle(sequenceX, sequenceY, sequenceWidth, sequenceHeight);
			}
		}
		
		private function renderAA(row:Row, isAA3:Boolean):void
		{
			var sequence:String = contentHolder.featuredSequence.sequence.sequence;
			var rowSequence:String = row.rowData.sequence;
			
			var aminoAcidsString1:String = '';
			var aminoAcidsString2:String = '';
			var aminoAcidsString3:String = '';
			for(var i:int = 0; i < rowSequence.length; i++) {
				var basePairs:String;
				
				if(contentHolder.featuredSequence.circular) {
					if(sequence.length < 3) {
						basePairs = "-";
					} else {
						if(row.rowData.start + i == sequence.length - 2) { 
							basePairs = sequence.charAt(row.rowData.start + i) + sequence.charAt(row.rowData.start + i + 1) + sequence.charAt(0);
						} else if(row.rowData.start + i == sequence.length - 1) {
							basePairs = sequence.charAt(row.rowData.start + i) + sequence.charAt(0) + sequence.charAt(1);
						} else {
							basePairs = sequence.charAt(row.rowData.start + i) + sequence.charAt(row.rowData.start + i + 1) + sequence.charAt(row.rowData.start + i + 2);
						}
					}
				} else {
					if(row.rowData.start + i + 2 > sequence.length - 1) { 
						basePairs = "-"
					} else {
						basePairs = sequence.charAt(row.rowData.start + i) + sequence.charAt(row.rowData.start + i + 1) + sequence.charAt(row.rowData.start + i + 2);
					}
				}
				
				var aminoAcid:AminoAcid = AminoAcidsHelper.instance.aminoAcidFromBP(basePairs);
				
				var aa:String;
				if(isAA3) {
					aa = (! aminoAcid) ? '---' : aminoAcid.name3;
				} else {
					aa = (! aminoAcid) ? '-  ' : aminoAcid.name1 + '  ';
				}
				
				if(i == 0 || (i % 3) == 0) {
					aminoAcidsString1 += aa;
				} else if(i == 1 || ((i + 2) % 3 == 0)) {
					aminoAcidsString2 += aa;
				} else if(i == 2 || ((i + 1) % 3 == 0)) {
					aminoAcidsString3 += aa;
				}
			}
			
			if(contentHolder.showSpaceEvery10Bp) {
				aminoAcidsString1 = splitWithSpaces(aminoAcidsString1, 10, false);
				aminoAcidsString2 = splitWithSpaces(aminoAcidsString2, 9, false);
				aminoAcidsString3 = splitWithSpaces(aminoAcidsString3, 8, false);
			}
			
			var g:Graphics = graphics;
			var aminoAcidRenderMatrix:Matrix = new Matrix();
			
			// Render first row of AA3
			for(var j1:int = 0; j1 < aminoAcidsString1.length; j1++) {
				var aminoAcidSymbolBitmap1:BitmapData = contentHolder.aminoAcidsTextRenderer.textToBitmap(aminoAcidsString1.charAt(j1));
				
				var leftShift1:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + j1 * aminoAcidSymbolBitmap1.width;
				
				aminoAcidRenderMatrix.tx += leftShift1;
				aminoAcidRenderMatrix.ty += _totalHeight;
				
				g.beginBitmapFill(aminoAcidSymbolBitmap1, aminoAcidRenderMatrix, false);
				g.drawRect(leftShift1, _totalHeight, aminoAcidSymbolBitmap1.width, aminoAcidSymbolBitmap1.height);
				g.endFill();
				
				aminoAcidRenderMatrix.tx -= leftShift1;
				aminoAcidRenderMatrix.ty -= _totalHeight;
			}
			
			_totalHeight += contentHolder.aminoAcidsTextRenderer.textHeight;
			
			// Render second row of AA3
			for(var j2:int = 0; j2 < aminoAcidsString2.length; j2++) {
				var aminoAcidSymbolBitmap2:BitmapData = contentHolder.aminoAcidsTextRenderer.textToBitmap(aminoAcidsString2.charAt(j2));
				
				var leftShift2:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + (j2 + 1) * aminoAcidSymbolBitmap2.width;
				
				aminoAcidRenderMatrix.tx += leftShift2;
				aminoAcidRenderMatrix.ty += _totalHeight;
				
				g.beginBitmapFill(aminoAcidSymbolBitmap2, aminoAcidRenderMatrix, false);
				g.drawRect(leftShift2, _totalHeight, aminoAcidSymbolBitmap2.width, aminoAcidSymbolBitmap2.height);
				g.endFill();
				
				aminoAcidRenderMatrix.tx -= leftShift2;
				aminoAcidRenderMatrix.ty -= _totalHeight;
			}
			
			_totalHeight += contentHolder.aminoAcidsTextRenderer.textHeight;
			
			// Render third row of AA3
			for(var j3:int = 0; j3 < aminoAcidsString3.length; j3++) {
				var aminoAcidSymbolBitmap3:BitmapData = contentHolder.aminoAcidsTextRenderer.textToBitmap(aminoAcidsString3.charAt(j3));
				
				var leftShift3:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + (j3 + 2) * aminoAcidSymbolBitmap3.width;
				
				aminoAcidRenderMatrix.tx += leftShift3;
				aminoAcidRenderMatrix.ty += _totalHeight;
				
				g.beginBitmapFill(aminoAcidSymbolBitmap3, aminoAcidRenderMatrix, false);
				g.drawRect(leftShift3, _totalHeight, aminoAcidSymbolBitmap3.width, aminoAcidSymbolBitmap3.height);
				g.endFill();
				
				aminoAcidRenderMatrix.tx -= leftShift3;
				aminoAcidRenderMatrix.ty -= _totalHeight;
			}
			
			_totalHeight += contentHolder.aminoAcidsTextRenderer.textHeight;
		}
		
		private function renderComplementarySequence(row:Row):void
		{
			var sequenceString:String = "      ";
			
			if(contentHolder.showSpaceEvery10Bp) {
				sequenceString += splitWithSpaces(row.rowData.oppositeSequence);
			} else {
				sequenceString += row.rowData.oppositeSequence;
			}
			
			var stringLength:int = sequenceString.length;
			var nucleotideMatrix:Matrix = new Matrix();
			
			var g:Graphics = graphics;
			
			for(var i:int = 0; i < stringLength; i++) {
				var complimentarySymbolBitmap:BitmapData = contentHolder.complimentarySymbolRenderer.textToBitmap(sequenceString.charAt(i));
				
				var leftShift:int = i * complimentarySymbolBitmap.width;
				
				nucleotideMatrix.tx += leftShift;
				nucleotideMatrix.ty += _totalHeight;
				
				g.beginBitmapFill(complimentarySymbolBitmap, nucleotideMatrix, false);
				g.drawRect(leftShift, _totalHeight, complimentarySymbolBitmap.width, complimentarySymbolBitmap.height);
				g.endFill();
				
				nucleotideMatrix.tx -= leftShift;
				nucleotideMatrix.ty -= _totalHeight;
			}
			
			_totalHeight += contentHolder.complimentarySymbolRenderer.textHeight;
		}
		
		private function renderIndexString(index:int):String
		{
			var result:String = String(index);
			
			if(index < 10) {
				result = "    " + result;
			} else if(index < 100) {
				result = "   " + result;
			} else if(index < 1000) {
				result = "  " + result;
			} else if(index < 10000) {
				result = " " + result;
			}
			
			return result;
		}
		
		private function splitWithSpaces(string:String, firstSplitShift:int = 10, splitLast:Boolean = true):String
		{
			var result:String = "";
			
			var stringLength:int = string.length;
			
			if(stringLength <= 10) {
				result += string;
			} else {
				var start:int = 0;
				var end:int = firstSplitShift;
				while(start < stringLength) {
					result += string.substring(start, end);
					
					start += (start == 0) ? firstSplitShift : 10;
					end = start + 10;
					
					if(start < stringLength) {
						if(end <= stringLength) {
							result += " ";
						} else {
							if(splitLast) {
								result += " ";
							}
						}
					}
				}
			}
			
			return result;
		}
	}
}
