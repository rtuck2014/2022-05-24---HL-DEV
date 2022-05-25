import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import cloneEngagement from '@salesforce/apex/SL_Clone_Engagement.cloneEngagement';
import { NavigationMixin } from 'lightning/navigation';

export default class EngagementCreateDivision extends NavigationMixin(LightningElement) {
    @api recordId;
    renderedCallback(){
        console.log('calling with: '+this.recordId);
        if(this.recordId){
            cloneEngagement({engagementId:this.recordId})
            .then((result)=>{
                let event;
                if(result.startsWith('ERROR')){
                    event = new ShowToastEvent({
                        title: 'Failure',
                        message: result,
                        variant: 'warning'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else if(result===this.recordId){
                    event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Record not cloned.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            objectApiName: 'Engagement__c',
                            actionName: 'view',
                            recordId:result
                        }
                    });
                }                
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