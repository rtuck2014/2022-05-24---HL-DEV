import { LightningElement, api } from 'lwc';

export default class LookupRecordListComponent extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;

    handleSelect(event){
        event.preventDefault();
        const selectedRecord = new CustomEvent(
            "select",
            {
                detail : this.record.Id
            }
        );
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
}