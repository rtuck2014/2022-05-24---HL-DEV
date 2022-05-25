import { LightningElement, wire, api} from 'lwc';

// importing to get the object info 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';


export default class RecordTypesInLWC extends LightningElement {
    @api selectedValue;
    @api options = [];
    @api objectApiName;
    // object info using wire service
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    accObjectInfo({data, error}) {
        if(data) {
            let optionsValues = [];
            // map of record type Info
            const rtInfos = data.recordTypeInfos;

            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.options = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }
     
    // Handling on change value
    handleChange(event) {
        this.selectedValue = event.detail.value;
        const selectedRt = new CustomEvent('rtchange',{detail:this.selectedValue});
        this.dispatchEvent(selectedRt);
    }

}