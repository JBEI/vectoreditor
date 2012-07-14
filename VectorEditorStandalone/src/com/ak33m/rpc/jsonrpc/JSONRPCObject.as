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

package com.ak33m.rpc.jsonrpc
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
	
	dynamic public class JSONRPCObject extends AbstractRPCObject
	{
		protected var _gateway:JSONConnection;
		override protected function makeCall(method:String, args:Array):AsyncToken
		{
			this._gateway.url = this.endpoint+this.destination;
			this._gateway.request = "POST";
			this._gateway.contentType = "application/xml"; //FIXME: seems not to work if set to "application/json" or "text/plain", works when set to "application/xml"
			this._gateway.resultFormat = "text"; //Must be set to object in order for the xmlDecode to be used //Set to text to allow result to pass through unprocessed for JSON
			this._gateway.xmlDecode = JSONRPCSerializer.deserialize; //Converts results to AS3 objects //Not used for JSON
			this._gateway.requestTimeout = this.requestTimeout;
			var ttoken:AsyncToken = this._gateway.send(JSONRPCSerializer.serialize(method,args));
			
			//====== THIS IS A HACK IMPLEMENTED TO THROW FAULT EVENTS FROM THE XML RPC CALL
			//@TODO think of better solution to this problem
			var rpctoken:AsyncToken = new AsyncToken(ttoken.message);//create "fake" token with the real token message
			var responder:RPCResponder = new RPCResponder (rpctoken); //Create a responder
			responder.timeout = this.requestTimeout;
			responder.addEventListener(RPCEvent.EVENT_RESULT,this.onResult);
            responder.addEventListener(RPCEvent.EVENT_FAULT,this.onFault);
            responder.addEventListener(RPCEvent.EVENT_CANCEL,this.onRemoveResponder);
            ttoken.addResponder(responder);
            return rpctoken;
		}
		
		/**
		 * The root url of the xmlrpc path. 
		 * @example endpoint="http://localhost/"
		 */
		override public function set endpoint (endpoint:String):void
		{
			this._endpoint = endpoint;
			this.makeConnection();
		}
		
		override protected function onResult (evt:RPCEvent):void
		{
			var token:AsyncToken = evt.target.token;
            var resultevent:ResultEvent = new ResultEvent(ResultEvent.RESULT,true,true,JSONRPCSerializer.deserialize(evt.data.result),token,token.message);
			token.message.body = resultevent.result; //The actual data would be in the result
			if (resultevent.result.error!= null )
			{
				var tfault:Fault = new Fault("JSONRPC ERROR","AN ERROR MESSAGE WAS THROWN",resultevent.result.error);
				var faultevent:FaultEvent= new FaultEvent(FaultEvent.FAULT,true,true,tfault,token);
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
		}
		
		 public function makeConnection ():void
        {
        	this._gateway = new JSONConnection(this._endpoint);
        }
	}
}