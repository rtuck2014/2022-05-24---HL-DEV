import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateOpp from '@salesforce/apex/OppRequestEngagement.validateOpp';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class OppRequestEngagement extends NavigationMixin(LightningElement) {
    @api recordId;
    hasLoaded=false;
    validationMessage;
renderedCallback() {
    validateOpp({recordId:  this.recordId,dateTimeData : Date.now()})
    .then(result=>{
        console.log('result '+result);
    })
    .catch(error=>{

    })
}
/*
    @wire(validateOpp, { recordId:  '$recordId',dateTimeData : Date.now()}) wiredlistView({error,data}) {
        if(data){
            console.log('data',data)
            this.validationMessage=data;
            this.hasLoaded=true;

            if (data=='') {
                this.dispatchEvent(new CloseActionScreenEvent());
            }
    }else{
        console.log('An error has occurred:');
        console.log(error);
        
    } 
    }*/
}