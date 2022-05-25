import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HlCoverageTeam extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeId;
    type;
    primarySector;
    secondarySector;
    tertiarySector;
    @api doRedirect;
    @api doCancel;
    fields = ['Next_Steps__c','Officer__c','Description__c','Line_of_Business__c','Coverage_Level__c','CuurencyIsoCode','Estimated_EV_MM__c',
              'Target_Transaction_Date__c','Target_Engagement_Date__c','Tier__c','Last_Activity__c','Priority__c','Company_Coverage_Status__c',
               'Arranged_by_R_D__c','Expected_Products__c','Profile_Date_Completed__c','Lead_Generation_Status__c','Intro_Conversation_Occurred_Date__c',
               'Coverage_Team_Status__c'];
    isLoading=false;

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Company__c=this.recordId;
        fields.Coverage_Type__c=this.type;
        fields.Primary_Sector__c=this.primarySector;
        fields.Secondary_Sector__c=this.secondarySector;
        fields.Tertiary_Sector__c=this.tertiarySector;        
        this.template.querySelector('lightning-record-form').submit(fields);
    }

    handleSectorChange(event){        
        this.type=event.detail.type;
        this.primarySector=event.detail.primarySector;
        this.secondarySector=event.detail.secondarySector;
        this.tertiarySector=event.detail.tertiarySector;
    }    

    handleSuccess(event){
        console.log('handleSuccess:'+event.detail.id);
        this.doRedirect(event.detail.Id);
        //const customevent = new CustomEvent("closeModalEvent", {
            //want pass some extra param, then you can do it at here.
       // });
        //this.dispatchEvent(customevent);
            /*this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.id,
                    objectApiName: 'Coverage_Team__c',
                    actionName: 'view'
                }
            }).then(url=>{
                console.log('url: '+url);
                //window.open(url);
            });*/
            //window.open('/'+event.detail.id);     
    }

    handleCancel(event){
        this.isLoading=true;
        this.doCancel();
        this.isLoading=false;
    }
}