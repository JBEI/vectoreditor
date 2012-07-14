package com.ak33m.rpc.core
{
	import mx.rpc.AsyncToken;
	
	public interface IRPCObject
	{
		/**
		 * RPC specific implementation of a method call
		 */
		function makeCall (method : String,args : Array): AsyncToken;
		
		/**
		 * Create connection to RPC gateway
		 */
		function makeConnection ():void;
	}
}