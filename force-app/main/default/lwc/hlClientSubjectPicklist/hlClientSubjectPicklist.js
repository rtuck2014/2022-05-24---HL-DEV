import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/hlClientSubjectPubSub';

export default class HlClientSubjectPicklist extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @api objectApiName;
    @api pickListfieldApiName;
    @api label;
    @api variant;

    /*only for lwc for mapping values in list and 
    also for mapping this with dependent picklist(give unique = record Id while using in dependent picklist)*/
    @api uniqueKey;

    @track value;
    @api recordTypeId;
    readOnly;
    @track options = [
        { label: '--None--', value: "" }
    ];   
    
   
    connectedCallback(){
        this.readOnly =  this.pickListfieldApiName === 'Type__c' ? true : false;
    }

    @api 
    get selectedValue() {
        console.log("getter", this.value);
        return this.value;
    }
    set selectedValue(val) {
        console.log("setter", val);
        if (val === '' || val === undefined || val === null)
            this.value = { label: '--None--', value: "" }.value;
        else
            this.value = val;
    }
         

    /*@wire(getObjectInfo, { objectApiName: '$objectApiName' })
    getRecordTypeId({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            if(this.recordTypeId === undefined){
                this.recordTypeId = this.record.defaultRecordTypeId;
            }
            console.log("Default Record Type Id", JSON.stringify(this.record.defaultRecordTypeId));
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("this.error",this.error);
        }
    }*/
                     
    @wire(getPicklistValuesByRecordType, { recordTypeId: '$recordTypeId', objectApiName: '$objectApiName' })
    wiredOptions({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            
            console.log("this.record picklist raw data", JSON.stringify(this.record));
            console.log("this.record.picklistFieldValues", JSON.stringify(this.record.picklistFieldValues));
            
            if(this.record.picklistFieldValues[this.pickListfieldApiName] !== undefined) {

                let tempOptions = [{ label: '--None--', value: "" }];
                let temp2Options = this.record.picklistFieldValues[this.pickListfieldApiName].values;
                temp2Options.forEach(opt => tempOptions.push(opt));

                this.options = tempOptions;
            }
            console.log("this.options pick", JSON.stringify(this.options));
            if(this.selectedValue === '' || this.selectedValue === undefined || this.selectedValue === null) {
                if(this.pickListfieldApiName === 'KeyCreditorImportance__c'){
                    this.selectedValue = 'Medium';
                    this.value = this.options.find(listItem => listItem.value === this.selectedValue).value;
                
                }else{
                this.value = { label: '--None--', value: "" }.value;
                }
            } else if(this.selectedValue !== null || this.options.includes(this.selectedValue)){
                //this.value = this.options.find(listItem => listItem.value === this.selectedValue).value;
                for(let i = 0 ; i < this.options.length; i++){
                    if(this.options[i].value === this.selectedValue){
                        this.value = this.options[i].value;
                    }
                }
            }
            else{
                this.value = this.options[1].value;
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log("this.error",this.error);
        }
    }


    handleChange(event) {
        let tempValue = event.target.value;
        console.log("event.target.value",event.target.value);
        console.log("this.value",tempValue);
        let selectedValue = tempValue;
        let key = this.uniqueKey;
        let  fieldApiName = this.pickListfieldApiName;

        //Firing change event for aura container to handle
        //For Self
        const pickValueChangeEvent = new CustomEvent('picklistchange', {
            detail: { selectedValue, key ,fieldApiName},
        });
        this.dispatchEvent(pickValueChangeEvent);

        //For dependent picklist
        let eventValues = {selValue : selectedValue, uniqueFieldKey: `${this.pickListfieldApiName}${this.uniqueKey}`};
        console.log("eventValues",JSON.stringify(eventValues));
        console.log("eventValues",eventValues);
        //Fire Pub/Sub Event, So that every other comp in the page knows the change
        fireEvent(this.pageRef, 'controllingValue', eventValues);
    }

}