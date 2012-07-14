package com.ak33m.rpc.core
{
	import flash.net.Responder;
	public interface IRPCConnection
	{
		/**
		 * Invoke RPC call to server
		 */
		function call(command:String,responder:Responder,...arguments):void;
	}
}