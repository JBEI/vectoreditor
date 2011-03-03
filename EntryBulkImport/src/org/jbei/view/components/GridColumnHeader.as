package org.jbei.view.components
{
	import mx.charts.chartClasses.NumericAxis;
	
	import org.jbei.model.EntryTypeField;
	
	import spark.components.Label;

	public class GridColumnHeader extends Label
	{
		public static const WIDTH:Number = GridCell.DEFAULT_WIDTH ;
		public static const HEIGHT:Number = 50; // GridCell.DEFAULT_HEIGHT + 15;
		
		private var _typeField:EntryTypeField;
		
		public function GridColumnHeader( typeField:EntryTypeField )
		{
			width = WIDTH;
			height = HEIGHT;
			
			this._typeField = typeField;
			this.text = this._typeField.name;
			
			// styles
			this.setStyle( "textAlign", "center" );
			this.setStyle( "verticalAlign", "middle" );
			this.setStyle( "fontSize", 12 );
			this.setStyle( "fontWeight", "bold" );
			this.setStyle( "paddingLeft", 2 );
			this.setStyle( "paddingRight", 2 );
			
			render();
		}
		
		public function render():void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, 0x000000 );
			this.graphics.beginFill( 0xCCCCCC );
			this.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
			this.graphics.endFill();
		}
		
		public function highlight() : void
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, 0x000000 );
			this.graphics.beginFill( 0xf6cc82 );
			this.graphics.drawRect( 0, 0, WIDTH, HEIGHT );
			this.graphics.endFill();
		}
		
		public function get typeField() : EntryTypeField
		{
			return this._typeField;
		}
	}
}