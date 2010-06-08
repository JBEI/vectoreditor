package org.jbei.components.common
{
	import flash.events.IEventDispatcher;
	
	import org.jbei.lib.SequenceProvider;

    /**
     * @author Zinovii Dmytriv
     */
	public interface ISequenceComponent extends IEventDispatcher
	{
		function get sequenceProvider():SequenceProvider;
		function set sequenceProvider(value:SequenceProvider):void;
		
		function get readOnly():Boolean;
		function set readOnly(value:Boolean):void;
		
		function get caretPosition():int;
		function set caretPosition(value:int):void;
		
		function get selectionStart():int
		function get selectionEnd():int
		
		function select(start:int, end:int):void;
		function deselect():void;
	}
}
