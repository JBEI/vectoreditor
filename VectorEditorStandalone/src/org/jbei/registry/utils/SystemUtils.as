package org.jbei.registry.utils
{
	import org.jbei.registry.Constants;
	
	public class SystemUtils
	{
		public static function applicationVersion():String
		{
			var versionDate:Date = new Date();
			
			var version:String = Constants.MAJOR_VERSION + "." + String(versionDate.getFullYear()).substr(2, 2) + "." + String(versionDate.getMonth() + 1) + "." + String(versionDate.getDate());
			
			return version;
		}
	}
}
