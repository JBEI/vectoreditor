package org.jbei.components.railClasses
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.display.Graphics;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import org.jbei.bio.data.CutSite;
	import org.jbei.bio.data.DNASequence;
	import org.jbei.bio.data.Feature;
	import org.jbei.bio.data.IAnnotation;
	import org.jbei.bio.data.ORF;
	import org.jbei.bio.utils.SequenceUtils;
	import org.jbei.components.Rail;
	import org.jbei.components.common.Alignment;
	import org.jbei.components.common.CaretEvent;
	import org.jbei.components.common.EditingEvent;
	import org.jbei.components.common.SelectionEvent;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.ORFMapper;
	import org.jbei.lib.RestrictionEnzymeMapper;
	
	public class ContentHolder extends UIComponent
	{
		private const BACKGROUND_COLOR:int = 0xFFFFFF;
		private const CONNECTOR_LINE_COLOR:int = 0x000000;
		private const CONNECTOR_LINE_TRASPARENCY:Number = 0.1;
		private const SELECTION_THRESHOLD:Number = 5;
		private const HORIZONTAL_PADDING:int = 25;
		private const FEATURED_SEQUENCE_CLIPBOARD_KEY:String = "VectorEditorFeaturedSequence";
		private const BOTTOM_PADDING:int = 55;
		private const LABELS_RAIL_GAP:Number = 20;
		
		private var rail:Rail;
		private var railBox:RailBox;
		private var selectionLayer:SelectionLayer;
		private var caret:Caret;
		private var nameBox:NameBox;
		private var highlightLayer:HighlightLayer;
		
		private var customContextMenu:ContextMenu;
		private var editFeatureContextMenuItem:ContextMenuItem;
		private var selectedAsNewFeatureContextMenuItem:ContextMenuItem;
		
		private var _horizontalCenter:Number;
		private var _featuredSequence:FeaturedSequence;
		private var _orfMapper:ORFMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Segment */;
		private var _startRailPoint:Point;
		private var _endRailPoint:Point;
		private var _caretPosition:int;
		private var _totalHeight:int = 0;
		private var _totalWidth:int = 0;
		private var _bpWidth:Number = 0;
		private var _showFeatures:Boolean = true;
		private var _showCutSites:Boolean = true;
		private var _showFeatureLabels:Boolean = true;
		private var _showCutSiteLabels:Boolean = true;
		private var _showORFs:Boolean = true;
		private var _safeEditing:Boolean = true;
		
		private var parentWidth:Number = 0;
		private var parentHeight:Number = 0;
		private var selectionDirection:int = 0;
		private var shiftKeyDown:Boolean = false;
		private var shiftDownCaretPosition:int = -1;
		private var featureRenderers:Array = new Array(); /* of FeatureRenderer */
		private var cutSiteRenderers:Array = new Array(); /* of CutSiteRenderer */
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
		
		private var featuredSequenceChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		private var featuresAlignmentChanged:Boolean = false;
		private var orfsAlignmentChanged:Boolean = false;
		private var needsMeasurement:Boolean = false;
		private var richSequenceChanged:Boolean = false;
		private var showFeaturesChanged:Boolean = false;
		private var showCutSitesChanged:Boolean = false;
		private var showFeatureLabelsChanged:Boolean = false;
		private var showCutSiteLabelsChanged:Boolean = false;
		private var showORFsChanged:Boolean = false;
		
		private var featureAlignmentMap:Dictionary;
		private var orfAlignmentMap:Dictionary;
		
		// Contructor
		public function ContentHolder(rail:Rail)
		{
			super();
			
			this.rail = rail;
			
			doubleClickEnabled = true;
		}
		
		// Properties
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			_featuredSequence = value;
			
			invalidateProperties();
			
			featuredSequenceChanged = true;
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
		
		public function get highlights():Array /* of Segment */
		{
			return _highlights;
		}
		
		public function set highlights(value:Array /* of Segment */):void
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
		
		public function get startRailPoint():Point
		{
			return _startRailPoint;
		}
		
		public function get endRailPoint():Point
		{
			return _endRailPoint;
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
		
		public function get horizontalCenter():Number
		{
			return _horizontalCenter;
		}
		
		public function get bpWidth():Number
		{
			return _bpWidth;
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
			return index >= 0 && index <= featuredSequence.sequence.length;
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
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(! _featuredSequence) {
				disableSequence();
				
				invalidateDisplayList();
				
				return;
			}
			
			if(featuredSequenceChanged) {
				featuredSequenceChanged = false;
				
				initializeSequence();
				
				needsMeasurement = true;
				
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
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(invalidSequence) {
				removeLabels();
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
			
			if(featuresAlignmentChanged) {
				featuresAlignmentChanged = false;
				
				rebuildFeaturesAlignment();
			}
			
			if(orfsAlignmentChanged) {
				orfsAlignmentChanged = false;
				
				rebuildORFsAlignment();
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
				
				_startRailPoint = new Point(HORIZONTAL_PADDING, yRailPosition);
				_endRailPoint = new Point(parentWidth - HORIZONTAL_PADDING, yRailPosition);
				
				_bpWidth = (_endRailPoint.x - _startRailPoint.x) / featuredSequence.sequence.length;
				
				_horizontalCenter = (_startRailPoint.x - _endRailPoint.x) / 2;
				
				_totalHeight = parentHeight;
				_totalWidth = parentWidth;
				
				loadFeatureRenderers();
				loadCutSiteRenderers();
				loadORFRenderers();
				loadLabels();
				
				renderLabels();
				renderFeatures();
				renderCutSites();
				renderORFs();
				
				// update children metrics
				railBox.updateMetrics();
				
				drawBackground();
				drawConnections();
				
				caret.updateMetrics();
				
				nameBox.update(_featuredSequence.name, _featuredSequence.sequence.length);
				
				if(highlightsChanged) {
					highlightsChanged = false;
				}
				
				highlightLayer.update();
				
				selectionLayer.updateMetrics();
				
				if(isValidIndex(startSelectionIndex) && isValidIndex(endSelectionIndex)) {
					selectionLayer.deselect();
					doSelect(startSelectionIndex, endSelectionIndex);
				}
			}
			
			validateCaret();
		}
		
		// Private Methods
		private function createContextMenu():void
		{
			customContextMenu = new ContextMenu();
			
			customContextMenu.hideBuiltInItems(); //hide the Flash built-in menu
			customContextMenu.clipboardMenu = true; // activate Copy, Paste, Cut, Menu items
			customContextMenu.clipboardItems.paste = true;
			customContextMenu.clipboardItems.selectAll = true;
			
			contextMenu = customContextMenu;
			
			customContextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onContextMenuSelect);
			
			createCustomContextMenuItems();
		}
		
		private function createCustomContextMenuItems():void
		{
			editFeatureContextMenuItem = new ContextMenuItem("Edit Feature");
			editFeatureContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onEditFeatureMenuItem);
			
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
		
		private function disableSequence():void
		{
			featureAlignmentMap = null;
			orfAlignmentMap = null;
			
			caretPosition = 0;
			
			invalidSequence = true;
			
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(MouseEvent.DOUBLE_CLICK, onMouseDoubleClick);
			
			rail.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			rail.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			rail.removeEventListener(Event.SELECT_ALL, onSelectAll);
			rail.removeEventListener(Event.COPY, onCopy);
			rail.removeEventListener(Event.CUT, onCut);
			rail.removeEventListener(Event.PASTE, onPaste);
			
			removeEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
		}
		
		private function initializeSequence():void
		{
			invalidSequence = false;
			
			featuresAlignmentChanged = true;
			orfsAlignmentChanged = true;
			
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
			rail.addEventListener(Event.CUT, onCut);
			rail.addEventListener(Event.PASTE, onPaste);
			
			addEventListener(SelectionEvent.SELECTION_CHANGED, onSelectionChanged);
		}
		
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
				
				selectionLayer.startSelecting();
				selectionLayer.select(start, end);
				
				tryMoveCaretToPosition(end);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			if(!mouseIsDown) { return; }
			
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
				dispatchEvent(new RailEvent(RailEvent.EDIT_FEATURE, true, false, (event.target as FeatureRenderer).feature));
			}
		}
		
		private function onSelectAll(event:Event):void
		{
			select(0, _featuredSequence.sequence.length);
		}
		
		private function onCopy(event:Event):void
		{
			if(isValidIndex(selectionLayer.start) && isValidIndex(selectionLayer.end)) {
				Clipboard.generalClipboard.clear();
				Clipboard.generalClipboard.setData(FEATURED_SEQUENCE_CLIPBOARD_KEY, _featuredSequence.subFeaturedSequence(startSelectionIndex, endSelectionIndex), false);
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _featuredSequence.subSequence(startSelectionIndex, endSelectionIndex).sequence, false);
			}
		}
		
		private function onCut(event:Event):void
		{
			if(isValidIndex(selectionLayer.start) && isValidIndex(selectionLayer.end)) {
				Clipboard.generalClipboard.clear();
				Clipboard.generalClipboard.setData(FEATURED_SEQUENCE_CLIPBOARD_KEY, _featuredSequence.subFeaturedSequence(selectionLayer.start, selectionLayer.end), false);
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _featuredSequence.subSequence(selectionLayer.start, selectionLayer.end).sequence, false);
				
				if(_safeEditing) {
					doDeleteSequence(selectionLayer.start, selectionLayer.end);
				} else {
					_featuredSequence.removeSequence(selectionLayer.start, selectionLayer.end);
					
					deselect();
				}
			}
		}
		
		private function onPaste(event:Event):void
		{
			if(! isValidIndex(_caretPosition)) { return; }
			
			if(Clipboard.generalClipboard.hasFormat(FEATURED_SEQUENCE_CLIPBOARD_KEY)) {
				var clipboardObject:Object = Clipboard.generalClipboard.getData(FEATURED_SEQUENCE_CLIPBOARD_KEY);
				
				if(clipboardObject != null) {
					var pasteFeaturedSequence:FeaturedSequence = clipboardObject as FeaturedSequence;
					
					if(!isValidPasteSequence(pasteFeaturedSequence.sequence.sequence)) { return; }
					
					if(_safeEditing) {
						doInsertFeaturedSequence(pasteFeaturedSequence, _caretPosition);
					} else {
						_featuredSequence.insertFeaturedSequence(pasteFeaturedSequence, _caretPosition);
						
						tryMoveCaretToPosition(_caretPosition + pasteFeaturedSequence.sequence.sequence.length);
					}				
				}
			} else if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
				var pasteSequence:String = String(Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_ONLY)).toUpperCase();
				
				if(!isValidPasteSequence(pasteSequence)) { return; }
				
				if(_safeEditing) {
					doInsertSequence(new DNASequence(pasteSequence), _caretPosition);
				} else {
					_featuredSequence.insertSequence(new DNASequence(pasteSequence), _caretPosition);
					
					tryMoveCaretToPosition(_caretPosition + pasteSequence.length);
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
			if(! _featuredSequence) { return; }
			
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
				customContextMenu.clipboardItems.cut = true;
			} else {
				customContextMenu.clipboardItems.copy = false;
				customContextMenu.clipboardItems.cut = false;
			}
		}
		
		private function onContextMenuSelect(event:ContextMenuEvent):void
		{
			customContextMenu.customItems = new Array();
			
			if(event.mouseTarget is FeatureRenderer) {
				customContextMenu.customItems.push(editFeatureContextMenuItem);
			}
			
			
			if(selectionLayer.selected) {
				customContextMenu.customItems.push(selectedAsNewFeatureContextMenuItem);
			}
		}
		
		private function onEditFeatureMenuItem(event:ContextMenuEvent):void
		{
			dispatchEvent(new RailEvent(RailEvent.EDIT_FEATURE, true, true, (event.mouseTarget as FeatureRenderer).feature));
		}
		
		private function onSelectedAsNewFeatureMenuItem(event:ContextMenuEvent):void
		{
			dispatchEvent(new RailEvent(RailEvent.CREATE_FEATURE, true, true, new Feature(selectionLayer.start, selectionLayer.end)));
		}
		
		private function renderFeatures():void
		{
			if(! featureRenderers) { return; }
			
			for(var i:int = 0; i < featureRenderers.length; i++) {
				var featureRenderer:FeatureRenderer = featureRenderers[i] as FeatureRenderer;
				
				featureRenderer.visible = _showFeatures;
				
				if(_showFeatures) {
					featureRenderer.update(featureAlignmentMap[featureRenderer.feature]);
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
					cutSiteRenderer.update();
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
					orfRenderer.update(orfAlignmentMap[orfRenderer.orf]);
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
				
				var leftGap:Number = _startRailPoint.x + _bpWidth * leftLabelBox1.relatedAnnotation.start - leftLabelBox1.totalWidth;
				
				if(leftGap < biggestLeftGap) {
					biggestLeftGap = leftGap;
				}
			}
			
			// Adjust RailMetrics and ContentMetrics because labels can stick out
			if(biggestLeftGap < 0) {
				_startRailPoint.x += Math.abs(biggestLeftGap);
				_endRailPoint.x += Math.abs(biggestLeftGap);
				_totalWidth += Math.abs(biggestLeftGap);
			}
			
			// Calculate Vertical Position
			var previousYPosition1:Number = _startRailPoint.y - LABELS_RAIL_GAP;
			for(var j1:uint = 0; j1 < numberOfLeftLabels; j1++) {
				var leftLabelBox2:LabelBox = leftLabels[j1] as LabelBox;
				
				if(! leftLabelBox2.includeInView) { continue; }
				
				leftLabelBox2.x = _startRailPoint.x + _bpWidth * leftLabelBox2.relatedAnnotation.start - leftLabelBox2.totalWidth;
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
				
				var rightGap:Number = _totalWidth - (_startRailPoint.x + _bpWidth * rightLabelBox1.relatedAnnotation.start + rightLabelBox1.totalWidth + HORIZONTAL_PADDING);
				
				if(rightGap < biggestRightGap) {
					biggestRightGap = rightGap;
				}
			}
			
			// Adjust ContentMetrics because labels can stick out
			if(biggestRightGap < 0) {
				_totalWidth += Math.abs(biggestRightGap);
			}
			
			// Calculate Vertical Position
			var previousYPosition2:Number = _startRailPoint.y - LABELS_RAIL_GAP;
			for(var j2:int = numberOfRightLabels - 1; j2 >= 0; j2--) {
				var rightLabelBox2:LabelBox = rightLabels[j2] as LabelBox;
				
				if(! rightLabelBox2.includeInView) { continue; }
				
				rightLabelBox2.x = _startRailPoint.x + _bpWidth * rightLabelBox2.relatedAnnotation.start;
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
				_startRailPoint.y += verticalShift;
				_endRailPoint.y += verticalShift;
				
				_totalHeight += verticalShift;
				
				for(var z1:int = 0; z1 < numberOfLeftLabels; z1++) {
					leftLabels[z1].y += verticalShift;
				}
				for(var z2:int = 0; z2 < numberOfRightLabels; z2++) {
					rightLabels[z2].y += verticalShift;
				}
			}
			
			_horizontalCenter = (_startRailPoint.x + _endRailPoint.x) / 2;
		}
		
		private function loadFeatureRenderers():void
		{
			removeFeatureRenderers();
			
			if(! _featuredSequence || ! _featuredSequence.features) { return; }
			
			for(var i:int = 0; i < featuredSequence.features.length; i++) {
				var feature:Feature = featuredSequence.features[i] as Feature;
				
				var featureRenderer:FeatureRenderer = new FeatureRenderer(this, feature);
				
				featuresToRendererMap[feature] = featureRenderer;
				
				addChild(featureRenderer);
				
				featureRenderers.push(featureRenderer);
			}
		}
		
		private function loadCutSiteRenderers():void
		{
			removeCutSiteRenderers();
			
			if(!showCutSites || !featuredSequence || !_restrictionEnzymeMapper || !_restrictionEnzymeMapper.cutSites) { return; }
			
			for(var i:int = 0; i < _restrictionEnzymeMapper.cutSites.length; i++) {
				var cutSite:CutSite = _restrictionEnzymeMapper.cutSites[i] as CutSite;
				
				var cutSiteRenderer:CutSiteRenderer = new CutSiteRenderer(this, cutSite);
				
				cutSitesToRendererMap[cutSite] = cutSiteRenderer;
				
				addChild(cutSiteRenderer);
				
				cutSiteRenderers.push(cutSiteRenderer);
			}
		}
		
		private function loadORFRenderers():void
		{
			removeORFRenderers();
			
			if(!showORFs || !featuredSequence || !_orfMapper || !_orfMapper.orfs) { return; }
			
			for(var i:int = 0; i < _orfMapper.orfs.length; i++) {
				var orf:ORF = _orfMapper.orfs[i] as ORF;
				
				var orfRenderer:ORFRenderer = new ORFRenderer(this, orf);
				
				addChild(orfRenderer);
				
				orfRenderers.push(orfRenderer);
			}
		}
		
		private function loadLabels():void
		{
			removeLabels();
			
			if(_featuredSequence.features && showFeatures && showFeatureLabels) {
				// Create new labels for annotations
				var numberOfFeatures:int = _featuredSequence.features.length;
				
				for(var i:int = 0; i < numberOfFeatures; i++) {
					var feature:Feature = _featuredSequence.features[i] as Feature;
					
					var featureLabelBox:FeatureLabelBox = new FeatureLabelBox(this, feature);
					
					labelBoxes.push(featureLabelBox);
				}
			}
			
			if(showCutSites && showCutSiteLabels && _restrictionEnzymeMapper && _restrictionEnzymeMapper.cutSites) {
				// Create new labels for restriction enzymes
				var numberOfCutSites:int = _restrictionEnzymeMapper.cutSites.length;
				
				for(var j:int = 0; j < numberOfCutSites; j++) { 
					var cutSite:CutSite = _restrictionEnzymeMapper.cutSites[j] as CutSite;
					
					var cutSiteLabelBox:LabelBox = new CutSiteLabelBox(this, cutSite);
					
					labelBoxes.push(cutSiteLabelBox);
				}
			}
			
			labelBoxes.sort(labelBoxesSort);
			
			// Split labels into 2 groups
			var totalNumberOfLabels:uint = labelBoxes.length;
			var totalLength:uint = _featuredSequence.sequence.length;
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
			
			if(!_showFeatures || !_featuredSequence || _featuredSequence.features.length == 0) { return; }
			
			featureAlignment = new Alignment(_featuredSequence.features.toArray(), _featuredSequence);
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
			
			var orfAlignment:Alignment = new Alignment(_orfMapper.orfs.toArray(), _featuredSequence);
			for(var k:int = 0; k < orfAlignment.rows.length; k++) {
				var orfsRow:Array = orfAlignment.rows[k];
				
				for(var l:int = 0; l < orfsRow.length; l++) {
					var orf:ORF = orfsRow[l] as ORF;
					
					orfAlignmentMap[orf] = k;
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
				
				var annotation1:IAnnotation = labelBox1.relatedAnnotation as IAnnotation;
				
				if(annotation1 is Feature) {
					if((annotation1 as Feature).label == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer1:FeatureRenderer = featuresToRendererMap[annotation1] as FeatureRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(featureRenderer1.connectionPoint.x, featureRenderer1.connectionPoint.y);
				} else if(annotation1 is CutSite) {
					if((annotation1 as CutSite).label == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
					var cutSiteRenderer1:CutSiteRenderer = cutSitesToRendererMap[annotation1] as CutSiteRenderer;
					
					g.moveTo(labelBox1.x, labelBox1.y + labelBox1.totalHeight / 2);
					g.lineTo(cutSiteRenderer1.connectionPoint.x, cutSiteRenderer1.connectionPoint.y);
				}
			}
			
			var numberOfLeftLabels:uint = leftLabels.length;
			for(var i2:uint = 0; i2 < numberOfLeftLabels; i2++) {
				var labelBox2:LabelBox = leftLabels[i2] as LabelBox;
				
				if(! labelBox2.includeInView) { continue; }
				
				var annotation2:IAnnotation = labelBox2.relatedAnnotation as IAnnotation;
				
				if(annotation2 is Feature) {
					if((annotation2 as Feature).label == "" || !showFeatures || !showFeatureLabels) { continue; }
					
					var featureRenderer2:FeatureRenderer = featuresToRendererMap[annotation2] as FeatureRenderer;
					
					g.moveTo(labelBox2.x + labelBox2.totalWidth, labelBox2.y + labelBox2.totalHeight / 2);
					g.lineTo(featureRenderer2.connectionPoint.x, featureRenderer2.connectionPoint.y);
				} else if(annotation2 is CutSite) {
					if((annotation2 as CutSite).label == "" || !showCutSites || !showCutSiteLabels) { continue; }
					
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
			} else if(newPosition > featuredSequence.sequence.length) {
				newPosition = featuredSequence.sequence.length;
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
		
		private function isValidPasteSequence(sequence:String):Boolean
		{
			var result:Boolean = true;
			
			for(var j:int = 0; j < sequence.length; j++) {
				if(SequenceUtils.SYMBOLS.indexOf(sequence.charAt(j)) == -1) {
					Alert.show("Paste DNA Sequence contains invalid characters at position " + j + "!\nAllowed only these \"ATGCUYRSWKMBVDHN\"");
					return result;
				}
			}
			
			return result;
		}
		
		private function bpAtPoint(point:Point):uint
		{
			var position:Point = parent.localToGlobal(new Point(x, y));
			var contentPoint:Point = new Point(point.x - position.x, point.y - position.y);
			
			var result:int = 0;
			
			if(contentPoint.x < _startRailPoint.x) {
				result = 0;
			} else if(contentPoint.x > _endRailPoint.x) {
				result = featuredSequence.sequence.length;
			} else {
				result = int(Math.floor((contentPoint.x - _startRailPoint.x) / _bpWidth));
			}
			
			return result;
		}
		
		private function doSelect(start:int, end:int):void
		{
			if(start > 0 && end == 0) {
				end == featuredSequence.sequence.length - 1;
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
		
		private function doDeleteSequence(start:int, end:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_DELETE, new Array(start, end)));
		}
		
		private function doInsertSequence(dnaSequence:DNASequence, position:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_SEQUENCE, new Array(dnaSequence, position)));
		}
		
		private function doInsertFeaturedSequence(currentFeaturedSequence:FeaturedSequence, position:int):void
		{
			dispatchEvent(new EditingEvent(EditingEvent.COMPONENT_SEQUENCE_EDITING, EditingEvent.KIND_INSERT_FEATURED_SEQUENCE, new Array(currentFeaturedSequence, position)));
		}
	}
}
