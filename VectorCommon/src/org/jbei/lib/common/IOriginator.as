package org.jbei.lib.common
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
