public class AutoCompleteComponentController{

    public String searchTerm{get;set;}
    
    @RemoteAction  
    public static List<AccountWrapper> getSearchSuggestions(String searchString){  
       List<AccountWrapper> accountWrappers = new List<AccountWrapper>();  
       List<List<sObject>> searchObjects = [FIND :searchString + '*' IN ALL FIELDS RETURNING Account (Id, Name)];  
       if(!searchObjects.isEmpty()){  
            for(List<SObject> objects : searchObjects){  
                 for(SObject obj : objects){
                      if(obj.getSObjectType().getDescribe().getName().equals('Account')){  
                           Account acct = (Account)obj;  
                           accountWrappers.add(new AccountWrapper(acct.name, acct.Id));  
                      } 
                 }  
            }  
       }  
       return accountWrappers;  
    }
    
    public class AccountWrapper {  
      public String label { get; set; }  
      public String value { get; set; }  
      public AccountWrapper (String label, String value){  
           this.label = label;  
           this.value = value;  
      }  
  }
  
}