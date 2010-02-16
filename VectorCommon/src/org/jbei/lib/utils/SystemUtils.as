package org.jbei.lib.utils
{
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	
	public final class SystemUtils
	{
		import flash.system.Capabilities;
		
		public static function getSystemMonospaceFontFamily():String
		{
			var resultFont:String = "Courier New";
			
			if(SystemUtils.isWindowsOS()) {
				resultFont = "Lucida Console";
			} else if (SystemUtils.isLinuxOS()) {
				resultFont = "Monospace";
			} else if (SystemUtils.isMacOS()) {
				resultFont = "Monaco";
			}
			
			return resultFont;
		}
		
		public static function isWindowsOS():Boolean
		{
			return Capabilities.os.indexOf("Windows") >= 0;
		}
		
		public static function isLinuxOS():Boolean
		{
			return Capabilities.os.indexOf("Linux") >= 0;
		}
		
		public static function isMacOS():Boolean
		{
			return Capabilities.os.indexOf("Mac") >= 0;
		}
		
		public static function goToUrl(url:String):void
		{
			if (ExternalInterface.available) {
				ExternalInterface.call("window.open", url, "_blank", "");
			} 
		}
		
		public static function applicationVersion(majorVersion:String):String
		{
			var versionDate:Date = new Date();
			
			var version:String = majorVersion + "." + String(versionDate.getFullYear()).substr(2, 2) + "." + String(versionDate.getMonth() + 1) + "." + String(versionDate.getDate());
			
			return version;
		}
	}
}
