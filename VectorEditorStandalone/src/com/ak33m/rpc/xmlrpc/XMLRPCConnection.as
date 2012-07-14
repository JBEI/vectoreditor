/**
 * Copyright (c) 2006, Akeem Philbert (based on the work of (between others): Jesse Warden, Xavi Beumala, Renaun 
	Erickson, Carlos Rovira)
	All rights reserved.
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
	following conditions are met:
	
	    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
		  disclaimer.
	    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
		  following disclaimer in the documentation and/or other materials provided with the distribution.
	    * Neither the name of the Akeem Philbert nor the names of its contributors may be used to endorse or promote 
		  products derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.ak33m.rpc.xmlrpc
{
	import com.ak33m.rpc.core.IRPCConnection;
	import flash.net.Responder;
	import mx.rpc.http.HTTPService;
	import flash.net.URLRequestHeader;

	public class XMLRPCConnection extends HTTPService  implements IRPCConnection
	{	
		public function XMLRPCConnection (rootURL:String=null)
		{
			super(rootURL);
			this.method = "post";
		}
		
		public function call(command:String,responder:Responder,...args):void
		{
			var trequestxml:XML = XMLRPCSerializer.serialize(command,args);
			send(trequestxml);
		}
	}
}