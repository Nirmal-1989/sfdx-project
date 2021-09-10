public with sharing class UsageMetricsLWCController {
    
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> retrieveChartTypeOptions() {     
        List<OptionWrapper> cityTypeOptions = new List<OptionWrapper>(); 
        cityTypeOptions.add(new OptionWrapper(''+System.Label.UM_totalVFPageViews, ''+System.Label.UM_totalVFPageViews));
        cityTypeOptions.add(new OptionWrapper(''+System.Label.UM_top5VFPages, ''+System.Label.UM_top5VFPages));
        cityTypeOptions.add(new OptionWrapper(''+System.Label.UM_totalRecordCount, ''+System.Label.UM_totalRecordCount)); 
        cityTypeOptions.add(new OptionWrapper(''+System.Label.UM_top5ObjCount, ''+System.Label.UM_top5ObjCount)); 
        
        return cityTypeOptions;
    }

    public class OptionWrapper{
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}