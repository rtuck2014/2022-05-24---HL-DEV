import { LightningElement,wire, api} from 'lwc';
import getCoverageType from '@salesforce/apex/HLSectorDependentPicklist.getCoverageType';
import getPrimaryCoverage from '@salesforce/apex/HLSectorDependentPicklist.getPrimaryCoverage';
import getSecondaryCoverage from '@salesforce/apex/HLSectorDependentPicklist.getSecondaryCoverage';
import getTertiaryCoverage from '@salesforce/apex/HLSectorDependentPicklist.getTertiaryCoverage';

export default class HlSectorDependentPicklist extends LightningElement {
    
    @api selectedTypeValue;
    selectedTypeLabel;
    @api selectedPrimaryValue;
    selectedPrimaryLabel;
    @api selectedSecondaryValue;
    selectedSecondaryLabel;
    @api selectedTertiaryValue;
    selectedTertiaryLabel;
    isPrimaryDisabled=true;
    isSecondaryDisabled=true;
    isTertiaryDisabled=true;
    coverageTypeItems = [];    
    primarySectorItems = [];
    secondarySectorItems = [];
    tertiarySectorItems = [];
    error;
    @api recordId;

    @wire (getCoverageType) 
    wiredCoverageTypes({error,data}){
        if(data){
            let options=[];
            //console.log('data:'+JSON.stringify(data));
            for(let i=0; i<data.length; i++){
                options.push({label:  data[i].label, value: data[i].value});
            }
            this.coverageTypeItems = options;
            console.log('finished type');
            //console.log(JSON.stringify(this.coverageTypeItems));
            this.error=undefined;
            
            if(this.selectedTypeValue){
                this.isPrimaryDisabled=false;
                getPrimaryCoverage({coverageTypeId: this.selectedTypeValue})
                .then(result=>{
                    let options=[];
                    for(let i=0;i<result.length;i++){
                        options.push({label:  result[i].label, value: result[i].value});
                    }
                    //console.log(JSON.stringify(options));
                    this.primarySectorItems=options;                    
                    if(this.selectedPrimaryValue){                                    
                        getSecondaryCoverage({coverageTypeId: this.selectedTypeValue, primarySectorId: this.selectedPrimaryValue})
                        .then(result=>{
                            let options=[];
                            for(let i=0;i<result.length;i++){
                                options.push({label:  result[i].label, value: result[i].value});
                            }            
                            this.secondarySectorItems=options;
                            if(options.length>0)
                                this.isSecondaryDisabled=false;
                            console.log('finished secondary');
                            if(this.selectedSecondaryValue){                                                     
                                getTertiaryCoverage({coverageTypeId: this.selectedTypeValue, primarySectorId: this.selectedPrimaryValue,secondarySectorId: this.selectedSecondaryValue})
                                .then(result=>{
                                    let options=[];
                                    for(let i=0;i<result.length;i++){
                                        options.push({label:  result[i].label, value: result[i].value});
                                    }            
                                    this.tertiarySectorItems=options;
                                    if(options.length>0)
                                        this.isTertiaryDisabled=false;
                                    console.log('finished tertiary');
                                })
                                .catch(error=>{
                                    this.error=error;
                                    this.tertiarySectorItems=undefined;
                                })
                            }
                        })
                        .catch(error=>{
                            this.error=error;
                            this.secondarySectorItems=undefined;
                        })
                    }
                })
                .catch(error=>{
                    this.error=error;
                    this.primarySectorItems=undefined;
                })  
            }            
        }else if(error){
            this.error=error;
            this.coverageTypeItems=undefined;
        }
    }

    handleTypeChange(event){        
        this.selectedTypeValue=event.detail.value;
        this.selectedTypeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedPrimaryValue=null;
        this.isPrimaryDisabled=true;
        this.selectedSecondaryValue=null;
        this.isSecondaryDisabled=true;
        this.selectedTertiaryValue=null;
        this.isTertiaryDisabled=true;
        const sectorEvent = new CustomEvent('child',{
            detail: {type:this.selectedTypeValue,primarySector:null,secondarySector:null,tertiarySector:null}
        });
        this.dispatchEvent(sectorEvent);
        getPrimaryCoverage({coverageTypeId: this.selectedTypeValue})
        .then(result=>{
            let options=[];
            for(let i=0;i<result.length;i++){
                options.push({label:  result[i].label, value: result[i].value});
            }
            //console.log(JSON.stringify(options));
            if(options.length>0){
                this.isPrimaryDisabled=false;
            }
            this.primarySectorItems=options;
        })
        .catch(error=>{
            this.error=error;
            this.primarySectorItems=undefined;
        })
    }

    handlePrimaryChange(event){        
        this.selectedPrimaryValue=event.detail.value;        
        this.selectedPrimaryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedSecondaryValue=null;
        this.isSecondaryDisabled=true;
        this.selectedTertiaryValue=null;
        this.isTertiaryDisabled=true;
        const sectorEvent = new CustomEvent('child',{
            detail: {type:this.selectedTypeValue,primarySector:this.selectedPrimaryValue,secondarySector:null,tertiarySector:null}
        });
        this.dispatchEvent(sectorEvent);
        getSecondaryCoverage({coverageTypeId: this.selectedTypeValue, primarySectorId: this.selectedPrimaryValue})
        .then(result=>{
            let options=[];
            for(let i=0;i<result.length;i++){
                options.push({label:  result[i].label, value: result[i].value});
            }          
            if(options.length>0){
                this.isSecondaryDisabled=false;
            }  
            this.secondarySectorItems=options;

        })
        .catch(error=>{
            this.error=error;
            this.secondarySectorItems=undefined;
        })
    }

    handleSecondaryChange(event){        
        this.selectedSecondaryValue=event.detail.value;      
        this.selectedSecondaryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;        
        this.selectedTertiaryValue=null;
        this.isTertiaryDisabled=true;        
        const sectorEvent = new CustomEvent('child',{
            detail: {type:this.selectedTypeValue,primarySector:this.selectedPrimaryValue,secondarySector:this.selectedSecondaryValue,tertiarySector:null}
        });
        this.dispatchEvent(sectorEvent);  
        getTertiaryCoverage({coverageTypeId: this.selectedTypeValue, primarySectorId: this.selectedPrimaryValue,secondarySectorId: this.selectedSecondaryValue})
        .then(result=>{
            let options=[];            
            for(let i=0;i<result.length;i++){
                options.push({label:  result[i].label, value: result[i].value});
            }
            if(options.length>0){
                this.isTertiaryDisabled=false;
            }
            this.tertiarySectorItems=options;
        })
        .catch(error=>{
            this.error=error;
            this.secondarySectorItems=undefined;
        })
    }

    handleTertiaryChange(event){
        this.selectedTertiaryValue=event.detail.value;      
        this.selectedTertiaryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        const sectorEvent = new CustomEvent('child',{
            detail: {type:this.selectedTypeValue,primarySector:this.selectedPrimaryValue,secondarySector:this.selectedSecondaryValue,tertiarySector:this.selectedTertiaryValue}
        });
        this.dispatchEvent(sectorEvent);  
    }
}