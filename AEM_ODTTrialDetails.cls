@RestResource(urlMapping='/AEMTrialDetails/*')
global with Sharing class AEM_ODTTrialDetails {
    
    @HttpPost
    global static void createLead(String firstName, String lastName,
        String email, String company) {
        Lead thisLead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Company = company);
        insert thisLead;
            
        AEMTrialWrapper trialwrapper = new AEMTrialWrapper(thisLead.Trial_ID__c, thisLead.id, 'Data Found');
        //return thisCase.Id;
    } 
    
    global class AEMTrialWrapper{
            //Lead leadDetails;
            String globalTrialID;
        	Id leadID;
            String Message;
            
            AEMTrialWrapper(String globalID,ID lID,String msg){
                this.globalTrialID = globalID; 
                this.leadID =lID; 
                this.Message=msg;
            }
        }     

}