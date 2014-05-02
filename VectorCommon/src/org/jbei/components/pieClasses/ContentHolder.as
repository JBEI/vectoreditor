package org.jbei.components.pieClasses
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
    import flash.utils.Dictionary;
    
    import mx.controls.Alert;
    import mx.core.EdgeMetrics;
    import mx.core.UIComponent;
    
    import org.jbei.bio.enzymes.RestrictionCutSite;
    import org.jbei.bio.orf.ORF;
    import org.jbei.bio.sequence.DNATools;
    import org.jbei.bio.sequence.common.Annotation;
    import org.jbei.bio.sequence.common.SymbolList;
    import org.jbei.bio.sequence.dna.Feature;
    import org.jbei.components.Pie;
    import org.jbei.components.common.Alignment;
    import org.jbei.components.common.AnnotationRenderer;
    import org.jbei.components.common.CaretEvent;
    import org.jbei.components.common.CommonEvent;
    import org.jbei.components.common.Constants;
    import org.jbei.components.common.EditingEvent;
    import org.jbei.components.common.IContentHolder;
    import org.jbei.components.common.LabelBox;
    import org.jbei.components.common.PasteDialogForm;
    import org.jbei.components.common.SelectionEvent;
    import org.jbei.components.common.SequenceUtils;
    import org.jbei.components.common.TextRenderer;
    import org.jbei.lib.SequenceProvider;
    import org.jbei.lib.data.DigestionSequence;
    import org.jbei.lib.data.TraceAnnotation;
    import org.jbei.lib.mappers.DigestionCutter;
    import org.jbei.lib.mappers.ORFMapper;
    import org.jbei.lib.mappers.RestrictionEnzymeMapper;
    import org.jbei.lib.mappers.TraceMapper;
    import org.jbei.lib.ui.dialogs.ModalDialog;
    import org.jbei.lib.ui.dialogs.ModalDialogEvent;
    import org.jbei.registry.utils.IceXmlUtils;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class ContentHolder extends UIComponent implements IContentHolder
	{
		private const BACKGROUND_COLOR:int = 0xFFFFFF;
		private const CONNECTOR_LINE_COLOR:int = 0x000000;
		private const CONNECTOR_LINE_TRASPARENCY:Number = 0.2;
		private const PIE_RADIUS_PERCENTS:Number = 0.60;
		private const SELECTION_THRESHOLD:Number = 5;
		private const DISTANCE_LABEL_FROM_RAIL:int = 30;
        private const LABEL_FONT_FACE:String = "Tahoma";
		private const FEATURE_LABEL_FONT_COLOR:int = 0x000000;
		private const CUTSITES_LABEL_FONT_COLOR:int = 0x888888;
		private const SINGLE_CUTTER_LABEL_FONT_COLOR:int = 0xE57676;
		
		private var pie:Pie;
		private var railBox:RailBox;
		private var selectionLayer:SelectionLayer;
		private var caret:Caret;
		private var nameBox:NameBox;
		private var highlightLayer:HighlightLayer;
		private var wireframeSelectionLayer:WireframeSelectionLayer;
		
		private var customContextMenu:ContextMenu;
		private var editFeatureContextMenuItem:ContextMenuItem;
		private var removeFeatureContextMenuItem:ContextMenuItem;
		private var selectedAsNewFeatureContextMenuItem:ContextMenuItem;
		
		private var _sequenceProvider:SequenceProvider;
		private var _orfMapper:ORFMapper;
		private var _traceMapper:TraceMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Annotation */;
		private var _labelFontSize:int = 10;
		
		private var _cutSiteTextRenderer:TextRenderer;
		private var _singleCutterCutSiteTextRenderer:TextRenderer;
		private var _featureTextRenderer:TextRenderer;
		
		private var _center:Point = new Point(0, 0);
		private var _caretPosition:int;
		private var _railRadius:Number = 0;
		private var parentWidth:Number = 0;
		private var parentHeight:Number = 0;
		private var shiftKeyDown:Boolean = false;
		private var shiftDownCaretPosition:int = -1;
		private var featureRenderers:Array = new Array(); /* of FeatureRenderer */
		private var cutSiteRenderers:Array = new Array(); /* of CutSiteRenderer */
		private var orfRenderers:Array = new Array(); /* of ORFRenderer */
		private var traceRenderers:Array = new Array(); /* of TraceRenderer */
		private var labelBoxes:Array /* of LabelBox */  = new Array();
		private var leftTopLabels:Array /* of LabelBox */ = new Array();
		private var leftBottomLabels:Array /* of LabelBox */ = new Array();
		private var rightTopLabels:Array /* of LabelBox */ = new Array();
		private var rightBottomLabels:Array /* of LabelBox */ = new Array();
		private var featuresToRendererMap:Dictionary = new Dictionary(); /* [Feature] = FeatureRenderer  */
		private var cutSitesToRendererMap:Dictionary = new Dictionary(); /* [CutSite] = CutSiteRenderer  */
		private var _totalHeight:int = 0;
		private var _totalWidth:int = 0;
		private var _readOnly:Boolean = true;
		private var _showFeatures:Boolean = true;
		private var _showCutSites:Boolean = false;
		private var _showORFs:Boolean = false;
		private var _showTraces:Boolean = false;
		private var _showFeatureLabels:Boolean = true;
		private var _showCutSiteLabels:Boolean = true;
		private var _safeEditing:Boolean = true;
		
		private var mouseIsDown:Boolean = false;
		private var clickPoint:Point;
		private var invalidSequence:Boolean = true;
		private var startSelectionIndex:int;
		private var endSelectionIndex:int;
		private var selectionDirection:int = 0;
		private var startSelectionAngle:Number;
		
		private var sequenceProviderChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var traceMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		private var featuresAlignmentChanged:Boolean = false;
		private var orfsAlignmentChanged:Boolean = false;
		private var tracesAlignmentChanged:Boolean = false;
		private var needsMeasurement:Boolean = false;
		private var showFeaturesChanged:Boolean = false;
		private var showCutSitesChanged:Boolean = false;
		private var showFeatureLabelsChanged:Boolean = false;
		private var showCutSiteLabelsChanged:Boolean = false;
		private var showORFsChanged:Boolean = false;
		private var showTracesChanged:Boolean = false;
		private var labelFontSizeChanged:Boolean = false;
		
		private var featureAlignmentMap:Dictionary;
		private var orfAlignmentMap:Dictionary;
		private var tracesAlignmentMap:Dictionary;
		private var maxORFAlignmentRow:int;
		private var maxTracesAlignmentRow:int;
		
        private var digestionCutter:DigestionCutter;
        private var pasteData:Object = null;
        
		// Contructor
		public function ContentHolder(pie:Pie)
		{
			super();
			
			this.pie = pie;
			
			doubleClickEnabled = true;
		}
		
		// Properties
		public function get sequenceProvider():SequenceProvider
		{
			return _sequenceProvider;
		}
		
		public function set sequenceProvider(value:SequenceProvider):void
		{
			_sequenceProvider = value;
			
			if(_sequenceProvider) {
				initializeSequence();
				
				invalidateProperties();
				
                sequenceProviderChanged = true;
			} else {
				disableSequence();
				
				invalidateDisplayList();
			}
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
		
		public function get traceMapper():TraceMapper
		{
			return _traceMapper;
		}
		
		public function set traceMapper(value:TraceMapper):void
		{
			_traceMapper = value;
			
			invalidateProperties();
			
			traceMapperChanged = true;
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

		public function get showFeatureLabels():Boolean
		{
			return _showFeatureLabels;
		}
		
		public function set showFeatureLabels(value:Boolean):void
		{
			if(_showFeatureLabels != value) {
				_showFeatureLabels = value;
				
				invalidateProperties();
				
				showFeatureLabelsChanged = true;
			}
		}
		
		public function get showCutSiteLabels():Boolean
		{
			return _showCutSiteLabels;
		}
		
		public function set showCutSiteLabels(value:Boolean):void
		{
			if(_showCutSiteLabels != value) {
				_showCutSiteLabels = value;
				
				invalidateProperties();
				
				showCutSiteLabelsChanged = true;
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
				
				invalidateProperties();
				
				showORFsChanged = true;
			}
		}
		
		public function get showTraces():Boolean
		{
			return _showTraces;
		}
		
		public function set showTraces(value:Boolean):void
		{
			if(_showTraces != value) {
				_showTraces = value;
				
				invalidateProperties();
				
				showTracesChanged = true;
			}
		}
		
		public function get caretPosition():int
		{
			return _caretPosition;
		}
		
		public function set caretPosition(value:int):void
		{
			if(_caretPosition != value) {
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
		
		public function get center():Point
		{
			return _center;
		}
		
		public function get railRadius():Number
		{
			return _railRadius;
		}
		
		public function get totalHeight():Number
		{
			return _totalHeight;
		}
		
		public function get totalWidth():Number
		{
			return _totalWidth;
		}
		
	    public function get selectionStart():int
	    {
	    	return startSelectionIndex;
	    }
	    
	    public function get selectionEnd():int
	    {
	    	return endSelectionIndex;
	    }
	    
		public function get cutSiteTextRenderer():TextRenderer
		{
			return _cutSiteTextRenderer;
		}
		
		public function get singleCutterCutSiteTextRenderer():TextRenderer
		{
			return _singleCutterCutSiteTextRenderer;
		}
		
		public function get featureTextRenderer():TextRenderer
		{
			return _featureTextRenderer;
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
		public function updateMetrics(parentWidth:Number, parentHeight:Number):void
		{
			this.parentWidth = parentWidth;
			this.parentHeight = parentHeight;
			
        	_center = new Point(parentWidth / 2, parentHeight / 2);
        	_railRadius = PIE_RADIUS_PERCENTS * Math.min(parentWidth / 2, parentHeight / 2);
			
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		public function select(startIndex: int, endIndex: int):void
		{
			if(invalidSequence) { return; }
			
			if(!isValidIndex(startIndex) || !isValidIndex(endIndex)) {
				deselect();
			} else if((selectionLayer.start != startIndex || selectionLayer.end != endIndex) && startIndex != endIndex) {
				doSelect(startIndex, endIndex);
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
			}
		}
		
		public function deselect():void
		{
			if(invalidSequence) { return; }
			
			if(selectionLayer.start != -1 || selectionLayer.end != -1) {
				doDeselect();
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
			}
		}
		
		public function showCaret():void
		{
			if(invalidSequence) { return; }
			
			caret.show();
		}
		
		public function hideCaret():void
		{
			if(invalidSequence) { return; }
			
			caret.hide();
		}
		
		public function isValidIndex(index:int):Boolean
		{
			return index >= 0 && index <= sequenceProvider.sequence.length;
		}
		
		public function contentBitmapData(pageWidth:Number, pageHeight:Number, scaleToPage:Boolean = false, page:int = 0):BitmapData
		{
			var bitmapData:BitmapData;
			
			var matrix:Matrix = new Matrix();
			if(scaleToPage) {
				bitmapData = new BitmapData(pageWidth, pageHeight);
				
				var scaleX:Number = pageWidth / _totalWidth;
				var scaleY:Number = pageHeight / _totalHeight;
				
				var relativeScale:Number = Math.min(scaleX, scaleY);
				
				matrix.scale(relativeScale, relativeScale);
				
				bitmapData.draw(this, matrix);
			} else {
				var currentHeight:Number = Math.min(pageHeight, totalHeight - pageHeight * page);
				
				bitmapData = new BitmapData(pageWidth, currentHeight);
				matrix.ty = -pageHeight * page;
				bitmapData.draw(this, matrix, null, null, new Rectangle(0, 0, pageWidth, currentHeight));
			}
			
			return bitmapData;
		}
		
	    // Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			createContextMenu();
			
	        createRailBox();
			
			createNameBox();
			
			createHighlightLayer();
			
	        createSelectionLayer();
	        
	        createCaret();
			
			createTextRenderers();
			
			createWireframeSelectionLayer();
	 	}
	 	
	 	protected override function commitProperties():void
	 	{
	 		super.commitProperties();
	 		
			if(invalidSequence) { return; }
			
			if(sequenceProviderChanged) {
                sequenceProviderChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(labelFontSizeChanged) {
				labelFontSizeChanged = false;
				
				needsMeasurement = true;
				
				var cutSiteTextFormat:TextFormat = new TextFormat(LABEL_FONT_FACE, _labelFontSize, CUTSITES_LABEL_FONT_COLOR);
				var singleCutterCutSiteTextFormat:TextFormat = new TextFormat(LABEL_FONT_FACE, _labelFontSize, SINGLE_CUTTER_LABEL_FONT_COLOR);
				var featureTextFormat:TextFormat = new TextFormat(LABEL_FONT_FACE, _labelFontSize + 1, FEATURE_LABEL_FONT_COLOR);
				
				_cutSiteTextRenderer.textFormat = cutSiteTextFormat;
				_singleCutterCutSiteTextRenderer.textFormat = singleCutterCutSiteTextFormat;
				_featureTextRenderer.textFormat = featureTextFormat;
				
				clearLabelTextRenderers();
				
				invalidateDisplayList();
			}
			
			if(restrictionEnzymeMapperChanged) {
				restrictionEnzymeMapperChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(orfMapperChanged) {
				orfMapperChanged = false;
				
				needsMeasurement = true;
				orfsAlignmentChanged = true;
				
				invalidateDisplayList();
			}
			
			if(traceMapperChanged) {
				traceMapperChanged = false;
				
				needsMeasurement = true;
				tracesAlignmentChanged = true;
				
				invalidateDisplayList();
			}
			
			if(showFeaturesChanged) {
				showFeaturesChanged = false;
				
				needsMeasurement = true;
				featuresAlignmentChanged = true;
				
				invalidateDisplayList();
			}
			
			if(showCutSitesChanged) {
				showCutSitesChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(showFeatureLabelsChanged) {
				showFeatureLabelsChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(showCutSiteLabelsChanged) {
				showCutSiteLabelsChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
	        if(showORFsChanged) {
	        	showORFsChanged = false;
	        	
	        	needsMeasurement = true;
	        	orfsAlignmentChanged = true;
	        	
	        	invalidateDisplayList();
	        }
			
			if(showTracesChanged) {
				showTracesChanged = false;
				
				needsMeasurement = true;
				tracesAlignmentChanged = true;
				
				invalidateDisplayList();
			}
	 	}
	 	
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        
			if(invalidSequence) {
				removeLabels();
				removeFeatureRenderers();
				removeCutSiteRenderers();
				removeORFRenderers();
				removeTraceRenderers();
				
				
				_totalHeight = parentHeight;
				_totalWidth = parentWidth;
				
				drawBackground();
				
				doDeselect();
				caret.hide();
				
				return;
			}
			
			if(featuresAlignmentChanged) {
	        	featuresAlignmentChanged = false;
	        	
		        rebuildFeaturesAlignment();
	        }
	        
			if(orfsAlignmentChanged) {
	        	orfsAlignmentChanged = false;
	        	
		        rebuildORFsAlignment();
	        }
	        
			if(tracesAlignmentChanged) {
				tracesAlignmentChanged = false;
				
				rebuildTraceAlignment();
			}
			
			if(highlightsChanged && !needsMeasurement) {
				highlightsChanged = false;
				
				highlightLayer.update();
			}
			
	        if(needsMeasurement) {
	        	needsMeasurement = false;
	        	
				_totalHeight = parentHeight;
				_totalWidth = parentWidth;
				
	        	loadFeatureRenderers();
				loadCutSiteRenderers();
				loadORFRenderers();
				loadTraceRenderers();
	        	loadLabels();
		        
		        renderLabels();
		        renderFeatures();
				renderCutSites();
				renderORFs();
				renderTraces();
		        
		        // update children metrics
				railBox.updateMetrics();
		        
		        caret.updateMetrics(_center, _railRadius + 10);
				
				nameBox.update(_center, _sequenceProvider.name, _sequenceProvider.sequence.length);
		        
				if(highlightsChanged) {
					highlightsChanged = false;
				}
				
				highlightLayer.update();
				
	        	drawBackground();
		        drawConnections();
		        
		        selectionLayer.updateMetrics(_railRadius + 10, _center);
				wireframeSelectionLayer.updateMetrics(_railRadius + 10, _center);
				
				if(isValidIndex(startSelectionIndex) && isValidIndex(endSelectionIndex)) {
					selectionLayer.deselect();
					doSelect(startSelectionIndex, endSelectionIndex);
				}
	        }
			
			width = _totalWidth;
			height = _totalHeight;
			
			validateCaret();
		}
		
        // Event Handlers
	    private function onMouseDown(event:MouseEvent):void
	    {
	    	if(event.target is AnnotationRenderer) { return; }
	    	
	    	if(selectionLayer.selected) {
	    		deselect();
	    	}
	    	
	    	mouseIsDown = true;
			selectionDirection = 0;
	    	
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			startSelectionIndex = bpAtPoint(new Point(event.stageX, event.stageY));
			startSelectionAngle = startSelectionIndex * 2 * Math.PI / _sequenceProvider.sequence.length;
			
			clickPoint = new Point(event.stageX, event.stageY);
			
			tryMoveCaretToPosition(startSelectionIndex);
			
			wireframeSelectionLayer.show();
	    }
	    
	    private function onMouseMove(event:MouseEvent):void
	    {
	    	if((mouseIsDown && Point.distance(clickPoint, new Point(event.stageX, event.stageY)) > SELECTION_THRESHOLD)) {
	    		endSelectionIndex = bpAtPoint(new Point(event.stageX, event.stageY));
	    		
				if(selectionDirection == 0) {
					var endSelectionAngle:Number = endSelectionIndex * 2 * Math.PI / _sequenceProvider.sequence.length;
					
					if(startSelectionAngle < Math.PI) {
						selectionDirection = (endSelectionAngle >= startSelectionAngle && endSelectionAngle <= (startSelectionAngle + Math.PI)) ? 1 : -1;
					} else {
						selectionDirection = (endSelectionAngle <= startSelectionAngle && endSelectionAngle >= (startSelectionAngle - Math.PI)) ? -1 : 1;
					}
				}
				
				var start:int = (selectionDirection == -1) ? endSelectionIndex : startSelectionIndex;
				var end:int = (selectionDirection == -1) ? startSelectionIndex : endSelectionIndex;
				
	    		wireframeSelectionLayer.startSelecting();
				wireframeSelectionLayer.select(start, end);
				
				if(event.ctrlKey) { // regular selection
					selectionLayer.startSelecting();
					selectionLayer.select(start, end);
					
					dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
				} else { // sticky selection
					doStickySelect(start, end);
				}
				
				tryMoveCaretToPosition(end);
	    	}
	    }
	    
		private function onMouseUp(event:MouseEvent):void
	    {
	    	if(!mouseIsDown) { return; }
	    	
	    	mouseIsDown = false;
	    	stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	    	stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	    	
	    	if(wireframeSelectionLayer.selected && wireframeSelectionLayer.selecting) {
				wireframeSelectionLayer.endSelecting();
				selectionLayer.endSelecting();
		    	
		    	dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end));
				
				wireframeSelectionLayer.hide();
	    	}
	    }
	    
        private function onMouseDoubleClick(event:MouseEvent):void
        {
        	if(event.target is FeatureRenderer) {
        		dispatchEvent(new CommonEvent(CommonEvent.EDIT_FEATURE, true, false, (event.target as FeatureRenderer).feature));
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
                
                var start:int = (startSelectionIndex > endSelectionIndex) ? endSelectionIndex : startSelectionIndex;
                var end:int = (startSelectionIndex > endSelectionIndex) ? startSelectionIndex : endSelectionIndex;
                
                for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
                    var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites.getItemAt(i) as RestrictionCutSite;
                    
                    if(start == cutSite.start) {
                        digestionStart = start;
                        digestionStartCutSite = cutSite;
                    }
                    
                    if(end == cutSite.end) {
                        digestionEnd = end;
                        digestionEndCutSite = cutSite;
                    }
                }
            }
            
            var externalContext:Object = new Object();
            if(digestionStart >= 0 && digestionEnd >= 0) {
                var subSequenceProvider:SequenceProvider = _sequenceProvider.subSequenceProvider(digestionStart, digestionEnd);
                var digestionSequence:DigestionSequence = new DigestionSequence(subSequenceProvider, digestionStartCutSite.restrictionEnzyme, digestionEndCutSite.restrictionEnzyme, 0, digestionEndCutSite.start - digestionStartCutSite.start);
                
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
			if(shiftKeyDown) {
				if(_caretPosition != shiftDownCaretPosition) {
					select(shiftDownCaretPosition, _caretPosition);
				} else {
					deselect();
				}
			}
			
	    	if(!event.shiftKey) {
	    		shiftKeyDown = false;
	    	}
	    }
	    
	    private function onKeyDown(event:KeyboardEvent):void
	    {
	    	if(! _sequenceProvider) { return; }
	    	
	    	if(event.shiftKey && !shiftKeyDown) {
	    		shiftDownCaretPosition = _caretPosition;
	    		shiftKeyDown = true;
	    	}
	    	
	    	if(event.keyCode == Keyboard.LEFT) {
    			tryMoveCaretToPosition(_caretPosition - 1);
	    	} else if(event.keyCode == Keyboard.RIGHT) {
				tryMoveCaretToPosition(_caretPosition + 1);
	    	}
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
            
            featureAlignmentMap = null;
            orfAlignmentMap = null;
            tracesAlignmentMap = null;
            
            caretPosition = 0;
            
            removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
            
            pie.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            pie.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            pie.removeEventListener(Event.SELECT_ALL, onSelectAll);
            pie.removeEventListener(Event.COPY, onCopy);
            if(!_readOnly) {
                pie.removeEventListener(Event.CUT, onCut);
                pie.removeEventListener(Event.PASTE, onPaste);
            }
            
            removeEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
        }
        
        private function initializeSequence():void
        {
            invalidSequence = false;
            
            featuresAlignmentChanged = true;
            orfsAlignmentChanged = true;
            tracesAlignmentChanged = true;
            
            if(selectionLayer.selected) {
                doDeselect();
            }
            
            _caretPosition = 0;
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
            
            pie.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            pie.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            pie.addEventListener(Event.SELECT_ALL, onSelectAll);
            pie.addEventListener(Event.COPY, onCopy);
            if(!_readOnly) {
                pie.addEventListener(Event.CUT, onCut);
                pie.addEventListener(Event.PASTE, onPaste);
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
        
        private function createRailBox():void
        {
            if(!railBox) {
                railBox = new RailBox(this);
                railBox.includeInLayout = false;
                
                addChild(railBox);
            }
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
            if(!selectionLayer) {
                selectionLayer = new SelectionLayer(this);
                selectionLayer.includeInLayout = false;
                addChild(selectionLayer);
            }
        }
        
        private function createNameBox():void
        {
            if(!nameBox) {
                nameBox = new NameBox(this);
                nameBox.includeInLayout = false;
                addChild(nameBox);
            }
        }
        
        private function createCaret():void
        {
            if(!caret) {
                caret = new Caret(this);
                caret.includeInLayout = false;
                addChild(caret);
            }
        }
        
        private function createTextRenderers():void
        {
            _cutSiteTextRenderer = new TextRenderer(new TextFormat(LABEL_FONT_FACE, labelFontSize, CUTSITES_LABEL_FONT_COLOR));
            _cutSiteTextRenderer.includeInLayout = false;
            _cutSiteTextRenderer.visible = false;
            
            _singleCutterCutSiteTextRenderer = new TextRenderer(new TextFormat(LABEL_FONT_FACE, labelFontSize, SINGLE_CUTTER_LABEL_FONT_COLOR));
            _singleCutterCutSiteTextRenderer.includeInLayout = false;
            _singleCutterCutSiteTextRenderer.visible = false;
            
            _featureTextRenderer = new TextRenderer(new TextFormat(LABEL_FONT_FACE, labelFontSize + 1, FEATURE_LABEL_FONT_COLOR));
            _featureTextRenderer.includeInLayout = false;
            _featureTextRenderer.visible = false;
            
            addChild(_cutSiteTextRenderer);
            addChild(_singleCutterCutSiteTextRenderer);
            addChild(_featureTextRenderer);
            
            // Load dummy renderers to calculate width and height
            _cutSiteTextRenderer.textToBitmap("EcoRI");
            _singleCutterCutSiteTextRenderer.textToBitmap("EcoRI");
            _featureTextRenderer.textToBitmap("EcoRI");
        }
        
        private function createWireframeSelectionLayer():void
        {
            if(!wireframeSelectionLayer) {
                wireframeSelectionLayer = new WireframeSelectionLayer(this);
                wireframeSelectionLayer.includeInLayout = false;
                addChild(wireframeSelectionLayer);
            }
        }
        
		private function drawBackground():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.beginFill(BACKGROUND_COLOR);
			g.drawRect(0, 0, _totalWidth, _totalHeight);
			g.endFill();
		}
		
		private function removeLabels():void
		{
			// Remove old leftTopLabels
			var numberOfLeftTopLabels:uint = leftTopLabels.length;
			if(numberOfLeftTopLabels > 0) {
				for(var i1:int = numberOfLeftTopLabels - 1; i1 >= 0; i1--) {
					removeChild(leftTopLabels[i1]);
					leftTopLabels.pop();
				}
			}
			
			// Remove old rightTopLabels
			var numberOfRightTopLabels:uint = rightTopLabels.length;
			if(numberOfRightTopLabels > 0) {
				for(var i2:int = numberOfRightTopLabels - 1; i2 >= 0; i2--) {
					removeChild(rightTopLabels[i2]);
					rightTopLabels.pop();
				}
			}
			
			// Remove old leftBottomLabels
			var numberOfLeftBottomLabels:uint = leftBottomLabels.length;
			if(numberOfLeftBottomLabels > 0) {
				for(var i3:int = numberOfLeftBottomLabels - 1; i3 >= 0; i3--) {
					removeChild(leftBottomLabels[i3]);
					leftBottomLabels.pop();
				}
			}
			
			// Remove old rightBottomLabels
			var numberOfRightBottomLabels:uint = rightBottomLabels.length;
			if(numberOfRightBottomLabels > 0) {
				for(var i4:int = numberOfRightBottomLabels - 1; i4 >= 0; i4--) {
					removeChild(rightBottomLabels[i4]);
					rightBottomLabels.pop();
				}
			}
			
			var numberOfLabels:uint = labelBoxes.length;
			if(numberOfLabels > 0) {
				for(var k:int = numberOfLabels - 1; k >= 0; k--) {
					labelBoxes.pop();
				}
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
		
		private function removeTraceRenderers():void
		{
			if(! traceRenderers) { return; }
			
			while(traceRenderers.length > 0) {
				var removedTraceRenderer:TraceRenderer = traceRenderers.pop() as TraceRenderer;
				
				if(contains(removedTraceRenderer)) {
					removeChild(removedTraceRenderer);
				}
			}
		}
		
		private function renderLabels():void
		{
			// Apply display settings to labelBoxes
			var adjustedContentMetrics:EdgeMetrics = new EdgeMetrics();
			
			var labelRadius:Number = _railRadius + DISTANCE_LABEL_FROM_RAIL;
			
			if(_showORFs && maxORFAlignmentRow > 0) {
				labelRadius += maxORFAlignmentRow * ORFRenderer.DISTANCE_BETWEEN_ORFS;
			}
			
            if(_showTraces && maxTracesAlignmentRow > 0) {
                labelRadius += maxTracesAlignmentRow * TraceRenderer.DISTANCE_BETWEEN_TRACES;
            }
            
			// Scale Right Top Labels
			var lastLabelYPosition:Number = _center.y - 15; // -15 to count label height
			var numberOfRightTopLabels:uint = rightTopLabels.length;
			for(var i1:int = numberOfRightTopLabels - 1; i1 >= 0; i1--) {
				var labelBox1:LabelBox = rightTopLabels[i1] as LabelBox;
				
				if(! labelBox1.includeInView) { continue; }
				
				var label1Center:int = annotationCenter(labelBox1.relatedAnnotation);
				var angle1:Number = label1Center * 2 * Math.PI / _sequenceProvider.sequence.length;
				
				var xPosition1:Number = _center.x + Math.sin(angle1) * labelRadius;
				var yPosition1:Number = _center.y - Math.cos(angle1) * labelRadius;
				
				if(yPosition1 < lastLabelYPosition) {
					lastLabelYPosition = yPosition1 - labelBox1.totalHeight;
				} else {
					yPosition1 = lastLabelYPosition;
					
					lastLabelYPosition = yPosition1 - labelBox1.totalHeight;
				}
				
				labelBox1.x = xPosition1;
				labelBox1.y = yPosition1;
				
				// Measure outling labels
				if(_totalWidth + adjustedContentMetrics.right < xPosition1 + labelBox1.totalWidth) {
					adjustedContentMetrics.right = xPosition1 + labelBox1.totalWidth - _totalWidth;
				}
				if(adjustedContentMetrics.top > yPosition1) {
					adjustedContentMetrics.top = yPosition1;
				}
			}

			// Scale Right Bottom Labels
			lastLabelYPosition = _center.y;
			var numberOfRightBottomLabels:uint = rightBottomLabels.length;
			for(var i2:int = 0; i2 < numberOfRightBottomLabels; i2++) {
				var labelBox2:LabelBox = rightBottomLabels[i2] as LabelBox;
				
				if(! labelBox2.includeInView) { continue; }
				
				var label2Center:int = annotationCenter(labelBox2.relatedAnnotation);
				var angle2:Number = label2Center * 2 * Math.PI / _sequenceProvider.sequence.length - Math.PI / 2;
				
				var xPosition2:Number = _center.x + Math.cos(angle2) * labelRadius;
				var yPosition2:Number = _center.y + Math.sin(angle2) * labelRadius;
				
				if(yPosition2 > lastLabelYPosition) {
					lastLabelYPosition = yPosition2 + labelBox2.totalHeight;
				} else {
					yPosition2 = lastLabelYPosition;
					
					lastLabelYPosition = yPosition2 + labelBox2.totalHeight;
				}
				
				labelBox2.x = xPosition2;
				labelBox2.y = yPosition2;
				
				// Measure outling labels
				if(_totalWidth + adjustedContentMetrics.right < xPosition2 + labelBox2.totalWidth) {
					adjustedContentMetrics.right = xPosition2 + labelBox2.totalWidth - _totalWidth;
				}
				if(_totalHeight + adjustedContentMetrics.bottom < yPosition2 + labelBox2.totalHeight) {
					adjustedContentMetrics.bottom = yPosition2 + labelBox2.totalHeight - _totalHeight;
				}
			}
			
			// Scale Left Top Labels
			lastLabelYPosition = _center.y - 15; // -15 to count label totalHeight
			var numberOfLeftTopLabels:uint = leftTopLabels.length;
			for(var i3:int = 0; i3 < numberOfLeftTopLabels; i3++) {
				var labelBox3:LabelBox = leftTopLabels[i3] as LabelBox;
				
				if(! labelBox3.includeInView) { continue; }
				
				var label3Center:int = annotationCenter(labelBox3.relatedAnnotation);
				var angle3:Number = 2 * Math.PI - label3Center * 2 * Math.PI / _sequenceProvider.sequence.length;
				
				var xPosition3:Number = _center.x - Math.sin(angle3) * labelRadius - labelBox3.totalWidth;
				var yPosition3:Number = _center.y - Math.cos(angle3) * labelRadius;
				
				if(yPosition3 < lastLabelYPosition) {
					lastLabelYPosition = yPosition3 - labelBox3.totalHeight;
				} else {
					yPosition3 = lastLabelYPosition;
					
					lastLabelYPosition = yPosition3 - labelBox3.totalHeight;
				}
				
				labelBox3.x = xPosition3;
				labelBox3.y = yPosition3;
				
				// Measure outling labels
				if(adjustedContentMetrics.left > xPosition3) {
					adjustedContentMetrics.left = xPosition3;
				}
				if(adjustedContentMetrics.top > yPosition3) {
					adjustedContentMetrics.top = yPosition3;
				}
			}
			
			// Scale Left Bottom Labels
			lastLabelYPosition = _center.y;
			var numberOfLeftBottomLabels:uint = leftBottomLabels.length;
			for(var i4:int = numberOfLeftBottomLabels - 1; i4 >= 0; i4--) {
				var labelBox4:LabelBox = leftBottomLabels[i4] as LabelBox;
				
				if(! labelBox4.includeInView) { continue; }
				
				var label4Center:int = annotationCenter(labelBox4.relatedAnnotation);
				var angle4:Number = label4Center * 2 * Math.PI / _sequenceProvider.sequence.length - Math.PI;
				
				var xPosition4:Number = _center.x - Math.sin(angle4) * labelRadius - labelBox4.totalWidth;
				var yPosition4:Number = _center.y + Math.cos(angle4) * labelRadius;
				
				if(yPosition4 > lastLabelYPosition) {
					lastLabelYPosition = yPosition4 + labelBox4.totalHeight;
				} else {
					yPosition4 = lastLabelYPosition;
					
					lastLabelYPosition = yPosition4 + labelBox4.totalHeight;
				}
				
				labelBox4.x = xPosition4;
				labelBox4.y = yPosition4;
				
				// Measure outling labels
				if(adjustedContentMetrics.left > xPosition4) {
					adjustedContentMetrics.left = xPosition4;
				}
				if(_totalHeight + adjustedContentMetrics.bottom < yPosition4 + labelBox4.totalHeight) {
					adjustedContentMetrics.bottom = yPosition4 + labelBox4.totalHeight - _totalHeight;
				}
			}
			
			// Move all labels because content metrics are going to be adjusted
			if(adjustedContentMetrics.left != 0) {
				for(var j1:int = 0; j1 < numberOfRightTopLabels; j1++) { rightTopLabels[j1].x += Math.abs(adjustedContentMetrics.left) + 10; } // +10 to look pretty
				for(var j2:int = 0; j2 < numberOfRightBottomLabels; j2++) { rightBottomLabels[j2].x += Math.abs(adjustedContentMetrics.left) + 10; } // +10 to look pretty
				for(var j3:int = 0; j3 < numberOfLeftTopLabels; j3++) { leftTopLabels[j3].x += Math.abs(adjustedContentMetrics.left) + 10; } // +10 to look pretty
				for(var j4:int = 0; j4 < numberOfLeftBottomLabels; j4++) { leftBottomLabels[j4].x += Math.abs(adjustedContentMetrics.left) + 10; } // +10 to look pretty
				
				_center.x += Math.abs(adjustedContentMetrics.left) + 10; // +10 to look pretty
			}
			
			if(adjustedContentMetrics.top != 0) {
				for(var z1:int = 0; z1 < numberOfRightTopLabels; z1++) { rightTopLabels[z1].y += Math.abs(adjustedContentMetrics.top) + 10; } // +10 to look pretty
				for(var z2:int = 0; z2 < numberOfRightBottomLabels; z2++) { rightBottomLabels[z2].y += Math.abs(adjustedContentMetrics.top) + 10; } // +10 to look pretty
				for(var z3:int = 0; z3 < numberOfLeftTopLabels; z3++) { leftTopLabels[z3].y += Math.abs(adjustedContentMetrics.top) + 10; } // +10 to look pretty
				for(var z4:int = 0; z4 < numberOfLeftBottomLabels; z4++) { leftBottomLabels[z4].y += Math.abs(adjustedContentMetrics.top) + 10; } // +10 to look pretty
				
				_center.y += Math.abs(adjustedContentMetrics.top) + 10; // +10 to look pretty
			}
			
			// Adjust content metrics
			if(adjustedContentMetrics.left != 0 || adjustedContentMetrics.right != 0) {
				_totalWidth += Math.abs(adjustedContentMetrics.left) + adjustedContentMetrics.right + 30; // + 20 because scrolls takes space also, +10 to look pretty
			}
			if(adjustedContentMetrics.top != 0 || adjustedContentMetrics.bottom != 0) {
				_totalHeight += Math.abs(adjustedContentMetrics.top) + adjustedContentMetrics.bottom + 30; // + 20 because scrolls takes space also, +10 to look pretty
			}
 		}
 		
		private function renderFeatures():void
		{
			if(! featureRenderers) { return; }
			
			for(var i:int = 0; i < featureRenderers.length; i++) {
				var featureRenderer:FeatureRenderer = featureRenderers[i] as FeatureRenderer;
				
				featureRenderer.visible = _showFeatures;
				
				if(_showFeatures) {
					featureRenderer.update(_railRadius, _center, featureAlignmentMap[featureRenderer.feature]);
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
					cutSiteRenderer.update(_railRadius, _center);
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
					orfRenderer.update(_railRadius, _center, orfAlignmentMap);
				}
			}
		}
		
		private function renderTraces():void
		{
			if(! traceRenderers) { return; }
			
			for(var i:int = 0; i < traceRenderers.length; i++) {
				var traceRenderer:TraceRenderer = traceRenderers[i] as TraceRenderer;
				
				traceRenderer.visible = _showTraces;
				
				if(_showTraces) {
					traceRenderer.update(_railRadius, _center, tracesAlignmentMap);
				}
			}
		}
		
		private function loadFeatureRenderers():void
		{
			removeFeatureRenderers();
			
			if(! _sequenceProvider || ! _sequenceProvider.features) { return; }
			
			for(var i:int = 0; i < _sequenceProvider.features.length; i++) {
				var feature:Feature = sequenceProvider.features[i] as Feature;
				
				var featureRenderer:FeatureRenderer = new FeatureRenderer(this, feature);
				
				featuresToRendererMap[feature] = featureRenderer;
				
				addChild(featureRenderer);
				
				featureRenderers.push(featureRenderer);
			}
		}
		
		private function loadCutSiteRenderers():void
		{
			removeCutSiteRenderers();
			
			if(!showCutSites || !sequenceProvider || !_restrictionEnzymeMapper || !_restrictionEnzymeMapper.cutSites) { return; }
			
			for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
				var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites[i] as RestrictionCutSite;
				
				var cutSiteRenderer:CutSiteRenderer = new CutSiteRenderer(this, cutSite);
				
				cutSitesToRendererMap[cutSite] = cutSiteRenderer;
				
				addChild(cutSiteRenderer);
				
				cutSiteRenderers.push(cutSiteRenderer);
			}
		}
		
		private function loadORFRenderers():void
		{
			removeORFRenderers();
			
			if(!showORFs || !sequenceProvider || !_orfMapper || !_orfMapper.orfs) { return; }
			
			for(var i:int = 0; i < _orfMapper.orfs.length; i++) {
				var orf:ORF = _orfMapper.orfs[i] as ORF;
				
				var orfRenderer:ORFRenderer = new ORFRenderer(this, orf);
				
				addChild(orfRenderer);
				
				orfRenderers.push(orfRenderer);
			}
		}
		
		private function loadTraceRenderers():void
		{
			removeTraceRenderers();
			
			if(!showTraces || !sequenceProvider || !_traceMapper || !_traceMapper.traceAnnotations) { return; }
			
			for(var i:int = 0; i < _traceMapper.traceAnnotations.length; i++) {
				var traceAnnotation:TraceAnnotation = _traceMapper.traceAnnotations[i] as TraceAnnotation;
				
				var traceRenderer:TraceRenderer = new TraceRenderer(this, traceAnnotation);
				
				addChild(traceRenderer);
				
				traceRenderers.push(traceRenderer);
			}
		}
		
	 	private function loadLabels():void
	 	{
	 		removeLabels();
	 		
			if(_sequenceProvider.features && showFeatures && showFeatureLabels) {
				// Create new labels for annotations
				var numberOfFeatures:int = _sequenceProvider.features.length;
				
				for(var i:int = 0; i < numberOfFeatures; i++) {
					var feature:Feature = _sequenceProvider.features[i] as Feature;
					
					var labelBox1:FeatureLabelBox = new FeatureLabelBox(this, feature);
					
					labelBoxes.push(labelBox1);
				}
			}
			
			if(showCutSites && showCutSiteLabels && _restrictionEnzymeMapper && _restrictionEnzymeMapper.cutSites) {
				// Create new labels for restriction enzymes
				var numberOfCutSites:int = _restrictionEnzymeMapper.cutSites.length;
				
				for(var j:int = 0; j < numberOfCutSites; j++) {
					var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites[j] as RestrictionCutSite;
					
					var labelBox2:LabelBox = new CutSiteLabelBox(this, cutSite);
					
					labelBoxes.push(labelBox2);
				}
			}
			
			labelBoxes.sort(labelBoxesSort);
			
			// Split labels into 4 groups
			var totalNumberOfLabels:uint = labelBoxes.length;
			var totalLength:uint = _sequenceProvider.sequence.length;
			for(var l:int = 0; l < totalNumberOfLabels; l++) {
				var labelBox:LabelBox = labelBoxes[l] as LabelBox;
				
				var labelCenter:int = annotationCenter(labelBox.relatedAnnotation);
				if(labelCenter < totalLength / 4) {
					rightTopLabels.push(labelBox);
				} else if((labelCenter >= totalLength / 4) && (labelCenter < totalLength / 2)) {
					rightBottomLabels.push(labelBox);
				} else if((labelCenter >= totalLength / 2) && (labelCenter < 3 * totalLength / 4)) {
					leftBottomLabels.push(labelBox);
				} else {
					leftTopLabels.push(labelBox);
				}
				addChild(labelBox);
				labelBox.validateNow();
			}
	 	}
	 	
	 	private function annotationCenter(annotation:Annotation):int
	 	{
	 		var result:int;
	 		
			if(annotation.start > annotation.end) {
				var virtualCenter:Number = annotation.end - ((sequenceProvider.sequence.length - annotation.start) + (annotation.end)) / 2 + 1;
				
				result = (virtualCenter >= 0) ? int(virtualCenter) : (sequenceProvider.sequence.length + int(virtualCenter) - 1);
			} else {
				result = (annotation.start + annotation.end - 1) / 2 + 1;
			}
			
			return result;
	 	}
	 	
	 	private function labelBoxesSort(labelBox1:LabelBox, labelBox2:LabelBox):int
		{
			var labelCenter1:int = annotationCenter(labelBox1.relatedAnnotation);
			var labelCenter2:int = annotationCenter(labelBox2.relatedAnnotation);
			
		    if(labelCenter1 > labelCenter2) {
		        return 1;
		    } else if(labelCenter1 < labelCenter2) {
		        return -1;
		    } else  {
		        return 0;
		    }
		}
 		
		private function drawConnections():void
		{
			var g:Graphics = graphics;
			g.lineStyle(1, CONNECTOR_LINE_COLOR, CONNECTOR_LINE_TRASPARENCY);
			
			var numberOfRightTopLabels:uint = rightTopLabels.length;
			for(var i1:uint = 0; i1 < numberOfRightTopLabels; i1++) {
				var labelBox1:LabelBox = rightTopLabels[i1] as LabelBox;
				
				if(! labelBox1.includeInView) { continue; }
				
				var annotation1:Annotation = labelBox1.relatedAnnotation as Annotation;
				
				if(annotation1 is Feature) {
					if(labelBox1.labelText == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer1:FeatureRenderer = featuresToRendererMap[annotation1] as FeatureRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(featureRenderer1.middlePoint.x, featureRenderer1.middlePoint.y);
				} else if(annotation1 is RestrictionCutSite) {
					if((annotation1 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer1:CutSiteRenderer = cutSitesToRendererMap[annotation1] as CutSiteRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(cutSiteRenderer1.middlePoint.x, cutSiteRenderer1.middlePoint.y);
				}
			}
			
			var numberOfRightBottomLabels:uint = rightBottomLabels.length;
			for(var i2:uint = 0; i2 < numberOfRightBottomLabels; i2++) {
				var labelBox2:LabelBox = rightBottomLabels[i2] as LabelBox;
				
				if(! labelBox2.includeInView) { continue; }
				
				var annotation2:Annotation = labelBox2.relatedAnnotation as Annotation;
				
				if(annotation2 is Feature) {
					if((annotation2 as Feature).name == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer2:FeatureRenderer = featuresToRendererMap[annotation2] as FeatureRenderer;
					
					g.moveTo(labelBox2.x, labelBox2.y + labelBox2.totalHeight / 2);
					g.lineTo(featureRenderer2.middlePoint.x, featureRenderer2.middlePoint.y);
				} else if(annotation2 is RestrictionCutSite) {
					if((annotation2 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer2:CutSiteRenderer = cutSitesToRendererMap[annotation2] as CutSiteRenderer;
					
					g.moveTo(labelBox2.x, labelBox2.y + labelBox2.totalHeight / 2);
					g.lineTo(cutSiteRenderer2.middlePoint.x, cutSiteRenderer2.middlePoint.y);
				}
			}
			
			var numberOfLeftTopLabels:uint = leftTopLabels.length;
			for(var i3:uint = 0; i3 < numberOfLeftTopLabels; i3++) {
				var labelBox3:LabelBox = leftTopLabels[i3] as LabelBox;
				
				if(! labelBox3.includeInView) { continue; }
				
				var annotation3:Annotation = labelBox3.relatedAnnotation as Annotation;
				
				if(annotation3 is Feature) {
					if((annotation3 as Feature).name == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer3:FeatureRenderer = featuresToRendererMap[annotation3] as FeatureRenderer;
					
					g.moveTo(labelBox3.x + labelBox3.totalWidth, labelBox3.y + labelBox3.totalHeight / 2);
					g.lineTo(featureRenderer3.middlePoint.x, featureRenderer3.middlePoint.y);
				} else if(annotation3 is RestrictionCutSite) {
					if((annotation3 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer3:CutSiteRenderer = cutSitesToRendererMap[annotation3] as CutSiteRenderer;
					
					g.moveTo(labelBox3.x + labelBox3.totalWidth, labelBox3.y + labelBox3.totalHeight / 2);
					g.lineTo(cutSiteRenderer3.middlePoint.x, cutSiteRenderer3.middlePoint.y);
				}
			}
			
			var numberOfLeftBottomLabels:uint = leftBottomLabels.length;
			for(var i4:uint = 0; i4 < numberOfLeftBottomLabels; i4++) {
				var labelBox4:LabelBox = leftBottomLabels[i4] as LabelBox;
				
				if(! labelBox4.includeInView) { continue; }
				
				var annotation4:Annotation = labelBox4.relatedAnnotation as Annotation;
				
				if(annotation4 is Feature) {
					if((annotation4 as Feature).name == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer4:FeatureRenderer = featuresToRendererMap[annotation4] as FeatureRenderer;
					
					g.moveTo(labelBox4.x + labelBox4.totalWidth, labelBox4.y + labelBox4.totalHeight / 2);
					g.lineTo(featureRenderer4.middlePoint.x, featureRenderer4.middlePoint.y);
				} else if(annotation4 is RestrictionCutSite) {
					if((annotation4 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer4:CutSiteRenderer = cutSitesToRendererMap[annotation4] as CutSiteRenderer;
					
					g.moveTo(labelBox4.x + labelBox4.totalWidth, labelBox4.y + labelBox4.totalHeight / 2);
					g.lineTo(cutSiteRenderer4.middlePoint.x, cutSiteRenderer4.middlePoint.y);
				}
			}
		}
		
		private function bpAtPoint(point:Point):uint
		{
	    	var position:Point = parent.localToGlobal(new Point(x, y));
	    	var contentPoint:Point = new Point(point.x - position.x, point.y - position.y);
	    	
			var index:uint = 0;
			
			var angle:Number = 0;
			if((contentPoint.x > _center.x) && (contentPoint.y < _center.y)) { // top right quater
				angle = Math.atan((contentPoint.x - _center.x) / (_center.y - contentPoint.y));
			} else if((contentPoint.x > _center.x) && (contentPoint.y > _center.y)) { // bottom right quater
				angle = Math.PI - Math.atan((contentPoint.x - _center.x) / (contentPoint.y - _center.y));
			} else if((contentPoint.x < _center.x) && (contentPoint.y > _center.y)) { // bottom left quater
				angle = Math.atan((_center.x - contentPoint.x) / (contentPoint.y - _center.y)) + Math.PI;
			} else if((contentPoint.x < _center.x) && (contentPoint.y < _center.y)) {  // top left quater
				angle = 2 * Math.PI - Math.atan((_center.x - contentPoint.x) / (_center.y - contentPoint.y));
			} else if((contentPoint.y == _center.y) && (contentPoint.x > _center.x)) {
				angle = Math.PI / 2;
			} else if((contentPoint.y == _center.y) && (contentPoint.x < _center.x)) {
				angle = 3 * Math.PI / 2;
			}
			
			index = Math.floor(angle * sequenceProvider.sequence.length / (2 * Math.PI));
			
			return index;
		}
		
		private function rebuildFeaturesAlignment():void
		{
			featureAlignmentMap = new Dictionary();
			
			if(!_showFeatures || !_sequenceProvider || _sequenceProvider.features.length == 0) { return; }
			
			var featureAlignment:Alignment = new Alignment(_sequenceProvider.features.toArray(), _sequenceProvider);
			for(var i:int = 0; i < featureAlignment.rows.length; i++) {
				var featuresRow:Array = featureAlignment.rows[i];
				
				for(var j:int = 0; j < featuresRow.length; j++) {
					var feature:Feature = featuresRow[j] as Feature;
					
					featureAlignmentMap[feature] = i;
				}
			}
		}
			
		private function rebuildORFsAlignment():void
		{
			orfAlignmentMap = new Dictionary();
			
			maxORFAlignmentRow = 0;
			
			if(!showORFs || !_orfMapper || _orfMapper.orfs.length == 0) { return; }
			
			var orfAlignment:Alignment = new Alignment(_orfMapper.orfs.toArray(), _sequenceProvider);
			maxORFAlignmentRow = orfAlignment.numberOfRows;
			for(var k:int = 0; k < orfAlignment.rows.length; k++) {
				var orfsRow:Array = orfAlignment.rows[k];
				
				for(var l:int = 0; l < orfsRow.length; l++) {
					var orf:ORF = orfsRow[l] as ORF;
					
					orfAlignmentMap[orf] = k;
				}
			}
		}
		
		private function rebuildTraceAlignment():void
		{
			tracesAlignmentMap = new Dictionary();
			
			maxTracesAlignmentRow = 0;
			
			if(!showTraces || !_traceMapper || _traceMapper.traceAnnotations.length == 0) { return; }
			
			var tracesAlignment:Alignment = new Alignment(_traceMapper.traceAnnotations.toArray(), _sequenceProvider);
			maxTracesAlignmentRow = tracesAlignment.numberOfRows;
			for(var k:int = 0; k < tracesAlignment.rows.length; k++) {
				var tracesRow:Array = tracesAlignment.rows[k];
				
				for(var l:int = 0; l < tracesRow.length; l++) {
					var traceAnnotation:TraceAnnotation = tracesRow[l] as TraceAnnotation;
					
					tracesAlignmentMap[traceAnnotation] = k;
				}
			}
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
			if(newPosition != _caretPosition) {
				if(! isValidIndex(newPosition)) {
					throw new Error("Invalid caret position: " + String(newPosition));
				}
				
				_caretPosition = newPosition;
				
				dispatchEvent(new CaretEvent(CaretEvent.CARET_POSITION_CHANGED, _caretPosition));
			}
			
			caret.position = _caretPosition;
		}
		
		private function validateCaret():void
		{
			tryMoveCaretToPosition(_caretPosition);
		}
		
		private function showInvalidPasteSequenceAlert():void
		{
			Alert.show("Paste DNA Sequence contains invalid characters!\nAllowed only these \"ATGCUYRSWKMBVDHN\"");
		}
		
		private function doSelect(start:int, end:int):void
		{
			if(start > 0 && end == 0) {
				end = sequenceProvider.sequence.length - 1;
			}
			
			startSelectionIndex = start;
			endSelectionIndex = end;
			
			selectionLayer.select(start, end);
		}
		
		private function doDeselect():void
		{
			startSelectionIndex = -1;
			endSelectionIndex = -1;
			selectionLayer.deselect();
		}
		
		private function doStickySelect(start:int, end:int):void
		{
			var selectedAnnotations:Array = new Array();
			var selectionAnnotation:Annotation = new Annotation(start, end);
			
			if(_showFeatures) {
				for(var i1:int = 0; i1 < sequenceProvider.features.length; i1++) {
					var feature:Feature = sequenceProvider.features[i1] as Feature;
					
					if(selectionAnnotation.contains(new Annotation(feature.start, feature.end))) {
						selectedAnnotations.push(feature);
					}
				}
			}
			
			if(_showCutSites && restrictionEnzymeMapper != null) {
				for(var i2:int = 0; i2 < restrictionEnzymeMapper.cutSites.length; i2++) {
					var cutSite:RestrictionCutSite = restrictionEnzymeMapper.cutSites[i2] as RestrictionCutSite;
					
					if(selectionAnnotation.contains(new Annotation(cutSite.start, cutSite.end))) {
						selectedAnnotations.push(cutSite);
					}
				}
			}
			
			if(_showORFs && orfMapper != null) {
				for(var i3:int = 0; i3 < orfMapper.orfs.length; i3++) {
					var orf:ORF = orfMapper.orfs[i3] as ORF;
					
					if(selectionAnnotation.contains(new Annotation(orf.start, orf.end))) {
						selectedAnnotations.push(orf);
					}
				}
			}
			
			if(_showTraces && traceMapper != null) {
				for(var i4:int = 0; i4 < traceMapper.traceAnnotations.length; i4++) {
					var traceAnnotation:TraceAnnotation = traceMapper.traceAnnotations[i4] as TraceAnnotation;
					
					if(selectionAnnotation.contains(new Annotation(traceAnnotation.start, traceAnnotation.end))) {
						selectedAnnotations.push(traceAnnotation);
					}
				}
			}
			
			if(selectedAnnotations.length > 0) {
				if(start <= end) { // normal
					var minStart:int = (selectedAnnotations[0] as Annotation).start;
					var maxEnd:int = (selectedAnnotations[0] as Annotation).end;
					
					for(var j1:int = 0; j1 < selectedAnnotations.length; j1++) {
						var annotation1:Annotation = selectedAnnotations[j1] as Annotation;
						
						if(minStart > annotation1.start) { minStart = annotation1.start; }
						if(maxEnd < annotation1.end) { maxEnd = annotation1.end; }
					}
					
					selectionLayer.startSelecting();
					selectionLayer.select(minStart, maxEnd);
				} else { // circular
					var minStart1:int = -1;
					var maxEnd1:int = -1;
					
					var minStart2:int = -1;
					var maxEnd2:int = -1;
					
					for(var j2:int = 0; j2 < selectedAnnotations.length; j2++) {
						var annotation2:Annotation = selectedAnnotations[j2] as Annotation;
						
						if(annotation2.start > start) {
							if(minStart1 == -1) { minStart1 = annotation2.start; }
							
							if(annotation2.start < minStart1) { minStart1 = annotation2.start; }
						} else {
							if(minStart2 == -1) { minStart2 = annotation2.start; }
							
							if(annotation2.start < minStart2) { minStart2 = annotation2.start; }
						}
						
						if(annotation2.end > end) {
							if(maxEnd1 == -1) { maxEnd1 = annotation2.end; }
							
							if(annotation2.end > maxEnd1) { maxEnd1 = annotation2.end; }
						} else {
							if(maxEnd2 == -1) { maxEnd2 = annotation2.end; }
							
							if(annotation2.end > maxEnd2) { maxEnd2 = annotation2.end; }
						}
					}
					
					var selStart:int = minStart1;
					var selEnd:int;
					
					if(minStart1 == -1 && minStart2 != -1) {
						selStart = minStart2;
					} else if(minStart1 != -1 && minStart2 == -1) {
						selStart = minStart1;
					} else if(minStart1 != -1 && minStart2 != -1) {
						selStart = minStart1;
					}
					
					if(maxEnd1 == -1 && maxEnd2 != -1) {
						selEnd = maxEnd2;
					} else if(maxEnd1 != -1 && maxEnd2 == -1) {
						selEnd = maxEnd1;
					} else if(maxEnd1 != -1 && maxEnd2 != -1) {
						selEnd = maxEnd2;
					}
					
					if(selEnd == -1 || selStart == -1) {
						selectionLayer.deselect();
					} else {
						selectionLayer.startSelecting();
						selectionLayer.select(selStart, selEnd);
					}
				}
			} else {
				selectionLayer.deselect();
			}
		}
		
		private function doDeleteSequence(start:int, end:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_DELETE, new Array(start, end)));
		}
		
		private function doInsertSequence(dnaSequence:SymbolList, position:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_SEQUENCE, new Array(dnaSequence, position)));
		}
		
		private function doInsertSequenceProvider(currentSequenceProvider:SequenceProvider, position:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_FEATURED_SEQUENCE, new Array(currentSequenceProvider, position)));
		}
		
		private function clearLabelTextRenderers():void
		{
			_cutSiteTextRenderer.clearCache();
			_singleCutterCutSiteTextRenderer.clearCache();
			_featureTextRenderer.clearCache();
			
			// Load dummy renderers to calculate width and height
			_cutSiteTextRenderer.textToBitmap("EcoRI");
			_singleCutterCutSiteTextRenderer.textToBitmap("EcoRI");
			_featureTextRenderer.textToBitmap("EcoRI");
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