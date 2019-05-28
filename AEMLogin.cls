public class AEMLogin {

    public PageReference AEMLogin() {
        return null;
    }

        public string contactId{get;set;}
    public list<Contact> con{get;set;}
    public AEMLogin() {
        con =[select firstname,lastname,email from contact where id =:contactId];
    }

}