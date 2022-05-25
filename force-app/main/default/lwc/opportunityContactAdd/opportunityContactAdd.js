import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityContactAdd extends LightningElement {
    @api recordId;
    handleSuccess(event){
        const st = new ShowToastEvent({
            title: 'Success',
            message: 'record created',
            variant: 'success'
        });
        this.dispatchEvent(st);
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleError(event){
        console.log(JSON.stringify(event));
        const st = new ShowToastEvent({
            title: 'Error',
            message: 'record error:'+JSON.stringify(event.detail.detail),
            variant: 'error'
        });
        this.dispatchEvent(st);
    }

}