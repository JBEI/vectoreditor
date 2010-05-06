package org.jbei.lib.ui.dialogs
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
	import mx.controls.Spacer;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class ModalDialog extends TitleWindow
	{
		private var _isOpen:Boolean = false;
		
		private var dialogForm:AbstractDialogForm;
		private var dialogParent:DisplayObject;
		
		private var mainBox:VBox = new VBox();
		private var buttonsBox:HBox = new HBox();
		private var spacer:Spacer = new Spacer();
		private var okButton:Button = new Button();
		private var cancelButton:Button = new Button();
		private var hRule:HRule = new HRule();
		
		// Constructor
		public function ModalDialog(dialogParent:DisplayObject, dialogFormClass:Class, dataObject:Object)
		{
			super();
			
			this.dialogParent = dialogParent;
			this.dialogForm = new dialogFormClass();
			this.dialogForm.dialog = this;
			
			showCloseButton = true;
			
			initializeControls();
			
			okButton.addEventListener(MouseEvent.CLICK, onOkButtonClick);
			okButton.addEventListener(KeyboardEvent.KEY_DOWN, onOkButtonKeyDown);
			cancelButton.addEventListener(MouseEvent.CLICK, onCancelButtonClick);
			cancelButton.addEventListener(KeyboardEvent.KEY_DOWN, onCancelButtonKeyDown);
			addEventListener(CloseEvent.CLOSE, onXButtonClick);
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			dialogForm.initialization(dataObject);
		}
		
		// Properties
		public function get isOpen():Boolean
		{
			return _isOpen;
		}
		
		// Public Methods
		public function open():void
		{
			_isOpen = true;
			
			PopUpManager.addPopUp(this, dialogParent, true);
			PopUpManager.centerPopUp(this);
		}
		
		public function close():void
		{
			if(isOpen) {
				closeDialog();
			}
		}
		
		public function submit():void
		{
			dialogForm.validate();
			
			if(dialogForm.isValid) {
				closeDialog();
				
				dispatchEvent(new ModalDialogEvent(ModalDialogEvent.SUBMIT, dialogForm.dataObject));
			}
		}
		
		public function cancel():void
		{
			closeDialog();
			
			dispatchEvent(new ModalDialogEvent(ModalDialogEvent.CANCEL));
		}
		
		// Event Handlers
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE) {
				cancel();
			}
		}
		
		private function onOkButtonClick(event:MouseEvent):void
		{
			submit();
		}
		
		private function onCancelButtonClick(event:MouseEvent):void
		{
			cancel();
		}
		
		private function onXButtonClick(event:CloseEvent):void
		{
			cancel();
		}
		
		private function onOkButtonKeyDown(event:KeyboardEvent):void
		{
			if(event.charCode == Keyboard.ENTER) {
				submit();
			}
		}
		
		private function onCancelButtonKeyDown(event:KeyboardEvent):void
		{
			if(event.charCode == Keyboard.ENTER) {
				cancel();
			}
		}
		
		// Private Methods
		private function initializeControls():void
		{
			mainBox.percentWidth = 100;
			mainBox.percentHeight = 100;
			
			okButton.label = "OK";
			okButton.width = 70;
			
			cancelButton.label = "Cancel";
			cancelButton.width = 70;
			
			spacer.percentWidth = 100;
			hRule.percentWidth = 100;
			hRule.setStyle("strokeWidth", 1);
			
			buttonsBox.percentWidth = 100;
			buttonsBox.height = 25;
			buttonsBox.setStyle("paddingLeft", 5);
			buttonsBox.setStyle("paddingRight", 5);
			buttonsBox.addChild(spacer);
			buttonsBox.addChild(okButton);
			buttonsBox.addChild(cancelButton);
			
			mainBox.addChild(dialogForm);
			mainBox.addChild(hRule);
			mainBox.addChild(buttonsBox);
			
			addChild(mainBox);
		}
		
		private function closeDialog():void
		{
			_isOpen = false;
			
			PopUpManager.removePopUp(this);
		}
	}
}
