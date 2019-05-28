/**
 * CHANGE HISTORY
 * =============================================================================
 * Date         Name                    Description
 * 2012-01-02   Parthasarathy M       Created
 * 2012-05-09   Srikanth Kuruva       Modified the SOQLs(on contacts) 
                                      Added columns Job_Function__c, MailingCity, 
                                      Work_Direct__c.
 * 2012-08-30   Anshita Sharma        Added list 'Account Hierarchy Training Events'
 * 2017-03-31   Debarghya Sen         Optimized the code as per JIRA STORY: PS0-1  
 * 2017-10-10   Harsha Naik           Created listView Filter condation base on Sub_BU(CRM-5) 
 * 2018-03-12   Seema Nagdev          Added changes for Account Team Member Related list(CRM-12987)  
 * =============================================================================
 */ 
public without sharing class AccountDetailRelatedListView {
    private Account oAccount;    
    public SetActivityClass oActivityHistory{get;set;}
    public SetActivityClass oOpenActivity{get;set;}    
    public boolean IsMasterAccount {get;set;}
    public String relListName{get;set;}
    public List<Opportunity> MasterAccountOpportunities {get;set;}
    public List<Contact> MasterAccountContacts {get;set;}   
    public List<Contact> AccountOnlineContacts {get;set;}
    public List<Contact> AccountBusinessContacts {get;set;}
    public List<user> listAccountTeamMembers {get;set;}
    public List<user> listuserAccounTeamMembers {get;set;}
    public List<Opportunity> AccountOpportunities {get;set;}
    public List<Training_Event__c> MasterAccountTrainingEvents {get;set;}
    Private set<id> setAccountIds;
    public String sortField {get; set;}
    public String order{get; set;}
    public String previousSortField {get; set;}
    public String AccountTeamview {get;set;} // filter select harsha naik.
    //Added for CRM-12987
    public List<AccountTeamMember> accountTeamMembersList {get;set;}
    public List<DispAccTeamMemberWrapper> dispAccTeamlist {get; set;}
    public SetActivityClass oAccTeam{get;set;}  
    public static String sortFieldAccTeam {get; set;}
    public static String orderAccTeam{get; set;}
    
    public AccountDetailRelatedListView(ApexPages.StandardController oController) {
        try {
             if (Test.isRunningTest()) {
               oAccount= [select id, parentID from account where id =:oController.getRecord().id]; 
           }
           else{        
              oController.addFields(new string[]{'Id', 'ParentId'});        
              oAccount = (Account) oController.getRecord(); 
           } 
           listAccountTeamMembers = new List<user>();
           listuserAccounTeamMembers= new list<user>();   
            relListName = ApexPages.currentPage().getParameters().get('RelatedListName');
            MasterAccountOpportunities = new list<opportunity>();        
            MasterAccountContacts =new list<contact>();                  
            AccountBusinessContacts =new list<contact>();
            AccountOnlineContacts =new list<contact>();
            AccountOpportunities = new list<opportunity>();
            MasterAccountTrainingEvents =new list<Training_Event__c>();
            List<sobject> sobjectlist = new list<sobject>();
            oActivityHistory = new SetActivityClass (sobjectlist );
            oOpenActivity = new SetActivityClass (sobjectlist );            
            sortField='a';
            previousSortField ='';
            IsMasterAccount = (oAccount.ParentId == null);
            //Added for CRM-12987
            accountTeamMembersList = new List<AccountTeamMember>();
            dispAccTeamlist = new List<DispAccTeamMemberWrapper>(); 
            oAccTeam = new SetActivityClass (sobjectlist ); 
            //sortFieldAccTeam = 'TerritoryNumber';
            //orderAccTeam = 'asc';
            
            if(relListName != null){
                if (IsMasterAccount) {
                    setAccountIds = AccountDetailController.getChildAccountIds(oAccount.Id);
                    if(relListName == 'Opportunity'){
                        //MasterAccountOpportunities = AccountDetailController.getOpportunities(setAccountIds,3000);
                        MasterAccountOpportunities = AccountDetailController.getOpportunities(setAccountIds,1200); //Added as a part of S2E Optimisation
                    }
                    if(relListName == 'Contact'){                   
                        //MasterAccountContacts = AccountDetailController.getContacts(setAccountIds,3000);
                        MasterAccountContacts = AccountDetailController.getContacts(setAccountIds,1200);//Added as a part of S2E Optimisation
                    }
                    if(relListName == 'OpenActivity'){
                        //oOpenActivity= new SetActivityClass(AccountDetailController.getOpenActivities(setAccountIds,3000,true));
                        oOpenActivity= new SetActivityClass(AccountDetailController.getOpenActivities(setAccountIds,1200,true));//Added as a part of S2E Optimisation
                    }
                    if(relListName == 'ActivityHistory'){
                        //oActivityHistory= new SetActivityClass(AccountDetailController.getActivityHistories(setAccountIds,3000,true));
                        oActivityHistory= new SetActivityClass(AccountDetailController.getActivityHistories(setAccountIds,1200,true));//Added as a part of S2E Optimisation
                    }
                }                
                if(relListName == 'OnlineContact' ){
                     /*AccountOnlineContacts = [SELECT   Id ,Name ,AccountId,Account.Name,LastName ,FirstName ,Title,Email, Phone,
                                    Contact_type__c, SAP_Role__c, Job_Function__c, MailingCity, Work_Direct__c FROM contact WHERE Accountid =:oAccount.id and Class__c='ONLINE' limit 3000];*/
                    AccountOnlineContacts = [SELECT   Id ,Name ,AccountId,Account.Name,LastName ,FirstName ,Title,Email, Phone,
                                    Contact_type__c, SAP_Role__c, Job_Function__c, MailingCity, Work_Direct__c FROM contact WHERE Accountid =:oAccount.id and Class__c='ONLINE' limit 1200]; //Added as a part of S2E Optimisation
                }
                if(relListName == 'BusinessContact'){                   
                     /*AccountBusinessContacts = [SELECT   Id ,Name ,AccountId,Account.Name,LastName ,FirstName ,Title,Email, Phone,
                                    Contact_type__c, SAP_Role__c, Job_Function__c, MailingCity, Work_Direct__c FROM contact WHERE Accountid =:oAccount.id and Class__c='REGULAR' limit 3000];*/
                    AccountBusinessContacts = [SELECT   Id ,Name ,AccountId,Account.Name,LastName ,FirstName ,Title,Email, Phone,
                                    Contact_type__c, SAP_Role__c, Job_Function__c, MailingCity, Work_Direct__c FROM contact WHERE Accountid =:oAccount.id and Class__c='REGULAR' limit 1200];//Added as a part of S2E Optimisation
                }
                if(relListName == 'AccountTeam'){
                    //Updated for CRM-12987
                    /**list<id> listUserIds = new List<id>();
                    for(accountTeamMember aTeam:  [select id,userid from AccountTeamMember where Accountid =:oAccount.id ]){
                        listUserIds.add(aTeam.userID);
                    }
                    listuserAccounTeamMembers=[select id,Rep_Type_Description__c, Name , Email,Sub_Bu__c from user where id in:listUserIds];
                    listAccountTeamMembers.addAll(listuserAccounTeamMembers);**/
                    accountTeamMembersList =  [select id, userid,User.Rep_Type_Description__c, User.Name, User.Sub_Bu__c,User.Business_Unit__c, user.email,user.phone,TeamMemberRole,user.District__c from AccountTeamMember where Accountid =:oAccount.id];
                    oAccTeam = new SetActivityClass(accountTeamMembersList);
                    dispAccTeamlist = getTerrNum(oAccTeam.getRecords(),oAccount.id);
                }    
                 if(relListName == 'AccountOpportunities'){
                    if(ApexPages.CurrentPage().getParameters().get('renewalflg')== 'true'){
                     //AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') and Renewal_Flag__c=true limit 3000];
                     AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') and Renewal_Flag__c=true limit 1200];//Added as a part of S2E Optimisation
                    }else if(ApexPages.CurrentPage().getParameters().get('renewalflg')== 'false'){
                      //AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') and Renewal_Flag__c=false limit 3000];
                      AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') and Renewal_Flag__c=false limit 1200];//Added as a part of S2E Optimisation
                    }else {
                      //AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') limit 3000];
                      AccountOpportunities = [Select Id,Name,AccountId,Account.Name,CloseDate,Stagename,Amount from Opportunity where AccountId=:oAccount.id and RecordTypeId=:ApexPages.CurrentPage().getParameters().get('recordtypeId') limit 1200];//Added as a part of S2E Optimisation
                    }
                }
                if(relListName == 'TrainingEvents'){
                        //MasterAccountTrainingEvents = AccountDetailController.getTrainingEvents(setAccountIds,3000);
                        MasterAccountTrainingEvents = AccountDetailController.getTrainingEvents(setAccountIds,1200);//Added as a part of S2E Optimisation
                    }
            }
        }
        catch (Exception oException) {
            ApexPages.addMessages(oException);
        }
    }
    
    /**
   * standard set controller for AccountTeam
   * 
   *
   */
   //Commented for CRM-12987
    /**public ApexPages.StandardSetController setAccountTeam {
        get {
            if(setAccountTeam == null) {
                setAccountTeam = new ApexPages.StandardSetController(listAccountTeamMembers);
                // sets the number of records in each page set
                setAccountTeam.setPageSize(60);
            }
            return setAccountTeam;
        }
        set;
    }**/
    
      // AccountReamMemeber Filter By Sub_bu CRM-5 
    public list<selectoption> getAccountTeamViews(){
       List<SelectOption> options = new List<SelectOption>();
        String strName=Label.AccountTeamViewFilter;
         if(strName !=null && strName!=''){
           for(String lists:strName.split(',')){
               options.Add(new SelectOption(lists,lists));
           }
          }
      return options;
    }
    //Updated for CRM-12987
    public void FliterAccountteam(){
        accountTeamMembersList.clear();
    /**for(user listuser:listuserAccounTeamMembers){
            if(listuser.Sub_Bu__c==AccountTeamview){
                listAccountTeamMembers.add(listuser);         
            }else{
                if(AccountTeamview=='ALL'){                
                    listAccountTeamMembers.add(listuser);                    
                }                
            }          
       }
       
       //Reset StandardsetController
       setAccountTeam = new ApexPages.StandardSetController(listAccountTeamMembers);
       // sets the number of records in each page set
       setAccountTeam.setPageSize(60);**/
        for(AccountTeamMember  accteam :[select id, userid,User.Rep_Type_Description__c, User.Name, User.Sub_Bu__c,User.Business_Unit__c, user.email,user.phone,TeamMemberRole,user.District__c from AccountTeamMember where Accountid =:oAccount.id]){
            if(accteam.User.Sub_Bu__c==AccountTeamview){
                accountTeamMembersList.add(accteam);         
            }else{
                if(AccountTeamview=='ALL'){                
                    accountTeamMembersList.add(accteam);                    
                }                
            }         
        }
        oAccTeam = new SetActivityClass(accountTeamMembersList);
        dispAccTeamlist = getTerrNum(oAccTeam.getRecords(),oAccount.id);
    }
       
       
    /**
   * To display the list in go to list page
   * 
   *
   * @return   list<user>
   *
   //Commented for CRM-12987
    /**public List<user> getGoToListAccountTeam() {
         return setAccountTeam.getRecords();
    }  **/
   /** public List<DispAccTeamMemberWrapper> getGoToAccTeamList() {
        dispAccTeamlist = getTerrNum(oAccTeam.getRecords(),oAccount.id);
        dispAccTeamlist.sort();
        return dispAccTeamlist;        
    }**/
    
    /**
   * standard set controller for Opportunities
   * 
   *
   */
   public ApexPages.StandardSetController setAccountOpportunities {
        get {
            if(setAccountOpportunities == null) {
                setAccountOpportunities = new ApexPages.StandardSetController(AccountOpportunities);
                // sets the number of records in each page set
                setAccountOpportunities.setPageSize(60);
            }
            return setAccountOpportunities;
        }
        set;
    }
    
    /**
   * To display the list in go to list page
   * 
   *
   * @return   list<Opportunity>
   */

    public List<Opportunity> getGoToListAccountOpportunities() {
         return setAccountOpportunities.getRecords();
    }
     /**
   * standard set controller for contacts
   * 
   *
   */
    public ApexPages.StandardSetController setHierarchyContacts {
        get {
            if(setHierarchyContacts == null) {
                setHierarchyContacts = new ApexPages.StandardSetController(MasterAccountContacts);
                // sets the number of records in each page set
                setHierarchyContacts.setPageSize(60);
            }
            return setHierarchyContacts;
        }
        set;
    }
    
    /**
   * To display the list in go to list page
   * 
   *
   * @return   list<contact>
   */
    public List<contact> getGoToListContacts() {
         return setHierarchyContacts.getRecords();
    }  
    
    
    /**
   * standard set controller for Online contacts
   * 
   *
   */
    public ApexPages.StandardSetController setAccountOnlineContacts {
        get {
            if(setAccountOnlineContacts == null) {
                setAccountOnlineContacts = new ApexPages.StandardSetController(AccountOnlineContacts);
                // sets the number of records in each page set
                setAccountOnlineContacts.setPageSize(60);
            }
            return setAccountOnlineContacts;
        }
        set;
    }
    
    /**
   * To display the list in go to list page
   * 
   *
   * @return   list<contact>
   */
    public List<contact> getGoToListOnlineContacts() {
         return setAccountOnlineContacts.getRecords();
    }
    
    /**
   * standard set controller for Business contacts
   * 
   *
   */
    public ApexPages.StandardSetController setAccountBusinessContacts {
        get {
            if(setAccountBusinessContacts == null) {
                setAccountBusinessContacts = new ApexPages.StandardSetController(AccountBusinessContacts);
                // sets the number of records in each page set
                setAccountBusinessContacts.setPageSize(60);
            }
            return setAccountBusinessContacts;
        }
        set;
    }
    
    /**
   * To display the list in go to list page
   * 
   *
   * @return   list<contact>
   */
    public List<contact> getGoToListBusinessContacts() {
         return setAccountBusinessContacts.getRecords();
    }
    
    /** 
   *Standard set controller for opportunity
   * 
   *@param  list<sobject>
   * @return   list<sobject>
   */
    public ApexPages.StandardSetController setHierarchyOpportunities {
        get {
            if(setHierarchyOpportunities == null) {
                setHierarchyOpportunities = new ApexPages.StandardSetController(MasterAccountOpportunities);
                // sets the number of records in each page set
                setHierarchyOpportunities.setPageSize(60);
            }
            return setHierarchyOpportunities;
        }
        set;
    }
    
     /**
   * To display the list in go to list page
   * 
   *
   * @return   list<opportunity>
   */
     public List<opportunity> getGoToListopportunities() {
         return setHierarchyOpportunities.getRecords();
    }   
    
    
     /** 
   *Standard set controller for Training Events
   * 
   *@param  list<sobject>
   * @return   list<sobject>
   */
    public ApexPages.StandardSetController setHierarchyTrainingEvents {
        get {
            if(setHierarchyTrainingEvents == null) {
                setHierarchyTrainingEvents = new ApexPages.StandardSetController(MasterAccountTrainingEvents);
                // sets the number of records in each page set
                setHierarchyTrainingEvents.setPageSize(60);
            }
            return setHierarchyTrainingEvents;
        }
        set;
    }
    
     /**
   * To display the list in go to list page
   * 
   *
   * @return   list<Training_Event__c>
   */
     public List<Training_Event__c> getGoToListTrainingEvents() {
         return setHierarchyTrainingEvents.getRecords();
    }   
    
    
     /**
   *Standard set controller Not available for Activity related list. Set activity class will act as a standard set controller
   * 
   *
   */
    public class SetActivityClass {
        public integer pagenumber{get;set;}
        public integer totalpages{get;set;}
        public integer pagesize{get;set;}
        public list<sobject> sobjectList{get;set;}
        
         /* *
           *Constructor
           * 
           *@param  list<sobject>
           * 
           **/       
        public SetActivityClass(list<sobject> sobjectList){
        pagenumber =1;
        pagesize = 60;        
        this.sobjectList=sobjectList;        
        totalpages= Integer.valueof(math.ceil((double)sobjectList.size()/(double)pagesize ));
        }
        public boolean gethasprevious(){
          return (pagenumber != 1);
        }
        public boolean gethasnext(){
            return (pagenumber != totalpages);
        }
        public pagereference Previous(){
        if(gethasprevious())
            pagenumber--;
            return null;
        }
        public pagereference next(){
        if(gethasnext())
            pagenumber++;
            return null;
        }
        public list<sobject> getRecords(){
        list<sobject> Sactivity = new list<sobject>();         
            for(integer counter2=(pagenumber-1)*pagesize;counter2<(math.min(pagenumber*pagesize,sobjectList.size()));counter2++){
                Sactivity.add(sobjectList.get(counter2));
            }
            return Sactivity;
        }
            
    }
     
      /**
   *method to display Activity history related list
   * 
   *
   * @return   list<activity history>
   */
    public List<ActivityHistory> getGoToListActivityHistories() {
    return oActivityHistory.getRecords();        
    }
    
     /**
   *method to display Activity history related list
   * 
   *
   * @return   list<open activity>
   */
    public List<OpenActivity> getGoToListOpenActivities() {
    return oOpenActivity.getRecords();        
    }     
    
    public pagereference doSort(){
        order = 'asc';
        if(previousSortField == sortField){
            order = 'desc';
            previousSortField = '';
        }else{
            previousSortField = sortField;
        }
        System.debug('order-->'+order);
        System.debug('previousSortField-->'+previousSortField);
        System.debug('sortField-->'+sortField);
        if(relListName == 'Opportunity'){
           MasterAccountOpportunities = GenericSort.sortList(MasterAccountOpportunities,sortField,order);
            setHierarchyOpportunities = null;
        }
        if(relListName == 'Contact'){                   
            MasterAccountContacts=GenericSort.sortList(MasterAccountContacts,sortField,order);
            setHierarchyContacts = null;
        }
        if(relListName == 'OpenActivity'){
            //oOpenActivity= new SetActivityClass(GenericSort.sortList(AccountDetailController.getOpenActivities(setAccountIds,3000,false),sortField,order));
            oOpenActivity= new SetActivityClass(GenericSort.sortList(AccountDetailController.getOpenActivities(setAccountIds,1200,false),sortField,order)); //Added as a part of S2E Optimisation
        }
        if(relListName == 'ActivityHistory'){
            //oActivityHistory= new SetActivityClass(GenericSort.sortList(AccountDetailController.getActivityHistories(setAccountIds,3000,false),sortField,order));
            oActivityHistory= new SetActivityClass(GenericSort.sortList(AccountDetailController.getActivityHistories(setAccountIds,1200,false),sortField,order)); //Added as a part of S2E Optimisation
        }
         if(relListName == 'OnlineContact' ){
            AccountOnlineContacts=GenericSort.sortList(AccountOnlineContacts,sortField,order);
            setAccountOnlineContacts = null;
        }
         if(relListName == 'BusinessContact'){
            AccountBusinessContacts=GenericSort.sortList(AccountBusinessContacts,sortField,order);
            setAccountBusinessContacts = null;
        } 
        if(relListName == 'AccountTeam'){//Updated for CRM-12987
            //listAccountTeamMembers=GenericSort.sortList(listAccountTeamMembers,sortField,order);
            //setAccountTeam = null;       
            sortFieldAccTeam = sortfield;
            orderAccTeam = order;
            dispAccTeamlist.sort();
        }       
        
        if(relListName == 'AccountOpportunities'){
            AccountOpportunities =GenericSort.sortList(AccountOpportunities,sortField,order);
            setAccountOpportunities = null;
        }        
        if(relListName == 'TrainingEvents'){
           MasterAccountTrainingEvents = GenericSort.sortList(MasterAccountTrainingEvents,sortField,order);
            setHierarchyTrainingEvents = null;
        }
        return null;
    }
    
    public pageReference gotoAccount(){
        return new pageReference('/'+oAccount.ID);
    }
    
   /** Start:Method to fetch the Territory Number for Account Team Member RL- CRM-12987**/
     public static List<DispAccTeamMemberWrapper> getTerrNum(List<AccountTeamMember> listAccountTeamMembers, Id accid){
        List<DispAccTeamMemberWrapper> tempAccTeamWrapList = new List<DispAccTeamMemberWrapper>();
     
        System.debug('listAccountTeamMembers-->'+listAccountTeamMembers);
        System.debug('listAccountTeamMembers-->'+listAccountTeamMembers.size());
        
        Map<id,String> accteamroleMap = new Map<id,String>();
        Map<id,String> accteammemberMap = new Map<id,String>();
        for(AccountTeamMember atm: listAccountTeamMembers){
            accteamroleMap.put(atm.id,atm.TeamMemberRole);
            accteammemberMap.put(atm.id,atm.Userid);
            tempAccTeamWrapList.add(new DispAccTeamMemberWrapper(atm));
            
        }
        System.debug('accteamroleMap-->'+accteamroleMap);
        System.debug('accteammemberMap-->'+accteammemberMap);
        System.debug('dispAccTeamlist1-->'+tempAccTeamWrapList);
        //Map<id,TMS_Territory__c> mapTMSRoleNum = new Map<id,TMS_Territory__c>([Select Territory_ID__c,id,TMS_Territory_Number__c,LCRM_Account_team_role__c from TMS_Territory__c where Account__c =:oAccount.id]);
        Map<id,TMS_Territory__c> mapTMSRoleNum = new Map<id,TMS_Territory__c>();
        for(TMS_Territory__c tms:[Select Territory_ID__c,id,TMS_Territory_Number__c,LCRM_Account_team_role__c from TMS_Territory__c where Account__c =:accid and LCRM_Account_team_role__c IN :accteamroleMap.values()]){
            mapTMSRoleNum.put(tms.Territory_ID__c,tms);
            
        }
        System.debug('mapTMSRoleNum-->'+mapTMSRoleNum);
        System.debug('mapTMSRoleNumValues-->'+mapTMSRoleNum.values());
        System.debug('mapTMSRoleNumKeySet-->'+mapTMSRoleNum.keyset());
        
        List<UserTerritory> userterritorylist = [SELECT Id,TerritoryId,UserId FROM UserTerritory where  UserId IN : accteammemberMap.values()];
        System.debug('userterritorylist-->'+userterritorylist); 
        Map<id,String> dispMap = new Map<id,String>();
        for(UserTerritory useterr : userterritorylist){
            if(mapTMSRoleNum.containsKey(useterr.TerritoryId)){
                dispMap.put(useterr.UserId,mapTMSRoleNum.get(useterr.TerritoryId).TMS_Territory_Number__c);
            }
            
        }
        
        System.debug('dispMap-->'+dispMap);
        for(DispAccTeamMemberWrapper disp: tempAccTeamWrapList){
            if(dispMap.containsKey(disp.UserId)){
                disp.TerritoryNumber = dispMap.get(disp.UserId);
            }
        }
        System.debug('dispAccTeamlist2-->'+tempAccTeamWrapList);
        System.debug('dispAccTeamlist2-->'+tempAccTeamWrapList.size());
        /**for(AccountTeamMember atm:listAccountTeamMembers){
            if(mapTMSRoleNum.)
            
        }**/
       return tempAccTeamWrapList;  
     }
     /**MethodEnd**/
     
    /** Start:Added Wrapper to display Account Team Member RL- CRM-12987**/ 
     public class DispAccTeamMemberWrapper implements Comparable {
         public String TeamMember{get; set;}
         public String PrimaryRepRole{get; set;}
         public String TeamMemberRole{get; set;}
         public String Subbu{get; set;}
         public String Region{get; set;}
         public String Email{get;set;}
         public String District{get;set;}
         public String TerritoryNumber{get;set;}
         public Id UserId{get;set;}
         public Id teamId{get;set;}
           
         public DispAccTeamMemberWrapper(AccountTeamMember accteammem){
            TeamMember = accteammem.User.Name;
            PrimaryRepRole = accteammem.User.Rep_Type_Description__c;
            TeamMemberRole = accteammem.TeamMemberRole;
            Subbu = accteammem.User.Sub_Bu__c;
            Region = accteammem.user.District__c;
            District = accteammem.user.District__c;
            Email = accteammem.user.email;
            UserId = accteammem.userid;
            teamId = accteammem.id; 
            TerritoryNumber  = '';
         }
         
         public  Integer compareTo(Object objToCompare){
           DispAccTeamMemberWrapper compWrap  = (DispAccTeamMemberWrapper) objToCompare;
           System.debug('orderAccTeam-->'+orderAccTeam);
           System.debug('sortFieldAccTeam-->'+sortFieldAccTeam);
            if(orderAccTeam == 'asc'){
                if(sortFieldAccTeam == 'TeamMember'){
                    if (TeamMember == compWrap.TeamMember) return 0;
                    if (TeamMember > compWrap.TeamMember) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'PrimaryRepRole'){
                    if (PrimaryRepRole == compWrap.PrimaryRepRole) return 0;
                    if (PrimaryRepRole > compWrap.PrimaryRepRole) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'TeamMemberRole'){
                    if (TeamMemberRole == compWrap.TeamMemberRole) return 0;
                    if (TeamMemberRole > compWrap.TeamMemberRole) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'TerritoryNumber'){
                    if (TerritoryNumber == compWrap.TerritoryNumber) return 0;
                    if (TerritoryNumber > compWrap.TerritoryNumber) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'Subbu'){
                    if (Subbu == compWrap.Subbu) return 0;
                    if (Subbu > compWrap.Subbu) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'Region'){
                    if (Region == compWrap.Region) return 0;
                    if (Region > compWrap.Region) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'District'){
                    if (District == compWrap.District) return 0;
                    if (District > compWrap.District) return 1;
                    return -1; 
                }
                if(sortFieldAccTeam == 'Email'){
                    if (Email == compWrap.Email) return 0;
                    if (Email > compWrap.Email) return 1;
                    return -1; 
                }
            } else {
                if(sortFieldAccTeam == 'TeamMember'){
                    if (TeamMember == compWrap.TeamMember) return 0;
                    if (TeamMember > compWrap.TeamMember) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'PrimaryRepRole'){
                    if (PrimaryRepRole == compWrap.PrimaryRepRole) return 0;
                    if (PrimaryRepRole > compWrap.PrimaryRepRole) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'TeamMemberRole'){
                    if (TeamMemberRole == compWrap.TeamMemberRole) return 0;
                    if (TeamMemberRole > compWrap.TeamMemberRole) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'TerritoryNumber'){
                    if (TerritoryNumber == compWrap.TerritoryNumber) return 0;
                    if (TerritoryNumber > compWrap.TerritoryNumber) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'Subbu'){
                    if (Subbu == compWrap.Subbu) return 0;
                    if (Subbu > compWrap.Subbu) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'Region'){
                    if (Region == compWrap.Region) return 0;
                    if (Region > compWrap.Region) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'District'){
                    if (District == compWrap.District) return 0;
                    if (District > compWrap.District) return -1;
                    return 1; 
                }
                if(sortFieldAccTeam == 'Email'){
                    if (Email == compWrap.Email) return 0;
                    if (Email > compWrap.Email) return -1;
                    return 1; 
                }
            
            }
            return null;
        }
     }
     /**Wrapper End**/
    
}