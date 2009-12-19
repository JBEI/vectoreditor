package org.jbei.components
{
    import flash.display.BitmapData;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    
    import mx.core.ScrollControlBase;
    import mx.core.ScrollPolicy;
    import mx.events.ResizeEvent;
    import mx.events.ScrollEvent;
    import mx.events.ScrollEventDirection;
    import mx.managers.IFocusManagerComponent;
    
    import org.jbei.components.common.CommonEvent;
    import org.jbei.components.sequenceClasses.ContentHolder;
    import org.jbei.lib.AAMapper;
    import org.jbei.lib.AAMapperEvent;
    import org.jbei.lib.FeaturedSequence;
    import org.jbei.lib.FeaturedSequenceEvent;
    import org.jbei.lib.ORFMapper;
    import org.jbei.lib.ORFMapperEvent;
    import org.jbei.lib.RestrictionEnzymeMapper;
    
	[Event(name="selectionChanged", type="org.jbei.components.common.SelectionEvent")]
	[Event(name="caretPositionChanged", type="org.jbei.components.common.CaretEvent")]
	[Event(name="featureDoubleClick", type="org.jbei.components.sequence.sequenceClasses.SequenceAnnotatorEvent")]
	[Event(name="editing", type="org.jbei.components.sequence.sequenceClasses.EditingEvent")]
	[Event(name="beforeUpdate", type="org.jbei.components.sequence.sequenceClasses.SequenceAnnotatorEvent")]
	[Event(name="afterUpdate", type="org.jbei.components.sequence.sequenceClasses.SequenceAnnotatorEvent")]
	
	public class SequenceAnnotator extends ScrollControlBase implements IFocusManagerComponent
	{
		private const DEFAULT_BP_PER_ROW:int = 60;
		private const LIVE_SCROLL_SPEED:Number = 10;
		private const MIN_FONT_SIZE:int = 10;
		private const MAX_FONT_SIZE:int = 18;
		private const MIN_LABEL_FONT_SIZE:int = 9;
		private const MAX_LABEL_FONT_SIZE:int = 14;
		
		private var _featuredSequence:FeaturedSequence;
		private var _orfMapper:ORFMapper;
		private var _aaMapper:AAMapper;
		private var _restrictionEnzymeMapper:RestrictionEnzymeMapper;
		private var _highlights:Array /* of Segment */;
		
		private var contentHolder:ContentHolder;
		
		private var _showCutSites:Boolean = true;
		private var _showComplementarySequence:Boolean = true;
		private var _showFeatures:Boolean = true;
		private var _bpPerRow:int = DEFAULT_BP_PER_ROW;
		private var _sequenceFontSize:int = 11;
		private var _labelFontSize:int = 10;
		private var _showSpaceEvery10Bp:Boolean = true;
		private var _showAminoAcids1:Boolean = false;
		private var _showAminoAcids3:Boolean = false;
		private var _showORFs:Boolean = false;
		private var _safeEditing:Boolean = true;
		private var _floatingWidth:Boolean = true;
		
		private var contentHeight:uint = 0;
		private var floatingBpPerRow:int = DEFAULT_BP_PER_ROW;
		
		private var featuredSequenceChanged:Boolean = false;
		private var orfMapperChanged:Boolean = false;
		private var aaMapperChanged:Boolean = false;
		private var restrictionEnzymeMapperChanged:Boolean = false;
		private var highlightsChanged:Boolean = false;
		private var needsMeasurement:Boolean = false;
		private var bpPerRowChanged:Boolean = false;
		private var showFeaturesChanged:Boolean = false;
		private var showCutSitesChanged:Boolean = false;
		private var showComplementaryChanged:Boolean = false;
		private var sequenceFontSizeChanged:Boolean = false;
		private var labelFontSizeChanged:Boolean = false;
		private var showSpaceEvery10BpChanged:Boolean = false;
		private var showAminoAcids1Changed:Boolean = false;
		private var showAminoAcids3Changed:Boolean = false;
		private var showORFsChanged:Boolean = false;
		private var editingMode:Boolean = false;
		private var floatingWidthChanged:Boolean = false;
		
		// Constructor
		public function SequenceAnnotator()
		{
			super();
			
	        verticalScrollPolicy = ScrollPolicy.AUTO;
	        horizontalScrollPolicy = ScrollPolicy.AUTO;
	        
	        liveScrolling = true;
	        
			addEventListener(ScrollEvent.SCROLL, onScroll);
	        addEventListener(ResizeEvent.RESIZE, onResize);
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
	    	_featuredSequence = value;
	    	
	    	featuredSequenceChanged = true;
	    	
	    	invalidateProperties();
	    	
	    	verticalScrollPosition = 0;
	    	horizontalScrollPosition = 0;
	    	
	    	contentHolder.x = 0;
	    	contentHolder.y = 0;
	    	
	    	if(_featuredSequence) {
	    		_featuredSequence.addEventListener(FeaturedSequenceEvent.SEQUENCE_CHANGED, onFeaturedSequenceChanged);
	    	}
	    }
		
	    public function get restrictionEnzymeMapper():RestrictionEnzymeMapper
	    {
	        return _restrictionEnzymeMapper;
	    }
		
	    public function set restrictionEnzymeMapper(value:RestrictionEnzymeMapper):void
	    {
	    	_restrictionEnzymeMapper = value;
	    	
	    	restrictionEnzymeMapperChanged = true;
	    	
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
		
		public function get aaMapper():AAMapper
		{
			return _aaMapper;
		}
		
		public function set aaMapper(value:AAMapper):void
		{
			_aaMapper = value;
			
			aaMapperChanged = true;
			if(_aaMapper) {
				_aaMapper.addEventListener(AAMapperEvent.AA_MAPPER_UPDATED, onAAMapperUpdated);
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
	    
	    public function get showComplementarySequence():Boolean
	    {
	        return _showComplementarySequence;
	    }
		
	    public function set showComplementarySequence(value:Boolean):void
	    {
	    	if(_showComplementarySequence != value) {
		    	_showComplementarySequence = value;
		    	
		    	showComplementaryChanged = true;
		    	
		    	invalidateProperties();
	    	}
	    }
	    
	    public function get bpPerRow():int
	    {
	        return _bpPerRow;
	    }
		
	    public function set bpPerRow(value:int):void
	    {
	    	if(_bpPerRow != value) {
		    	_bpPerRow = value;
		    	
		    	bpPerRowChanged = true;
		    	
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
				
				if(floatingWidth) {
					calculateFloatingBpPerRow();
				}
		    	
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
	    
	    public function get sequenceFontSize():int
	    {
	    	return _sequenceFontSize;
	    }
	    
	    public function set sequenceFontSize(value:int):void
	    {
	    	if(value < MIN_FONT_SIZE) { value = MIN_FONT_SIZE; }
	    	if(value > MAX_FONT_SIZE) { value = MAX_FONT_SIZE; }
	    	
	    	if (value != sequenceFontSize) {
	    		_sequenceFontSize = value;
	    		
	    		sequenceFontSizeChanged = true;
	    		
	    		invalidateProperties();
	    	}
	    }
	    
		public function get floatingWidth():Boolean
		{
			return _floatingWidth;
		}
		
		public function set floatingWidth(value:Boolean):void
		{
			if (value != floatingWidth) {
				_floatingWidth = value;
				
				floatingWidthChanged = true;
				
				invalidateProperties();
			}
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
		
	    public function get caretPosition():int
	    {
	    	return contentHolder.caretPosition;
	    }
	    
	    public function set caretPosition(value:int):void
	    {
	    	contentHolder.caretPosition = value;
	    }
	    
	    public function get selectionStart():int
	    {
	    	return contentHolder.selectionStart;
	    }
	    
	    public function get selectionEnd():int
	    {
	    	return contentHolder.selectionEnd;
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
		
	    // Public Methods
		public function scrollToSelection():void
		{
			if(!contentHolder.isValidIndex(selectionStart) || !contentHolder.isValidIndex(selectionEnd)) { return; }
			
			verticalScrollPosition = contentHolder.adjustedSelectionVerticalPosition();
			contentHolder.y = -verticalScrollPosition;
		}
		
	    public function select(start:int, end:int):void
	    {
	    	contentHolder.select(start, end);
	    }
	    
	    public function deselect():void
	    {
	    	contentHolder.deselect();
	    }
		
		public function printableContent():BitmapData
		{
			// CRASHES IF content height or width bigger then 2800px
			// Read more http://livedocs.adobe.com/flex/3/langref/flash/display/BitmapData.html#BitmapData()
			// Fix it later by making pagination
			var contentBitmapData:BitmapData = new BitmapData(contentHolder.totalWidth, contentHolder.totalHeight);
			contentBitmapData.draw(contentHolder);
			
			return contentBitmapData;
		}
		
		// Protected Methods
		protected override function createChildren():void
		{
			super.createChildren();
			
	        if(!contentHolder) {
	            contentHolder = new ContentHolder(this);
	            contentHolder.includeInLayout = false;
            	addChild(contentHolder);
	            // Make content fit into ScrollControlBase control
	            // Hide invisible portion of the content
	            contentHolder.mask = maskShape;
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
	        
			if(aaMapperChanged) {
				aaMapperChanged = false;
				
				needsMeasurement = true;
				
				contentHolder.aaMapper = _aaMapper;
				
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
			
	        if(showComplementaryChanged) {
	        	showComplementaryChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.showComplementary = _showComplementarySequence;
				
	        	invalidateDisplayList();
	        }
	        
	        if(showCutSitesChanged) {
	        	showCutSitesChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.showCutSites = _showCutSites;
				
	        	invalidateDisplayList();
	        }
	        
	        if(showFeaturesChanged) {
	        	showFeaturesChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.showFeatures = _showFeatures;
				
	        	invalidateDisplayList();
	        }
	        
			if(floatingWidthChanged) {
				floatingWidthChanged = false;
				
				needsMeasurement = true;
				
				if(floatingWidth) {
					calculateFloatingBpPerRow();
					
					contentHolder.bpPerRow = floatingBpPerRow;
				} else {
					contentHolder.bpPerRow = _bpPerRow;
				}
			}
			
	        if(bpPerRowChanged && !floatingWidth) {
	        	bpPerRowChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.bpPerRow = _bpPerRow;
				
	        	invalidateDisplayList();
	        }
	        
	        if(sequenceFontSizeChanged) {
	        	sequenceFontSizeChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.sequenceFontSize = _sequenceFontSize;
				
	        	invalidateDisplayList();
	        }
	        
			if(labelFontSizeChanged) {
				labelFontSizeChanged = true;
				
				needsMeasurement = true;
				
				contentHolder.labelFontSize = _labelFontSize;
				
				invalidateDisplayList();
			}
			
	        if(showSpaceEvery10BpChanged) {
	        	showSpaceEvery10BpChanged = false;
	        	
				needsMeasurement = true;
				
				contentHolder.showSpaceEvery10Bp = _showSpaceEvery10Bp;
				
	        	invalidateDisplayList();
	        }
	        
	        if(showAminoAcids1Changed) {
	        	showAminoAcids1Changed = false;
	        	
	        	needsMeasurement = true;
	        	
	        	contentHolder.showAminoAcids1 = _showAminoAcids1;
	        	
	        	invalidateDisplayList();
	        }
	        
	        if(showAminoAcids3Changed) {
	        	showAminoAcids3Changed = false;
	        	
	        	needsMeasurement = true;
	        	
	        	contentHolder.showAminoAcids3 = _showAminoAcids3;
	        	
	        	invalidateDisplayList();
	        }
	        
	        if(showORFsChanged) {
	        	showORFsChanged = false;
	        	
	        	needsMeasurement = true;
	        	
	        	contentHolder.showORFs = _showORFs;
	        	
	        	invalidateDisplayList();
	        }
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(needsMeasurement) {
				needsMeasurement = false;
				
				dispatchEvent(new CommonEvent(CommonEvent.BEFORE_UPDATE));
				
				try {
					contentHolder.updateMetrics(unscaledWidth, unscaledHeight);
					contentHolder.validateNow();
					
					adjustScrollBars();
				} catch (error:Error) {
					trace(error.getStackTrace());
				} finally {
					dispatchEvent(new CommonEvent(CommonEvent.AFTER_UPDATE));
				}
			}
		}
		
		protected override function mouseWheelHandler(event:MouseEvent):void
		{
			if(verticalScrollBar) {
				doScroll(event.delta, verticalScrollBar.lineScrollSize);
			}
		}
		
		// Private Methods
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
				
				// Prevent scrolling further then content
				if(contentHolder.y + contentHolder.totalHeight < height) {
					contentHolder.y += height - (contentHolder.y + contentHolder.totalHeight)
				}
				
				// Adjust scroll position to content position
				if (verticalScrollPosition != -contentHolder.y) {
					verticalScrollPosition = -contentHolder.y;
				}
	    	}
		}
	    
	    private function onResize(event:ResizeEvent):void
	    {
	    	needsMeasurement = true;
	    	
	    	invalidateDisplayList();
	    	
	    	horizontalScrollPosition = 0;
	    	verticalScrollPosition = 0;
	    	
	    	if(contentHolder) {
		    	contentHolder.y = 0;
		    	contentHolder.x = 0;
		    }
			
			if(floatingWidth) {
				calculateFloatingBpPerRow();
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
        
		private function onAAMapperUpdated(event:AAMapperEvent):void
		{
			aaMapperChanged = true;
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
		private function onORFMapperUpdated(event:ORFMapperEvent):void
		{
			orfMapperChanged = true;
			needsMeasurement = true;
			
			invalidateDisplayList();
		}
		
        private function onFeaturedSequenceChanged(event:FeaturedSequenceEvent):void
        {
			featuredSequenceChanged = true;
			
			invalidateProperties();
        }
		
		private function adjustScrollBars():void
		{
			setScrollBarProperties(contentHolder.totalWidth, width, contentHolder.totalHeight, height);
			
			if(verticalScrollBar) {
				verticalScrollBar.lineScrollSize = contentHolder.averageRowHeight;
				verticalScrollBar.pageScrollSize = verticalScrollBar.lineScrollSize * 10;
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
				
				var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
				scrollEvent.direction = ScrollEventDirection.VERTICAL;
				scrollEvent.position = verticalScrollPosition;
				scrollEvent.delta = verticalScrollPosition - oldPosition;
				dispatchEvent(scrollEvent);
			}
		}
		
		private function calculateFloatingBpPerRow():void
		{
			if(contentHolder) {
				var numberOfFittingBP:int = int((width - 30) / contentHolder.sequenceSymbolRenderer.textWidth) - 7; // -30 for scrollbar and extra space, -7 for index
				
				var extraSpaces:int = showSpaceEvery10Bp ? int(numberOfFittingBP / 10) : 0;
				
				floatingBpPerRow = (numberOfFittingBP < 20) ? 10 : (10 * int(Math.floor((numberOfFittingBP - extraSpaces) / 10)));
			} else {
				floatingBpPerRow = DEFAULT_BP_PER_ROW;
			}
			
			contentHolder.bpPerRow = floatingBpPerRow;
		}
	}
}
