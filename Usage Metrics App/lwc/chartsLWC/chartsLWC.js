import { LightningElement, api, track } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ChartExample extends LightningElement {
    @track isChartJsInitialized;
    chart;

    config = {
        type: 'line',
        data: {
            datasets: [{
                fill: false,
                label: 'Line Dataset',
                data: [{  
                    y:100,
                    x:0
                 },
                 {  
                    y:96,
                    x:10
                 },
                 {  
                    y:93,
                    x:20
                 },
                 {  
                    y:89,
                    x:30
                 },
                 {  
                    y:85,
                    x:50
                 },
                 {  
                    y:80,
                    x:60
                 },
                 {  
                    y:71,
                    x:70
                 },
                 {  
                    y:43,
                    x:80
                 },
                 {  
                    y:19,
                    x:90
                 },
                 {  
                    y:9,
                    x:100
                 },
                 {  
                    y:4,
                    x:110
                 },
                 {  
                    y:2,
                    x:120
                 },
                 {  
                    y:0,
                    x:130
                 },
                 {  
                    y: 140,
                    x:140
                 }
                 
                 ],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)'
                ],
                pointBackgroundColor: 'rgba(255, 99, 132, 0.2)',
                pointBorderColor: 'rgba(255, 99, 132, 1)'
            },
            {
                fill: false,
                label: 'Line Dataset 2',
                data: [{  
                    y:100,
                    x:0
                 },{  
                    y:98,
                    x:10
                 },{  
                    y:95,
                    x:20
                 },{  
                    y:92,
                    x:30
                 },{  
                    y:88,
                    x:50
                 },{  
                    y:84,
                    x:60
                 },{  
                    y:75,
                    x:70
                 },{  
                    y:50,
                    x:80
                 },{  
                    y:25,
                    x:90
                 },{  
                    y:14,
                    x:100
                 },{  
                    y:8,
                    x:110
                 },{  
                    y:5,
                    x:120
                 },{  
                    y:2,
                    x:130
                 }],
                backgroundColor: [
                    '#80aaff'
                ],
                borderColor: [
                    'blue'
                ],
                pointBackgroundColor: '#80aaff',
                pointBorderColor: 'blue'
            }
            ]
        },
        options: {
            title: {
                display: true,
                text: 'Sand Samples Against Comm Weight %.'
            },
            scales: {
                xAxes: [{
                    type: 'linear',
                    ticks: {
                        suggestedMin: 0,
                        suggestedMax: 140,
                        stepSize: 10
                    }
                }],
                yAxes: [{
                    type: 'linear',
                    ticks: {
                        autoSkip: true,
                        suggestedMin: 0,
                        suggestedMax: 100,
                        stepSize: 5,
                        callback: function (value) {
                            return value + '%';
                        }
                    }
                }]
            },
        }
    };

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        this.isChartJsInitialized = true;

        Promise.all([
         //   loadStyle(this, chartjs + '/ChartJS/CSS/Chart.css'),
           // loadStyle(this, chartjs + '/ChartJS/CSS/Chart.css'),
            loadScript(this, chartjs + '/ChartJS/JS/Chart.bundle.min.js'),
            //loadScript(this, chartjs + '/ChartJS/JS/Chart.bundle.js'),
            //loadScript(this, chartjs + '/ChartJS/JS/Chart.js'),
            //loadScript(this, chartjs + '/ChartJS/JS/Chart.min.js')
            
        ]).then(() => {
            const ctx = this.template.querySelector('canvas.linechart').getContext('2d');
            console.log('ctx '+ctx) ;
            console.log('config '+this.config) ;
            console.log('window Chart '+new window.Chart(ctx, this.config)) ;
            this.chart = new window.Chart(ctx, this.config);
            console.log('chart '+this.chart) ;
            console.log('parentNode '+this.chart.canvas.parentNode) ;
            this.chart.canvas.parentNode.style.height = '75%';
            this.chart.canvas.parentNode.style.width = '75%';
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading ChartJS',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

  /*  @api chartjsInitialized = false;
    @api recordId;
    renderedCallback() {
         if (this.chartjsInitialized) {
           return;
          }
         this.chartjsInitialized = true;
         console.log('chartjs loading');
         Promise.all([
            loadScript(this, chartjs + '/ChartJS/JS/Chart.min.js')
         ])
     .then(() => {
         this.Initializechartjs();
     })
     .catch(error => {
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Error loading chartJs',
                 message: error.message,
                 variant: 'error'
             })
         );
     });
    }
 
   Initializechartjs() {
     console.log("loaded");
     //Get the context of the canvas element we want to select
     var ctx = this.template.querySelector(".line-chart");
     var lineChart = new Chart(ctx ,{
         type: 'line',
         data: {
             labels: ['Sunday','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
             datasets: [
                 {
                     label:'Day',
                     data: [110, 290, 150, 250, 500, 420, 100],
                     borderColor:'rgba(62, 159, 222, 1)',
                     fill: false,
                     pointBackgroundColor: "#FFFFFF",
                     pointBorderWidth: 4,
                     pointHoverRadius: 5,
                     pointRadius: 3,
                     bezierCurve: true,
                     pointHitRadius: 10
                 }
             ]
         },
         options: {  
             legend: {
                 position: 'bottom',
                 padding: 10,
             },
             responsive: true
         }
        });
       }*/
}