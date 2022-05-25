import { LightningElement,api } from 'lwc';
import updateContactAddress from '@salesforce/apex/HL_AccConAddress.updateContactAddress';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class AccountContactAddressSync extends LightningElement {
    @api recordId;
    renderedCallback(){
        console.log('calling with: '+this.recordId);
        if(this.recordId){
            updateContactAddress({AccID : this.recordId})
            .then(()=>{
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'All contact addresses updated.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error=>{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            });
        }
    }
}