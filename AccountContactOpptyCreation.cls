public class AccountContactOpptyCreation{   
    public static void createAccount(Ecom_OrderRequest.cls_customerDetails leadInfo,Ecom_OrderRequest.cls_storeOrder storeOrder){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<APTSECOM_Store__c> stores =  [ Select Id,name,APTSECOM_Price_List__c,APTSECOM_Adjustment_Amount__c, APTSECOM_Customer_Pricing_Segment__c,APTSECOM_Adjustment_Type__c,APTSECOM_Default_Contract_Term__c,
                                               (Select Id,name,APTSECOM_Category_Hierarchy__c,APTSECOM_Adjustment_Type__c,APTSECOM_Adjustment_Amount__c 
                                                From Store_Price_Adjustments__r 
                                                Where name =: storeOrder.plan )
                                           From APTSECOM_Store__c 
                                           Where name =: storeOrder.storeName Limit 1];

        Account prospectAcc = new Account();
        prospectAcc.RecordTypeId = RecordTypeId;
        prospectAcc.name = leadInfo.organizationName;
        prospectAcc.BillingStreet = leadInfo.address.addressLine1;
        prospectAcc.BillingCity = leadInfo.address.city;
        prospectAcc.BillingState = leadInfo.address.state;
        prospectAcc.BillingCountry = leadInfo.address.country;
        prospectAcc.BillingPostalCode = leadInfo.address.zipCode;
        prospectAcc.Sales_Org__c = 'WEST';
        prospectAcc.Customer_Type__c = 'Organization';
        prospectAcc.Customer_Group__c = stores[0].APTSECOM_Customer_Pricing_Segment__c;
        
        insert prospectAcc;
        System.debug('=============querycount=========createAccount1======' + Limits.getQueries());
        createContact(leadInfo, prospectAcc);
        System.debug('=============querycount=========createAccount2======' + Limits.getQueries());
        createOpportunity(prospectAcc, storeOrder);
         System.debug('=============querycount=========createAccount3======' + Limits.getQueries());
        
    }
     public static void createContact(Ecom_OrderRequest.cls_customerDetails leadInfo, Account prospectAcc){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('S2E').getRecordTypeId();
        
        Contact prospectCon = new Contact();
        prospectCon.RecordTypeId = RecordTypeId;
        prospectCon.accountId = prospectAcc.Id;
        
        prospectCon.firstname = leadInfo.firstName;
        prospectCon.lastname = leadInfo.lastName;
        prospectCon.Email = leadInfo.businessEmail;
        prospectCon.Phone = leadInfo.phoneNumber;
        
        insert prospectCon;
    }
    public static void createOpportunity(Account prospectAcc, Ecom_OrderRequest.cls_storeOrder storeOrder){
        Id priceBookId = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1][0].Id;
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pipeline Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = prospectAcc.Name +' - '+ storeOrder.storeName, AccountId = prospectAcc.Id, Amount = storeOrder.totalPrice,
                                          CloseDate = Date.today().addDays(60), RecordTypeId = recordTypeId, StageName = '75%', Status__c = 'Converted',isDigitalSpearHead__c = TRUE,
                                          Pricebook2Id = priceBookId);
        insert opp; 
        //createOLI(opp, storeOrder, priceBookId); 
        List<Opportunity> optyList = [Select id,name,Ownerid,owner.name,owner.id,AccountId,Account.APTS_Band_Number__c,Account.APTS_eOutput_Eligibilty__c,Status__c,StageName,Renewal_Date__c,RecordTypeId,Campaign_Code__c from Opportunity WHERE Id =: opp.Id];
        if(!optyList.isEmpty()){
          //  List<Apttus_Proposal__Proposal__c> lstProposal = ProposalUtility.proposalCreation(optyList);
          //  ProposalUtility.createCart(lstProposal, storeOrder);
        }
    }
}