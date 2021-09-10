import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import starRating from '@salesforce/resourceUrl/Star_Rating' ;
import loadCities from '@salesforce/apex/HospitalListController.loadCities';
import findHospitalsForSelectedCity from '@salesforce/apex/HospitalListController.findHospitalsForSelectedCity';
import getCityForCoordinates from '@salesforce/apex/HospitalListController.getCityForCoordinates';
import getDistanceDurationToHospital from '@salesforce/apex/HospitalListController.getDistanceDurationToHospital';
import saveFeedbackAndfetchHospitals from '@salesforce/apex/HospitalListController.saveFeedbackAndLoadHospitals';
import setNewReviewSection from '@salesforce/apex/HospitalListController.setNewReviewSectionToHospital';

export default class HospitalList extends LightningElement {
    @track hospitals;	
	@track currentCity;
	@track routeDuration;
	@track errorMessage;
	@track cityOptions = [];
	@track reviewComments = ''; 	
	@track reviewRating = '';
	ratingOptions = [
							{ label: 'rating5', value: '5', title : '5 stars' },
							{ label: 'rating4', value: '4', title : '4 stars'  },
							{ label: 'rating3', value: '3', title : '3 stars' },
							{ label: 'rating2', value: '2', title : '2 stars'  },
							{ label: 'rating1', value: '1', title : '1 star'  }
						]; 
	
    connectedCallback() {
		this.loadExternalCSS() ;
		this.loadHospitals();
		this.loadCityOptions();
	}

	loadExternalCSS(){
		Promise.all([
			loadStyle(this, starRating + '/StarRating/starRatingCSS.css' ), 
			//loadStyle(this, starRating + '/StarRating/starBootstrapCSS.css'  ) 
        ])
        .then(() => { 
            this.errorMessage = undefined;
        })
        .catch(error => {
            this.errorMessage = error;      
        });   
	}

	loadCityOptions() {
		loadCities()
		.then(cityList => {
			for(const cityName of cityList){
				const option = {label: cityName,value: cityName};
				this.cityOptions = [ ...this.cityOptions, option ];
			}
			this.errorMessage = undefined;
		})
		.catch(error => {
			this.errorMessage = error;
			this.cities = undefined;
		});
	}
	
	filterHospitals(event) {
		this.currentCity = event.detail.value;
		const city = this.currentCity ;
		// eslint-disable-next-line no-console
		console.log('city='+city);
		findHospitalsForSelectedCity({city})
		.then(hospitalList => {
			this.hospitals = hospitalList;
			this.errorMessage = undefined;
		})
		.catch(error => {
			this.errorMessage = error;
			this.hospitals = undefined;
		});
	}
	
	getLocation(){
		// eslint-disable-next-line no-unused-vars
		return new Promise((resolve, reject) => {
			navigator.geolocation.getCurrentPosition(
				position => {
					resolve(position);
				},
				// eslint-disable-next-line no-console
				(error) => console.log(error),
				{ enableHighAccuracy: true, timeout: 5000,maximumAge: 0}
			);
		})
	}

	loadHospitals(){
		this.getLocation().then(pos => {
			const latitude = pos.coords.latitude;
			const longitude = pos.coords.longitude;
			// eslint-disable-next-line no-console
			console.log('latitude '+latitude) ;
			// eslint-disable-next-line no-console
			console.log('longitude '+longitude) ;
			getCityForCoordinates({latitude, longitude})
			.then(city => {
				// eslint-disable-next-line no-console
				console.log('city '+city) ;
				this.currentCity = city; 
				this.errorMessage = undefined;
				findHospitalsForSelectedCity({city})
				.then(hospitalList => {
					this.hospitals = hospitalList;
					this.errorMessage = undefined;
				})
				.catch(error => {
					this.errorMessage = error;
					this.hospitals = undefined;
				});
			})
			.catch(error => {
				// eslint-disable-next-line no-console
				console.log('error in city '+error) ;
				this.errorMessage = error;
				this.currentCity = undefined;
			});
		}) ;		
	}

	fetchDistanceDurationToHospital(event) {  
		const hospitalId = event.currentTarget.dataset.key;
		// eslint-disable-next-line no-console
		console.log('&&&hospitalId '+hospitalId);
		const city = this.currentCity ;
		getDistanceDurationToHospital({hospitalId, city})
			.then(hospitalList => {
				this.hospitals = hospitalList;
				this.errorMessage = undefined;
			})
			.catch(error => {
				this.errorMessage = error;
				this.hospitals = undefined;
			});
		// eslint-disable-next-line no-console
		//console.log('&&&routeDuration '+this.routeDuration);
	}

	addFeedback(event) {  
		this.reviewComments = ''; 	
		this.reviewRating = '';
		const hospitalId = event.currentTarget.dataset.key;
		const city = this.currentCity ; 
		setNewReviewSection({hospitalId, city})
			.then(hospitalList => {
				this.hospitals = hospitalList;
				this.errorMessage = undefined;
			})
			.catch(error => {
				this.errorMessage = error;
				this.hospitals = undefined;
			});
	}
	
	handleRatingChange(event) {
		this.reviewRating = event.currentTarget.value;
	}

	handleReviewChange(event) {
		this.reviewComments = event.target.value;
	}

	saveFeedback(event) {  		
		const hospitalId = event.currentTarget.dataset.key;
		const comments =  this.reviewComments ;
		const rating = this.reviewRating ;
		const city = this.currentCity ; 
		// eslint-disable-next-line no-console
		console.log('&&&comments '+comments);
		// eslint-disable-next-line no-console
		console.log('&&&rating '+rating);
		if(comments !== '' && rating !== ''){
			saveFeedbackAndfetchHospitals({hospitalId,comments,rating, city})
			.then(hospitalList => {
				this.hospitals = hospitalList;
				this.reviewComments = ''; 	
				this.reviewRating = '';
				this.errorMessage = undefined;
			})
			.catch(error => {
				this.errorMessage = error;
				this.hospitals = undefined;
			});
		}
	}  
	
	cancelFeedback() {  
		this.reviewComments = ''; 	
		this.reviewRating = '';
		const city = this.currentCity ;
		findHospitalsForSelectedCity({city})
			.then(hospitalList => {
				this.hospitals = hospitalList;
				this.errorMessage = undefined;
			})
			.catch(error => {
				this.errorMessage = error;
				this.hospitals = undefined;
			});       
	}	
}