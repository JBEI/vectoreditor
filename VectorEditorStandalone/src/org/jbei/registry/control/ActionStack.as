package org.jbei.registry.control
{
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.jbei.lib.common.IMemento;
	import org.jbei.registry.ApplicationFacade;
	
	public class ActionStack extends EventDispatcher
	{
		private var undoStack:ArrayCollection /* of IMemento */ = new ArrayCollection();
		private var redoStack:ArrayCollection /* of IMemento */ = new ArrayCollection();
		
		// Properties
		public function get undoStackIsEmpty():Boolean
		{
			return undoStack.length == 0;
		}
		
		public function get redoStackIsEmpty():Boolean
		{
			return redoStack.length == 0;
		}
		
		// Public Methods
		public function undo():void
		{
			if(undoStack.length == 0) { return; }
			
			var item:IMemento = undoStack[0] as IMemento;
			undoStack.removeItemAt(0);
			redoStack.addItemAt(ApplicationFacade.getInstance().featuredSequence.createMemento(), 0);
			
			ApplicationFacade.getInstance().featuredSequence.setMemento(item);
			
			dispatchEvent(new ActionStackEvent(ActionStackEvent.ACTION_STACK_CHANGED));
		}
		
		public function redo():void
		{
			if(redoStack.length == 0) { return; }
			
			var item:IMemento = redoStack[0] as IMemento;
			redoStack.removeItemAt(0);
			undoStack.addItemAt(ApplicationFacade.getInstance().featuredSequence.createMemento(), 0);
			
			ApplicationFacade.getInstance().featuredSequence.setMemento(item);
			
			dispatchEvent(new ActionStackEvent(ActionStackEvent.ACTION_STACK_CHANGED));
		}
		
		public function add(item:IMemento):void
		{
			undoStack.addItemAt(item, 0);
			
			redoStack.removeAll();
			
			dispatchEvent(new ActionStackEvent(ActionStackEvent.ACTION_STACK_CHANGED));
		}
		
		public function clear():void
		{
			undoStack.removeAll();
			redoStack.removeAll();
			
			dispatchEvent(new ActionStackEvent(ActionStackEvent.ACTION_STACK_CHANGED));
		}
	}
}
