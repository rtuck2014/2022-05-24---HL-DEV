import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import convertEngagement from '@salesforce/apex/OppConvertEngagement.convertEngagement';

export default class OppConvertEngagement extends NavigationMixin(LightningElement) {
    _recordId;
    hasLoaded=false;
    validationMessage;
    errorMessage;

    @api set recordId(value) {
        this._recordId = value;
        convertEngagement({recordId: this._recordId})        
        .then(result=>{
            console.log('result:'+result);
            if(result.startsWith('a09')){
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId:result,
                        actionName: 'view',
                    },
                });
            }else{
                this.validationMessage=result;
                this.hasLoaded=true;
            }
        }).catch(error=>{
            console.log('calling error:'+JSON.stringify(error));
            this.hasLoaded=true;
            this.validationMessage=error.body.message;
        });
    }
    
    get recordId() {
        return this._recordId;
    }

    /*
    renderedCallback(){
        console.log('calling'+this.recordId);
        convertEngagement({recordId: this.recordId})        
        .then(result=>{
            console.log('calling result:'+JSON.stringify(result));
            this.validationMessage=result;
            this.hasLoaded=true;
        }).catch(error=>{
            console.log('calling error:'+JSON.stringify(error));
            this.hasLoaded=true;
            this.validationMessage=error;
        });
    }*/
}