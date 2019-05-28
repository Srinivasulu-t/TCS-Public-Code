/*
======================================================================================================================
TEST CLASS NAME: AccountDetailRelatedListView_Test
======================================================================================================================
PURPOSE:    Validates the functionality provided by the AccountDetailRelatedListView class.

CHANGE HISTORY:
======================================================================================================================
  DATE                  NAME                           DESC

2017-03-31            Karthi                     Optimized the coverage as per JIRA STORY: PS0-1
2018-03-12            Seema                      Updated.
======================================================================================================================
*/
@istest
Public with sharing class AccountDetailRelatedListView_Test{
public static testMethod void testRelatedListController(){
         List<string> relListName = new List<string>{'Contact','OnlineContact','AccountOpportunities','BusinessContact','Opportunity','OpenActivity','ActivityHistory','AccountTeam','TrainingEvents'};
        Account testAcc1 = UnitTest.getAccountInstance();
        Account testAcc2 = UnitTest.getAccountInstance();
        insert testAcc1;        
        insert testAcc2;        
        List<contact> con = new list<contact>();
        for (integer i=0; i < 5; i++) {
            con.add(UnitTest.getContactInstance(testAcc2.id));
        }
        con[0].class__c='ONLINE';
        con[1].class__c='REGULAR';        
        insert con;
        opportunity opp = UnitTest.getOpportunityInstance(testAcc2.id);
        insert opp;
        task oActivty = UnitTest.getTaskInstance(testAcc2.id,true);
        insert oActivty;
        task oActivty2 = UnitTest.getTaskInstance(testAcc2.id,false);
        insert oActivty2; 
        AccountTeamMember oTestTeam = new AccountTeamMember(accountid=testAcc2.id,userid=userinfo.getuserid());
        insert oTestTeam ;
        ApexPages.standardController sc = new ApexPages.standardController(testAcc1);
        ApexPages.standardController sc2 = new ApexPages.standardController(testAcc2);
        Test.StartTest();
        Test.setCurrentPageReference(Page.AccountDetailRelatedListView);       
        testAcc1.parentId= testAcc2.id;
        update testAcc2;
       AccountDetailRelatedListView cont;
        AccountDetailRelatedListView cont2;
        cont = new AccountDetailRelatedListView(sc);       
        for( string rel:relListName ){
          ApexPages.currentPage().getParameters().put('RelatedListName',rel);          
          cont2 = new AccountDetailRelatedListView(sc2);
          system.debug('***'+cont2);          
          cont2.sortfield='id';
          cont2.dosort();                              
        }
       
        cont2.getGoToListOnlineContacts();
        cont2.getGoToListBusinessContacts();
        cont2.getGoToListopportunities();
        cont2.getGoToListContacts();
        cont2.getGoToListActivityHistories();
        cont2.getGoToListOpenActivities();
        cont2.oOpenActivity.next();
        cont2.oOpenActivity.previous();   
        cont2.getGoToListTrainingEvents(); 
        cont2.getGoToListAccountOpportunities();
        //cont2.getGoToListAccountTeam();  //commented for CRM-12987
        cont2.getAccountTeamViews();
        cont2.FliterAccountteam();
        cont2.relListName ='TrainingEvents';
        cont2.DoSort();
        Test.StopTest();
    }    
    
    public static testMethod void testAccounTeamRL()
    {
        List<string> relListName = new List<string>{'AccountTeam'};
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'test', Email='testuser@thomsonreuters.com',EmailEncodingKey ='UTF-8', LastName ='Test User1', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testuser@trpcorelegal.com',isActive = true,Sub_Bu__c ='USL');
        insert u;
                
        System.runAs(u) 
        {
          recordtype accountRT = [select id from recordtype where name ='GLI Account' and sobjecttype='Account' limit 1];
          
       
            Account gliAccount = UnitTest.getAccountInstance();
            gliAccount.Name = 'TestAccount';
            gliAccount.Is_GLI__c = true;
            gliAccount.RecordTypeId=accountRT.Id;
       
            insert gliAccount;
        
            UserTerritory oUserTerritory = [SELECT Id, TerritoryId, UserId FROM UserTerritory WHERE IsActive=true  AND UserId !=null LIMIT 1];
            UserTerritory oUserTerritory2 = [SELECT Id, TerritoryId, UserId FROM UserTerritory WHERE Id !=:oUserTerritory.Id AND IsActive=true  AND UserId !=null LIMIT 1];
        
            User oUser = [SELECT Id, Name,isActive FROM User WHERE Id=:oUserTerritory.UserId ];
            System.debug('oUSer:-'+oUser.id+' '+oUser.isActive);
            if(!oUser.isActive){
                oUser.isActive = true;
                update oUser;
             }
            
            
            
            Territory oTerritory = [SELECT Id, Name,District__c,ParentTerritoryId, Description, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, ForecastUserId, MayForecastManagerShare, CurrencyIsoCode, RestrictOpportunityTransfer,TMS_Market_Segment_Desc__c, TMS_Market_Segment_ID__c, TMS_Parent_Territory_ID__c, TMS_Rep_Function_Desc__c, TMS_Rep_Function_ID__c, TMS_Sales_Force_Desc__c, TMS_Sales_Force_ID__c, TMS_Terr_Num__c, TMS_Territory_ID__c, TMS_New_Sales_Quota_Curr_Yr__c, TMS_Renewal_Sales_Quota_Curr_Yr__c, Region__c, TMS_Sales_Force_Code__c, TMS_Market_Segment_Code__c, TMS_Ref_Function_Code__c FROM Territory WHERE Id=:oUserTerritory.TerritoryId];
        
            Territory oTerritory2 = [SELECT Id, Name,District__c,ParentTerritoryId, Description, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, ForecastUserId, MayForecastManagerShare, CurrencyIsoCode, RestrictOpportunityTransfer, TMS_Market_Segment_Desc__c, TMS_Market_Segment_ID__c, TMS_Parent_Territory_ID__c, TMS_Rep_Function_Desc__c, TMS_Rep_Function_ID__c, TMS_Sales_Force_Desc__c, TMS_Sales_Force_ID__c, TMS_Terr_Num__c, TMS_Territory_ID__c, TMS_New_Sales_Quota_Curr_Yr__c, TMS_Renewal_Sales_Quota_Curr_Yr__c, Region__c, TMS_Sales_Force_Code__c, TMS_Market_Segment_Code__c, TMS_Ref_Function_Code__c FROM Territory WHERE Id=:oUserTerritory2.TerritoryId];
        
            set<ID> oTerritoryID = new set<ID>();
            oTerritoryID.add(oTerritory.Id);
            oTerritoryID.add(oTerritory2.Id);
        
            Group oGroup = [SELECT Id, RelatedId FROM Group WHERE RelatedId=:oTerritory.Id AND Type='Territory' LIMIT 1];
            Group oGroup2 = [SELECT Id, RelatedId FROM Group WHERE RelatedId=:oTerritory2.Id AND Type='Territory' LIMIT 1];
        
            List<AccountShare> accountsharelist = new List<AccountShare>();
        
            AccountShare oAccountShareA = new AccountShare();
            oAccountShareA.AccountId =  gliAccount.Id;
            oAccountShareA.UserOrGroupId = oGroup.Id;
            accountsharelist.add(oAccountShareA);
        
            if(accountsharelist.size()>0)
            {
                insert accountsharelist;            
            }
        
        
            List<AccountTeamMember> members = new list<AccountTeamMember>();
        
            members.add(New AccountTeamMember(AccountId = gliAccount.id, TeamMemberRole = 'ACC-Team-Mem1', UserId= u.Id));
            members.add(New AccountTeamMember(AccountId = gliAccount.id, TeamMemberRole = 'ACC-Team-Mem', UserId= oUser.Id));
                   
            insert members;
        
            List<TMS_Territory__c> lstTMsTerritory = new List<TMS_Territory__c>();
        
            TMS_Territory__c TMS_Terr =new TMS_Territory__c();
            TMS_Terr.Name = 'Test_created by SystemAdmin';
            TMS_Terr.Account__c = gliAccount.id;
            TMS_Terr.Territory_ID__c =oTerritory.id;
            TMS_Terr.TMS_Sales_Force_Desc__c ='ACC';
            TMS_Terr.TMS_Market_Segment_Desc__c='Team';
            TMS_Terr.TMS_Rep_Function_Desc__c ='Mem';
            TMS_Terr.TMS_Territory_Number__c ='1234';
            lstTMsTerritory .add(TMS_Terr);
        
            
        
            TMS_Territory__c TMS_Terr1 =new TMS_Territory__c();
            TMS_Terr1.Name = 'Test_created by SystemAdmin';
            TMS_Terr1.Account__c = gliAccount.id;
            TMS_Terr1.Territory_ID__c =oTerritory.id;
            TMS_Terr1.TMS_Sales_Force_Desc__c ='ACC';
            TMS_Terr1.TMS_Market_Segment_Desc__c='Team';
            TMS_Terr1.TMS_Rep_Function_Desc__c ='Mem1';
            TMS_Terr1.TMS_Territory_Number__c ='1234';
            lstTMsTerritory .add(TMS_Terr1);
        
            TMS_Territory__c TMS_TerrRec1 =new TMS_Territory__c();
            TMS_TerrRec1.Name = 'Test_created by SystemAdmin';
            TMS_TerrRec1.Account__c = gliAccount.id;
            TMS_TerrRec1.TMS_Sales_Force_Desc__c ='ACC';
            TMS_Terr1.Territory_ID__c =oTerritory.id;
            TMS_TerrRec1.TMS_Market_Segment_Desc__c='Team';
            TMS_TerrRec1.TMS_Rep_Function_Desc__c ='Mem1';
            TMS_TerrRec1.TMS_Territory_Number__c ='123';
            lstTMsTerritory .add(TMS_TerrRec1);
        
            if(lstTMsTerritory.size()>0)
            {
                insert lstTMsTerritory ;
            } 
        
            Test.startTest();
            ApexPages.standardController sc = new ApexPages.standardController(gliAccount);
            Test.setCurrentPageReference(Page.AccountDetailRelatedListView);
            AccountDetailRelatedListView ocont1 = new AccountDetailRelatedListView(sc);
            // ApexPages.currentPage().getParameters().put('relListName','AccountTeam');
            for( string rel:relListName ){
              ApexPages.currentPage().getParameters().put('RelatedListName',rel);          
              ocont1 = new AccountDetailRelatedListView(sc);
              system.debug('***'+ocont1);          
              ocont1.sortfield='Subbu';
              ocont1.order = 'asc';
              ocont1.dosort();
              ocont1.order = 'desc';
              ocont1.dosort(); 
              ocont1.sortfield='Email';
              ocont1.order = 'asc';
              ocont1.dosort(); 
              ocont1.order = 'desc';
              ocont1.dosort(); 
              ocont1.sortfield='TeamMemberRole';
              ocont1.order = 'asc';
              ocont1.dosort(); 
              ocont1.order = 'desc';
              ocont1.dosort(); 
            }
            Test.stopTest();
             System.assertEquals('ACC-Team-Mem1', ocont1.dispAccTeamlist[0].TeamMemberRole);  
        }


    }
}