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
	import mx.utils.Base64Encoder;
	import flash.utils.ByteArray;
	import mx.formatters.DateFormatter;
	import mx.utils.Base64Decoder;
	import mx.rpc.Fault;
	import com.ak33m.rpc.core.RPCMessageCodes;
	import flash.xml.XMLNode;
	import flash.xml.XMLDocument;
	
	public class XMLRPCSerializer
	{
		internal static const TYPE_INT:String = "int";
		internal static const TYPE_I4:String = "i4";
		internal static const TYPE_DOUBLE:String = "double";
		internal static const TYPE_STRING:String = "string";
		internal static const TYPE_BOOLEAN:String = "boolean";
		internal static const TYPE_ARRAY:String = "array";
		internal static const TYPE_BASE64:String = "base64";
		internal static const TYPE_STRUCT:String = "struct";
		internal static const TYPE_DATE:String = "dateTime.iso8601";
		
		public function XMLRPCSerializer ()
		{
			
		}
		
		public static function serialize (method:String,params:Array):XML
		{
			var xmlrpc:XML = <methodCall>
								<methodName>{method}</methodName>
							 </methodCall>
			if (params.length > 0)
			{
				var tparams:XML = <params></params>
				for each (var param:* in params)
				{
					tparams.appendChild(<param><value>{encodeObject(param)}</value></param>);
				}
				xmlrpc.insertChildAfter(xmlrpc.methodName,tparams);
			}
			
			return xmlrpc;		
		}
		
		protected static function encodeObject (tobject:*):XMLList
		{
			var txmllist:XMLList;
			if (tobject is String)
			{
				txmllist =  encodeString(tobject);
			}
			else if (tobject is Number && Math.floor(tobject)==tobject)
			{
				txmllist =  encodeInteger(tobject);
			}
			else if (tobject is Boolean)
			{
				txmllist =  encodeBoolean(tobject);
			}
			else if (tobject is Number)
			{
				txmllist =  encodeDouble(tobject);
			}
			else if (tobject is Date)
			{
				txmllist =  encodeDate(tobject);
			}
			else if (tobject is Array)
			{
				txmllist =  encodeArray(tobject);
			}
			else if (tobject is IXMLRPCStruct)
			{
				txmllist =  encodeStruct(tobject.getPropertyData());
			}
			else if (tobject is Object)
			{
				txmllist =  encodeStruct(tobject);
			}
			else
			{
				txmllist = encodeString(tobject as String);
			}
			
			return txmllist;
		}
		
		protected static function encodeString(rstring:String):XMLList
		{
			return new XMLList("<"+TYPE_STRING+">"+rstring+"</"+TYPE_STRING+">");
		}
		
		protected static function encodeBoolean (rboolean:Boolean):XMLList
		{
			var xmlrpcboolean:String = rboolean ? "1" : "0";
			return new XMLList("<"+TYPE_BOOLEAN+">"+xmlrpcboolean+"</"+TYPE_BOOLEAN+">");
		}
		
		protected static function encodeInteger (rinteger:int):XMLList
		{
			return new XMLList("<"+TYPE_INT+">"+rinteger+"</"+TYPE_INT+">");
		}
		
		protected static function encodeDouble (rdouble:Number):XMLList
		{
			return new XMLList("<"+TYPE_DOUBLE+">"+rdouble+"</"+TYPE_DOUBLE+">");
		}
		
		protected static function encodeDate (rdate:Date):XMLList
		{
			var tdateformatter:DateFormatter = new DateFormatter();
			tdateformatter.formatString = "YYYYMMDDTJJ:NN:SS";
			var tdatestring:String = tdateformatter.format(rdate);
			return new XMLList("<"+TYPE_DATE+">"+tdatestring+"</"+TYPE_DATE+">");
		}
		
		protected static function encodeArray (rarray:Array):XMLList
		{
			var tarrayxml:XML = <array>
								</array>
			var tarraydataxml:XML = <data>
									</data>
			for (var i:int; i<rarray.length; i++)
			{
				tarraydataxml.appendChild(<value>{encodeObject(rarray[i])}</value>);
			}
			tarrayxml.appendChild(tarraydataxml);
			return new XMLList(tarrayxml);
		}
		
		protected static function encodeBase64 (rbase64:ByteArray):XMLList
		{
			var enc:Base64Encoder = new Base64Encoder();
			enc.encodeBytes(rbase64);
			return new XMLList("<"+TYPE_BASE64+">"+enc.flush()+"</"+TYPE_BASE64+">");
		}
		
		protected static function encodeStruct (rprops:*):XMLList
		{
			var tstructxml:XML = <struct>
								 </struct>
			for (var j:* in rprops)
			{
				tstructxml.appendChild(<member><name>{j}</name><value>{encodeObject(rprops[j])}</value></member>);
			}
			return new XMLList(tstructxml);
		}
		
		public static function deserialize (rxmlresult:XMLDocument):*
		{
			var xmlresult:XML = new XML(rxmlresult.toString());
			var resultvaluexml:XMLList = xmlresult.params.param.value;
			var faultxml:XMLList = xmlresult.fault.value;
			if (resultvaluexml.toString() != "")
			return decodeObject(resultvaluexml);
			else if (faultxml)
			{
				var faultobj:* = decodeObject(faultxml);
				var tfault:Fault = new Fault(faultobj.faultCode,faultobj.faultString);
				return tfault;
			}
			else
			{
				throw new Error(RPCMessageCodes.INVALID_XMLRPCFORMAT);
			}
		}
		
		protected static function decodeObject (robject:*):*
		{
			if (robject.children().name() == TYPE_STRING)
			{
				return String(robject.string);
			}
			else if (robject.children().name() == TYPE_INT)
			{
				return new int(robject.int);
			}
			else if (robject.children().name() == TYPE_I4)
			{
				return new int (robject.i4);
			}
			else if (robject.children().name() == TYPE_BOOLEAN)
			{
				if (isNaN(robject.boolean))
				{
					if (String(robject.boolean).toLowerCase() == "true")
					return true;
					else if (String(robject.boolean).toLowerCase() == "false")
					return false;
					else
					return null;
				}
				else
				{
					return Boolean(Number(robject.boolean));
				}
			}
			else if (robject.children().name()== TYPE_DATE)
			{
				var tdatestring:String = robject.children();
				var datepattern:RegExp = /^(-?\d\d\d\d)-?(\d\d)-?(\d\d)T(\d\d):(\d\d):(\d\d)/;
				var d:Array = tdatestring.match(datepattern);
				var tdate:Date =  new Date(d[1],d[2]-1,d[3],d[4],d[5],d[6]);
				return tdate;
			}
			else if (robject.children().name() == TYPE_BASE64)
			{
				var base64decoder:Base64Decoder = new Base64Decoder();
				base64decoder.decode(robject.base64);
				return base64decoder.flush();
				
			}
			else if (robject.children().name() == TYPE_ARRAY)
			{
				var tarray:Array = new Array();
				for each (var value:* in robject.array.data.value)
				{
					tarray.push(decodeObject(value));
				}
				return tarray;
			}
			else if (robject.children().name() == TYPE_STRUCT)
			{
				var tvalue:Object = new Object();
				for each (var member:* in robject.struct.member)
				{
					tvalue[member.name] = decodeObject(member.value);
				}
				return tvalue;
			}
			else if (robject.children().name() == TYPE_DOUBLE)
			{
				return Number(robject.double);
			}
			else 
			{
				return String(robject);
			}
		}
	}
}