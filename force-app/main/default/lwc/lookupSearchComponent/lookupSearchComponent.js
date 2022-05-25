/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, api } from 'lwc';
const DELAY = 400;

export default class LookupSearchComponent extends LightningElement {

@track searchKey;
@api searchFieldLabel;
@api placeholder;
@api type="search";

handleChange(event){
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    // eslint-disable-next-line no-console
    console.log('searchKey>>>'+searchKey);
    event.preventDefault();
    this.delayTimeout = setTimeout(() => {
      const searchEvent = new CustomEvent(
        'searchkeychange', 
        { 
            detail : searchKey
        }
    );
    this.dispatchEvent(searchEvent);
}, DELAY);
}

@api
clearFieldValue() {
    this.template.querySelector('lightning-input').value = '';
}
}