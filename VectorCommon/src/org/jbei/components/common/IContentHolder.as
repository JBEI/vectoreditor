package org.jbei.components.common
{
	import org.jbei.lib.SequenceProvider;

    /**
     * @author Zinovii Dmytriv
     */
	public interface IContentHolder
	{
		function get sequenceProvider():SequenceProvider;
		
		function select(startIndex: int, endIndex: int):void;
		
		function deselect():void;
	}
}
