package org.jbei.registry.mediators
{
	import org.jbei.lib.utils.StringFormatter;
	import org.jbei.lib.utils.SystemUtils;
	import org.jbei.registry.Notifications;
	import org.jbei.registry.models.TraceSequence;
	import org.jbei.registry.view.ui.AlignmentPanel;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AlignmentPanelMediator extends Mediator
	{
		private const NAME:String = "AlignmentPanelMediator";
		private const NUCLEOTIDES_ALIGNMENT_PER_ROW:int = 60;
		
		private var alignmentPanel:AlignmentPanel;
		
		// Constructor
		public function AlignmentPanelMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			alignmentPanel = viewComponent as AlignmentPanel;
			
			alignmentPanel.traceSequenceAlignmentTextArea.setStyle("fontFamily", SystemUtils.getSystemMonospaceFontFamily());
		}
		
		// Public Methods
		public override function listNotificationInterests():Array 
		{
			return [
				Notifications.TRACE_SEQUENCE_SELECTION_CHANGED
			];
		}
		
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName()) {
				case Notifications.TRACE_SEQUENCE_SELECTION_CHANGED:
					updateAlignment(notification.getBody() as TraceSequence)
					
					break;
			}
		}
		
		// Private Methods
		private function updateAlignment(traceSequence:TraceSequence):void {
			alignmentPanel.traceSequenceAlignmentTextArea.htmlText = "";
			
			if(traceSequence == null) {
				return;
			}
			
			if(traceSequence.traceSequenceAlignment.queryAlignment.length != traceSequence.traceSequenceAlignment.subjectAlignment.length) {
				alignmentPanel.traceSequenceAlignmentTextArea.text = "ERROR: Alignment length doesn't much!";
				
				return;
			}
			
			var subjectAlignmentString:String = traceSequence.traceSequenceAlignment.subjectAlignment.toUpperCase();
			var queryAlignmentString:String = traceSequence.traceSequenceAlignment.queryAlignment.toUpperCase();
			
			var subjectAlignmentLength:int = subjectAlignmentString.length;
			var queryAlignmentLength:int = queryAlignmentString.length;
			
			var numberOfLines:int = subjectAlignmentString.length / NUCLEOTIDES_ALIGNMENT_PER_ROW;
			
			var output:String = "";
			
			for(var i:int = 0; i < numberOfLines; i++) {
				var rowStart:int = i * NUCLEOTIDES_ALIGNMENT_PER_ROW;
				var rowEnd:int = ((i + 1) * NUCLEOTIDES_ALIGNMENT_PER_ROW > queryAlignmentLength) ? queryAlignmentLength : ((i + 1) * NUCLEOTIDES_ALIGNMENT_PER_ROW);
				
				var queryRowSequence:String = queryAlignmentString.substring(rowStart, rowEnd);
				var subjectRowSequence:String = subjectAlignmentString.substring(rowStart, rowEnd);
				
				var highlightedQueryRowSequence:String = highlightMismatches(queryRowSequence, subjectRowSequence);
				var highlightedSubjectRowSequence:String = highlightMismatches(subjectRowSequence, queryRowSequence);
				
				if(i == 0) {
					output += "<b>Query  " + StringFormatter.sprintf("%6d", traceSequence.traceSequenceAlignment.queryStart) + ": </b>";
				} else {
					output += "               ";
				}
				
				output += highlightedQueryRowSequence;
				
				if(i == numberOfLines - 1) {
					output += "   <b>" + traceSequence.traceSequenceAlignment.queryEnd + "</b>";
				}
				
				output += "\n";
				
				if(i == 0) {
					output += "<b>Subject" + StringFormatter.sprintf("%6d", traceSequence.traceSequenceAlignment.subjectStart) + ": </b>";
				} else {
					output += "               ";
				}
				
				output += highlightedSubjectRowSequence;
				
				if(i == numberOfLines - 1) {
					output += "   <b>" + traceSequence.traceSequenceAlignment.subjectEnd + "</b>";
				}
				
				output += "\n\n";
			}
			
			output += ""
			
			alignmentPanel.traceSequenceAlignmentTextArea.htmlText = output;
		}
		
		private function highlightMismatches(sequence1:String, sequence2:String):String
		{
			var result:String = "";
			
			if(sequence1 == "") {
				return "";
			}
			
			var length:int = sequence1.length;
			
			var isMismatch:Boolean = false;
			for(var i:int = 0; i < length; i++) {
				if(sequence1.charAt(i) == sequence2.charAt(i)) {
					if(isMismatch) {
						result += "</span>" + sequence1.charAt(i);
					} else {
						result += sequence1.charAt(i);
					}
					
					isMismatch = false;
				} else {
					if(isMismatch) {
						result += sequence1.charAt(i);
					} else {
						result += "<span class=\"mismatch\">" + sequence1.charAt(i);
					}
					
					isMismatch = true;
				}
			}
			
			if(isMismatch) {
				result += "</span>";
			}
			
			return result;
		}
	}
}
