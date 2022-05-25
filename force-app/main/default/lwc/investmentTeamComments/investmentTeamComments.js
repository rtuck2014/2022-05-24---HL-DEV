import { LightningElement, api } from 'lwc';
//import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INVESTMENT_COMMENT from '@salesforce/schema/Investment_Comment__c.Comment__c';
import INVESTMENT_COMMENT_TYPE from '@salesforce/schema/Investment_Comment__c.CommentType__c';
import RELATED_INVESTMENT from '@salesforce/schema/Investment_Comment__c.Related_Investment__c';
export default class RecordEditForm extends LightningElement {
    @api recordId;
    @api objectApiName;
    //@api recordIds;

        
    iComment = INVESTMENT_COMMENT;
    iCommentType = INVESTMENT_COMMENT_TYPE;
    icRelatedInvestment = RELATED_INVESTMENT;
     
     handleSuccess(){
         if(this.recordId !== null){
             this.dispatchEvent(new ShowToastEvent({
                     title: "SUCCESS!",
                     message: "New record has been created.",
                    variant: "success",
                 }),  
                
            );    
          }
          window.location.reload();
          //getRecordNotifyChange([{ recordId: this.recordId }]);
     } }