package org.jbei.common
{
	public interface IOriginator
	{
		function createMemento():IMemento;
		function setMemento(memento:IMemento):void;
	}
}
