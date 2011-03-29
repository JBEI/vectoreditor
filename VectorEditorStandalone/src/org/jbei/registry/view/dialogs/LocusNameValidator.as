package org.jbei.registry.view.dialogs
{
    
    import mx.controls.TextInput;
    import mx.events.ValidationResultEvent;
    import mx.utils.StringUtil;
    import mx.validators.ValidationResult;
    import mx.validators.Validator;
    
    public class LocusNameValidator extends Validator
    {
        public function LocusNameValidator()
        {
            super();
        }
        
        public override function validate(value:Object = null, suppressEvents:Boolean = false):ValidationResultEvent
        {
            CONFIG::standalone {
                var temp:TextInput = source as TextInput;
                temp.text = StringUtil.trim(temp.text);
                var result:ValidationResultEvent 
                if (temp.text.indexOf(" ") == -1 ) {
                    result = new ValidationResultEvent(ValidationResultEvent.VALID);
                } else {
                    result = new ValidationResultEvent(ValidationResultEvent.INVALID);
                    result.results = new Array();
                    result.results.push(new ValidationResult(true, null, "Locus Name Error","Spaces are not allowed in name"));
                    temp.errorString = "Spaces are not allowed in name";
                }
                
                return result;
            }
            
            return new ValidationResultEvent(ValidationResultEvent.VALID);
            
        }
        
        override protected function doValidation(value:Object):Array
        {
            
            
            return validate(value).results;
        }
    }
}