import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordUi } from 'lightning/uiRecordApi';
//LL20190510 - Supports rendering of Header using VF and LightningOut. 
//LL20190510 - Component will be deprecated when migrated to Lightning Pages
export default class HlUniversalHeader extends LightningElement {
    //LL20190510 - Establish component properties and import properties from hlUniversalContainer #PROPERTIES
    @api hlHeaderId;
    @api hlHeaderObjectApi;
    @api buttonOneLabel;
    @api buttonTwoLabel;
    @api buttonOneUrl;
    @api buttonTwoUrl;
    @track hNameField;
    @track hKeyFields;
    @track hAllFields;
    @track hIcon;
    @track hData;
    //LL20190513 - Get all metadata and data for a Record #NODML #METADATA #GETDATA
    @wire(getRecordUi, { recordIds: '$hlHeaderId', layoutTypes: ['Compact'], modes: ['View'] })
    getHeaderRecord({error, data}){
        if(error){
            // console.log('hlUnviersalHeader:error:this.hlHeaderId','==>',this.hlHeaderId);
            let message = 'Unknown error';
            if (Array.isArray(error.body)) message = error.body.map(e => e.message).join(', ');
            else if (typeof error.body.message === 'string') message = error.body.message;
            this.dispatchEvent(new ShowToastEvent({title: 'Error loading header record',message,variant: 'error',}),);
        }
        else if(data){
            //LL20190510 - Get key fields and values based on compact layout (Record Name field should be first in layout) - #NODML #UI
            // console.log('hlUnviersalHeader:good:this.hlHeaderId','==>',this.hlHeaderId);
        //    console.log(' CHeck (getHeaderRecord) >> ', data);
            const hRecords = data.records;
            const hRec = hRecords[Object.keys(hRecords)[0]];
        //    console.log('getHeaderRecord >>>>> Header App.hRec1', hRec);
            const hRecKeys = Object.keys(hRec);
           // console.log('getHeaderRecord >>>>> Header App.hRecKeys', hRecKeys);
 
            console.log('getHeaderRecord >>>>> Header App.hRecObj 1', hRec);

            const newhRecObj = {
                id: hRec.id,
                fields: hRec.fields,
                recordTypeInfo: hRec.recordTypeInfo
            };
            console.log('getHeaderRecord >>>>> Header App.newhRecObj 2', newhRecObj);
        /*    for (let i = 0; i < hRecKeys.length; i++){  
                console.log('getHeaderRecord >>>>> Header App.hRecKeys 4', hRecKeys[i]);
                console.log('getHeaderRecord >>>>> Header App.hRecKeys 5', hRec[hRecKeys[i]]);

                newhRecObj[hRecKeys[i]] = hRec[hRecKeys[i]];
                console.log('getHeaderRecord >>>>> Header App.hRecKeys 6', typeof hRecKeys[i]);
            }
            console.log('getHeaderRecord >>>>> Header App.newhRecObj', newhRecObj); */
            const contextEvent = new CustomEvent('context', {detail: hRec});
            this.dispatchEvent(contextEvent);
            const hRecordFields = hRec.fields;
            const hObjectInfos = data.objectInfos;
            const hObjectInfo = hObjectInfos[this.hlHeaderObjectApi];
            if(hObjectInfo.themeInfo){
                const hIconUrl = hObjectInfo.themeInfo.iconUrl.split('/');
                const hIconSet = hIconUrl[hIconUrl.length-2];
                const hIconName = hIconUrl[hIconUrl.length-1].split('.')[0].split('_')[0];
                this.hIcon = hIconSet + ':' + hIconName;    
            }
            const hObjectFields = hObjectInfo.fields;
            const hLayouts = data.layouts;
            const hLayoutObj = hLayouts[this.hlHeaderObjectApi];
            const hLayoutId = hLayoutObj[Object.keys(hLayoutObj)[0]];
            const hLayoutRows = hLayoutId.Compact.View.sections[0].layoutRows;
            const hKeyFieldsArray = [];
            for (let i = 0; i < hLayoutRows.length; i++) { 
                const hLayoutItems = hLayoutRows[i].layoutItems;
                for (let j = 0; j < hLayoutItems.length; j++) {
                    const hLayoutItem = hLayoutItems[j];
                    const hKeyAPIName = hLayoutItem.layoutComponents[0].apiName;
                    const hKeyLabel = hLayoutItem.layoutComponents[0].label;
                    const hKeyMetaObj = hObjectFields[hKeyAPIName];
                    const hKeyReference = hKeyMetaObj.reference;
                    const fieldObj = {apiName: hKeyAPIName, label: hKeyLabel, object: hKeyMetaObj, record: hRecordFields[hKeyAPIName]};
                    if(hKeyAPIName === 'Name') this.hNameField = fieldObj;
                    else{ 
                        if(hKeyReference) fieldObj.reference = hRecordFields[hKeyMetaObj.relationshipName];
                        hKeyFieldsArray.push(fieldObj);
                    }
                }
            }
            this.hKeyFields = hKeyFieldsArray;
            this.hData = JSON.stringify(this.hKeyFields, null, 2);
        }
    }
}