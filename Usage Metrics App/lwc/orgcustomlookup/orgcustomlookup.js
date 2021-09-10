import { LightningElement, track, api} from 'lwc';
import findOrgForSearchkey from '@salesforce/apex/UsageMetricsLWCController.findOrgSearched';

export default class Orgcustomlookup extends LightningElement {
    @track search = '';
    
    @track selectedOrg;
    @api orgSearchLabel = 'Org Name';
   
    @track orgList = [];
    @track isAutoSearchLoaded = false;
    @track error;

    connectedCallback(){
    
    }

    searchOrg(searchKey) {
        
        findOrgForSearchkey({ searchKey })
            .then(result => {
                this.template.querySelector('.orgs_list').classList.remove('slds-hide');
                this.orgList = result;   
                this.isAutoSearchLoaded = false ;  
                          
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.isAutoSearchLoaded = false ;
                this.orgList = undefined;
            });
	}
    
    handleKeyUp(event) {
        this.search = event.target.value; 
        this.orgSearchLabel = 'Org Name' ;
        this.orgList = [];    
        if (this.search.length >=3) {        
            this.isAutoSearchLoaded = true ;
            this.searchOrg(this.search) ;
            
        }else if(this.search.length <= 2){
            this.template.querySelector('.orgs_list').classList.add('slds-hide');
        }     
    }

    handleOptionSelect(event) {     
        this.selectedOrg = event.currentTarget.dataset.name;
        const selectedOrgId = event.currentTarget.dataset.id;
        this.orgSearchLabel = 'Org Name (' + selectedOrgId + ')' ;
        const selectedOrgEvent = new CustomEvent('autopopulateevent', { detail: selectedOrgId });
        this.dispatchEvent(selectedOrgEvent);

        this.template.querySelector('.selectedOption').classList.remove('slds-hide');
        this.template.querySelector('.orgs_list').classList.add('slds-hide');
        this.template.querySelector('.slds-combobox__form-element').classList.add('slds-input-has-border_padding');          
    }


    handleRemoveSelectedOption() {
        this.orgSearchLabel = 'Org Name' ;
        this.search = '' ;

        const removedOrgEvent = new CustomEvent('autopopulateevent', { detail: '' });
        this.dispatchEvent(removedOrgEvent);

        this.template.querySelector('.selectedOption').classList.add('slds-hide');
        this.template.querySelector('.slds-combobox__form-element').classList.remove('slds-input-has-border_padding');   
    } 
    
    @api
    handleHideAllSearchComponents(){
        this.handleRemoveSelectedOption() ;
        this.template.querySelector('.orgs_list').classList.add('slds-hide');
    }
}