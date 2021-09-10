/* eslint-disable no-console */
import { LightningElement , track } from 'lwc';
import fetchAllFirstAids from '@salesforce/apex/FirstAidListController.getAllFirstAids';
import retrieveFirstAids from '@salesforce/apex/FirstAidListController.findFirstAids';
const DELAY = 350;



export default class FirstAidList extends LightningElement {
    @track firstAids;
    @track error;
    
    connectedCallback() {
		this.loadFirstAids(error = `abc`);
	}



	loadFirstAids(error) {
		fetchAllFirstAids()
			.then(result => {
				this.firstAids = result ;
				this.error = undefined;
			})
			.catch(error => {
				this.error = error;
				this.firstAids = undefined;
			});
	}

	searchFirsAids(event) {
		window.clearTimeout(this.delayTimeout);
        var searchKey = event.target.value;
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
            retrieveFirstAids({ searchKey })
                .then(result => {
                    this.firstAids = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.firstAids = undefined;
                });
        }, DELAY);
	}
}