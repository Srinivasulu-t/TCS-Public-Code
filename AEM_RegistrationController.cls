public class AEM_RegistrationController {
    public Lead l{get;set;}
    public AEM_RegistrationController(ApexPages.StandardController controller) {
           l = new Lead();
    }
       public PageReference save(){
        insert l;
        return new PageReference('/'+l.Id);
       }
        public PageReference showProducts(){      
           PageReference pr = new PageReference('/apex/AEM_Products');         
            pr.setRedirect(false);
            return pr;
    }
}