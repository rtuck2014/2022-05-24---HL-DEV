/* eslint-disable no-console */
import { LightningElement, api, track} from 'lwc';
import TIMEZONE from '@salesforce/i18n/timeZone';

export default class HlMobileFormattedFieldValueComponent extends LightningElement {

    @api fieldValue;
    @api fieldDataType;
    @api index;
    @api isHeaderField;
    @track isDate = false;
    @track isDatetime=false;
    @track isOther=false;
    @track timeZone = TIMEZONE;


    connectedCallback() {
        if(this.isHeaderField && this.index > 0){
            this.fieldValue = ' - ' +this.fieldValue;
        }
        
        if (this.fieldDataType === 'DATE') {
            this.isDate = true;
        } else if (this.fieldDataType === 'DATETIME') {
            this.isDatetime = true;
        } else {
            this.isOther = true;
        }
    }
}