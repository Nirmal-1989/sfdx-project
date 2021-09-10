import {LightningElement, track} from 'lwc';

import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import toastCSS from '@salesforce/resourceUrl/ToastCSS' ;
import getChartTypeOptions from '@salesforce/apex/UsageMetricsLWCController.retrieveChartTypeOptions';
import getAllOrgOptions from '@salesforce/apex/UsageMetricsLWCController.retrieveAllOrgOptions';
import getNameSpaceOptions from '@salesforce/apex/UsageMetricsLWCController.retrieveNameSpaceOptions';
import getMetricsData from '@salesforce/apex/UsageMetricsLWCController.retrieveMetricsData'; 
export default class UsageMetricsLWC extends LightningElement {
	
	orgTypeChosen = 'All Orgs'; 

	@track allOrgValue;
	allOrgOptions = [];
	@track singleOrgValue;
	orgId = '' ;
	orgFilterValue = '' ;

	@track appValue;
	appOptions = [];

	@track chartTypeValue;
	chartTypeOptions = [];

	@track metricsStartDate = this.fetchMetricsStartDate();
	@track metricsEndDate =  this.fetchTodayDate() ;
	todayDate =  this.fetchTodayDate() ;

	@track data = [];
	@track columns = [];
	config ;
	lineChart ;

	@track defaultSortDirection = 'asc';
	@track sortDirection = 'asc';
	@track sortedBy;

	validationMessage = '' ;
	@track isSpinnerLoaded = false;
	@track showData = false;
	@track showChart = true;
	hasDataRetrieved = false ;

	connectedCallback(){
		this.isSpinnerLoaded = true;
		this.loadViewMetricsOptions() ;
	}

	fetchMetricsStartDate(){
		var todayDate = new Date();
		todayDate.setDate(todayDate.getDate() - 30);
		var dateString = todayDate.toISOString().split('T')[0];
		return dateString ;
	}

	fetchTodayDate(){
		return (new Date()).toISOString().split('T')[0] ;
	}

	loadViewMetricsOptions(){
		this.loadAllOrgptions();
		this.loadChartTypeOptions();
		this.loadNamespaceOptions();
	}

	loadAllOrgptions(){
		getAllOrgOptions()
			.then(result =>{
				this.allOrgOptions = result ;
				this.allOrgValue = this.allOrgOptions[0].value ;
			})
			.catch(error =>{
				this.allOrgOptions = undefined;
				this.isSpinnerLoaded = false
				this.showMessage('Error in loading org options', error.message, 'error', 'dismissable') ;
				
			});
	}

	loadChartTypeOptions(){
		getChartTypeOptions()
			.then(result =>{
				this.chartTypeOptions = result;
				this.chartTypeValue = this.chartTypeOptions[0].value ;
			})
			.catch(error =>{
				this.chartTypeOptions = undefined;
				this.isSpinnerLoaded = false;
				this.showMessage('Error in loading chart options', error.message, 'error', 'dismissable') ;				
			});
	}

	loadNamespaceOptions(){
		getNameSpaceOptions()
			.then(result =>{
				this.appOptions = result;
				this.appValue = this.appOptions[0].value ;
				this.isSpinnerLoaded = false;
			})
			.catch(error =>{
				this.appOptions = undefined;
				this.isSpinnerLoaded = false;
				this.showMessage('Error in loading app namespaces', error.message, 'error', 'dismissable') ;	
			});		
	}

