import { LightningElement, api } from 'lwc';
//import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import COVERAGE_TEAM_COMMENT from '@salesforce/schema/Coverage_Team_Comment__c.Comment__c';
import COVERAGE_TEAM_COMMENT_TYPE from '@salesforce/schema/Coverage_Team_Comment__c.Comment_Type__c';
import COVERAGE_TEAM_COMMENT_RELATED_CT from '@salesforce/schema/Coverage_Team_Comment__c.Related_Coverage_Team__c';
export default class RecordEditForm extends LightningElement {
    @api recordId;
    @api objectApiName;
    //@api recordIds;

        
    ctComment = COVERAGE_TEAM_COMMENT;
    ctCommentType = COVERAGE_TEAM_COMMENT_TYPE;
    ctcRelatedCoverageTeam = COVERAGE_TEAM_COMMENT_RELATED_CT;
     
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