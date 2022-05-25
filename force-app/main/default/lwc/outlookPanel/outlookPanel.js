import { LightningElement,api,wire} from 'lwc';
import getEvent from '@salesforce/apex/OutlookPanelCon.getEvent';

export default class OutlookPanel extends LightningElement {
    @api messageBody;
    @api subject;
    @api people;
    @api dates;
    @api source;
    eventList;
    siteUrl;
    returnedRecordId;
    purpose;
    event;
    //@wire (getEvent,{subject:'$subject',startDate:'$dates.start',endDate:'$dates.end'})
    //wiredEventList

    connectedCallback(){
        if(this.subject && this.dates){
            getEvent({subject:this.subject,startDate:this.dates.start,endDate:this.dates.end})
            .then(result=>{
                if(result[0]){
                    this.returnedRecordId=result[0].Id;
                    this.event = result[0];
                    //this.purpose=result[0].Purpose__c;
                    this.siteUrl='/apex/HL_ActivityEventViewOutlook?Id='+result[0].Id;
                    //this.eventList = result;
                }
            })
        }
    }
        
}