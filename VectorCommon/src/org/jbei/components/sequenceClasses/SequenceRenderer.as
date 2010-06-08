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
			
			var sequence:String = contentHolder.featuredSequence.sequence.seqString();
			
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
						_totalHeight += row.rowData.cutSitesAlignment.length * contentHolder.cutSiteTextRenderer.textHeight + 3;
					}
				}
				
				// AminoAcids 3
				if(contentHolder.showAminoAcids3) {
					//renderAA(row, true);
					renderAA(row);
				}
				
				// AminoAcids 1
				if(contentHolder.showAminoAcids1) {
					//renderAA(row, false);
					renderAA(row);
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
				
				// AminoAcids 1 RevCom
				if(contentHolder.showAminoAcids1RevCom) {
					renderAARevCom(row);
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
		
		private function renderAA(row:Row):void
		{
			var aa1:String = contentHolder.aaMapper.sequenceAA1Frame1Sparse;
			var aa2:String = " " + contentHolder.aaMapper.sequenceAA1Frame2Sparse;
			var aa3:String = "  " + contentHolder.aaMapper.sequenceAA1Frame3Sparse;
			
			var start:int = row.rowData.start;
			var end:int = row.rowData.end;
			
			var aminoAcidsString1:String = aa1.substring(start, end + 1);
			var aminoAcidsString2:String = aa2.substring(start, end + 1);
			var aminoAcidsString3:String = aa3.substring(start, end + 1);
			
			var numberOfSpaces:int = 0;
			
			if(contentHolder.showSpaceEvery10Bp) {
				aminoAcidsString1 = splitWithSpaces(aminoAcidsString1, 0, false);
				aminoAcidsString2 = splitWithSpaces(aminoAcidsString2, 0, false);
				aminoAcidsString3 = splitWithSpaces(aminoAcidsString3, 0, false);
				
				numberOfSpaces = (row.rowData.sequence.length % 10) ? int(row.rowData.sequence.length / 10) : (int(row.rowData.sequence.length / 10) - 1);
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
				
				var leftShift2:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + j2 * aminoAcidSymbolBitmap2.width;
				
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
				
				var leftShift3:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + j3 * aminoAcidSymbolBitmap3.width;
				
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
		
		private function renderAARevCom(row:Row):void
		{
			var aa1:String = contentHolder.aaMapper.revComAA1Frame1Sparse;
			var aa2:String = " " + contentHolder.aaMapper.revComAA1Frame2Sparse;
			var aa3:String = "  " + contentHolder.aaMapper.revComAA1Frame3Sparse;
			
			var start:int = contentHolder.featuredSequence.sequence.length - row.rowData.end - 1;
			var end:int = contentHolder.featuredSequence.sequence.length - row.rowData.start - 1;
			
			var aminoAcidsString1:String = aa1.substring(start, end + 1);
			var aminoAcidsString2:String = aa2.substring(start, end + 1);
			var aminoAcidsString3:String = aa3.substring(start, end + 1);
			
			var numberOfSpaces:int = 0;
			
			if(contentHolder.showSpaceEvery10Bp) {
				aminoAcidsString1 = splitWithSpaces(aminoAcidsString1, 0, false);
				aminoAcidsString2 = splitWithSpaces(aminoAcidsString2, 0, false);
				aminoAcidsString3 = splitWithSpaces(aminoAcidsString3, 0, false);
				
				numberOfSpaces = (row.rowData.sequence.length % 10) ? int(row.rowData.sequence.length / 10) : (int(row.rowData.sequence.length / 10) - 1);
			}
			
			var g:Graphics = graphics;
			var aminoAcidRenderMatrix:Matrix = new Matrix();
			
			// Render first row of AA3
			for(var j1:int = 0; j1 < aminoAcidsString1.length; j1++) {
				var aminoAcidSymbolBitmap1:BitmapData = contentHolder.aminoAcidsTextRenderer.textToBitmap(aminoAcidsString1.charAt(j1));
				
				var leftShift1:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + ((row.rowData.sequence.length - 1) + numberOfSpaces - j1) * aminoAcidSymbolBitmap1.width;
				
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
				
				var leftShift2:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + ((row.rowData.sequence.length - 1) + numberOfSpaces - j2) * aminoAcidSymbolBitmap2.width;
				
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
				
				var leftShift3:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + ((row.rowData.sequence.length - 1) + numberOfSpaces - j3) * aminoAcidSymbolBitmap3.width;
				
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
		
		private function renderAAOld(row:Row, isAA3:Boolean):void
		{
			/*var aa1:String = isAA3 ? contentHolder.aaMapper.sequenceAA3Frame1 : contentHolder.aaMapper.sequenceAA1Frame1;
			var aa2:String = isAA3 ? contentHolder.aaMapper.sequenceAA3Frame2 : contentHolder.aaMapper.sequenceAA1Frame2;
			var aa3:String = isAA3 ? contentHolder.aaMapper.sequenceAA3Frame3 : contentHolder.aaMapper.sequenceAA1Frame3;*/
			
			var aa1:String = contentHolder.aaMapper.sequenceAA1Frame1;
			var aa2:String = contentHolder.aaMapper.sequenceAA1Frame2;
			var aa3:String = contentHolder.aaMapper.sequenceAA1Frame3;
			
			var shift1:int = 0;
			var shift2:int = 0;
			var shift3:int = 0;
			
			if(row.rowData.start % 3 == 0) {
				shift1 = 0;
				shift2 = 1;
				shift3 = 2;
			} else if(row.rowData.start % 3 == 1) {
				shift1 = 2;
				shift2 = 0;
				shift3 = 1;
			} else if(row.rowData.start % 3 == 2) {
				shift1 = 1;
				shift2 = 2;
				shift3 = 0;
			}
			
			var start1:int = 0;
			var start2:int = 0;
			var start3:int = 0;
			
			var end1:int = 0;
			var end2:int = 0;
			var end3:int = 0;
			
			if(row.rowData.start % 3 == 0) {
				start1 = row.rowData.start;
			} else if(row.rowData.start % 3 == 1) {
				start1 = 3 * (int(row.rowData.start / 3) + 1);
			} else if(row.rowData.start % 3 == 2) {
				start1 = 3 * (int(row.rowData.start / 3) + 1);
			}
			
			if(row.rowData.start % 3 == 1) {
				start2 = 3 * int(row.rowData.start / 3);
			} else if(row.rowData.start % 3 == 0) {
				start2 = row.rowData.start;
			} else if(row.rowData.start % 3 == 2) {
				start2 = 3 * (int(row.rowData.start / 3) + 1);
			}
			
			if(row.rowData.start % 3 == 2) {
				start3 = 3 * int(row.rowData.start / 3);
			} else if(row.rowData.start % 3 == 1) {
				start3 = 3 * int(row.rowData.start / 3);
			} else if(row.rowData.start % 3 == 0) {
				start3 = row.rowData.start;
			}
			
			if((row.rowData.end + 1) % 3 == 0) {
				end1 = (row.rowData.end + 1);
			} else if((row.rowData.end + 1) % 3 == 1) {
				end1 = 3 * (int((row.rowData.end + 1) / 3) + 1);
			} else if((row.rowData.end + 1) % 3 == 2) {
				end1 = 3 * (int((row.rowData.end + 1) / 3) + 1);
			}
			
			if((row.rowData.end + 1) % 3 == 1) {
				end2 = 3 * int((row.rowData.end + 1) / 3);
			} else if((row.rowData.end + 1) % 3 == 0) {
				end2 = (row.rowData.end + 1);
			} else if((row.rowData.end + 1) % 3 == 2) {
				end2 = 3 * (int((row.rowData.end + 1) / 3) + 1);
			}
			
			if((row.rowData.end + 1) % 3 == 2) {
				end3 = 3 * int((row.rowData.end + 1) / 3);
			} else if((row.rowData.end + 1) % 3 == 1) {
				end3 = 3 * int((row.rowData.end + 1) / 3);
			} else if((row.rowData.end + 1) % 3 == 0) {
				end3 = (row.rowData.end + 1);
			}
			
			var aminoAcidsString1:String = "";
			var aminoAcidsString2:String = "";
			var aminoAcidsString3:String = "";
			if(isAA3) {
				aminoAcidsString1 = aa1.substring(start1, end1);
				aminoAcidsString2 = aa2.substring(start2, end2);
				aminoAcidsString3 = aa3.substring(start3, end3);
			} else {
				var subString1:String = aa1.substring(start1 / 3, end1 / 3);
				var subString2:String = aa2.substring(start2 / 3, end2 / 3);
				var subString3:String = aa3.substring(start3 / 3, end3 / 3);
				
				var sparsedString1:String = "";
				var sparsedString2:String = "";
				var sparsedString3:String = "";
				
				for(var i:int = 0; i < subString1.length; i++) {
					sparsedString1 += subString1.charAt(i) + "  ";
					sparsedString2 += subString2.charAt(i) + "  ";
					sparsedString3 += subString3.charAt(i) + "  ";
				}
				
				aminoAcidsString1 = sparsedString1.substring(0, end1 - start1 + 1);
				aminoAcidsString2 = sparsedString2.substring(0, end2 - start2 + 1);
				aminoAcidsString3 = sparsedString3.substring(0, end3 - start3 + 1);
			}
			
			if(contentHolder.showSpaceEvery10Bp) {
				aminoAcidsString1 = splitWithSpaces(aminoAcidsString1, shift1, false);
				aminoAcidsString2 = splitWithSpaces(aminoAcidsString2, shift2, false);
				aminoAcidsString3 = splitWithSpaces(aminoAcidsString3, shift3, false);
			}
			
			var g:Graphics = graphics;
			var aminoAcidRenderMatrix:Matrix = new Matrix();
			
			// Render first row of AA3
			for(var j1:int = 0; j1 < aminoAcidsString1.length; j1++) {
				var aminoAcidSymbolBitmap1:BitmapData = contentHolder.aminoAcidsTextRenderer.textToBitmap(aminoAcidsString1.charAt(j1));
				
				var leftShift1:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + (j1 + shift1) * aminoAcidSymbolBitmap1.width;
				
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
				
				var leftShift2:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + (j2 + shift2) * aminoAcidSymbolBitmap2.width;
				
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
				
				var leftShift3:int = 6 * contentHolder.sequenceSymbolRenderer.textWidth + (j3 + shift3) * aminoAcidSymbolBitmap3.width;
				
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
		
		private function splitWithSpaces(string:String, shift:int = 0, splitLast:Boolean = true):String
		{
			var result:String = "";
			
			var stringLength:int = string.length;
			
			if(stringLength <= 10 - shift) {
				result += string;
			} else {
				var start:int = 0;
				var end:int = 10 - shift;
				while(start < stringLength) {
					result += string.substring(start, end);
					
					start = end;
					end += 10;
					
					if(end <= contentHolder.bpPerRow) {
						result += " ";
					}
				}
			}
			
			return result;
		}
	}
}
