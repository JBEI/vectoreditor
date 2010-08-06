package org.jbei.registry.lib
{
    /**
     * @author Zinovii Dmytriv
     */
	public interface IOriginator
	{
		function createMemento():IMemento;
		function setMemento(memento:IMemento):void;
	}
}