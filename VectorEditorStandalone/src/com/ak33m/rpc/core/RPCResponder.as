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
package com.ak33m.rpc.core
{
	import mx.rpc.IResponder;
	import flash.net.Responder;
	import mx.rpc.AsyncToken;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.Fault;
	import flash.events.*;
	

	public class RPCResponder extends Responder implements IEventDispatcher,IResponder
	{
		protected var _token:AsyncToken;
		protected var _timeout:Number = 0;
		protected var _timer:Timer;
		protected var _dispatcher:EventDispatcher;
		
		public function RPCResponder (token:AsyncToken)
		{
			super(this.result,this.fault);
			this._dispatcher = new EventDispatcher(this);
			this._token = token;
		}
		
		public function get token ():AsyncToken
		{
			return this._token;
		}
		
		public function set timeout (value:Number) : void
        {
            _timeout = value;
            _timer = new Timer(value,1);
            if (_timeout > 0)
            {
                _timer.addEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
                _timer.start();
            }
        }
        
        public function get timeout (): Number
        {
            return _timeout;
        }
		
		public function result (data:Object):void
		{
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
			dispatchEvent(new RPCEvent(RPCEvent.EVENT_RESULT,false,true,data));
		}
		
		public function fault (info:Object):void
		{
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,cancelRequest);
			dispatchEvent(new RPCEvent(RPCEvent.EVENT_FAULT,false,true,info));
		}
		
		private function cancelRequest (event:TimerEvent):void
		{
			if (event.target.currentCount == 1)
			{
				dispatchEvent(new RPCEvent(RPCEvent.EVENT_CANCEL,false,true));
			}
		}
		
		//EVENTDISPATCHER IMPLEMENTATION
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
       	 	this._dispatcher.addEventListener(type, listener, useCapture, priority);
   		}
           
	    public function dispatchEvent(evt:Event):Boolean
	    {
	        return this._dispatcher.dispatchEvent(evt);
	    }
    
	    public function hasEventListener(type:String):Boolean
	    {
	        return this._dispatcher.hasEventListener(type);
	    }
    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	    {
	        this._dispatcher.removeEventListener(type, listener, useCapture);
	    }
                   
	    public function willTrigger(type:String):Boolean 
	    {
	        return this._dispatcher.willTrigger(type);
	    }
	}
}