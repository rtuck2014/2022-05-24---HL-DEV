import { LightningElement ,api,track,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ParentCounterPartyComponent extends LightningElement {

    @api recordId;
    showAddParty = false;

    handleClick(){
        //alert('Add Counterparties');
        this.showAddParty = true;
    }

    handleCloseAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleBackButton(){
        this.showAddParty = false;
    }
}