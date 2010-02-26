package org.jbei.registry.commands
{
	import org.jbei.registry.ApplicationFacade;
	import org.jbei.registry.proxies.EntriesServiceProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class FetchEntryCommand extends SimpleCommand
	{
		public override function execute(notification:INotification):void
		{
			var entriesProxy:EntriesServiceProxy = ApplicationFacade.getInstance().retrieveProxy(EntriesServiceProxy.NAME) as EntriesServiceProxy;
			
			//entriesProxy.fetchEntry(randomSequenceId());
			entriesProxy.fetchEntry(ApplicationFacade.getInstance().sessionId, ApplicationFacade.getInstance().entryId);
		}
		
		private function randomSequenceId():String
		{
			var sequencesList:Array = new Array();
			
			sequencesList.push("31912c13-4822-41d2-b1b2-0a2ea7829c6f");
			sequencesList.push("4c876cb9-285e-446e-b974-348971eee448");
			sequencesList.push("b7b1bdf8-ccc0-4249-9d91-327a7659fb4e");
			sequencesList.push("f67ca0df-11e3-4146-92fe-af079888b82f");
			sequencesList.push("b7b1bdf8-ccc0-4249-9d91-327a7659fb4e");
			sequencesList.push("42d6cd31-d724-4de0-ac0b-cf4ee20373e9");
			sequencesList.push("367b5c30-d461-49e0-ab1c-ed16754e81fd");
			sequencesList.push("0577dc96-eee0-46d6-b5df-ce8fe026947f");
			sequencesList.push("adc63f8f-051a-48c1-88a1-34a24d82be83");
			sequencesList.push("0d5110e7-4746-4ccd-aea3-3f03e61aba8e");
			sequencesList.push("27f2d1dc-d398-4ee4-b7b5-4308a7e3dc91");
			sequencesList.push("efa0214d-1211-48e9-9fe6-ff8b77f79977");
			sequencesList.push("5ed148b3-363a-4f54-b5c7-c5caeb6118f2");
			sequencesList.push("77fcfa6f-4547-49a3-9389-3ba8c2431024");
			sequencesList.push("448236aa-edf9-4317-bc59-d796d56f64f4");
			sequencesList.push("fc745187-a217-41c8-85e6-d0e313036c1c");
			sequencesList.push("31bc331e-ba72-4f14-bd71-628855e67636");
			sequencesList.push("3b37480f-ba8a-4eae-97c9-209431e4799f");
			sequencesList.push("58be5ac1-ff2f-42b0-91ca-373380a848ea");
			sequencesList.push("b5664023-7b86-4a48-925c-a1c69114068b");
			sequencesList.push("97eb3c5b-02c9-4f9e-a6cc-a73194bbf9dd");
			sequencesList.push("f563a3f2-ff46-41e4-b924-3bf391b2fe47");
			sequencesList.push("401e28d9-cbdc-45ae-bbae-13dd53f5a9d8");
			sequencesList.push("b0254a3e-e155-4fb8-ab77-b6b0970e132f");
			sequencesList.push("c42c3948-8fc2-4431-9f8c-0243646100ff");
			sequencesList.push("ca7676a8-0248-4869-a574-dc60a8caddc4");
			sequencesList.push("67669ed3-a270-4ed3-8e58-720d89841bb9");
			sequencesList.push("f4e005cb-c226-41c1-9e4a-fc660b4adae2");
			
			return sequencesList[Math.floor(Math.random() * (sequencesList.length - 1))];
		}
	}
}
