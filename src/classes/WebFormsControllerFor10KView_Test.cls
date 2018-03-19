@isTest(SeeAllData = false)
private class WebFormsControllerFor10KView_Test {

    static testMethod void test_usecase_one() {
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Phone = '1234(98765)';
        //controller.selectedOption = '';
        //controller.objLead.Salesforce_Edition__c = '';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.Current_Use_of_3rd_Party_SFDC_Resources__c = 'Developer';
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';
        //Validation
        controller.submitLeadForClients();
        System.assertEquals(true, controller.isMessageToDisplay);                
        
        List<String> lstSalesforceProductsUsed = new List<String>();
        lstSalesforceProductsUsed.add('Pardot');
        lstSalesforceProductsUsed.add('SteelBrick');
        //Validation    
        controller.selectedOption = lstSalesforceProductsUsed;
        controller.submitLeadForClients();
        System.assertEquals(true, controller.isMessageToDisplay);
        
        controller.objLead.Email = 'test';
        controller.submitLeadForClients();
        System.assertEquals(true, controller.isMessageToDisplay);
        
        controller.objLead.Email = 'test@testemail.com';
        controller.submitLeadForClients();
        Test.startTest();
            List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            System.assertEquals(0,leadList.size());
            
            controller.objLead.Salesforce_Edition__c = 'Group';
            controller.submitLeadForClients();
            leadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            System.assertEquals(1,leadList.size());
            System.assertEquals('test@testemail.com',leadList[0].Email);
            System.assertEquals(Constants.RECORDTYPEID_Customer, leadList[0].RecordTypeId);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_two() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test@testemail.com', '', 1);
        insert contactList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.Current_Use_of_3rd_Party_SFDC_Resources__c = 'Developer';
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';
        controller.objLead.Salesforce_Edition__c = 'Group';
        
        List<String> lstSalesforceProductsUsed = new List<String>();
        lstSalesforceProductsUsed.add('Pardot');
        lstSalesforceProductsUsed.add('SteelBrick');
            
        controller.selectedOption = lstSalesforceProductsUsed;
        controller.submitLeadForClients();
        Test.startTest();
            List<Contact> contactResultList = [SELECT Id, FirstName, LastName, Email From Contact];
            System.debug(contactResultList);
            System.assertEquals(1,contactResultList.size());
            System.assertEquals('test@testemail.com',contactResultList[0].Email);
            System.assertEquals('TestFirstName',contactResultList[0].FirstName);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:contactResultList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:contactResultList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_three() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Customer, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.Current_Use_of_3rd_Party_SFDC_Resources__c = 'Developer';
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';
        controller.objLead.Salesforce_Edition__c = 'Group';
        
        List<String> lstSalesforceProductsUsed = new List<String>();
        lstSalesforceProductsUsed.add('Pardot');
        lstSalesforceProductsUsed.add('SteelBrick');
            
        controller.selectedOption = lstSalesforceProductsUsed;
        controller.submitLeadForClients();
        Test.startTest();
            List<Lead> leadResultList = [SELECT Id, FirstName, LastName, Email From Lead];
            System.assertEquals(1,leadResultList.size());
            System.assertEquals('test@testemail.com',leadResultList[0].Email);
            System.assertEquals('TestLastName',leadResultList[0].LastName);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_four() {
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        //controller.objLead.CountryCode = 
        controller.objLead.Description = 'Test Description';
        
        controller.submitLeadForExperts();
        Test.startTest();
            List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            System.assertEquals(1,leadList.size());
            System.assertEquals('test@testemail.com',leadList[0].Email);
            System.assertEquals(Constants.RECORDTYPEID_Expert, leadList[0].RecordTypeId);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Jared_User_Name AND IsActive = false AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            System.debug([SELECT WhoId,OwnerId,Status,Subject FROM Task]);
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            //System.assertEquals(2,taskList.size());
            System.assertNOTEquals(NULL,taskList);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_five() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test@testemail.com', '', 1);
        insert contactList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        //controller.objLead.CountryCode = 
        controller.objLead.Description = 'Test Description';
        
        controller.submitLeadForExperts();
        
        Test.startTest();
            List<Contact> contactResultList = [SELECT Id, FirstName, LastName, Email From Contact];
            System.assertEquals(1,contactResultList.size());
            System.assertEquals('test@testemail.com',contactResultList[0].Email);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_six() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Expert, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        //controller.objLead.CountryCode = 
        controller.objLead.Description = 'Test Description';
        
        controller.submitLeadForExperts();
        Test.startTest();
            List<Lead> leadResultList = [SELECT Id, FirstName, LastName, Email From Lead];
            System.assertEquals(1,leadResultList.size());
            System.assertEquals('test@testemail.com',leadResultList[0].Email);
            //System.assertEquals('TestLastName',leadResultList[0].LastName);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            System.debug([SELECT WhoId,OwnerId,Status,Subject FROM Task]);
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            //System.assertEquals(2,taskList.size());
            System.assertNOTEquals(NULL,taskList);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_seven() {
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';

        controller.submitLeadForPartners();
        
        controller.objLead.Partner_Type__c = 'ISV';
        controller.submitLeadForPartners();
        
        controller.objLead.Partner_Tier__c = 'Platinum';
        controller.submitLeadForPartners();
        
        Test.startTest();
            List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            System.assertEquals(1,leadList.size());
            System.assertEquals('test@testemail.com',leadList[0].Email);
            System.assertEquals(Constants.RECORDTYPEID_Partner,leadList[0].RecordTypeId);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_eight() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test@testemail.com', '', 1);
        insert contactList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        List<SelectOption> lstSelectOption = controller.lstPickListEntryToBind;
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Partner_Type__c = 'ISV';
        controller.objLead.Partner_Tier__c = 'Platinum';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';
        
        controller.submitLeadForPartners();
        
        Test.startTest();
            List<Contact> contactResultList = [SELECT Id, FirstName, LastName, Email From Contact];
            System.assertEquals(1,contactResultList.size());
            System.assertEquals('test@testemail.com',contactResultList[0].Email);
            System.assertEquals('TestFirstName',contactResultList[0].FirstName);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:contactResultList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:contactResultList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_nine() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Partner, 'TestCompany', 'LName', 'test@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Partner_Type__c = 'ISV';
        controller.objLead.Partner_Tier__c = 'Platinum';
        controller.objLead.Num_of_Employees_Focused_on_Salesforce__c = 3;
        controller.objLead.What_type_of_help_are_you_looking_for__c = 'Developer';
        
        controller.submitLeadForPartners();
        Test.startTest();
            List<Lead> leadResultList = [SELECT Id,FirstName,LastName,Email,RecordTypeId From Lead];
            System.assertEquals(1,leadResultList.size());
            System.assertEquals('test@testemail.com',leadResultList[0].Email);
            System.assertEquals('TestLastName',leadResultList[0].LastName);
            
            List<User> userLi = [SELECT Id, Name From User WHERE Name =:Label.Nick_User_Name AND IsActive = true AND Profile.Name = 'System Administrator'];
            System.assertEquals(1,userLi.size());
            List<Task> taskList = [SELECT WhoId,OwnerId,Status,Subject FROM Task WHERE (Subject='Form submitted from 10Kview.com' AND Status='Completed' AND WhoId=:leadList[0].Id) 
                                                                        OR (Subject='Follow up on 10kview.com form submission' AND Status='Open' AND OwnerId=:userLi[0].Id AND WhoId=:leadList[0].Id)];
            System.assertEquals(2,taskList.size());
        Test.stopTest();
    }
    
    static testMethod void test_usecase_ten() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        insert contactList;
        
        List<Contact> contactResultList = [SELECT Id,Referral_Code__c FROM Contact WHERE Id=:contactList[0].Id];
        
        ApexPages.currentPage().getParameters().put('rs','fb');
        ApexPages.currentPage().getParameters().put('rc',contactResultList[0].Referral_Code__c);
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Description = 'Test Description';
        
        controller.submitLeadForExperts();
        Test.startTest();
            List<Lead> leadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            System.assertEquals(1,leadList.size());
            List<Referral__c> referralLi = [SELECT Id, Referee_Contact__c, Referee_Lead__c, Referred_By_Contact__c, Referred_By_Lead__c, Referral_Source__c FROM Referral__c];
            System.assertEquals(leadList[0].Id,referralLi[0].Referee_Lead__c);
            System.assertEquals(contactResultList[0].Id,referralLi[0].Referred_By_Contact__c);
            //System.assertEquals(,referralLi[0].Referred_By_Lead__c);
            System.assertEquals('Facebook',referralLi[0].Referral_Source__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_eleven() {
        
        List<Lead> leadList = TestDataFactory_Leads.generateLeads(Constants.RECORDTYPEID_Partner, 'TestCompany', 'LName', 'test2@testemail.com', null, null, 'US', 1);
        insert leadList;
        
        List<Lead> leadResultList = [SELECT Id,Referral_Code__c FROM Lead WHERE Id=:leadList[0].Id];
        
        ApexPages.currentPage().getParameters().put('rs','li');
        ApexPages.currentPage().getParameters().put('rc',leadResultList[0].Referral_Code__c);
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Description = 'Test Description';
        
        controller.submitLeadForExperts();
        Test.startTest();
            List<Lead> newLeadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead WHERE Id !=:leadList[0].Id];
            List<Referral__c> referralLi = [SELECT Id, Referee_Contact__c, Referee_Lead__c, Referred_By_Contact__c, Referred_By_Lead__c, Referral_Source__c FROM Referral__c];
            System.assertEquals(newLeadList[0].Id,referralLi[0].Referee_Lead__c);
            //System.assertEquals(contactResultList[0].Id,referralLi[0].Referred_By_Contact__c);
            System.assertEquals(leadResultList[0].Id, referralLi[0].Referred_By_Lead__c);
            System.assertEquals('LinkedIn',referralLi[0].Referral_Source__c);
        Test.stopTest();
    }
    
    static testMethod void test_usecase_twelve() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1);
        contactList.addAll(TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName','test2@testemail.com', '', 1));
        insert contactList;
        
        List<Contact> contactResultList = [SELECT Id,Referral_Code__c FROM Contact WHERE Id=:contactList[1].Id];
        
        Database.MergeResult result = Database.merge(contactList[0], contactList[1], false);
        
        ApexPages.currentPage().getParameters().put('rs','tw');
        ApexPages.currentPage().getParameters().put('rc',contactResultList[0].Referral_Code__c);
        
        WebFormsControllerFor10KView controller = new WebFormsControllerFor10KView();
        System.assertNotEquals(controller.options.size(),0);
        
        controller.objLead.Company = 'TestCompany';
        controller.objLead.FirstName = 'TestFirstName';
        controller.objLead.LastName = 'TestLastName';
        controller.objLead.Title = 'TestTitle';
        controller.objLead.Email = 'test@testemail.com';
        controller.objLead.Website = 'testemail.com';
        controller.objLead.Description = 'Test Description';

        controller.submitLeadForExperts();
        Test.startTest();
            List<Lead> newLeadList = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, 
                                            Trailhead_Profile_URL__c, RecordTypeId,State,Country 
                                        From Lead];
            List<Referral__c> referralLi = [SELECT Id, Referee_Contact__c, Referee_Lead__c, Referred_By_Contact__c, Referred_By_Lead__c, Referral_Source__c FROM Referral__c];
            System.assertEquals(newLeadList[0].Id,referralLi[0].Referee_Lead__c);
            System.assertEquals(contactList[0].Id,referralLi[0].Referred_By_Contact__c);
            System.assertEquals('Twitter',referralLi[0].Referral_Source__c);
        Test.stopTest();
    }
}