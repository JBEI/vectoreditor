/*  sprintf(3) implementation in ActionScript 3.0.
*
*  Author:  Manish Jethani (manish.jethani@gmail.com)
*  Date:    April 3, 2006
*  Version: 0.1
*
*  Copyright (c) 2006 Manish Jethani
*
*  Permission is hereby granted, free of charge, to any person obtaining a
*  copy of this software and associated documentation files (the "Software"),
*  to deal in the Software without restriction, including without limitation
*  the rights to use, copy, modify, merge, publish, distribute, sublicense,
*  and/or sell copies of the Software, and to permit persons to whom the
*  Software is furnished to do so, subject to the following conditions:
*
*  The above copyright notice and this permission notice shall be included in
*  all copies or substantial portions of the Software.
*
*  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
*  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
*  DEALINGS IN THE SOFTWARE.  
*/

package org.jbei.utils
{
	public class StringUtils
	{
		/*  sprintf(3) implementation in ActionScript 3.0.
		*
		*  http://www.die.net/doc/linux/man/man3/sprintf.3.html
		*
		*  The following flags are supported: '#', '0', '-', '+'
		*
		*  Field widths are fully supported.  '*' is not supported.
		*
		*  Precision is supported except one difference from the standard: for an
		*  explicit precision of 0 and a result string of "0", the output is "0"
		*  instead of an empty string.
		*
		*  Length modifiers are not supported.
		*
		*  The following conversion specifiers are supported: 'd', 'i', 'o', 'u', 'x',
		*  'X', 'f', 'F', 'c', 's', '%'
		*
		*  Report bugs to manish.jethani@gmail.com
		*/
		public static function sprintf(format:String, ... args):String
		{
			var result:String = "";
			
			var length:int = format.length;
			for (var i:int = 0; i < length; i++)
			{
				var c:String = format.charAt(i);
				
				if (c == "%")
				{
					var pastFieldWidth:Boolean = false;
					var pastFlags:Boolean = false;
					
					var flagAlternateForm:Boolean = false;
					var flagZeroPad:Boolean = false;
					var flagLeftJustify:Boolean = false;
					var flagSpace:Boolean = false;
					var flagSign:Boolean = false;
					
					var fieldWidth:String = "";
					var precision:String = "";
					
					c = format.charAt(++i);
					
					while (c != "d"
						&& c != "i"
						&& c != "o"
						&& c != "u"
						&& c != "x"
						&& c != "X"
						&& c != "f"
						&& c != "F"
						&& c != "c"
						&& c != "s"
						&& c != "%")
					{
						if (!pastFlags)
						{
							if (!flagAlternateForm && c == "#")
								flagAlternateForm = true;
							else if (!flagZeroPad && c == "0")
								flagZeroPad = true;
							else if (!flagLeftJustify && c == "-")
								flagLeftJustify = true;
							else if (!flagSpace && c == " ")
								flagSpace = true;
							else if (!flagSign && c == "+")
								flagSign = true;
							else
								pastFlags = true;
						}
						
						if (!pastFieldWidth && c == ".")
						{
							pastFlags = true;
							pastFieldWidth = true;
							
							c = format.charAt(++i);
							continue;
						}
						
						if (pastFlags)
						{
							if (!pastFieldWidth)
								fieldWidth += c;
							else
								precision += c;
						}
						
						c = format.charAt(++i);
					}
					
					switch (c)
					{
						case "d":
						case "i":
							var next:* = args.shift();
							var str:String = String(Math.abs(int(next)));
							
							if (precision != "")
								str = leftPad(str, int(precision), "0");
							
							if (int(next) < 0)
								str = "-" + str;
							else if (flagSign && int(next) >= 0)
								str = "+" + str;
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str = rightPad(str, int(fieldWidth));
								else if (flagZeroPad && precision == "")
									str = leftPad(str, int(fieldWidth), "0");
								else
									str = leftPad(str, int(fieldWidth));
							}
							
							result += str;
							break;
						
						case "o":
							var next1:* = args.shift();
							var str1:String = uint(next1).toString(8);
							
							if (flagAlternateForm && str1 != "0")
								str1 = "0" + str1;
							
							if (precision != "")
								str1 = leftPad(str1, int(precision), "0");
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str1 = rightPad(str1, int(fieldWidth));
								else if (flagZeroPad && precision == "")
									str1 = leftPad(str1, int(fieldWidth), "0");
								else
									str1 = leftPad(str1, int(fieldWidth));
							}
							
							result += str1;
							break;
						
						case "u":
							var next2:* = args.shift();
							var str2:String = uint(next2).toString(10);
							
							if (precision != "")
								str2 = leftPad(str2, int(precision), "0");
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str2 = rightPad(str2, int(fieldWidth));
								else if (flagZeroPad && precision == "")
									str2 = leftPad(str2, int(fieldWidth), "0");
								else
									str2 = leftPad(str2, int(fieldWidth));
							}
							
							result += str2;
							break;
						
						case "X":
							var capitalise:Boolean = true;
						case "x":
							var next3:* = args.shift();
							var str3:String = uint(next3).toString(16);
							
							if (precision != "")
								str3 = leftPad(str3, int(precision), "0");
							
							var prepend:Boolean = flagAlternateForm && uint(next3) != 0;
							
							if (fieldWidth != "" && !flagLeftJustify
								&& flagZeroPad && precision == "")
								str3 = leftPad(str3, prepend
									? int(fieldWidth) - 2 : int(fieldWidth), "0");
							
							if (prepend)
								str3 = "0x" + str3;
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str3 = rightPad(str3, int(fieldWidth));
								else
									str3 = leftPad(str3, int(fieldWidth));
							}
							
							if (capitalise)
								str3 = str3.toUpperCase();
							
							result += str3;
							break;
						
						case "f":
						case "F":
							var next4:* = args.shift();
							var str4:String = Math.abs(Number(next4)).toFixed(
								precision != "" ?  int(precision) : 6);
							
							if (int(next4) < 0)
								str4 = "-" + str4;
							else if (flagSign && int(next4) >= 0)
								str4 = "+" + str4;
							
							if (flagAlternateForm && str4.indexOf(".") == -1)
								str4 += ".";
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str4 = rightPad(str4, int(fieldWidth));
								else if (flagZeroPad && precision == "")
									str4 = leftPad(str4, int(fieldWidth), "0");
								else
									str4 = leftPad(str4, int(fieldWidth));
							}
							
							result += str4;
							break;
						
						case "c":
							var next5:* = args.shift();
							var str5:String = String.fromCharCode(int(next5));
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str5 = rightPad(str5, int(fieldWidth));
								else
									str5 = leftPad(str5, int(fieldWidth));
							}
							
							result += str5;
							break;
						
						case "s":
							var next6:* = args.shift();
							var str6:String = String(next6);
							
							if (precision != "")
								str6 = str6.substring(0, int(precision));
							
							if (fieldWidth != "")
							{
								if (flagLeftJustify)
									str6 = rightPad(str6, int(fieldWidth));
								else
									str6 = leftPad(str6, int(fieldWidth));
							}
							
							result += str6;
							break;
						
						case "%":
							result += "%";
					}
				}
				else
				{
					result += c;
				}
			}
			
			return result;
		}
		
		// Private functions
		private static function leftPad(source:String, targetLength:int, padChar:String = " "):String
		{
			if (source.length < targetLength)
			{
				var padding:String = "";
				
				while (padding.length + source.length < targetLength)
					padding += padChar;
				
				return padding + source;
			}
			
			return source;
		}
		
		private static function rightPad(source:String, targetLength:int, padChar:String = " "):String
		{
			while (source.length < targetLength)
				source += padChar;
			
			return source;
		}
	}
}
