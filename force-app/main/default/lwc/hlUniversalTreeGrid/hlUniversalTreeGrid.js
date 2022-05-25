import { LightningElement, api, track } from 'lwc';
 
export default class HlUniversalTreeGrid extends LightningElement {
    @api title;
    @api icon;
    @api treeGridData;
    @api treeGridColumns;
    @track treeGridDataStructured;
}