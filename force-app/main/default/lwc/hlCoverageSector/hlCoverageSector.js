import { LightningElement,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['CoverageSector__c.CoverageType__c','CoverageSector__c.PrimarySector__c','CoverageSector__c.SecondarySector__c','CoverageSector__c.TertiarySector__c'];

export default class HlCoverageTeam extends NavigationMixin(LightningElement) {
    @api recordId;
    @api coverageSectorId;
    @api coverageTeamTypeId;
    @api isMain;
    type;
    primarySector;
    secondarySector;
    tertiarySector;
    @api doRedirect;
    @api doCancel;
    hasData = false;
    error;
    
    @wire(getRecord, { recordId: '$coverageSectorId', fields : FIELDS}) 
    wiredCoverageSector({ error, data }) {
        if (data) {
            //console.log(JSON.stringify(data));
            this.type=data.fields.CoverageType__c.value;
            this.primarySector=data.fields.PrimarySector__c.value;
            this.secondarySector=data.fields.SecondarySector__c.value;
            this.tertiarySector=data.fields.TertiarySector__c.value;
            this.error = undefined;
            this.hasData=true;
        } else if (error) {
            console.log('error:'+error);
            this.error = error;            
        } 
    }

    handleSubmit(event){
        event.preventDefault();        
        this.error = undefined;
        const fields = event.detail.fields;        
        fields.CoverageTeam__c=this.recordId;
        fields.CoverageType__c=this.type;
        fields.PrimarySector__c=this.primarySector;        
        if(fields.CoverageType__c==null||fields.PrimarySector__c==null){
            this.error='Please select all required fields';
            return;
        }
        fields.SecondarySector__c=this.secondarySector;
        fields.TertiarySector__c=this.tertiarySector;        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        
    }

    handleSectorChange(event){
        //console.log('type:'+event.detail.type);
        //console.log('primarySector'+event.detail.primarySector);
        //console.log('secondarySector'+event.detail.secondarySector);
        //console.log('tertiarySector'+event.detail.tertiarySector);
        this.type=event.detail.type;
        this.primarySector=event.detail.primarySector;
        this.secondarySector=event.detail.secondarySector;
        this.tertiarySector=event.detail.tertiarySector;
    }    

    handleSuccess(event){
        this.handleCancel();
       // console.log('handleSuccess:'+event.detail.id);
        //this.doRedirect(event.detail.id);
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
        this.doCancel();
    }
    
    handleError(event){
        console.log('error:'+event.detail.message);
    }
}