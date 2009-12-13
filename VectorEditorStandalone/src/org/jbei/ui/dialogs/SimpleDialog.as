package org.jbei.ui.dialogs
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.HBox;
	import mx.containers.TitleWindow;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.HRule;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class SimpleDialog extends TitleWindow
	{
		private var dialogForm:SimpleDialogForm;
		private var dialogParent:DisplayObject;
		
		private var _activeTabIndex:int;
		
		private var mainBox:VBox = new VBox();
		private var buttonsBox:HBox = new HBox();
		private var okButton:Button = new Button();
		private var hRule:HRule = new HRule();
		
		// Constructor
		public function SimpleDialog(dialogParent:DisplayObject, dialogFormClass:Class, activeTabIndex:int = 0)
		{
			super();
			
			this.dialogParent = dialogParent;
			this.dialogForm = new dialogFormClass();
			this.dialogForm.dialog = this;
			
			_activeTabIndex = activeTabIndex;
			
			showCloseButton = true;
			
			initializeControls();
			
			okButton.addEventListener(MouseEvent.CLICK, onOkButtonClick);
			okButton.addEventListener(KeyboardEvent.KEY_DOWN, onOkButtonKeyDown);
			addEventListener(CloseEvent.CLOSE, onXButtonClick);
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			// Hack to fix flex's setFocus bug
			this.callLater(function ():void {okButton.setFocus();});
		}
		
		// Properties
		public function get activeTabIndex():int
		{
			return _activeTabIndex;
		}
		
		// Public Methods
		public function open():void
		{
			PopUpManager.addPopUp(this, dialogParent, true);
			PopUpManager.centerPopUp(this);
		}
		
		public function close():void
		{
			closeDialog();
		}
		
		// Event Handlers
		private function onOkButtonClick(event:MouseEvent):void
		{
			cancel();
		}
		
		private function onXButtonClick(event:CloseEvent):void
		{
			cancel();
		}
		
		private function onOkButtonKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER) {
				cancel();
			}
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE) {
				cancel();
			}
		}
		
		// Private Methods
		protected function initializeControls():void
		{
			mainBox.percentWidth = 100;
			mainBox.percentHeight = 100;
			
			okButton.label = "OK";
			okButton.width = 70;
			
			hRule.percentWidth = 100;
			hRule.setStyle("strokeWidth", 1);
			
			buttonsBox.percentWidth = 100;
			buttonsBox.height = 25;
			buttonsBox.setStyle("paddingLeft", 5);
			buttonsBox.setStyle("paddingRight", 5);
			buttonsBox.setStyle("horizontalAlign", "right");
			buttonsBox.addChild(okButton);
			
			mainBox.addChild(dialogForm);
			mainBox.addChild(hRule);
			mainBox.addChild(buttonsBox);
			
			addChild(mainBox);
		}
		
		private function cancel():void
		{
			closeDialog();
		}
		
		private function closeDialog():void
		{
			PopUpManager.removePopUp(this);
		}
	}
}
