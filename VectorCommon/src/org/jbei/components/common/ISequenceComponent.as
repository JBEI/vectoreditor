package org.jbei.components.common
{
	import flash.events.IEventDispatcher;
	
	import org.jbei.lib.FeaturedSequence;

	public interface ISequenceComponent extends IEventDispatcher
	{
		function get featuredSequence():FeaturedSequence;
		function set featuredSequence(value:FeaturedSequence):void;
		
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
