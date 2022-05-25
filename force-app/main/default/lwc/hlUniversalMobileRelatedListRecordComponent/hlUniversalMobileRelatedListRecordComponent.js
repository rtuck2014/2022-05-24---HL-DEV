/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HlUniversalMobileRelatedListRecordComponent extends NavigationMixin(LightningElement) {
    @api record;
    @api parentrecordid;
    @api parentapi;
    @api iconname;
    @track dateTimeValue;
    @api recordobjectapiname;
    @api redirectType;

    handleClick() {
        // eslint-disable-next-line no-unused-vars
        /*   let selectedActivityId = this.record.ParentId__c;
           this[NavigationMixin.Navigate]({
               type: 'standard__component',
               attributes:{
                   componentName: 'c__ActivityDetails'
               },
               state: {
                   c__selectedActivityId : selectedActivityId,
                   c__relatedRecordId   : this.parentrecordid,
                   c__relatedParentAPI  : this.parentapi
               }
           });*/
        if (this.redirectType === 'standard__recordPage') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.record.key,
                    objectApiName: this.recordobjectapiname,
                    actionName: 'view'
                }
            });
        } else if (this.redirectType === 'standard__component') {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__ActivityDetails'
                },
                state: {
                    c__selectedActivityId: this.record.key,
                    c__relatedRecordId: this.parentrecordid,
                    c__relatedParentAPI: this.parentapi
                }
            });
        }
    }
}