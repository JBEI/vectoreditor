package org.jbei.lib.common
{
	public interface IOriginator
	{
		function createMemento():IMemento;
		function setMemento(memento:IMemento):void;
	}
}
