public with sharing class AC_JSONCtrl {

   public String getJSON(){
     List<DataWrapper> wrp = new List<DataWrapper>();

     //get params from url
     String searchTerm = Apexpages.currentPage().getParameters().get('q');
     
     system.debug('@@@@'+searchTerm);
     
     String objName = Apexpages.currentPage().getParameters().get('obj');
     system.debug('objName----'+objName);
     List<String> lstFields = new List<String>();
     String label = Apexpages.currentPage().getParameters().get('label');
     system.debug('label----'+label);
     lstFields.add(label);
     String urlDetail = Apexpages.currentPage().getParameters().get('detail');
     system.debug('urlDetail----'+urlDetail);
     String urlWhere = ApexPages.currentPage().getParameters().get('wc');
     System.debug('--urlWhere--'+urlWhere);
     if(urlWhere != null && urlWhere != ''){
       urlWhere = EncodingUtil.urlDecode(urlWhere,'utf-8').trim();
       if(urlWhere.startsWith('and')){
         urlWhere = urlWhere.substring(3);
       }
     }
     String urlLimit = ApexPages.currentPage().getParameters().get('lm');
     if(urlLimit == null || urlLimit == ''){
       urlLimit = '10';
     }

     //add comma-separated detail fields to query and store in separate list for retrieve
     List<String> lstDetail = new List<String>();
     if(urlDetail != null && urlDetail != ''){
       lstDetail = urlDetail.split(',');
       lstFields.addAll(lstDetail);
     }
     String value = Apexpages.currentPage().getParameters().get('value');
      system.debug('value----'+value);
     lstFields.add(value);

     //start building query
     String qry = 'Select ';
     List<String> fieldQry = new List<String>();
     for(String s :lstFields){
       fieldQry.add(s);
     }
     
     if(fieldQry != null && !fieldQry.isEmpty()){
        qry += String.join(fieldQry,','); 
     }
     
        
     qry += ' from ' + objName + ' where ' + label + ' like \'%' + searchTerm + '%\'';
     if(urlWhere != null && urlWhere != ''){
       qry += ' and ' + urlWhere;
     }

     qry+= ' Limit ' + urlLimit;
     System.debug('====>> qry : ' + qry);

     //loop through records to get data
     for(SObject o :Database.query(qry)){
       String thisdetail ='';
       System.debug('*****'+o);

       //since multiple details fields can exist, loop through and store data in list
       //then convert list to comma-separated string for display
       if(urlDetail != null && urlDetail != ''){
         if(lstDetail.size() > 1){
           List<String> dlist = new List<String>();
           for(String d :lstDetail){
             dlist.add((String)o.get(d));
           }
           thisdetail = String.join(dlist,', ');
         }
         else{
           thisdetail = (String) o.get(lstDetail[0]);
         }
       }
       wrp.add(new DataWrapper(((String)o.get(label)), thisdetail, ((String)o.get(value))));
     }

     return JSON.serialize(wrp);
   }

   public class DataWrapper{
     String label, detail, value;

     public DataWrapper(String l, String d, String v){
       label = l; //label of suggestion
       detail = d; //detail of suggestion
       value = v; //the value of what is stored in the input tag. Commonly the Id of the record
     }
   }
}