/* eslint-disable no-console */
import { LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class HlMobileRelatedListRecordComponent extends NavigationMixin(LightningElement) {
    @api record;
    @api parentrecordid;
    @api parentapi;
    @track title ="Activities";
    @track iconname="standard:event";
   
    handleClick(){
        // eslint-disable-next-line no-unused-vars
        let selectedActivityId = this.record.ParentId__c;
        console.log('10>>>>'+selectedActivityId);
        console.log('20>>>'+this.record.AccountId);
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
        });
    }
}