	storeOrgSelection(event){
		this.orgTypeChosen = event.currentTarget.dataset.key;	
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}else if(this.hasDataRetrieved == false){
			this.clearComponentsOnRadioOptionChange() ;
		}						
	}

	clearComponentsOnRadioOptionChange(){
		if(this.orgTypeChosen == 'All Orgs'){
			this.template.querySelector('c-orgcustomlookup').handleHideAllSearchComponents() ;
			this.singleOrgValue = '' ;
		}else if(this.orgTypeChosen == 'Single Org'){
			this.template.querySelector('c-orgcustomlookup').handleHideAllSearchComponents() ;
			this.allOrgValue = '' ;
		}else if(this.orgTypeChosen == 'Org Name'){
			this.allOrgValue = '' ;
			this.singleOrgValue = '' ;
			if(this.orgId){
				this.template.querySelector('c-orgcustomlookup').orgSearchLabel = 'Org Name (' + this.orgId + ')' ;
			}
		}
		this.allOrgValue = this.allOrgOptions[0].value ;	
	}

	storeAllOrgValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.allOrgValue = event.currentTarget.value;	
	}

	storeSingleOrgValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.singleOrgValue = event.currentTarget.value;
	}

	handleAutopopulateEvent(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.orgId = event.detail; 
		if(this.orgId){
			this.template.querySelector('c-orgcustomlookup').orgSearchLabel = 'Org Name (' + this.orgId + ')' ;
		}
	}

	storeAppValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.appValue = event.currentTarget.value ;
	}

	storeStartDateValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.metricsStartDate = event.currentTarget.value;
	}

	storeEndDateValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.metricsEndDate = event.currentTarget.value;
	}

	storeChartValue(event){
		if(this.hasDataRetrieved == true){
			this.clearComponentsOnSearchParamsChange() ;
		}
		this.chartTypeValue = event.currentTarget.value;
	}

	clearComponentsOnSearchParamsChange(){
		this.allOrgValue = this.allOrgOptions[0].value ;
		this.singleOrgValue = '' ;
		this.template.querySelector('c-orgcustomlookup').handleHideAllSearchComponents() ;
		this.appValue = this.appOptions[0].value ;
		this.metricsStartDate = this.fetchMetricsStartDate() ;
		this.metricsEndDate = this.todayDate ;
		this.chartTypeValue = this.chartTypeOptions[0].value;
		this.data = [];
		this.columns = [];
		if(this.lineChart){
			this.lineChart.destroy();
		}	
		this.showData = false ;
		this.hasDataRetrieved = false ;
	}

	toggleChartDisplay(event){
		this.showChart = event.currentTarget.checked ;
		if(this.showChart == true && this.showData == true){
			this.loadChartJSOptions() ;
		}
	}

	submitMetricsData(event) {
		this.isSpinnerLoaded = true;
		this.showData = true ;
		this.hasDataRetrieved = false ;
		this.performValidationOnFilterDetails() ;
		if(this.validationMessage.length == 0){
			this.passFilterDetailsMetricsData(this.orgTypeChosen, this.orgFilterValue, this.appValue, 
				this.chartTypeValue, this.metricsStartDate, this.metricsEndDate) ;			
		}else if(this.validationMessage.length > 0){
			this.isSpinnerLoaded = false;
			this.showData = false ;
			this.showMessage('Please fill metrics filter options', this.validationMessage, 'warning', 'dismissable') ; 
		}		
	}

	performValidationOnFilterDetails(){
		this.validationMessage = '' ;
		if(this.orgTypeChosen == 'All Orgs'){
			if (this.allOrgValue) {
				this.orgFilterValue = this.allOrgValue ;
			}else{
				this.validationMessage = 'Please select value in all organization picklist field. \n' ;
			}			
		}else if(this.orgTypeChosen == 'Single Org'){
			if (this.singleOrgValue) {
				this.orgFilterValue = this.singleOrgValue ;
			}else{
				this.validationMessage = 'Please enter value in single organization text field. \n' ;
			}
		}else if(this.orgTypeChosen == 'Org Name'){
			if (this.orgId) {
				this.orgFilterValue = this.orgId ;
			}else{
				this.validationMessage = 'Please select org name in organization name search field. \n' ;
			}
		}

		if (!this.appValue) {
			this.validationMessage = this.validationMessage + 'Please select value in app picklist field. \n' ; 
		}

		if (!this.chartTypeValue) {
			this.validationMessage = this.validationMessage + 'Please select data to be shown before pressing View Metrics button. \n' ; 
		}

		if (!this.metricsStartDate) {
			this.validationMessage = this.validationMessage + 'Please select date in Metrics start date field.' ;
		}

		if (!this.metricsEndDate) {
			this.validationMessage = this.validationMessage + 'Please select date in Metrics end date field.' ;
		}
	}

	passFilterDetailsMetricsData(orgTypeFilterChosen, orgFilterChosen, appFilterChosen, 
								 chartTypeFilterChosen, startDateFilterChosen, endDateFilterChosen){
		getMetricsData({ orgTypeFilterChosen, orgFilterChosen, appFilterChosen, 
							  chartTypeFilterChosen, startDateFilterChosen, endDateFilterChosen})
            .then(result =>{
				if(result.hasError == true){
					this.isSpinnerLoaded = false; 
					this.showData = false ;
					this.data = [];
					this.columns = [];	
					if(this.lineChart){
						this.lineChart.destroy();
					}
					this.showMessage('Error in viewing metrics', result.errorMessage, 'warning', 'dismissable') ;						
				}else if(result.hasError == false){
					this.data = result.tableData ;
					this.columns = result.tableColumns ;	

					this.setUpChartForData(result.chartData.labels, result.chartData.datasets) ;					
					
					this.sortedBy = 'column_1' ;
					this.showData = true ;
					this.isSpinnerLoaded = false;
					this.hasDataRetrieved = true ;
					this.showMessage('', 'The results are retrieved successfully', 'success', 'dismissable') ;
				}
			})
            .catch(error =>{
				this.isSpinnerLoaded = false; 
				this.showData = false ;
				this.data = [];
				this.columns = [];	
				if(this.lineChart){
					this.lineChart.destroy();
				}
                this.showMessage('Error in viewing metrics', error.message, 'error', 'dismissable') ; 
            });
	}

	setUpChartForData(chartLabels, dataSets){
		var dataSetList = [] ;
		for (var dataSetNo = 0; dataSetNo < dataSets.length; dataSetNo++) {					
			var dataSetWrapper = dataSets[dataSetNo] ;
			var dataList = [];
			var dataPointSize = dataSetWrapper.data.length ;
			for(var dataPointNo = 0; dataPointNo < dataPointSize; dataPointNo++){
				var datapointWrapper = dataSetWrapper.data[dataPointNo] ;
				var data = {t: datapointWrapper.t, y: datapointWrapper.y }
				dataList.push(data) ;
			}	
			var colorList = [] ;
			colorList.push(dataSetWrapper.color) ;
			var dataSet = {
				fill: false, label: dataSetWrapper.label, data: dataList,
				backgroundColor: colorList, borderColor: colorList,
				pointBackgroundColor: dataSetWrapper.color, pointBorderColor: dataSetWrapper.color
			}
			dataSetList.push(dataSet) ;			
		}
		this.config = {type: 'line', data: {labels:chartLabels, datasets: dataSetList},  options: {
			responsive: true, legend: { position: 'bottom' , labels: {boxWidth: 15, padding: 15,
			fontSize: 16, fontStyle: 'normal', fontFamily: 'Arial', fontColor: 'black'}}}} ;
		if(this.showChart == true){
			this.loadChartJSOptions() ;
		}
	}

	sortBy(field, reverse, primer){
		const key = primer ?
			function (x) {
				return primer(x[field]);
			} :
			function (x) {
				return x[field];
			};
		return function (a, b) {
			a = key(a);
			b = key(b);
			return reverse * ((a > b) - (b > a));
		};
	}

	onHandleSort(event){
		const {
			fieldName: sortedBy,
			sortDirection
		} = event.detail;
		const cloneData = [...this.data];

		cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		this.data = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
	}

	loadChartJSOptions(){
		Promise.all([
			loadScript(this, chartjs + '/ChartJS/JS/Chart.bundle.min.js')
		]).then(() =>{
			const ctx = this.template.querySelector('canvas.linechart').getContext('2d');
			this.lineChart = new window.Chart(ctx, this.config);
		}).catch(error =>{
			this.isSpinnerLoaded = false; 
			this.showData = false ;
			this.showMessage('Error in loading charts', error.message, 'error', 'dismissable') ;
		});
	}
	
	showMessage(title, message, variant, mode){
		Promise.all([
			loadStyle(this, toastCSS + '/ToastCSS/toast.css') 
		]).then(() =>{
			this.dispatchEvent(new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: mode
			}));
		}).catch(error =>{
			this.isSpinnerLoaded = false; 
			this.showData = false ;
			this.showMessage('Error in loading charts', error.message, 'error', 'sticky') ;
		});
	}
}
