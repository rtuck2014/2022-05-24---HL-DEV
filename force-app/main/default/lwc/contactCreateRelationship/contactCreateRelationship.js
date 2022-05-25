import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import createRelationship from '@salesforce/apex/SL_CreateRelationship.createRelationship';

const FIELDS = ['Contact.Id', 'Contact.User_ID__c'];

export default class ContactCreateRelationship extends LightningElement {
    @api recordId;
    contact;    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.contact = data;            
            createRelationship({strContactId: this.contact.fields.Id.value,strUserId:this.contact.fields.User_ID__c.value})
            .then((result)=>{
                let event;
                if(result==='User field of Contact is blank.'){
                    event = new ShowToastEvent({
                        title: 'Failure',
                        message: result,
                        variant: 'warning'
                    });
                }else{
                    event = new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success'
                    });
                }
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