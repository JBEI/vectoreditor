package org.jbei.components.sequenceClasses
{
    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.desktop.ClipboardTransferMode;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextFormat;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.Keyboard;
    
    import mx.controls.Alert;
    import mx.core.UIComponent;
    
    import org.jbei.bio.enzymes.RestrictionCutSite;
    import org.jbei.bio.orf.ORF;
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.alphabets.DNAAlphabet;
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.bio.sequence.dna.Feature;
    import org.jbei.components.SequenceAnnotator;
    import org.jbei.components.common.AnnotationRenderer;
    import org.jbei.components.common.CaretEvent;
    import org.jbei.components.common.CommonEvent;
    import org.jbei.components.common.Constants;
    import org.jbei.components.common.EditingEvent;
    import org.jbei.components.common.IContentHolder;
    import org.jbei.components.common.PasteDialogForm;
    import org.jbei.components.common.SelectionEvent;
    import org.jbei.components.common.SequenceUtils;
    import org.jbei.components.common.TextRenderer;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.data.DigestionSequence;
    import org.jbei.lib.mappers.AAMapper;
    import org.jbei.lib.mappers.DigestionCutter;
    import org.jbei.lib.mappers.ORFMapper;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;
    import org.jbei.lib.ui.dialogs.ModalDialog;
    import org.jbei.lib.ui.dialogs.ModalDialogEvent;
    import org.jbei.lib.utils.SystemUtils;
    import org.jbei.registry.utils.IceXmlUtils;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class ContentHolder extends UIComponent implements IContentHolder
	{
		private const BACKGROUND_COLOR:int = 0xFFFFFF;
		private const SPLIT_LINE_COLOR:int = 0x000000;
		private const SPLIT_LINE_TRANSPARENCY:Number = 0.15;
		private const DEFAULT_MONOSPACE_FONT_FACE:String = "Courier New";
		private const LINUX_MONOSPACE_FONT_FACE:String = "Monospace";
		private const WINDOWS_MONOSPACE_FONT_FACE:String = "Lucida Console";
		private const MACOS_MONOSPACE_FONT_FACE:String = "Monaco";
		private const CUTSITES_FONT_FACE:String = "Tahoma";
		private const SEQUENCE_FONT_COLOR:int = 0x000000;
		private const COMPLIMENTARY_FONT_COLOR:int = 0xB0B0B0;
		private const CUTSITES_FONT_COLOR:int = 0x888888;
		private const SINGLE_CUTTER_CUTSITES_FONT_COLOR:int = 0xE57676;
		private const AMINOACIDS_FONT_COLOR:int = 0x0066FF;
		private const MINIMUM_BP_PER_ROW:int = 10;
		
		private var sequenceAnnotator:SequenceAnnotator;
		private var selectionLayer:SelectionLayer;
		private var highlightLayer:HighlightLayer;
		private var caret:Caret;
		
		private var customContextMenu:ContextMenu;
		private var editFeatureContextMenuItem:ContextMenuItem;
		private var removeFeatureContextMenuItem:ContextMenuItem;
		private var selectedAsNewFeatureContextMenuItem:ContextMenuItem;
		
		private var featureRenderers:Array = new Array(); /* of FeatureRenderer */
		private var cutSiteRenderers:Array = new Array(); /* of CutSiteRenderer */
		private var orfRenderers:Array = new Array(); /* of ORFRenderer */
		private var sequenceRenderer:SequenceRenderer;
		
		private var _sequenceProvider:SequenceProvider;
		private var _orfMapper:ORFMapper;
		private var _aaMapper:AAMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Annotation */;
		
		private var _rowMapper:RowMapper;
		private var _bpPerRow:int;
		private var _sequenceSymbolRenderer:TextRenderer;
		private var _complimentarySymbolRenderer:TextRenderer;
		private var _cutSiteTextRenderer:TextRenderer;
		private var _singleCutterCutSiteTextRenderer:TextRenderer;
		private var _aminoAcidsTextRenderer:TextRenderer;
		private var _averageRowHeight:int = 0;
		private var _totalHeight:int = 0;
		private var _totalWidth:int = 0;
		private var _readOnly:Boolean = true;
		private var _showComplementary:Boolean = true;
		private var _showFeatures:Boolean = true;
		private var _showCutSites:Boolean = false;
		private var _showORFs:Boolean = false;
		private var _sequenceFontSize:int = 11;
		private var _labelFontSize:int = 10;
		private var _caretPosition:int = 0;
		private var _showSpaceEvery10Bp:Boolean = true;
		private var _showAminoAcids1:Boolean = false;
		private var _showAminoAcids1RevCom:Boolean = false;
		private var _showAminoAcids3:Boolean = false;
		private var _safeEditing:Boolean = true;
		
		private var parentWidth:Number = 0;
		private var parentHeight:Number = 0;
		
		private var shiftKeyDown:Boolean = false;
		private var shiftDownCaretPosition:int = -1;
		private var mouseIsDown:Boolean = false;
		private var startSelectionIndex:int;
		private var endSelectionIndex:int;
		private var selectionDirection:int = 0;
		private var keysSelectionDirection:int = 0;
		private var startHandleResizing:Boolean = false;
		private var endHandleResizing:Boolean = false;
		
		private var invalidSequence:Boolean = true;
		private var needsMeasurement:Boolean = false;
		private var sequenceProviderChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var aaMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		private var rowMapperChanged:Boolean = false;
		private var bpPerRowChanged:Boolean = false;
		private var showFeaturesChanged:Boolean = false;
		private var showCutSitesChanged:Boolean = false;
		private var showComplementaryChanged:Boolean = false;
		private var sequenceFontSizeChanged:Boolean = false;
		private var labelFontSizeChanged:Boolean = false;
		private var showSpaceEvery10BpChanged:Boolean = false;
		private var showAminoAcids1Changed:Boolean = false;
		private var showAminoAcids1RevComChanged:Boolean = false;
		private var showAminoAcids3Changed:Boolean = false;
		private var showORFsChanged:Boolean = false;
        
        private var digestionCutter:DigestionCutter;
        private var pasteData:Object = null;
		
		// Constructor
		public function ContentHolder(sequenceAnnotator:SequenceAnnotator)
		{
			super();
			 
			this.sequenceAnnotator = sequenceAnnotator;
			bpPerRow = sequenceAnnotator.bpPerRow;
			_rowMapper = new RowMapper(this);
			
	        doubleClickEnabled = true;
		}
		
		// Properties
	    public function get rowMapper():RowMapper
	    {
	    	return _rowMapper;
	    }
	    
		public function get sequenceProvider():SequenceProvider
		{
			return _sequenceProvider;
		}
		
		public function set sequenceProvider(value:SequenceProvider):void
		{
			_sequenceProvider = value;
			
			invalidateProperties();
			
            sequenceProviderChanged = true;
		}
		
		public function get restrictionEnzymeMapper():RestrictionEnzymeMapper
		{
			return _restrictionEnzymeMapper;
		}
		
		public function set restrictionEnzymeMapper(value:RestrictionEnzymeMapper):void
		{
			_restrictionEnzymeMapper = value;
			
			invalidateProperties();
			
			restrictionEnzymeMapperChanged = true;
		}
		
		public function get orfMapper():ORFMapper
		{
			return _orfMapper;
		}
		
		public function set orfMapper(value:ORFMapper):void
		{
			_orfMapper = value;
			
			invalidateProperties();
			
			orfMapperChanged = true;
		}
		
		public function get aaMapper():AAMapper
		{
			return _aaMapper;
		}
		
		public function set aaMapper(value:AAMapper):void
		{
			_aaMapper = value;
			
			invalidateProperties();
			
			aaMapperChanged = true;
		}
		
		public function get highlights():Array /* of Annotation */
		{
			return _highlights;
		}
		
		public function set highlights(value:Array /* of Annotation */):void
		{
			_highlights = value;
			
			invalidateDisplayList();
			
			highlightsChanged = true;
		}
		
		public function get showCutSites():Boolean
		{
			return _showCutSites;
		}
		
		public function set showCutSites(value:Boolean):void
		{
			if(_showCutSites != value) {
				_showCutSites = value;
				
				invalidateProperties();
				
				showCutSitesChanged = true;
			}
		}
		
		public function get showFeatures():Boolean
		{
			return _showFeatures;
		}
		
		public function set showFeatures(value:Boolean):void
		{
			if(_showFeatures != value) {
				_showFeatures = value;
				
				invalidateProperties();
				
				showFeaturesChanged = true;
			}
		}
		
		public function get showComplementary():Boolean
		{
			return _showComplementary;
		}
		
		public function set showComplementary(value:Boolean):void
		{
			if(_showComplementary != value) {
				_showComplementary = value;
				
	        	invalidateProperties();
				
				showComplementaryChanged = true;
			}
		}
		
		public function get bpPerRow():int
		{
			return _bpPerRow;
		}
		
		public function set bpPerRow(value:int):void
		{
			if(_bpPerRow != value) {
				_bpPerRow = (value <= 0) ? MINIMUM_BP_PER_ROW : value;
				
				bpPerRowChanged = true;
				
				invalidateProperties(); 
			}
		}
	    
	    public function get sequenceFontSize():int
	    {
	    	return _sequenceFontSize;
	    }
	    
	    public function set sequenceFontSize(value:int):void
	    {
	    	if (value != sequenceFontSize) {
	    		_sequenceFontSize = value;
	    		
	    		sequenceFontSizeChanged = true;
	    		
	    		invalidateProperties();
	    	}
	    }
	    
		public function get labelFontSize():int
		{
			return _labelFontSize;
		}
		
		public function set labelFontSize(value:int):void
		{
			if (value != labelFontSize) {
				_labelFontSize = value;
				
				labelFontSizeChanged = true;
				
				invalidateProperties();
			}
		}
		
	    public function get showSpaceEvery10Bp():Boolean
	    {
	        return _showSpaceEvery10Bp;
	    }
		
	    public function set showSpaceEvery10Bp(value:Boolean):void
	    {
	    	if(_showSpaceEvery10Bp != value) {
		    	_showSpaceEvery10Bp = value;
		    	
		    	showSpaceEvery10BpChanged = true;
		    	
		    	invalidateProperties();
	    	}
	    }
	    
	    public function get showAminoAcids1():Boolean
	    {
	        return _showAminoAcids1;
	    }
		
	    public function set showAminoAcids1(value:Boolean):void
	    {
	    	if(_showAminoAcids1 != value) {
		    	_showAminoAcids1 = value;
		    	
		    	showAminoAcids1Changed = true;
		    	
		    	invalidateProperties();
	    	}
	    }
	    
		public function get showAminoAcids1RevCom():Boolean
		{
			return _showAminoAcids1RevCom;
		}
		
		public function set showAminoAcids1RevCom(value:Boolean):void
		{
			if(_showAminoAcids1RevCom != value) {
				_showAminoAcids1RevCom = value;
				
				showAminoAcids1RevComChanged = true;
				
				invalidateProperties();
			}
		}
		
	    public function get showAminoAcids3():Boolean
	    {
	        return _showAminoAcids3;
	    }
		
	    public function set showAminoAcids3(value:Boolean):void
	    {
	    	if(_showAminoAcids3 != value) {
		    	_showAminoAcids3 = value;
		    	
		    	showAminoAcids3Changed = true;
		    	
		    	invalidateProperties();
	    	}
	    }
	    
	    public function get showORFs():Boolean
	    {
	        return _showORFs;
	    }
		
	    public function set showORFs(value:Boolean):void
	    {
	    	if(_showORFs != value) {
		    	_showORFs = value;
		    	
		    	showORFsChanged = true;
		    	
		    	invalidateProperties();
	    	}
	    }
	    
	    public function get averageRowHeight():int
	    {
	    	return _averageRowHeight;
	    }
	    
	    public function get selectionStart():int
	    {
	    	return startSelectionIndex;
	    }
	    
	    public function get selectionEnd():int
	    {
	    	return endSelectionIndex;
	    }
	    
	    public function get totalHeight():int
	    {
	    	return _totalHeight;
	    }
	    
	    public function get totalWidth():int
	    {
	    	return _totalWidth;
	    }
	    
        /**
        * @private
        */
	    public function get sequenceSymbolRenderer():TextRenderer
	    {
	    	return _sequenceSymbolRenderer;
	    }
	    
        /**
        * @private
        */
	    public function get complimentarySymbolRenderer():TextRenderer
	    {
	    	return _complimentarySymbolRenderer;
	    }
	    
        /**
        * @private
        */
	    public function get cutSiteTextRenderer():TextRenderer
	    {
	    	return _cutSiteTextRenderer;
	    }
	    
        /**
        * @private
        */
	    public function get singleCutterCutSiteTextRenderer():TextRenderer
	    {
	    	return _singleCutterCutSiteTextRenderer;
	    }
	    
        /**
        * @private
        */
	    public function get aminoAcidsTextRenderer():TextRenderer
	    {
	    	return _aminoAcidsTextRenderer;
	    }
	    
	    public function get caretPosition():int
	    {
	    	return _caretPosition;
	    }
	    
	    public function set caretPosition(value:int):void
	    {
	    	if (value != caretPosition) {
	    		tryMoveCaretToPosition(value);
	    	}
	    }
	    
		public function get safeEditing():Boolean
		{
			return _safeEditing;
		}
		
		public function set safeEditing(value:Boolean):void
		{
			_safeEditing = value;
		}
		
		public function get readOnly():Boolean
		{
			return _readOnly;
		}
		
		public function set readOnly(value:Boolean):void
		{
			_readOnly = value;
		}
		
		// Public Methods
        /**
        * @private
        */
		public function updateMetrics(parentWidth:Number, parentHeight:Number):void
		{
			this.parentWidth = parentWidth;
			this.parentHeight = parentHeight;
			
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		public function select(startIndex: int, endIndex: int):void
		{
			if(invalidSequence) { return; }

			if(!isValidIndex(startIndex) || !isValidIndex(endIndex)) {
				deselect();

				return;
			}

			if((selectionLayer.start != startIndex || selectionLayer.end != endIndex) && startIndex != endIndex) {
				doSelect(startIndex, endIndex);

				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, startIndex, endIndex));

				tryMoveCaretToPosition(startIndex);
			}
		}

        public function deselect():void
		{
			if(invalidSequence) { return; }

			if(selectionLayer.selected) {
				doDeselect();

				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
			}
		}

        /**
        * @private
        */
		public function showCaret():void
		{
			if(invalidSequence) { return; }

			caret.show();
		}

        /**
        * @private
        */
		public function hideCaret():void
		{
			if(invalidSequence) { return; }

			caret.hide();
		}

        /**
        * @private
        */
		public function isValidIndex(index:int):Boolean
		{
			return index >= 0 && index <= sequenceProvider.sequence.length;
		}

        /**
        * @private
        */
		public function bpMetricsByIndex(index:int):Rectangle
		{
			if(!isValidIndex(index)) {
				throw new Error("Can't get bp metrics for bp with index " + String(index));
			}

			var row:Row = rowByBpIndex(index);

			var resultMetrics:Rectangle;

			if(row == null) {
				throw new Error("Can't get bp point for index: " + String(index));  // => this case should never happen
			} else {
				var numberOfCharacters:int = index - row.index * _bpPerRow;

				if(_showSpaceEvery10Bp) {
					numberOfCharacters += int(numberOfCharacters / 10);
				}

				var bpX:Number = row.sequenceMetrics.x + numberOfCharacters * _sequenceSymbolRenderer.textWidth;
				var bpY:Number = row.sequenceMetrics.y;

				resultMetrics = new Rectangle(bpX, bpY, _sequenceSymbolRenderer.textWidth, _sequenceSymbolRenderer.textHeight);
			}

			return resultMetrics;
		}

        /**
        * @private
        */
		public function rowByBpIndex(index:int):Row
		{
			if(!isValidIndex(index)) {
				throw new Error("Can't get row for bp with index " + String(index));
			}

			return rowMapper.rows[int(Math.floor(index / _bpPerRow))];
		}
		
        /**
        * @private
        */
		public function adjustedSelectionVerticalPosition():int
		{
			var position:int = 0;
			var rowIndex:int = int(selectionLayer.start / bpPerRow);
			
			if(rowIndex > 2) {
				var row:Row = rowMapper.rows[rowIndex - 1] as Row;
				
				position = row.metrics.y;
			}
			
			return position;
		}

        /**
        * @private
        */
		public function contentBitmapData(page:int, pageWidth:Number, pageHeight:Number):BitmapData
		{
			var currentHeight:Number = Math.min(pageHeight, totalHeight - pageHeight * page);

			var bitmapData:BitmapData = new BitmapData(pageWidth, currentHeight);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, 0, -pageHeight * page);
			bitmapData.draw(this, matrix, null, null, new Rectangle(0, 0, pageWidth, currentHeight));
			
			return bitmapData;
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			createContextMenu();
			
			createTextRenderers();
			
			createSequenceRenderer();
			
			createCaret();
			
			createHighlightLayer();
			
			createSelectionLayer();
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(! _sequenceProvider) {
				disableSequence();
				
				invalidateDisplayList();
				
				return;
			}
			
			if(sequenceProviderChanged) {
                sequenceProviderChanged = false;
				
				rowMapperChanged = true;
				needsMeasurement = true;
				
				initializeSequence();
				
				invalidateDisplayList();
			}
			
			if(restrictionEnzymeMapperChanged) {
				restrictionEnzymeMapperChanged = false;
				
				rowMapperChanged = true;
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(orfMapperChanged) {
				orfMapperChanged = false;
				
				rowMapperChanged = true;
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(aaMapperChanged) {
				aaMapperChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(showComplementaryChanged) {
				showComplementaryChanged = false;
				
				needsMeasurement = true;
				
				adjustCaretSize();
				
				invalidateDisplayList();
			}
			
			if(showCutSitesChanged) {
				showCutSitesChanged = false;
				
	        	if(restrictionEnzymeMapper) {
		        	needsMeasurement = true;
		        	rowMapperChanged = true;
		        }
				
				invalidateDisplayList();
			}
			
			if(showFeaturesChanged) {
				showFeaturesChanged = false;
				
				rowMapperChanged = true;
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(bpPerRowChanged) {
				bpPerRowChanged = false;
				
				needsMeasurement = true;
				rowMapperChanged = true;
				
				invalidateDisplayList();
			}
	        
	        if(sequenceFontSizeChanged) {
	        	sequenceFontSizeChanged = false;
	        	
				needsMeasurement = true;
				
				var newSequenceTextFormat:TextFormat = new TextFormat(_sequenceSymbolRenderer.textFormat.font, _sequenceFontSize, _sequenceSymbolRenderer.textFormat.color);
				var newComplimentaryTextFormat:TextFormat = new TextFormat(_complimentarySymbolRenderer.textFormat.font, _sequenceFontSize, _complimentarySymbolRenderer.textFormat.color);
				var newAminoAcidsTextFormat:TextFormat = new TextFormat(_aminoAcidsTextRenderer.textFormat.font, _sequenceFontSize, _aminoAcidsTextRenderer.textFormat.color);
				
				_sequenceSymbolRenderer.textFormat = newSequenceTextFormat;
				_complimentarySymbolRenderer.textFormat = newComplimentaryTextFormat;
				_aminoAcidsTextRenderer.textFormat = newAminoAcidsTextFormat;
				
				clearSequenceTextRenderers();
				
				adjustCaretSize();
				
				invalidateDisplayList();
	        }
	        
			if(labelFontSizeChanged) {
				labelFontSizeChanged = false;
				
				needsMeasurement = true;
				
				var cutSiteTextFormat:TextFormat = new TextFormat(_cutSiteTextRenderer.textFormat.font, _labelFontSize, _cutSiteTextRenderer.textFormat.color);
				var singleCutterCutSiteTextFormat:TextFormat = new TextFormat(_singleCutterCutSiteTextRenderer.textFormat.font, _labelFontSize, _singleCutterCutSiteTextRenderer.textFormat.color);
				
				_cutSiteTextRenderer.textFormat = cutSiteTextFormat;
				_singleCutterCutSiteTextRenderer.textFormat = singleCutterCutSiteTextFormat;
				
				clearCutterTextRenderers();
				
				invalidateDisplayList();
			}
			
	        if(showSpaceEvery10BpChanged) {
	        	showSpaceEvery10BpChanged = false;
	        	
	        	needsMeasurement = true;
	        	
	        	invalidateDisplayList();
	        }
	        
	        if(showAminoAcids1Changed) {
	        	showAminoAcids1Changed = false;
	        	
	        	needsMeasurement = true;
	        	
	        	invalidateDisplayList();
	        }
	        
			if(showAminoAcids1RevComChanged) {
				showAminoAcids1RevComChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
	        if(showAminoAcids3Changed) {
	        	showAminoAcids3Changed = false;
	        	
	        	needsMeasurement = true;
	        	
	        	invalidateDisplayList();
	        }
	        
	        if(showORFsChanged) {
	        	showORFsChanged = false;
	        	
	        	if(orfMapper) {
		        	needsMeasurement = true;
		        	rowMapperChanged = true;
		        }
				
	        	invalidateDisplayList();
	        }
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(invalidSequence) {
				removeFeatureRenderers();
				removeCutSiteRenderers();
				removeORFRenderers();
				
				_totalHeight = parentHeight;
				_totalWidth = parentWidth;
				
				drawBackground();
				
				doDeselect();
				caret.hide();
				
				return;
			}
			
			if(rowMapperChanged) {
				rowMapperChanged = false;
				
				rowMapper.update();
				
				loadFeatureRenderers();
				loadCutSiteRenderers();
				loadORFRenderers();
			}
			
			if(highlightsChanged && !needsMeasurement) {
				highlightsChanged = false;
				
				highlightLayer.update();
			}
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				sequenceRenderer.update();
				sequenceRenderer.validateNow();
				
				_totalHeight = Math.max(sequenceRenderer.totalHeight + 20, parentHeight); // +20 for scrollbar
				_totalWidth = Math.max(sequenceRenderer.totalWidth + 20, parentWidth);    // +20 for scrollbar
				
				renderFeatures();
				renderCutSites();
				renderORFs();
				
				if(highlightsChanged) {
					highlightsChanged = false;
				}
				
				highlightLayer.update();
				
				drawBackground();
				drawSplitLines();
				
				updateAverageRowHeight();
				
				if(isValidIndex(startSelectionIndex) && isValidIndex(endSelectionIndex)) {
					doSelect(startSelectionIndex, endSelectionIndex);
					
					if(numChildren > 1) {
						swapChildren(selectionLayer, getChildAt(numChildren - 1));
					}
				}
			}
			
			validateCaret();
		}
		
		// Event Handlers
        private function onMouseDown(event:MouseEvent):void
        {
            if(event.target is AnnotationRenderer) { return; }
            
            if(selectionLayer.selected) { deselect(); }
            
            mouseIsDown = true;
            
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            
            if(!startHandleResizing && !endHandleResizing) {
                startSelectionIndex = bpAtPoint(new Point(event.localX, event.localY));
                
                selectionDirection = 0;
            }
            
            tryMoveCaretToPosition(startSelectionIndex);
        }
        
        private function onMouseMove(event:MouseEvent):void
        {
            if(mouseIsDown || startHandleResizing || endHandleResizing) {
                var bpIndex:int = bpAtPoint(new Point(mouseX, mouseY));
                
                if(bpIndex == -1) { return; }
                
                if(startHandleResizing) {
                    startSelectionIndex = bpIndex;
                    
                    selectionDirection = 1; // ignore direction on resizing
                    
                    tryMoveCaretToPosition(startSelectionIndex);
                } else if(endHandleResizing) {
                    endSelectionIndex = bpIndex;
                    
                    selectionDirection = 1; // ignore direction on resizing
                    
                    tryMoveCaretToPosition(endSelectionIndex);
                } else {
                    endSelectionIndex = bpIndex;
                    
                    tryMoveCaretToPosition(endSelectionIndex);
                }
                
                if(isValidIndex(startSelectionIndex) && isValidIndex(endSelectionIndex)) {
                    if(selectionDirection == 0 && startSelectionIndex != endSelectionIndex) {
                        selectionDirection = (startSelectionIndex < endSelectionIndex) ? 1 : -1;
                    }
                    
                    var start:int = (selectionDirection == -1) ? endSelectionIndex : startSelectionIndex;
                    var end:int = (selectionDirection == -1) ? startSelectionIndex : endSelectionIndex;
                    
                    selectionLayer.startSelecting();
                    selectionLayer.select(start, end);
                }
            }
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            if(!(mouseIsDown || startHandleResizing || endHandleResizing)) { return; }
            
            mouseIsDown = false;
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            
            if(selectionLayer.selected && selectionLayer.selecting) {
                selectionLayer.endSelecting();
                
                dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
            }
        }
        
        private function onMouseDoubleClick(event:MouseEvent):void
        {
            if(event.target is FeatureRenderer) {
                dispatchEvent(new CommonEvent(CommonEvent.EDIT_FEATURE, true, true, (event.target as FeatureRenderer).feature));
            }
        }
        
        private function onContextMenuSelect(event:ContextMenuEvent):void
        {
            customContextMenu.customItems = new Array();
            
            if(!_readOnly && event.mouseTarget is FeatureRenderer) {
                customContextMenu.customItems.push(editFeatureContextMenuItem);
                customContextMenu.customItems.push(removeFeatureContextMenuItem);
            }
            
            if(!_readOnly && selectionLayer.selected) {
                customContextMenu.customItems.push(selectedAsNewFeatureContextMenuItem);
            }
        }
        
        private function onEditFeatureMenuItem(event:ContextMenuEvent):void
        {
            if(event.mouseTarget is FeatureRenderer) {
                dispatchEvent(new CommonEvent(CommonEvent.EDIT_FEATURE, true, true, (event.mouseTarget as FeatureRenderer).feature));
            }
        }
        
        private function onRemoveFeatureMenuItem(event:ContextMenuEvent):void
        {
            if(event.mouseTarget is FeatureRenderer) {
                dispatchEvent(new CommonEvent(CommonEvent.REMOVE_FEATURE, true, true, (event.mouseTarget as FeatureRenderer).feature));
            }
        }
        
        private function onSelectedAsNewFeatureMenuItem(event:ContextMenuEvent):void
        {
            dispatchEvent(new CommonEvent(CommonEvent.CREATE_FEATURE, true, true, new Feature("", selectionLayer.start, selectionLayer.end, "", 0)));
        }
        
        private function onSelectAll(event:Event):void
        {
            select(0, _sequenceProvider.sequence.length);
        }
        
        private function onCopy(event:Event):void
        {
            if(!isValidIndex(selectionLayer.start) || !isValidIndex(selectionLayer.end)) {
                return;
            }
            
            var digestionStart:int = -1;
            var digestionEnd:int = -1;
            var digestionStartCutSite:RestrictionCutSite = null;
            var digestionEndCutSite:RestrictionCutSite = null;
            
            if(_showCutSites
                && _restrictionEnzymeMapper
                && _restrictionEnzymeMapper.cutSites
                && _restrictionEnzymeMapper.cutSites.length > 0) {
                
                for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
                    var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites.getItemAt(i) as RestrictionCutSite;
                    
                    if(selectionLayer.start == cutSite.start) {
                        digestionStartCutSite = cutSite;
                        digestionStart = selectionLayer.start;
                    }
                    
                    if(selectionLayer.end == cutSite.end) {
                        digestionEnd = selectionLayer.end;
                        digestionEndCutSite = cutSite;
                    }
                }
            }
            
            var externalContext:Object = new Object();
            if(digestionStart >= 0 && digestionEnd >= 0) {
                var subSequenceProvider:SequenceProvider = _sequenceProvider.subSequenceProvider(digestionStart, digestionEnd);
                var digestionSequence:DigestionSequence = new DigestionSequence(subSequenceProvider, digestionStartCutSite.restrictionEnzyme, digestionEndCutSite.restrictionEnzyme, 0, (selectionLayer.start > selectionLayer.end) ? (digestionEndCutSite.start + sequenceProvider.sequence.length - digestionStartCutSite.start - 1) : (digestionEndCutSite.start - digestionStartCutSite.start));
                
                Clipboard.generalClipboard.clear();
                Clipboard.generalClipboard.setData(Constants.DIGESTION_SEQUENCE_CLIPBOARD_KEY, digestionSequence, true);
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY, subSequenceProvider, true);
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, subSequenceProvider.sequence.seqString(), true);
                
                externalContext.name = _sequenceProvider.name;
                externalContext.icePartId = _sequenceProvider.icePartId; //will be null or empty string if not tied to ice registry
                externalContext.iceEntryURI = _sequenceProvider.iceEntryURI; //will be null or empty string if not tied to ice registry
                externalContext.start = digestionStart;
                externalContext.end = digestionEnd;
                if (_sequenceProvider.sequence.length <= Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_MAX_LENGTH) {
                    externalContext.sequence = _sequenceProvider.sequence.seqString();
                } else {
                    externalContext.sequence = _sequenceProvider.subSequence(0, Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_MAX_LENGTH).seqString();
                }
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_CLIPBOARD_KEY, externalContext, true);

                Clipboard.generalClipboard.setData(Constants.JBEI_SEQUENCE_XML_CLIPBOARD_KEY, IceXmlUtils.sequenceProviderToJbeiSeqXml(_sequenceProvider));
                
                dispatchEvent(new CommonEvent(CommonEvent.ACTION_MESSAGE, true, true, "Digestion sequence has been copied to clipboard. Enzymes: [" + digestionStartCutSite.restrictionEnzyme.name + ", " + digestionEndCutSite.restrictionEnzyme.name + "]"));
            } else {
                Clipboard.generalClipboard.clear();
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY, _sequenceProvider.subSequenceProvider(selectionLayer.start, selectionLayer.end), true);
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _sequenceProvider.subSequence(selectionLayer.start, selectionLayer.end).seqString(), true);
                
                externalContext.name = _sequenceProvider.name;
                externalContext.icePartId = _sequenceProvider.icePartId; //will be null or empty string if not tied to ice registry
                externalContext.iceEntryURI = _sequenceProvider.iceEntryURI; //will be null or empty string if not tied to ice registry
                externalContext.start = selectionLayer.start;
                externalContext.end = selectionLayer.end;
                if (_sequenceProvider.sequence.length <= Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_MAX_LENGTH) {
                    externalContext.sequence = _sequenceProvider.sequence.seqString();
                } else {
                    externalContext.sequence = _sequenceProvider.subSequence(0, Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_MAX_LENGTH).seqString();
                }
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_EXTERNAL_CONTEXT_CLIPBOARD_KEY, externalContext, true);
                
                Clipboard.generalClipboard.setData(Constants.JBEI_SEQUENCE_XML_CLIPBOARD_KEY, IceXmlUtils.sequenceProviderToJbeiSeqXml(_sequenceProvider));
                
                dispatchEvent(new CommonEvent(CommonEvent.ACTION_MESSAGE, true, true, "Sequence has been copied to clipboard"));
            }
        }
        
        private function onCut(event:Event):void
        {
            if(isValidIndex(selectionLayer.start) && isValidIndex(selectionLayer.end)) {
                Clipboard.generalClipboard.clear();
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY, _sequenceProvider.subSequenceProvider(selectionLayer.start, selectionLayer.end), true);
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _sequenceProvider.subSequence(selectionLayer.start, selectionLayer.end).seqString(), true);
                
                dispatchEvent(new CommonEvent(CommonEvent.ACTION_MESSAGE, true, true, "Sequence has been copied to clipboard"));
                
                if(_safeEditing) {
                    doDeleteSequence(selectionLayer.start, selectionLayer.end);
                } else {
                    _sequenceProvider.removeSequence(selectionLayer.start, selectionLayer.end);
                    
                    deselect();
                }
            }
        }
        
        private function onPaste(event:Event):void
        {
            if(! isValidIndex(_caretPosition)) { return; }
            
            var pasteSequenceType:String = null;
            
            if(Clipboard.generalClipboard.hasFormat(Constants.DIGESTION_SEQUENCE_CLIPBOARD_KEY)) {
                if(startSelectionIndex == -1 || endSelectionIndex == -1 || !isValidDigestionRegion() || !_showCutSites || !_restrictionEnzymeMapper || !_restrictionEnzymeMapper.cutSites || _restrictionEnzymeMapper.cutSites.length == 0) {
                    pasteData = Clipboard.generalClipboard.getData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY) as SequenceProvider;
                    
                    pasteSequenceType = "sequence";
                } else {
                    var digestionClipboardObject:Object = Clipboard.generalClipboard.getData(Constants.DIGESTION_SEQUENCE_CLIPBOARD_KEY);
                    
                    var digestionSequence:DigestionSequence = digestionClipboardObject as DigestionSequence;
                    pasteData = digestionSequence;
                    
                    digestionCutter = new DigestionCutter(_sequenceProvider, selectionLayer.start, selectionLayer.end, digestionSequence, _restrictionEnzymeMapper);

                    if(digestionCutter.matchType == DigestionCutter.MATCH_NONE) {
                        pasteSequenceType = "digestion-none";
                    } else if(digestionCutter.matchType == DigestionCutter.MATCH_NORMAL_ONLY) {
                        pasteSequenceType = "digestion-normal";
                    } else if(digestionCutter.matchType == DigestionCutter.MATCH_REVCOM_ONLY) {
                        pasteSequenceType = "digestion-reverse";
                    } else if(digestionCutter.matchType == DigestionCutter.MATCH_BOTH) {
                        pasteSequenceType = "digestion-both";
                    }
                }
            } else if(Clipboard.generalClipboard.hasFormat(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY)) {
                pasteData = Clipboard.generalClipboard.getData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY) as SequenceProvider;
                
                pasteSequenceType = "sequence";
            } else if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
                pasteData = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_ONLY)).toUpperCase();
                
                pasteSequenceType = "sequence";
            }
            
            var pasteModalDialog:ModalDialog = new ModalDialog(PasteDialogForm, pasteSequenceType);
            pasteModalDialog.open();
            pasteModalDialog.title = "Paste ...";
            pasteModalDialog.addEventListener(ModalDialogEvent.SUBMIT, onPasteDialogSubmit);
        }
        
        private function onPasteDialogSubmit(event:ModalDialogEvent):void
        {
            if(event.data == null || !(event.data is String)) {
                return;
            }
            
            var pasteType:String = event.data as String;
            
            if(pasteType == "sequence") {
                if(pasteData is DigestionSequence) {
                    var pasteSequenceProvider:SequenceProvider = (pasteData as DigestionSequence).sequenceProvider;
                    
                    if(_safeEditing) {
                        doInsertSequenceProvider(pasteSequenceProvider, _caretPosition);
                    } else {
                        _sequenceProvider.insertSequenceProvider(pasteSequenceProvider, _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + pasteSequenceProvider.sequence.length);
                    }
                } else if(pasteData is SequenceProvider) {
                    var pasteSequenceProvider2:SequenceProvider = pasteData as SequenceProvider;
                    
                    if(_safeEditing) {
                        doInsertSequenceProvider(pasteSequenceProvider2, _caretPosition);
                    } else {
                        _sequenceProvider.insertSequenceProvider(pasteSequenceProvider2, _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + pasteSequenceProvider2.sequence.length);
                    }
                } else if(pasteData is String) {
                    var pasteSequence2:String = pasteData as String;
                    
                    if(!SequenceUtils.isCompatibleSequence(pasteSequence2)) {
                        showInvalidPasteSequenceAlert();
                        
                        return;
                    } else {
                        pasteSequence2 = SequenceUtils.purifyCompatibleSequence(pasteSequence2);
                    }
                    
                    if(_safeEditing) {
                        doInsertSequence(DNATools.createDNA(pasteSequence2), _caretPosition);
                    } else {
                        _sequenceProvider.insertSequence(DNATools.createDNA(pasteSequence2), _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + pasteSequence2.length);
                    }
                }
            } else if(pasteType == "revcom") {
                if(pasteData is String) {
                    var pasteSequence3:String = pasteData as String;
                    
                    if(!SequenceUtils.isCompatibleSequence(pasteSequence3)) {
                        showInvalidPasteSequenceAlert();
                        
                        return;
                    } else {
                        pasteSequence3 = SequenceUtils.purifyCompatibleSequence(pasteSequence3);
                    }
                    
                    var dnaRevComSequence:SymbolList = DNATools.reverseComplement(DNATools.createDNA(pasteSequence3));
                    
                    if(_safeEditing) {
                        doInsertSequence(dnaRevComSequence, _caretPosition);
                    } else {
                        _sequenceProvider.insertSequence(dnaRevComSequence, _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + dnaRevComSequence.length);
                    }
                } else if(pasteData is DigestionSequence) {
                    var pasteSequenceProvider3:SequenceProvider = (pasteData as DigestionSequence).sequenceProvider;
                    
                    var revComSequenceProvider:SequenceProvider = SequenceProvider.reverseSequence(pasteSequenceProvider3);
                    
                    if(_safeEditing) {
                        doInsertSequenceProvider(revComSequenceProvider, _caretPosition);
                    } else {
                        _sequenceProvider.insertSequenceProvider(revComSequenceProvider, _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + revComSequenceProvider.sequence.length);
                    }
                } else if(pasteData is SequenceProvider) {
                    var pasteSequenceProvider4:SequenceProvider = pasteData as SequenceProvider;
                    
                    var revComSequenceProvider2:SequenceProvider = SequenceProvider.reverseSequence(pasteSequenceProvider4);
                    
                    if(_safeEditing) {
                        doInsertSequenceProvider(revComSequenceProvider2, _caretPosition);
                    } else {
                        _sequenceProvider.insertSequenceProvider(revComSequenceProvider2, _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + revComSequenceProvider2.sequence.length);
                    }
                }
            } else if(pasteType == "digestion-normal") {
                digestionCutter.digest(DigestionCutter.MATCH_NORMAL_ONLY);
            } else if(pasteType == "digestion-reverse") {
                digestionCutter.digest(DigestionCutter.MATCH_REVCOM_ONLY);
            }
        }
        
        private function onKeyUp(event:KeyboardEvent):void
        {
            if(!event.shiftKey) {
                shiftKeyDown = false;
            }
        }
        
        private function onKeyDown(event:KeyboardEvent):void
        {
            var keyCharacter:String = String.fromCharCode(event.charCode).toLowerCase();
            
            if(event.shiftKey && !shiftKeyDown) {
                shiftDownCaretPosition = _caretPosition;
                shiftKeyDown = true;
                keysSelectionDirection = 0;
            }
            
            if(event.ctrlKey && event.keyCode == Keyboard.LEFT) {
                tryMoveCaretToPosition((_caretPosition % 10 == 0) ? _caretPosition - 10 : int(_caretPosition / 10) * 10);
            } else if(event.ctrlKey && event.keyCode == Keyboard.RIGHT) {
                tryMoveCaretToPosition((_caretPosition % 10 == 0) ? _caretPosition + 10 : int(_caretPosition / 10 + 1) * 10);
            } else if(event.ctrlKey && event.keyCode == Keyboard.HOME) {
                tryMoveCaretToPosition(0);
            } else if(event.ctrlKey && event.keyCode == Keyboard.END) {
                tryMoveCaretToPosition(_sequenceProvider.sequence.length);
            } else if(event.keyCode == Keyboard.LEFT) {
                tryMoveCaretToPosition(_caretPosition - 1);
            } else if(event.keyCode == Keyboard.UP) {
                tryMoveCaretToPosition(_caretPosition - bpPerRow);
            } else if(event.keyCode == Keyboard.RIGHT) {
                tryMoveCaretToPosition(_caretPosition + 1);
            } else if(event.keyCode == Keyboard.DOWN) {
                tryMoveCaretToPosition(_caretPosition + bpPerRow);
            } else if(event.keyCode == Keyboard.HOME || event.keyCode == Keyboard.END) {
                var row:Row = rowByBpIndex(_caretPosition);
                
                if(event.keyCode == Keyboard.HOME) {
                    tryMoveCaretToPosition(row.rowData.start);
                } else {
                    tryMoveCaretToPosition(row.rowData.end);
                }
            } else if(event.keyCode == Keyboard.PAGE_UP || event.keyCode == Keyboard.PAGE_DOWN) {
                var numberOfVisibleRows:int = Math.max(int(sequenceAnnotator.height / _averageRowHeight - 1), 1);
                
                if(event.keyCode == Keyboard.PAGE_UP) {
                    tryMoveCaretToPosition(_caretPosition - numberOfVisibleRows * _bpPerRow);
                } else {
                    tryMoveCaretToPosition(_caretPosition + numberOfVisibleRows * _bpPerRow);
                }
            } else if(!event.ctrlKey && !event.altKey && _caretPosition != -1) {
                if(DNAAlphabet.instance.symbolByValue(keyCharacter)) {
                    if(_safeEditing) {
                        doInsertSequence(DNATools.createDNA(keyCharacter), _caretPosition);
                    } else {
                        _sequenceProvider.insertSequence(DNATools.createDNA(keyCharacter), _caretPosition);
                        
                        tryMoveCaretToPosition(_caretPosition + 1);
                    }
                } else if(event.keyCode == Keyboard.DELETE) {
                    if(selectionLayer.selected) {
                        if(_safeEditing) {
                            doDeleteSequence(selectionLayer.start, selectionLayer.end);
                        } else {
                            _sequenceProvider.removeSequence(selectionLayer.start, selectionLayer.end);
                            
                            tryMoveCaretToPosition(selectionLayer.start);
                            
                            deselect();
                        }
                    } else {
                        if(_safeEditing) {
                            doDeleteSequence(_caretPosition, _caretPosition + 1);
                        } else {
                            _sequenceProvider.removeSequence(_caretPosition, _caretPosition + 1);
                        }
                    }
                } else if(event.keyCode == Keyboard.BACKSPACE && _caretPosition > 0) {
                    if(selectionLayer.selected) {
                        if(_safeEditing) {
                            doDeleteSequence(selectionLayer.start, selectionLayer.end);
                        } else {
                            _sequenceProvider.removeSequence(selectionLayer.start, selectionLayer.end);
                            
                            tryMoveCaretToPosition(selectionLayer.start);
                            
                            deselect();
                        }
                    } else {
                        if(_safeEditing) {
                            doDeleteSequence(_caretPosition - 1, _caretPosition);
                        } else {
                            _sequenceProvider.removeSequence(_caretPosition - 1, _caretPosition);
                            
                            tryMoveCaretToPosition(_caretPosition - 1);
                        }
                    }
                }
            }
            
            if(shiftKeyDown) {
                if(keysSelectionDirection == 0) {
                    if(_caretPosition > shiftDownCaretPosition) {
                        keysSelectionDirection = 1;
                    } else if(_caretPosition < shiftDownCaretPosition) {
                        keysSelectionDirection = -1;
                    } else {
                        deselect();
                        return;
                    }
                }
                
                if(isValidIndex(shiftDownCaretPosition) && isValidIndex(_caretPosition)) {
                    if(keysSelectionDirection == 1) {
                        doSelect(shiftDownCaretPosition, _caretPosition);
                        
                        dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, shiftDownCaretPosition, _caretPosition));
                    } else {
                        doSelect(_caretPosition, shiftDownCaretPosition);
                        
                        dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, _caretPosition, shiftDownCaretPosition));
                    }
                }
            }
        }
        
        private function onSelectionHandleClicked(event:SelectionLayerEvent):void
        {
            startSelectionIndex = selectionLayer.start;
            endSelectionIndex = selectionLayer.end;
            
            startHandleResizing = event.handleKind == SelectionHandle.START_HANDLE;
            endHandleResizing = event.handleKind == SelectionHandle.END_HANDLE;
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onSelectionHandleReleased(event:SelectionLayerEvent):void
        {
            startHandleResizing = false;
            endHandleResizing = false;
            
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onSelectionChanged(event:SelectionEvent):void
        {
            if(event.start >= 0 && event.end >= 0) {
                customContextMenu.clipboardItems.copy = true;
                customContextMenu.clipboardItems.cut = !_readOnly;
            } else {
                customContextMenu.clipboardItems.copy = false;
                customContextMenu.clipboardItems.cut = false;
            }
        }
        
        // Private Methods
		private function disableSequence():void
		{
			invalidSequence = true;
			
			caretPosition = 0;
			
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			
			sequenceAnnotator.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			sequenceAnnotator.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			sequenceAnnotator.removeEventListener(Event.SELECT_ALL, onSelectAll);
			sequenceAnnotator.removeEventListener(Event.COPY, onCopy);
			if(!_readOnly) {
				sequenceAnnotator.removeEventListener(Event.CUT, onCut);
				sequenceAnnotator.removeEventListener(Event.PASTE, onPaste);
			}
			
			removeEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
		}
		
		private function initializeSequence():void
		{
			invalidSequence = false;
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			
			sequenceAnnotator.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			sequenceAnnotator.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			sequenceAnnotator.addEventListener(Event.SELECT_ALL, onSelectAll);
			sequenceAnnotator.addEventListener(Event.COPY, onCopy);
			if(!_readOnly) {
				sequenceAnnotator.addEventListener(Event.CUT, onCut);
				sequenceAnnotator.addEventListener(Event.PASTE, onPaste);
			}
			
			addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
		}
		
        private function createContextMenu():void
        {
			customContextMenu = new ContextMenu();
			
			customContextMenu.hideBuiltInItems(); //hide the Flash built-in menu
			customContextMenu.clipboardMenu = true; // activate Copy, Paste, Cut, Menu items
			customContextMenu.clipboardItems.paste = !_readOnly;
			customContextMenu.clipboardItems.selectAll = true;
			
			contextMenu = customContextMenu;
			
			customContextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onContextMenuSelect);
			
    		createCustomContextMenuItems();
        }
        
        private function createCustomContextMenuItems():void
        {
			editFeatureContextMenuItem = new ContextMenuItem("Edit Feature");
			editFeatureContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onEditFeatureMenuItem);
        	
			removeFeatureContextMenuItem = new ContextMenuItem("Remove Feature");
			removeFeatureContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onRemoveFeatureMenuItem);
			
			selectedAsNewFeatureContextMenuItem = new ContextMenuItem("Selected as New Feature");
			selectedAsNewFeatureContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelectedAsNewFeatureMenuItem);
        }
        
		private function createSequenceRenderer():void
		{
			if(sequenceRenderer == null) {
				sequenceRenderer = new SequenceRenderer(this);
				
				addChild(sequenceRenderer);
			}
		}
		
		private function createTextRenderers():void
		{
			var widthGap:int = 0;
			var heighGap:int = 0;
			var fontSize:int = 11;
			var fontFace:String = DEFAULT_MONOSPACE_FONT_FACE;
			var fontColor:int = 0x000000;
			
			if(SystemUtils.isLinuxOS()) {
				widthGap = 2;
				heighGap = 5;
				fontSize = 11;
				fontFace = LINUX_MONOSPACE_FONT_FACE;
			} else if(SystemUtils.isWindowsOS()) {
				widthGap = 2;
				heighGap = 3;
				fontSize = 12;
				fontFace = WINDOWS_MONOSPACE_FONT_FACE;
			} else if(SystemUtils.isMacOS()) {
				widthGap = 2;
				heighGap = 3;
				fontSize = 12;
				fontFace = MACOS_MONOSPACE_FONT_FACE;
			}
			
			_sequenceSymbolRenderer = new TextRenderer(new TextFormat(fontFace, fontSize, SEQUENCE_FONT_COLOR), widthGap, heighGap);
			_sequenceSymbolRenderer.includeInLayout = false;
			_sequenceSymbolRenderer.visible = false;
			
			_complimentarySymbolRenderer = new TextRenderer(new TextFormat(fontFace, fontSize, COMPLIMENTARY_FONT_COLOR), widthGap, heighGap);
			_complimentarySymbolRenderer.includeInLayout = false;
			_complimentarySymbolRenderer.visible = false;
			
			_cutSiteTextRenderer = new TextRenderer(new TextFormat(CUTSITES_FONT_FACE, 10, CUTSITES_FONT_COLOR));
			_cutSiteTextRenderer.includeInLayout = false;
			_cutSiteTextRenderer.visible = false;
			
			_singleCutterCutSiteTextRenderer = new TextRenderer(new TextFormat(CUTSITES_FONT_FACE, 10, SINGLE_CUTTER_CUTSITES_FONT_COLOR));
			_singleCutterCutSiteTextRenderer.includeInLayout = false;
			_singleCutterCutSiteTextRenderer.visible = false;
			
			_aminoAcidsTextRenderer = new TextRenderer(new TextFormat(fontFace, fontSize, AMINOACIDS_FONT_COLOR), widthGap, heighGap - 1)
			_aminoAcidsTextRenderer.includeInLayout = false;
			_aminoAcidsTextRenderer.visible = false;
			
			addChild(_sequenceSymbolRenderer);
			addChild(_complimentarySymbolRenderer);
			addChild(_cutSiteTextRenderer);
			addChild(_singleCutterCutSiteTextRenderer);
			addChild(_aminoAcidsTextRenderer);
			
			// Load dummy renderers to calculate width and height
			_sequenceSymbolRenderer.textToBitmap("A");
			_complimentarySymbolRenderer.textToBitmap("A");
			_cutSiteTextRenderer.textToBitmap("EcoRI");
			_aminoAcidsTextRenderer.textToBitmap("A");
			_singleCutterCutSiteTextRenderer.textToBitmap("EcoRI");
		}
		
		private function createHighlightLayer():void
		{
			if(highlightLayer == null) {
				highlightLayer = new HighlightLayer(this);
				highlightLayer.includeInLayout = false;
				
				addChild(highlightLayer);
			}
		}
		
		private function createSelectionLayer():void
		{
			if(selectionLayer == null) {
				selectionLayer = new SelectionLayer(this);
				selectionLayer.includeInLayout = false;
				addChild(selectionLayer);
				
		        if(numChildren > 1) {
		        	swapChildren(selectionLayer, getChildAt(numChildren - 1));
		        }
		        
	            selectionLayer.addEventListener(SelectionLayerEvent.SELECTION_HANDLE_CLICKED, onSelectionHandleClicked);
				selectionLayer.addEventListener(SelectionLayerEvent.SELECTION_HANDLE_RELEASED, onSelectionHandleReleased);
			}
		}
		
		private function createCaret():void
		{
			if(!caret) {
				caret = new Caret(this);
				caret.includeInLayout = false;
				caret.hide();
	        	addChild(caret);
	        	
	        	// set caret height according to default sequence height
	        	caret.caretHeight = _showComplementary ? 2 * _sequenceSymbolRenderer.textHeight : _sequenceSymbolRenderer.textHeight;
			}
		}
		
		private function clearSequenceTextRenderers():void
		{
			_sequenceSymbolRenderer.clearCache();
			_complimentarySymbolRenderer.clearCache();
			_aminoAcidsTextRenderer.clearCache();
			
			// Load dummy renderers to calculate width and height
			_sequenceSymbolRenderer.textToBitmap("A");
			_complimentarySymbolRenderer.textToBitmap("A");
			_aminoAcidsTextRenderer.textToBitmap("A");
		}
		
		private function clearCutterTextRenderers():void
		{
			_cutSiteTextRenderer.clearCache();
			_singleCutterCutSiteTextRenderer.clearCache();
			
			// Load dummy renderers to calculate width and height
			_cutSiteTextRenderer.textToBitmap("EcoRI");
			_singleCutterCutSiteTextRenderer.textToBitmap("EcoRI");
		}
		
		private function drawBackground():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.beginFill(BACKGROUND_COLOR);
			g.drawRect(0, 0, _totalWidth, _totalHeight);
			g.endFill();
		}
		
		private function drawSplitLines():void
		{
			var g:Graphics = graphics;
			
			var numberOfRows:int = rowMapper.rows.length;
			for(var i:int = 0; i < numberOfRows; i++) {
				var row:Row = rowMapper.rows[i] as Row;
				
				if(i != numberOfRows - 1) {
					g.lineStyle(1, SPLIT_LINE_COLOR, SPLIT_LINE_TRANSPARENCY);
					g.moveTo(row.metrics.x, row.metrics.y + row.metrics.height - 1);
					g.lineTo(_totalWidth, row.metrics.y + row.metrics.height - 1);
				}
			}
		}
		
		private function bpAtPoint(point:Point):int
		{
			var numberOfRows:int = rowMapper.rows.length;
			
			var bpIndex:int = -1;
			for(var i:int = 0; i < numberOfRows; i++) {
				var row:Row = rowMapper.rows[i] as Row;
				
				if((point.y >= row.metrics.y) && (point.y <= row.metrics.y + row.metrics.height)) {
					bpIndex = i * _bpPerRow;
					
					if(point.x < row.sequenceMetrics.x) {
					} else if(point.x > row.sequenceMetrics.x + row.sequenceMetrics.width) {
						bpIndex += row.rowData.sequence.length;
					} else {
						var numberOfCharactersFromBegining:int = Math.floor((point.x - row.sequenceMetrics.x + (sequenceSymbolRenderer.textWidth - 1) / 2) / sequenceSymbolRenderer.textWidth);
						
						var numberOfSpaces:int = 0;
						
						if(_showSpaceEvery10Bp) {
							numberOfSpaces = int(numberOfCharactersFromBegining / 11);
						}
						
						var numberOfValidCharacters:int = numberOfCharactersFromBegining - numberOfSpaces;
						
						bpIndex += numberOfValidCharacters;
						//Math.floor((point.x - row.sequenceMetrics.x - numberOfSpaces * sequenceSymbolRenderer.textWidth + (sequenceSymbolRenderer.textWidth - 1) / 2) / sequenceSymbolRenderer.textWidth);
					}
					
					break;
				}
			}
			
			return bpIndex;
		}
		
		private function updateAverageRowHeight():void
		{
			var totalHeight:Number = 0;
			
			var numberOfRows:int = rowMapper.rows.length;
			for(var i:int = 0; i < numberOfRows; i++) {
				var row:Row = rowMapper.rows[i] as Row;
				
				totalHeight += row.metrics.height;
			}
			
			_averageRowHeight = (numberOfRows > 0) ? totalHeight / numberOfRows : 0;
		}
		
		private function tryMoveCaretToPosition(newPosition:int):void
		{
			if(invalidSequence) { return; }
			
			if(newPosition < 0) {
				newPosition = 0;
			} else if(newPosition > sequenceProvider.sequence.length) {
				newPosition = sequenceProvider.sequence.length;
			}
			
			moveCaretToPosition(newPosition);
		}
		
		private function moveCaretToPosition(newPosition:int):void
		{
			if(! isValidIndex(newPosition)) {
				throw new Error("Invalid caret position: " + String(newPosition));
			}
			
			if(newPosition != _caretPosition) {
				_caretPosition = newPosition;
				
				dispatchEvent(new CaretEvent(CaretEvent.CARET_POSITION_CHANGED, _caretPosition));
			}
			
			caret.position = _caretPosition;
			
			adjustContentToCaret();
		}
		
		private function validateCaret():void
		{
			tryMoveCaretToPosition(_caretPosition);
		}
		
		private function adjustContentToCaret():void
		{
			var row:Row = rowByBpIndex(_caretPosition);
			
			if(!row) { return; }
			
			if(_totalHeight < sequenceAnnotator.verticalScrollPosition + sequenceAnnotator.height) {
				this.y = sequenceAnnotator.height - _totalHeight;
				sequenceAnnotator.verticalScrollPosition = -this.y;
			}
			
			if(row.metrics.y + row.metrics.height > sequenceAnnotator.verticalScrollPosition + sequenceAnnotator.height) {
				this.y = sequenceAnnotator.height - (row.metrics.y + row.metrics.height + 20); // +20 extra space for horizontal scroll bar
				if (sequenceAnnotator.verticalScrollPosition != -this.y) {
					sequenceAnnotator.verticalScrollPosition = -this.y;
				}
			} else if(row.metrics.y < sequenceAnnotator.verticalScrollPosition) {
				this.y = -row.metrics.y;
				if (sequenceAnnotator.verticalScrollPosition != -this.y) {
					sequenceAnnotator.verticalScrollPosition = -this.y;
				}
			}
			
			if (caret.x > sequenceAnnotator.horizontalScrollPosition + sequenceAnnotator.width - 20) { // -20 vertical scroll adjustment
				this.x = sequenceAnnotator.width - Math.min(caret.x + sequenceSymbolRenderer.textWidth * 10, this.totalWidth) - 20; // shift to the right by 10bp width, -20 vertical scroll width adjustment 
				if (sequenceAnnotator.horizontalScrollPosition != -this.x) {
					sequenceAnnotator.horizontalScrollPosition = -this.x;
				}
			} else if(caret.x < sequenceAnnotator.horizontalScrollPosition + 5) { // +5 to look pretty
				this.x = -Math.max(0, caret.x - sequenceSymbolRenderer.textWidth * 10); // shift to the left by 10bp width 
				if (sequenceAnnotator.horizontalScrollPosition != -this.x) {
					sequenceAnnotator.horizontalScrollPosition = -this.x;
				}
			}
		}
		
	    private function adjustCaretSize():void
	    {
			// set caret height according to default sequence height
	        caret.caretHeight = _showComplementary ? 2 * _sequenceSymbolRenderer.textHeight : _sequenceSymbolRenderer.textHeight;
	    }
		
		private function loadFeatureRenderers():void
		{
			removeFeatureRenderers();
			
			if(!showFeatures || !_sequenceProvider.features) { return; }
			
			for(var i:int = 0; i < _sequenceProvider.features.length; i++) {
				var feature:Feature = _sequenceProvider.features[i] as Feature;
				
				var featureRenderer:FeatureRenderer = new FeatureRenderer(this, feature);
				
				addChild(featureRenderer);
				
				featureRenderers.push(featureRenderer);
			}
		}
		
		private function loadCutSiteRenderers():void
		{
			removeCutSiteRenderers();
			
			if(!showCutSites || !_restrictionEnzymeMapper || !_restrictionEnzymeMapper.cutSites) { return; }
			
			for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
				var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites[i] as RestrictionCutSite;
				
				var cutSiteRenderer:CutSiteRenderer = new CutSiteRenderer(this, cutSite);
				
				addChild(cutSiteRenderer);
				
				cutSiteRenderers.push(cutSiteRenderer);
			}
		}
		
		private function loadORFRenderers():void
		{
			removeORFRenderers();
			
			if(!showORFs || ! _orfMapper || ! _orfMapper.orfs) { return; }
			
			for(var i:int = 0; i < _orfMapper.orfs.length; i++) {
				var orf:ORF = _orfMapper.orfs[i] as ORF;
				
				var orfRenderer:ORFRenderer = new ORFRenderer(this, orf);
				
				addChild(orfRenderer);
				
				orfRenderers.push(orfRenderer);
			}
		}
		
		private function removeFeatureRenderers():void
		{
			if(! featureRenderers) { return; }
			
			while(featureRenderers.length > 0) {
				var removedFeature:FeatureRenderer = featureRenderers.pop() as FeatureRenderer;
				
				if(contains(removedFeature)) {
					removeChild(removedFeature);
				}
			}
		}
		
		private function removeCutSiteRenderers():void
		{
			if(! cutSiteRenderers) { return; }
			
			while(cutSiteRenderers.length > 0) {
				var removedCutSite:CutSiteRenderer = cutSiteRenderers.pop() as CutSiteRenderer;
				
				if(contains(removedCutSite)) {
					removeChild(removedCutSite);
				}
			}
		}
		
		private function removeORFRenderers():void
		{
			if(! orfRenderers) { return; }
			
			while(orfRenderers.length > 0) {
				var removedORF:ORFRenderer = orfRenderers.pop() as ORFRenderer;
				
				if(contains(removedORF)) {
					removeChild(removedORF);
				}
			}
		}
		
		private function renderFeatures():void
		{
			if(! featureRenderers) { return; }
			
			for(var i:int = 0; i < featureRenderers.length; i++) {
				var featureRenderer:FeatureRenderer = featureRenderers[i] as FeatureRenderer;
				
				featureRenderer.visible = _showFeatures;
				
				if(_showFeatures) {
					featureRenderer.update();
				}
			}
		}
		
		private function renderCutSites():void
		{
			if(! cutSiteRenderers) { return; }
			
			for(var i:int = 0; i < cutSiteRenderers.length; i++) {
				var cutSiteRenderer:CutSiteRenderer = cutSiteRenderers[i] as CutSiteRenderer;
				
				cutSiteRenderer.visible = _showCutSites;
				
				if(_showCutSites) {
					cutSiteRenderer.update();
				}
			}
		}
		
		private function renderORFs():void
		{
			if(! orfRenderers) { return; }
			
			for(var i:int = 0; i < orfRenderers.length; i++) {
				var orfRenderer:ORFRenderer = orfRenderers[i] as ORFRenderer;
				
				orfRenderer.visible = _showORFs;
				
				if(_showORFs) {
					orfRenderer.update();
				}
			}
		}
		
	    private function isSelected():Boolean
	    {
	    	return selectionLayer.selected;
	    }
	    
		private function showInvalidPasteSequenceAlert():void
		{
			Alert.show("Paste DNA Sequence contains invalid characters!\nAllowed only these \"ATGCUYRSWKMBVDHN\"");
		}
		
	    private function doSelect(startIndex:int, endIndex:int):void
	    {
			if(startIndex > 0 && endIndex == 0) {
				endIndex = sequenceProvider.sequence.length - 1;
			}
			
			selectionLayer.deselect();
			if(isValidIndex(startIndex) && isValidIndex(endIndex)) {
				selectionLayer.startSelecting();
				selectionLayer.select(startIndex, endIndex);
				selectionLayer.endSelecting();
			}
			
			startSelectionIndex = startIndex;
			endSelectionIndex = endIndex;
	    }
	    
	    private function doDeselect():void
	    {
	    	startSelectionIndex = -1;
	    	endSelectionIndex = -1;
	    	selectionLayer.deselect();
	    }
		
		private function doDeleteSequence(start:int, end:int):void
		{
			if(! _readOnly) {
				dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_DELETE, new Array(start, end)));
			}
		}
		
		private function doInsertSequence(dnaSequence:SymbolList, position:int):void
		{
			if(! _readOnly) {
				dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_SEQUENCE, new Array(dnaSequence, position)));
			}
		}
		
		private function doInsertSequenceProvider(currentSequenceProvider:SequenceProvider, position:int):void
		{
			if(! _readOnly) {
				dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_FEATURED_SEQUENCE, new Array(currentSequenceProvider, position)));
			}
		}
        
        private function isValidDigestionRegion():Boolean
        {
            if(!_showCutSites || !_restrictionEnzymeMapper || !_restrictionEnzymeMapper.cutSites || _restrictionEnzymeMapper.cutSites.length == 0) {
            
                return false;
            }
            
            var matchedStart:Boolean = false;
            var matchedEnd:Boolean = false;

            for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
                var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites.getItemAt(i) as RestrictionCutSite;

                if(selectionLayer.start == cutSite.start) {
                    matchedStart = true;
                }
                
                if(selectionLayer.end == cutSite.end) {
                    matchedEnd = true;
                }
                            
                if(matchedStart && matchedEnd) {
                    break;
                }
                
            }
            
            return matchedStart && matchedEnd;
        }
	}
}
