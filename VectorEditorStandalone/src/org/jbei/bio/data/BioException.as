package org.jbei.bio.data
{
	public class BioException extends Error
	{
		public function BioException(message:String="", id:int=0)
		{
			super(message, id);
		}
	}
}