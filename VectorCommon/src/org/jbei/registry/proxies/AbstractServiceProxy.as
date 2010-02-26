package org.jbei.registry.proxies
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class AbstractServiceProxy extends Proxy
	{
		private var _serviceName:String;
		private var _service:RemoteObject;
		
		// Constructor
		public function AbstractServiceProxy(proxyName:String, serviceName:String)
		{
			super(proxyName);
			
			_serviceName = serviceName;
			
			initializeService();
			registerServiceOperations();
		}
		
		// Properties
		public function get serviceName():String
		{
			return _serviceName;
		}
		
		public function get service():RemoteObject
		{
			return _service;
		}
		
		// Public Methods
		// Protected Methods
		protected function initializeService():void
		{
			_service = new RemoteObject(serviceName);
			_service.addEventListener(FaultEvent.FAULT, onServiceFault);
			_service.addEventListener(InvokeEvent.INVOKE, onServiceInvoke);
		}
		
		protected function onServiceFault(event:FaultEvent):void
		{
		}
		
		protected function onServiceInvoke(event:InvokeEvent):void
		{
		}
		
		protected function registerServiceOperations():void
		{
		}
	}
}
