import { LightningElement, track, api } from "lwc";
import search from "@salesforce/apex/EmailMessageController.search";

export default class EmailInput extends LightningElement {
    @track items = [];
    searchTerm = "";
    blurTimeout;
    boxClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    //@api defaultSelectedValues=[];
    @api defaultSelectedContactList=[];
    _selectedValues;
    @api selectedValuesMap = new Map();

    get selectedValues() {
        return this._selectedValues;
    }
    set selectedValues(value) {
        this._selectedValues = value;

        const selectedValuesEvent = new CustomEvent("selection", { detail: { selectedValues: this._selectedValues} });
        this.dispatchEvent(selectedValuesEvent);
    }
    
    connectedCallback(){
        console.log('called with:'+JSON.stringify(this.defaultSelectedContactList));
        let tempArray=[];        
        /*this.defaultSelectedValues.forEach(emailAddress=>{
            tempArray.push(emailAddress);
            this.selectedValuesMap.set(emailAddress, emailAddress);
        });*/
        this.defaultSelectedContactList.forEach(contact=>{
            tempArray.push(contact.Email);
            this.selectedValuesMap.set(contact.Email, contact);
        });
        this._selectedValues=tempArray;
    }

    handleInputChange(event) {
        event.preventDefault();
        if (event.target.value.length < 3) {
            return;
        }

        search({ searchString: event.target.value })
            .then((result) => {
                this.items = result;
                if (this.items.length > 0) {
                    this.boxClass =
                        "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open";
                }
            })
            .catch((error) => {
                console.error("Error:", error);
            });
    }

    handleBlur() {
        console.log("In onBlur");
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = setTimeout(() => {
            this.boxClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
            const value = this.template.querySelector('input.input').value
            if (value !== undefined && value != null && value !== "") {
                this.selectedValuesMap.set(value, value);
                this.selectedValues = [...this.selectedValuesMap.keys()];
            }

            this.template.querySelector('input.input').value = "";
        }, 300);
    }

    get hasItems() {
        return this.items.length;
    }

    handleKeyPress(event) {
        if (event.keyCode === 13) {
            event.preventDefault(); // Ensure it is only this code that runs

            const value = this.template.querySelector('input.input').value;
            if (value !== undefined && value != null && value !== "") {
                this.selectedValuesMap.set(value, value);
                this.selectedValues = [...this.selectedValuesMap.keys()];
            }
            this.template.querySelector('input.input').value = "";
        }
    }

    handleRemove(event) {        
        const item = event.target.label;        
        this.selectedValuesMap.delete(item);
        this.selectedValues = [...this.selectedValuesMap.keys()];
        const valueSelectedEvent = new CustomEvent("valueremove", {
            detail: { email:item }            
        });
        this.dispatchEvent(valueSelectedEvent);
    }

    onSelect(event) {
        this.template.querySelector('input.input').value = "";
        let ele = event.currentTarget;
        let selectedId = ele.dataset.id;
        let selectedValue = this.items.find((record) => record.Id === selectedId);
        console.log('onSelect adding:'+selectedValue.Email+':'+JSON.stringify(selectedValue));
        this.selectedValuesMap.set(selectedValue.Email, selectedValue);
        this.selectedValues = [...this.selectedValuesMap.keys()];

        //As a best practise sending selected value to parent and inreturn parent sends the value to @api valueId
        let key = this.uniqueKey;        
        const valueSelectedEvent = new CustomEvent("valueselect", {
            //detail: { selectedId, key }
            detail: {key:selectedValue.Email, value:selectedValue.Id}
        });
        this.dispatchEvent(valueSelectedEvent);

        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        console.log('selectedValuesMap:'+JSON.stringify(this.selectedValuesMap));
        console.log('selectedValues:'+JSON.stringify(this.selectedValues));
        this.boxClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    }

    @api reset() {
        this.selectedValuesMap = new Map();
        this.selectedValues = [];
    }

    @api validate() {
        this.template.querySelector('input').reportValidity();
        const isValid = this.template.querySelector('input').checkValidity();
        return isValid;
    }
}