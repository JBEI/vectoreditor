package org.jbei.view.components
{
	import mx.collections.ArrayCollection;
	
	import spark.components.DropDownList;

	public class PartTypeOptions extends DropDownList
	{
		public function PartTypeOptions()
		{
			this.prompt = "Select Type";
			this.labelField = "name";
		}
	}
}