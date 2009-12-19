package org.jbei.components
{
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.core.ScrollControlBase;
	import mx.core.ScrollPolicy;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDirection;
	import mx.managers.IFocusManagerComponent;
	
	import org.jbei.components.railClasses.ContentHolder;
	import org.jbei.lib.FeaturedSequence;
	import org.jbei.lib.FeaturedSequenceEvent;
	import org.jbei.lib.ORFMapper;
	import org.jbei.lib.ORFMapperEvent;
	import org.jbei.lib.RestrictionEnzymeMapper;
	import org.jbei.lib.RestrictionEnzymeMapperEvent;
	
	[Event(name="selectionChanged", type="org.jbei.components.common.SelectionEvent")]
	[Event(name="caretPositionChanged", type="org.jbei.components.common.CaretEvent")]
	[Event(name="editing", type="org.jbei.components.sequence.sequenceClasses.EditingEvent")]
	
	public class Rail extends ScrollControlBase implements IFocusManagerComponent
	{
		private const MIN_LABEL_FONT_SIZE:int = 9;
		private const MAX_LABEL_FONT_SIZE:int = 14;
		
		private var contentHolder:ContentHolder;
		
		private var _featuredSequence:FeaturedSequence;
		private var _orfMapper:ORFMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Segment */;
		
		private var _showCutSites:Boolean = true;
		private var _showFeatures:Boolean = true;
		private var _showCutSiteLabels:Boolean = true;
		private var _showFeatureLabels:Boolean = true;
		private var _showORFs:Boolean = true;
		private var _safeEditing:Boolean = true;
		private var _labelFontSize:int = 10;
		
		private var featuredSequenceChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		
		private var needsMeasurement:Boolean = false;
		private var showFeaturesChanged:Boolean = false;
		private var showCutSitesChanged:Boolean = false;
		private var showORFsChanged:Boolean = false;
		private var showFeatureLabelsChanged:Boolean = false;
		private var showCutSiteLabelsChanged:Boolean = false;
		private var labelFontSizeChanged:Boolean = false;
		
		// Contructor
		public function Rail()
		{
			super();
			
			verticalScrollPolicy = ScrollPolicy.AUTO;
			horizontalScrollPolicy = ScrollPolicy.AUTO;
			
			addEventListener(ResizeEvent.RESIZE, onResize);
			addEventListener(ScrollEvent.SCROLL, onScroll);
			
			addEventListener(MouseEvent.CLICK, onMouseClick);
			
			addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		// Properties
		public function get featuredSequence():FeaturedSequence
		{
			return _featuredSequence;
		}
		
		public function set featuredSequence(value:FeaturedSequence):void
		{
			if(value) {
				if(_featuredSequence != value) {
					_featuredSequence = value;
					
					_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
				}
			} else {
				_featuredSequence = null;
				
				verticalScrollPosition = 0;
				horizontalScrollPosition = 0;
				
				contentHolder.x = 0;
				contentHolder.y = 0;
			}
			
			featuredSequenceChanged = true;
			
			invalidateProperties();
		}
		
		public function get restrictionEnzymeMapper():RestrictionEnzymeMapper
		{
			return _restrictionEnzymeMapper;
		}
		
		public function set restrictionEnzymeMapper(value:RestrictionEnzymeMapper):void
		{
			_restrictionEnzymeMapper = value;
			
			restrictionEnzymeMapperChanged = true;
			if(_restrictionEnzymeMapper) {
				_restrictionEnzymeMapper.addEventListener(RestrictionEnzymeMapperEvent.RESTRICTION_ENZYME_MAPPER_UPDATED, onRestrictionEnzymeMapperUpdated);
			}
			
			invalidateProperties();
		}
		
		public function get orfMapper():ORFMapper
		{
			return _orfMapper;
		}
		
		public function set orfMapper(value:ORFMapper):void
		{
			_orfMapper = value;
			
			orfMapperChanged = true;
			if(_orfMapper) {
				_orfMapper.addEventListener(ORFMapperEvent.ORF_MAPPER_UPDATED, onORFMapperUpdated);
			}
			
			invalidateProperties();
		}
		
		public function get highlights():Array /* of Segment */
		{
			return _highlights;
		}
		
		public function set highlights(value:Array /* of Segment */):void
		{
			_highlights = value;
			
			highlightsChanged = true;
			
			invalidateProperties();
		}
		
		public function get showFeatures():Boolean
		{
			return _showFeatures;
		}
		
		public function set showFeatures(value:Boolean):void
		{
			if(_showFeatures != value) {
				_showFeatures = value;
				
				showFeaturesChanged = true;
				
				invalidateProperties();
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
		
		public function get showFeatureLabels():Boolean
		{
			return _showFeatureLabels;
		}
		
		public function set showFeatureLabels(value:Boolean):void
		{
			if(_showFeatureLabels != value) {
				_showFeatureLabels = value;
				
				showFeatureLabelsChanged = true;
				
				invalidateProperties();
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
				
				showCutSiteLabelsChanged = true;
				
				invalidateProperties();
			}
		}
		
		public function get caretPosition():int
		{
			return contentHolder.caretPosition;
		}
		
		public function set caretPosition(value:int):void
		{
			contentHolder.caretPosition = value;
		}
		
		public function get safeEditing():Boolean
		{
			return _safeEditing;
		}
		
		public function set safeEditing(value:Boolean):void
		{
			if(_safeEditing != value) {
				_safeEditing = value;
				
				contentHolder.safeEditing = _safeEditing;
			}
		}
		
		public function get selectionStart():int
		{
			return contentHolder.selectionStart;
		}
		
		public function get selectionEnd():int
		{
			return contentHolder.selectionEnd;
		}
		
		public function get labelFontSize():int
		{
			return _labelFontSize;
		}
		
		public function set labelFontSize(value:int):void
		{
			if(value < MIN_LABEL_FONT_SIZE) { value = MIN_LABEL_FONT_SIZE; }
			if(value > MAX_LABEL_FONT_SIZE) { value = MAX_LABEL_FONT_SIZE; }
			
			if (value != labelFontSize) {
				_labelFontSize = value;
				
				labelFontSizeChanged = true;
				
				invalidateProperties();
			}
		}
		
		// Public Methods
		public function select(start:int, end:int):void
		{
			contentHolder.select(start, end);
		}
		
		public function deselect():void
		{
			contentHolder.deselect();
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
			createContentHolder();
		}
		
		protected override function mouseWheelHandler(event:MouseEvent):void
		{
			if(verticalScrollBar) {
				doScroll(event.delta, verticalScrollBar.lineScrollSize);
			}
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(featuredSequenceChanged) {
				featuredSequenceChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.featuredSequence = _featuredSequence;
				
				invalidateDisplayList();
			}
			
			if(restrictionEnzymeMapperChanged) {
				restrictionEnzymeMapperChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.restrictionEnzymeMapper = _restrictionEnzymeMapper;
				
				invalidateDisplayList();
			}
			
			if(orfMapperChanged) {
				orfMapperChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.orfMapper = _orfMapper;
				
				invalidateDisplayList();
			}
			
			if(highlightsChanged) {
				highlightsChanged = false;
				
				contentHolder.highlights = _highlights;
				
				invalidateDisplayList();
			}
			
			if(showFeaturesChanged) {
				showFeaturesChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.showFeatures = _showFeatures;
				
				invalidateDisplayList();
			}
			
			if(showCutSitesChanged) {
				showCutSitesChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.showCutSites = _showCutSites;
				
				invalidateDisplayList();
			}
			
			if(showFeatureLabelsChanged) {
				showFeatureLabelsChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.showFeatureLabels = _showFeatureLabels;
				
				invalidateDisplayList();
			}
			
			if(showCutSiteLabelsChanged) {
				showCutSiteLabelsChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.showCutSiteLabels = _showCutSiteLabels;
				
				invalidateDisplayList();
			}
			
			if(showORFsChanged) {
				showORFsChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.showORFs = _showORFs;
				
				invalidateDisplayList();
			}
			
			if(labelFontSizeChanged) {
				labelFontSizeChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.labelFontSize = _labelFontSize;
				
				invalidateDisplayList();
			}
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				//dispatchEvent(new SequenceAnnotatorEvent(SequenceAnnotatorEvent.BEFORE_UPDATE));
				
				try {
					contentHolder.updateMetrics(unscaledWidth, unscaledHeight);
					contentHolder.validateNow();
					
					contentHolder.x = 0;
					contentHolder.y = 0;
					
					adjustScrollBars();
				} catch (error:Error) {
					trace(error.getStackTrace());
				} finally {
					//dispatchEvent(new SequenceAnnotatorEvent(SequenceAnnotatorEvent.AFTER_UPDATE));
				}
			}
		}
		
		// Private Methods
		private function createContentHolder():void
		{
			if(!contentHolder) {
				contentHolder = new ContentHolder(this);
				contentHolder.includeInLayout = false;
				addChild(contentHolder);
				
				contentHolder.mask = maskShape;
			}
		}
		
		private function adjustScrollBars():void
		{
			verticalScrollPosition = 0;
			horizontalScrollPosition = 0;
			
			setScrollBarProperties(contentHolder.totalWidth, width, contentHolder.totalHeight, height);
			
			if(verticalScrollBar) {
				verticalScrollBar.lineScrollSize = 20;
				verticalScrollBar.pageScrollSize = verticalScrollBar.lineScrollSize * 10;
				
				verticalScrollPosition = contentHolder.totalHeight - height;
				contentHolder.y = -verticalScrollPosition;
			}
			
			if(horizontalScrollBar) {
				horizontalScrollPosition = contentHolder.horizontalCenter - width / 2;
				contentHolder.x = -horizontalScrollPosition;
			}
		}
		
		private function doScroll(delta:int, speed:uint = 3):void
		{
			if (verticalScrollBar && verticalScrollBar.visible) {
				var scrollDirection:int = delta <= 0 ? 1 : -1;
				
				var oldPosition:Number = verticalScrollPosition;
				verticalScrollPosition += speed * scrollDirection;
				
				if(verticalScrollPosition < 0) {
					verticalScrollPosition = 0;
				}
				
				if(verticalScrollPosition > maxVerticalScrollPosition) {
					verticalScrollPosition = maxVerticalScrollPosition;
				}
				
				var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
				scrollEvent.direction = ScrollEventDirection.VERTICAL;
				scrollEvent.position = verticalScrollPosition;
				scrollEvent.delta = verticalScrollPosition - oldPosition;
				dispatchEvent(scrollEvent);
			}
		}
		
		private function onResize(event:ResizeEvent):void
		{
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		private function onScroll(event:ScrollEvent):void
		{
			if(event.direction == ScrollEventDirection.HORIZONTAL) {
				// Adjust content position. Content moves into oposide direction to scroll.
				contentHolder.x = -event.position;
				
				// Adjust scroll position to content position
				if (horizontalScrollPosition != -contentHolder.x) {
					horizontalScrollPosition = -contentHolder.x;
				}
			} else if(event.direction == ScrollEventDirection.VERTICAL) {
				// Adjust content position. Content moves into oposide direction to scroll.
				contentHolder.y = -event.position;
				
				// Adjust scroll position to content position
				if (verticalScrollPosition != -contentHolder.y) {
					verticalScrollPosition = -contentHolder.y;
				}
			}
		}
		
		private function onFocusIn(event:FocusEvent):void
		{
			contentHolder.showCaret();
		}
		
		private function onFocusOut(event:FocusEvent):void
		{
			contentHolder.hideCaret();
		}
		
		private function onMouseClick(event:MouseEvent):void
		{
			if(focusManager.getFocus() != this) {
				focusManager.setFocus(this);
			}
		}
		
		private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
		{
			featuredSequenceChanged = true;
			
			invalidateProperties();
		}
		
		private function onORFMapperUpdated(event:ORFMapperEvent):void
		{
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		private function onRestrictionEnzymeMapperUpdated(event:RestrictionEnzymeMapperEvent):void
		{
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
	}
}
