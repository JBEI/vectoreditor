package org.jbei.components.railClasses
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
	import mx.core.UIComponent;
	
	import org.jbei.bio.data.TraceAnnotation;
	import org.jbei.bio.enzymes.RestrictionCutSite;
	import org.jbei.bio.orf.ORF;
	import org.jbei.bio.sequence.DNATools;
	import org.jbei.bio.sequence.common.Annotation;
	import org.jbei.bio.sequence.dna.DNASequence;
	import org.jbei.bio.sequence.dna.Feature;
	import org.jbei.components.Rail;
	import org.jbei.components.common.Alignment;
	import org.jbei.components.common.AnnotationRenderer;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.CommonEvent;
	import org.jbei.components.common.Constants;
	import org.jbei.components.common.EditingEvent;
	import org.jbei.components.common.IContentHolder;
	import org.jbei.components.common.LabelBox;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.components.common.SequenceUtils;
	import org.jbei.components.common.TextRenderer;
	import org.jbei.lib.SequenceProvider;
	import org.jbei.lib.mappers.DigestionSequence;
	import org.jbei.lib.mappers.ORFMapper;
	import org.jbei.lib.mappers.RestrictionEnzymeMapper;
	import org.jbei.lib.mappers.TraceMapper;
	
    /**
     * @author Zinovii Dmytriv
     */
	public class ContentHolder extends UIComponent implements IContentHolder
	{
		private const BACKGROUND_COLOR:int = 0xFFFFFF;
		private const CONNECTOR_LINE_COLOR:int = 0x000000;
		private const CONNECTOR_LINE_TRASPARENCY:Number = 0.1;
		private const SELECTION_THRESHOLD:Number = 5;
		private const HORIZONTAL_PADDING:int = 25;
		private const BOTTOM_PADDING:int = 55;
		private const LABELS_RAIL_GAP:Number = 20;
		private const LABEL_FONT_FACE:String = "Tahoma";
		private const FEATURE_LABEL_FONT_COLOR:int = 0x000000;
		private const CUTSITES_LABEL_FONT_COLOR:int = 0x888888;
		private const SINGLE_CUTTER_LABEL_FONT_COLOR:int = 0xE57676;
		
		private var rail:Rail;
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
        
		private var _cutSiteTextRenderer:TextRenderer;
		private var _singleCutterCutSiteTextRenderer:TextRenderer;
		private var _featureTextRenderer:TextRenderer;
		
		private var _hCenter:Number;
		private var _sequenceProvider:SequenceProvider;
		private var _orfMapper:ORFMapper;
		private var _traceMapper:TraceMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Annotation */;
		private var _caretPosition:int;
		private var _totalHeight:int = 0;
		private var _totalWidth:int = 0;
		private var _bpWidth:Number = 0;
		private var _readOnly:Boolean = true;
		private var _showFeatures:Boolean = true;
		private var _showCutSites:Boolean = false;
		private var _showORFs:Boolean = false;
		private var _showTraces:Boolean = false;
		private var _showFeatureLabels:Boolean = true;
		private var _showCutSiteLabels:Boolean = true;
		private var _safeEditing:Boolean = true;
		private var _labelFontSize:int = 10;
		
		private var _railMetrics:Rectangle;
		private var parentWidth:Number = 0;
		private var parentHeight:Number = 0;
		private var selectionDirection:int = 0;
		private var shiftKeyDown:Boolean = false;
		private var shiftDownCaretPosition:int = -1;
		private var featureRenderers:Array = new Array(); /* of FeatureRenderer */
		private var cutSiteRenderers:Array = new Array(); /* of CutSiteRenderer */
		private var traceRenderers:Array = new Array(); /* of TraceRenderer */
		private var orfRenderers:Array = new Array(); /* of ORFRenderer */
		private var labelBoxes:Array /* of LabelBox */  = new Array();
		private var leftLabels:Array /* of LabelBox */ = new Array();
		private var rightLabels:Array /* of LabelBox */ = new Array();
		private var featuresToRendererMap:Dictionary = new Dictionary(); /* [Feature] = FeatureRenderer  */
		private var cutSitesToRendererMap:Dictionary = new Dictionary(); /* [CutSite] = CutSiteRenderer  */
		private var featureAlignment:Alignment;
		
		private var mouseIsDown:Boolean = false;
		private var clickPoint:Point;
		private var invalidSequence:Boolean = true;
		private var startSelectionIndex:int;
		private var endSelectionIndex:int;
		
		private var sequenceProviderChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var traceMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		private var featuresAlignmentChanged:Boolean = false;
		private var orfsAlignmentChanged:Boolean = false;
		private var tracesAlignmentChanged:Boolean = false;
		private var needsMeasurement:Boolean = false;
		private var richSequenceChanged:Boolean = false;
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
		private var maxTracesAlignmentRow:int;
		
		// Contructor
		public function ContentHolder(rail:Rail)
		{
			super();
			
			this.rail = rail;
			
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
		
		public function get railMetrics():Rectangle
		{
			return _railMetrics;
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
		
		public function get hCenter():Number
		{
			return _hCenter;
		}
		
		public function get bpWidth():Number
		{
			return _bpWidth;
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
				bitmapData = new BitmapData(pageWidth, pageHeight);
				
				matrix.ty = pageHeight * (page + 1) - totalHeight;
				bitmapData.draw(this, matrix, null, null, new Rectangle(0, 0, pageWidth, pageHeight));
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
			
			if(restrictionEnzymeMapperChanged) {
				restrictionEnzymeMapperChanged = false;
				
				needsMeasurement = true;
				
				invalidateDisplayList();
			}
			
			if(labelFontSizeChanged) {
				labelFontSizeChanged = false;
				
				needsMeasurement = true;
				
				var cutSiteTextFormat:TextFormat = new TextFormat(_cutSiteTextRenderer.textFormat.font, _labelFontSize, _cutSiteTextRenderer.textFormat.color);
				var singleCutterCutSiteTextFormat:TextFormat = new TextFormat(_singleCutterCutSiteTextRenderer.textFormat.font, _labelFontSize, _singleCutterCutSiteTextRenderer.textFormat.color);
				var featureTextFormat:TextFormat = new TextFormat(_cutSiteTextRenderer.textFormat.font, _labelFontSize, _cutSiteTextRenderer.textFormat.color);
				
				_cutSiteTextRenderer.textFormat = cutSiteTextFormat;
				_singleCutterCutSiteTextRenderer.textFormat = singleCutterCutSiteTextFormat;
				
				clearLabelTextRenderers();
				
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
				
				var yRailPosition:Number = parentHeight - BOTTOM_PADDING;
				
				if(featureAlignment && featureAlignment.numberOfRows > 0) {
					yRailPosition -= featureAlignment.numberOfRows * (FeatureRenderer.DEFAULT_FEATURE_HEIGHT + FeatureRenderer.DEFAULT_GAP)
				}
				
				_railMetrics = new Rectangle(HORIZONTAL_PADDING, yRailPosition, parentWidth - 2 * HORIZONTAL_PADDING, RailBox.THICKNESS);
				
				_bpWidth = _railMetrics.width / sequenceProvider.sequence.length;
				
				_hCenter = _railMetrics.x + _railMetrics.width / 2;
				
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
				
				drawBackground();
				drawConnections();
				
				caret.updateMetrics();
				
				nameBox.update(_sequenceProvider.name, _sequenceProvider.sequence.length);
				
				if(highlightsChanged) {
					highlightsChanged = false;
				}
				
				highlightLayer.update();
				
				selectionLayer.updateMetrics();
				wireframeSelectionLayer.updateMetrics();
				
				if(isValidIndex(startSelectionIndex) && isValidIndex(endSelectionIndex)) {
					selectionLayer.deselect();
					doSelect(startSelectionIndex, endSelectionIndex);
				}
			}
			
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
			
			clickPoint = new Point(event.stageX, event.stageY);
			
			tryMoveCaretToPosition(startSelectionIndex);
			
			wireframeSelectionLayer.show();
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			if((mouseIsDown && Point.distance(clickPoint, new Point(event.stageX, event.stageY)) > SELECTION_THRESHOLD)) {
				endSelectionIndex = bpAtPoint(new Point(event.stageX, event.stageY));
				
				if(selectionDirection == 0) {
					selectionDirection = (startSelectionIndex <= endSelectionIndex) ? 1: -1;
				}
				
				var start:int = (selectionDirection == -1) ? endSelectionIndex : startSelectionIndex;
				var end:int = (selectionDirection == -1) ? startSelectionIndex : endSelectionIndex;
				
				wireframeSelectionLayer.startSelecting();
				wireframeSelectionLayer.select(start, end);
				
				if(event.ctrlKey) { // regular selection
					selectionLayer.startSelecting();
					selectionLayer.select(start, end);
					
					dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end + 1));
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
				
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECTION_CHANGED, selectionLayer.start, selectionLayer.end + 1));
				
				wireframeSelectionLayer.hide();
			}
		}
		
		private function onMouseDoubleClick(event:MouseEvent):void
		{
			if(event.target is FeatureRenderer) {
				dispatchEvent(new CommonEvent(CommonEvent.EDIT_FEATURE, true, false, (event.target as FeatureRenderer).feature));
			}
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
                    
                    if(startSelectionIndex == cutSite.start) {
                        digestionStart = startSelectionIndex;
                        digestionStartCutSite = cutSite;
                    }
                    
                    if(endSelectionIndex == cutSite.end + 1) {
                        digestionEnd = endSelectionIndex;
                        digestionEndCutSite = cutSite;
                    }
                }
            }
            
            if(digestionStart >= 0 && digestionEnd >= 0) {
                var subSequenceProvider:SequenceProvider = _sequenceProvider.subSequenceProvider(digestionStart, digestionEnd);
                var digestionSequence:DigestionSequence = new DigestionSequence(subSequenceProvider, digestionStartCutSite.restrictionEnzyme, digestionEndCutSite.restrictionEnzyme, 0, digestionEndCutSite.start - digestionStartCutSite.start);
                
                Clipboard.generalClipboard.clear();
                Clipboard.generalClipboard.setData(Constants.DIGESTION_SEQUENCE_CLIPBOARD_KEY, digestionSequence, true);
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY, subSequenceProvider, true);
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, subSequenceProvider.sequence.seqString(), true);
                
                dispatchEvent(new CommonEvent(CommonEvent.ACTION_MESSAGE, true, true, "Digestion sequence has been copied to clipboard. Enzymes: [" + digestionStartCutSite.restrictionEnzyme.name + ", " + digestionEndCutSite.restrictionEnzyme.name + "]"));
            } else {
                Clipboard.generalClipboard.clear();
                Clipboard.generalClipboard.setData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY, _sequenceProvider.subSequenceProvider(selectionLayer.start, selectionLayer.end), true);
                Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _sequenceProvider.subSequence(selectionLayer.start, selectionLayer.end).seqString(), true);
                
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
			
			if(Clipboard.generalClipboard.hasFormat(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY)) {
				var clipboardObject:Object = Clipboard.generalClipboard.getData(Constants.SEQUENCE_PROVIDER_CLIPBOARD_KEY);
				
				if(clipboardObject != null) {
					var pasteSequenceProvider:SequenceProvider = clipboardObject as SequenceProvider;
					var pasteSequence1:String = pasteSequenceProvider.sequence.seqString();
					
					if(!SequenceUtils.isCompatibleSequence(pasteSequence1)) {
						showInvalidPasteSequenceAlert();
						
						return;
					} else {
						pasteSequence1 = SequenceUtils.purifyCompatibleSequence(pasteSequence1);
					}
					
					if(_safeEditing) {
						doInsertSequenceProvider(pasteSequenceProvider, _caretPosition);
					} else {
						_sequenceProvider.insertSequenceProvider(pasteSequenceProvider, _caretPosition);
						
						tryMoveCaretToPosition(_caretPosition + pasteSequence1.length);
					}				
				}
			} else if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
				var pasteSequence2:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_ONLY)).toUpperCase();
				
				if(!SequenceUtils.isCompatibleSequence(pasteSequence2)) {
					showInvalidPasteSequenceAlert();
					
					return;
				}
				
				if(_safeEditing) {
					doInsertSequence(DNATools.createDNA(pasteSequence2) as DNASequence, _caretPosition);
				} else {
					_sequenceProvider.insertSequence(DNATools.createDNA(pasteSequence2) as DNASequence, _caretPosition);
					
					tryMoveCaretToPosition(_caretPosition + pasteSequence2.length);
				}				
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
				customContextMenu.clipboardItems.cut = _readOnly ? false : true;
			} else {
				customContextMenu.clipboardItems.copy = false;
				customContextMenu.clipboardItems.cut = false;
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
        
        // Private Methods
        private function createContextMenu():void
        {
            customContextMenu = new ContextMenu();
            
            customContextMenu.hideBuiltInItems(); //hide the Flash built-in menu
            customContextMenu.clipboardMenu = true; // activate Copy, Paste, Cut, Menu items
            customContextMenu.clipboardItems.paste = _readOnly ? false : true;
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
        
        private function createHighlightLayer():void
        {
            if(highlightLayer == null) {
                highlightLayer = new HighlightLayer(this);
                highlightLayer.includeInLayout = false;
                
                addChild(highlightLayer);
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
            
            rail.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            rail.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            rail.removeEventListener(Event.SELECT_ALL, onSelectAll);
            rail.removeEventListener(Event.COPY, onCopy);
            if(!_readOnly) {
                rail.removeEventListener(Event.CUT, onCut);
                rail.removeEventListener(Event.PASTE, onPaste);
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
            
            rail.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            rail.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            
            rail.addEventListener(Event.SELECT_ALL, onSelectAll);
            rail.addEventListener(Event.COPY, onCopy);
            if(!_readOnly) {
                rail.addEventListener(Event.CUT, onCut);
                rail.addEventListener(Event.PASTE, onPaste);
            }
            
            addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
        }
        
		private function renderFeatures():void
		{
			if(! featureRenderers) { return; }
			
			for(var i:int = 0; i < featureRenderers.length; i++) {
				var featureRenderer:FeatureRenderer = featureRenderers[i] as FeatureRenderer;
				
				featureRenderer.visible = _showFeatures;
				
				if(_showFeatures) {
					featureRenderer.update(_railMetrics, bpWidth, featureAlignmentMap[featureRenderer.feature]);
					featureRenderer.validateNow();
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
					cutSiteRenderer.update(_railMetrics, bpWidth);
					cutSiteRenderer.validateNow();
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
					orfRenderer.update(_railMetrics, bpWidth, orfAlignmentMap[orfRenderer.orf]);
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
					traceRenderer.update(_railMetrics, _bpWidth, tracesAlignmentMap[traceRenderer.traceAnnotation]);
				}
			}
		}
		
		private function renderLabels():void
		{
			// Align left labels
			var biggestLeftGap:Number = 0;
			var biggestTopGap:Number = 0;
			
			var numberOfLeftLabels:uint = leftLabels.length;
			for(var i1:uint = 0; i1 < numberOfLeftLabels; i1++) {
				var leftLabelBox1:LabelBox = leftLabels[i1] as LabelBox;
				
				if(! leftLabelBox1.includeInView) { continue; }
				
				var leftGap:Number = _railMetrics.x + _bpWidth * leftLabelBox1.relatedAnnotation.start - leftLabelBox1.totalWidth;
				
				if(leftGap < biggestLeftGap) {
					biggestLeftGap = leftGap;
				}
			}
			
			// Adjust RailMetrics and ContentMetrics because labels can stick out
			if(biggestLeftGap < 0) {
				_railMetrics.x += Math.abs(biggestLeftGap);
				_totalWidth += Math.abs(biggestLeftGap);
			}
			
			// Calculate Vertical Position
			var previousYPosition1:Number = _railMetrics.y - LABELS_RAIL_GAP;
			for(var j1:uint = 0; j1 < numberOfLeftLabels; j1++) {
				var leftLabelBox2:LabelBox = leftLabels[j1] as LabelBox;
				
				if(! leftLabelBox2.includeInView) { continue; }
				
				leftLabelBox2.x = _railMetrics.x + _bpWidth * leftLabelBox2.relatedAnnotation.start - leftLabelBox2.totalWidth;
				leftLabelBox2.y = previousYPosition1 - leftLabelBox2.totalHeight;
				previousYPosition1 = leftLabelBox2.y;
				
				// Adjust content height because labels can be higher then content
				if(leftLabelBox2.y < biggestTopGap) {
					biggestTopGap = leftLabelBox2.y;
				}
			}
			
			// Align right labels
			var biggestRightGap:Number = 0;
			
			var numberOfRightLabels:uint = rightLabels.length;
			for(var i2:uint = 0; i2 < numberOfRightLabels; i2++) {
				var rightLabelBox1:LabelBox = rightLabels[i2] as LabelBox;
				
				if(! rightLabelBox1.includeInView) { continue; }
				
				var rightGap:Number = _totalWidth - (_railMetrics.x + _bpWidth * rightLabelBox1.relatedAnnotation.start + rightLabelBox1.totalWidth + HORIZONTAL_PADDING);
				
				if(rightGap < biggestRightGap) {
					biggestRightGap = rightGap;
				}
			}
			
			// Adjust ContentMetrics because labels can stick out
			if(biggestRightGap < 0) {
				_totalWidth += Math.abs(biggestRightGap);
			}
			
			// Calculate Vertical Position
			var previousYPosition2:Number = _railMetrics.y - LABELS_RAIL_GAP;
			for(var j2:int = numberOfRightLabels - 1; j2 >= 0; j2--) {
				var rightLabelBox2:LabelBox = rightLabels[j2] as LabelBox;
				
				if(! rightLabelBox2.includeInView) { continue; }
				
				rightLabelBox2.x = _railMetrics.x + _bpWidth * rightLabelBox2.relatedAnnotation.start;
				rightLabelBox2.y = previousYPosition2 - rightLabelBox2.totalHeight;
				previousYPosition2 = rightLabelBox2.y;
				
				// Adjust content height because labels can be higher then content
				if(rightLabelBox2.y < biggestTopGap) {
					biggestTopGap = rightLabelBox2.y;
				}
			}
			 
			// Adjust content height
			if(biggestTopGap < 0) {
				var verticalShift:Number = Math.abs(biggestTopGap) + 10; // +10 just to look nice
				_railMetrics.y += verticalShift;
				
				_totalHeight += verticalShift;
				
				for(var z1:int = 0; z1 < numberOfLeftLabels; z1++) {
					leftLabels[z1].y += verticalShift;
				}
				for(var z2:int = 0; z2 < numberOfRightLabels; z2++) {
					rightLabels[z2].y += verticalShift;
				}
			}
			
			_hCenter = _railMetrics.x + _railMetrics.width / 2;
		}
		
		private function loadFeatureRenderers():void
		{
			removeFeatureRenderers();
			
			if(! _sequenceProvider || ! _sequenceProvider.features) { return; }
			
			for(var i:int = 0; i < sequenceProvider.features.length; i++) {
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
					
					var featureLabelBox:FeatureLabelBox = new FeatureLabelBox(this, feature);
					
					labelBoxes.push(featureLabelBox);
				}
			}
			
			if(showCutSites && showCutSiteLabels && _restrictionEnzymeMapper && _restrictionEnzymeMapper.cutSites) {
				// Create new labels for restriction enzymes
				var numberOfCutSites:int = _restrictionEnzymeMapper.cutSites.length;
				
				for(var j:int = 0; j < numberOfCutSites; j++) { 
					var cutSite:RestrictionCutSite = _restrictionEnzymeMapper.cutSites[j] as RestrictionCutSite;
					
					var cutSiteLabelBox:LabelBox = new CutSiteLabelBox(this, cutSite);
					
					labelBoxes.push(cutSiteLabelBox);
				}
			}
			
			labelBoxes.sort(labelBoxesSort);
			
			// Split labels into 2 groups
			var totalNumberOfLabels:uint = labelBoxes.length;
			var totalLength:uint = _sequenceProvider.sequence.length;
			for(var l:int = 0; l < totalNumberOfLabels; l++) {
				var labelBox:LabelBox = labelBoxes[l] as LabelBox;
				
				if(l < totalNumberOfLabels / 2) {
					leftLabels.push(labelBox);
				} else {
					rightLabels.push(labelBox);
				}
				addChild(labelBox);
				labelBox.validateNow();
			}
		}
		
		private function labelBoxesSort(labelBox1:LabelBox, labelBox2:LabelBox):int
		{
			var labelCenter1:int = labelBox1.relatedAnnotation.start;
			var labelCenter2:int = labelBox2.relatedAnnotation.start;
			
			if(labelCenter1 > labelCenter2) {
				return 1;
			} else if(labelCenter1 < labelCenter2) {
				return -1;
			} else  {
				return 0;
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
		
		private function removeLabels():void
		{
			// Remove old leftLabels
			var numberOfLeftLabels:uint = leftLabels.length;
			if(numberOfLeftLabels > 0) {
				for(var i1:int = numberOfLeftLabels - 1; i1 >= 0; i1--) {
					removeChild(leftLabels[i1]);
					leftLabels.pop();
				}
			}
			
			// Remove old RightLabels
			var numberOfRightLabels:uint = rightLabels.length;
			if(numberOfRightLabels > 0) {
				for(var i2:int = numberOfRightLabels - 1; i2 >= 0; i2--) {
					removeChild(rightLabels[i2]);
					rightLabels.pop();
				}
			}
			
			var numberOfLabels:uint = labelBoxes.length;
			if(numberOfLabels > 0) {
				for(var k:int = numberOfLabels - 1; k >= 0; k--) {
					labelBoxes.pop();
				}
			}
		}
		
		private function rebuildFeaturesAlignment():void
		{
			featureAlignmentMap = new Dictionary();
			
			if(!_showFeatures || !_sequenceProvider || _sequenceProvider.features.length == 0) { return; }
			
			featureAlignment = new Alignment(_sequenceProvider.features.toArray(), _sequenceProvider);
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
			
			if(!showORFs || !_orfMapper || _orfMapper.orfs.length == 0) { return; }
			
			var orfAlignment:Alignment = new Alignment(_orfMapper.orfs.toArray(), _sequenceProvider);
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
		
		private function drawBackground():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.beginFill(BACKGROUND_COLOR);
			g.drawRect(0, 0, _totalWidth, _totalHeight);
			g.endFill();
		}
		
		private function drawConnections():void
		{
			var g:Graphics = graphics;
			g.lineStyle(1, CONNECTOR_LINE_COLOR, CONNECTOR_LINE_TRASPARENCY);
			
			var numberOfRightLabels:uint = rightLabels.length;
			for(var i1:uint = 0; i1 < numberOfRightLabels; i1++) {
				var labelBox1:LabelBox = rightLabels[i1] as LabelBox;
				
				if(! labelBox1.includeInView) { continue; }
				
				var annotation1:Annotation = labelBox1.relatedAnnotation as Annotation;
				
				if(annotation1 is Feature) {
					if((annotation1 as Feature).name == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer1:FeatureRenderer = featuresToRendererMap[annotation1] as FeatureRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(featureRenderer1.connectionPoint.x, featureRenderer1.connectionPoint.y);
				} else if(annotation1 is RestrictionCutSite) {
					if((annotation1 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer1:CutSiteRenderer = cutSitesToRendererMap[annotation1] as CutSiteRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(cutSiteRenderer1.connectionPoint.x, cutSiteRenderer1.connectionPoint.y);
				}
			}
			
			var numberOfLeftLabels:uint = leftLabels.length;
			for(var i2:uint = 0; i2 < numberOfLeftLabels; i2++) {
				var labelBox2:LabelBox = leftLabels[i2] as LabelBox;
				
				if(! labelBox2.includeInView) { continue; }
				
				var annotation2:Annotation = labelBox2.relatedAnnotation as Annotation;
				
				if(annotation2 is Feature) {
					if((annotation2 as Feature).name == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer2:FeatureRenderer = featuresToRendererMap[annotation2] as FeatureRenderer;
					
					g.moveTo(labelBox2.x + labelBox2.totalWidth, labelBox2.y + labelBox2.totalHeight / 2);
					g.lineTo(featureRenderer2.connectionPoint.x, featureRenderer2.connectionPoint.y);
				} else if(annotation2 is RestrictionCutSite) {
					if((annotation2 as RestrictionCutSite).restrictionEnzyme.name == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer2:CutSiteRenderer = cutSitesToRendererMap[annotation2] as CutSiteRenderer;
					
					g.moveTo(labelBox2.x + labelBox2.totalWidth, labelBox2.y + labelBox2.totalHeight / 2);
					g.lineTo(cutSiteRenderer2.connectionPoint.x, cutSiteRenderer2.connectionPoint.y);
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
		
		private function bpAtPoint(point:Point):uint
		{
			var position:Point = parent.localToGlobal(new Point(x, y));
			var contentPoint:Point = new Point(point.x - position.x, point.y - position.y);
			
			var result:int = 0;
			
			if(contentPoint.x < _railMetrics.x) {
				result = 0;
			} else if(contentPoint.x > _railMetrics.x + _railMetrics.width) {
				result = sequenceProvider.sequence.length;
			} else {
				result = int(Math.floor((contentPoint.x - _railMetrics.x) / _bpWidth));
			}
			
			return result;
		}
		
		private function doSelect(start:int, end:int):void
		{
			if(start > 0 && end == 0) {
				end == sequenceProvider.sequence.length - 1;
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
		
		private function doInsertSequence(dnaSequence:DNASequence, position:int):void
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
                
                if(startSelectionIndex == cutSite.start) {
                    matchedStart = true;
                }
                
                if(endSelectionIndex == cutSite.end + 1) {
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
