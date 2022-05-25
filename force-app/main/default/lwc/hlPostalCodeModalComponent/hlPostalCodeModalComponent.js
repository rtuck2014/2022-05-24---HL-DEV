import { LightningElement, api } from 'lwc';

export default class HlPostalCodeModalComponent extends LightningElement {
@api recordList;
@api title;

modalCancel(){
    this.dispatchEvent(new CustomEvent('closemodal'));
}
handleSelect(event){
    var index = event.target.value;
    this.dispatchEvent(new CustomEvent('select', { detail: index }));
}
}