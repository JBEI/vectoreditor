package org.jbei.components.common
{
	import org.jbei.lib.FeaturedSequence;

	public interface IContentHolder
	{
		function get featuredSequence():FeaturedSequence;
		
		function select(startIndex: int, endIndex: int):void;
		
		function deselect():void;
	}
}
