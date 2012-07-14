/**
 * Copyright (c) 2007, Akeem Philbert (based on the work of (between others): Jesse Warden, Xavi Beumala, Renaun 
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
	import com.ak33m.rpc.core.*;
	
	import mx.core.IMXMLObject;
	import mx.managers.CursorManager;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.messaging.messages.IMessage;
	import mx.messaging.messages.RemotingMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.*;
	import mx.rpc.mxml.IMXMLSupport;
	
	[Bindable]
	/**
	 * XMLRPCObject can be used to make XMLRPC calls. It mimics the RemoteObject implementation with a few exceptions.
	 * @example <xmlrpc:XMLRPCObject id="wordpress" endpoint="http://localhost/" destination="wordpress/xmlrpc.php"></xmlrpc:XMLRPCObject>
	*/
	public dynamic class XMLRPCObject extends AbstractRPCObject implements IMXMLObject, IMXMLSupport
	{
		protected var _gateway:XMLRPCConnection;
		protected var _contentType:String = "text/xml"; //This content type is true to the xmlrpc spec
		/**
		 * The root url of the xmlrpc path. 
		 * @example endpoint="http://localhost/"
		 */
		override public function set endpoint (endpoint:String):void
		{
			this._endpoint = endpoint;
			this.makeConnection();
		}
		
		/**
		 * Set request headers
		 * @example 
		 * <code>
		 * var headers:Object = new Object();
		   headers["CustomHeaderA"] = "SomeValue";
		   headers["CustomHeaderB"] = "SomeValue";
		   xmprpcobject.headers = headers;
		   </code>
		 */
		public function set headers (headers:Object):void
		{
			this._gateway.headers = headers;
		}
		
		public function get headers ():Object
		{
			return this._gateway.headers;
		}
		
		/**
		 * set if to use proxy
		 */
		public function set useProxy (useproxy:Boolean):void
		{
			this._gateway.useProxy = useproxy;
		}
		
		public function get useProxy ():Boolean
		{
			return this._gateway.useProxy;
		}
		
		override public function setCredentials (username:String,password:String,charset:String=null):void
		{
			this._gateway.setCredentials(username,password);
		}
		
		override public function setRemoteCredentials (username:String,password:String,charset:String=null):void
		{
			this._gateway.setRemoteCredentials(username,password);
		}
		
		public function set contentType (contenttype:String):void
		{
			this._contentType = contenttype;
		}
		
		public function get contentType ():String
		{
			return this._contentType;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function makeCall(method:String, args:Array):AsyncToken
		{
			this._gateway.url = this.endpoint+this.destination;
			this._gateway.request = "POST";
			this._gateway.contentType = this._contentType;
			this._gateway.resultFormat = "object"; //Must be set to object in order for the xmlDecode to be used
			this._gateway.xmlDecode = XMLRPCSerializer.deserialize; //Converts results to AS3 objects
			this._gateway.requestTimeout = this.requestTimeout;
			var ttoken:AsyncToken = this._gateway.send(XMLRPCSerializer.serialize(method,args));
			
			//====== THIS IS A HACK IMPLEMENTED TO THROW FAULT EVENTS FROM THE XML RPC CALL
			//@TODO think of better solution to this problem
			var rpctoken:AsyncToken = new AsyncToken(ttoken.message);//create "fake" token with the real token message
			var responder:RPCResponder = new RPCResponder (rpctoken); //Create a responder
			responder.timeout = this.requestTimeout;
			responder.addEventListener(RPCEvent.EVENT_RESULT,this.onResult);
            responder.addEventListener(RPCEvent.EVENT_FAULT,this.onFault);
            responder.addEventListener(RPCEvent.EVENT_CANCEL,this.onRemoveResponder);
            ttoken.addResponder(responder);
            
            //Show Busy cursor 
             this.respondercounter++;
     
            return rpctoken;
		}
		
		override protected function onResult (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			//var resultevent:ResultEvent = ResultEvent(evt.data); //@NOTE because the RPCResponder is a responder to HTTPService the result data will be a result event
			var currentRE:ResultEvent = ResultEvent(evt.data);
            var resultevent:ResultEvent = new ResultEvent(currentRE.type, currentRE.bubbles, currentRE.cancelable, currentRE.result, token);
            token.message.body = resultevent.result; //The actual data would be in the result
			if (resultevent.result is Fault)//The XMLRPCSerializer.deserialize will return a fault object if a fault is returned by the rpc call
			{
				var faultevent:FaultEvent= new FaultEvent(FaultEvent.FAULT,true,true,resultevent.result as Fault,token);
				dispatchEvent(faultevent);
				if (token.hasResponder())
				{
					for (var i:int; i<token.responders.length; i++)
					{
						token.responders[i].fault.call(token.responders[i],faultevent);
					}
				}
			}
			else
			{
				dispatchEvent(resultevent);
				if (token.hasResponder())
				{
					for (var j:int; j<token.responders.length; j++)
					{
						token.responders[j].result.call(token.responders[j],resultevent);
					}
				}
			}
			
			//this.onRemoveResponder(evt);
			this.respondercounter--;
		}
		
		override protected function onFault (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
			var faultevent:FaultEvent= FaultEvent(evt.data);
			dispatchEvent(faultevent);
			if (token.hasResponder())
			{
				for (var i:int; i<token.responders.length; i++)
				{
					token.responders[i].fault.call(token.responders[i],faultevent);
				}
			}
			
			//this.onRemoveResponder(evt);
			this.respondercounter--;
		}
		
		
		
		 public function makeConnection ():void
         {
        	this._gateway = new XMLRPCConnection(this._endpoint);
         }
		
	}
}