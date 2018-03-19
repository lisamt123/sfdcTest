@isTest
private class ProvisionCommunityUserController_Test{
    
    public static void createTestData() {
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','rajeshkamath123@gmail.com', '', 1);
        insert contactList;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                        'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
    }
    
    @isTest static void test_usecase_one() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, null, 'Record',null, '', 1);
        insert contactList;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
    
        ApexPages.currentPage().getParameters().put('code', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E');
        Apexpages.currentpage().getparameters().put('Id', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('state', contactList[0].Id);
        
        ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
        
        contactList[0].Email = 'rajeshkamath123@gmail.com';
        update contactList;
        
        objPCC = new ProvisionCommunityUserController();
        
        contactList[0].FirstName = 'Test1';
        update contactList;
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            objPCC = new ProvisionCommunityUserController();
            System.assertEquals(contactList[0].Id, objPCC.strContactId);
            System.assertEquals(true, objPCC.isLightningExperience);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_two() {
        createTestData();
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        List<Contact> contactList = [SELECT Id,FirstName,LastName,Email FROM Contact];
        List<User> userList = TestDataFactory_Users.generateUsers(contactList[0].Id, '10K Services Client (License)', true, 1);
        insert userList;
    
        ApexPages.currentPage().getParameters().put('code', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E');
        Apexpages.currentpage().getparameters().put('Id', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('state', contactList[0].Id);
        
        List<PermissionSet> permissionSetList = [Select Id, Name From PermissionSet WHERE Name = 'Community_Projects_Assignments_and_Time_Entries_Experts'];
        System.assertEquals(1, permissionSetList.size());
        
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr) {
            PermissionSetAssignment permissionSetAssign = new PermissionSetAssignment(PermissionSetId = permissionSetList[0].Id, AssigneeId = userList[0].Id);
            insert permissionSetAssign;
            Test.startTest();
                ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
                System.assertEquals(contactList[0].Id, objPCC.strContactId);
                System.assertEquals(1, objPCC.userPermisstionSet.size());
            Test.stopTest();
        }
    }
    
    @isTest static void test_usecase_three() {
        createTestData();
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());

        Test.startTest();
            List<Contact> lstContacts = [SELECT Id,FirstName,LastName,Email FROM Contact];
    
            Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
            ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
    
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();  
    
            objPCC.selectedUserType = 'Services Client';
            objPCC.selectedLoginType = 'Dedicated License';
            objPCC.createCommunityUser();
            
            System.assertEquals(true, objPCC.isUserCreated);
            List<User> userLi = [SELECT Id,Name,UserRoleId,UserRole.Name,accountId FROM User WHERE ContactId =: lstContacts[0].Id];
            System.assertEquals(1, userLi.size());
        
        Test.stopTest();
    }

    @isTest static void test_usecase_four() {
        createTestData();
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());

        Test.startTest();
            List<Contact> lstContacts = [Select Id,FirstName,LastName,Email from contact];
    
            Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
            ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
    
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();  
    
            objPCC.selectedUserType = 'Product Client';
            objPCC.selectedLoginType = 'Dedicated License';
            objPCC.createCommunityUser();
            
            System.assertEquals(true, objPCC.isUserCreated);
            List<User> userLi = [SELECT Id,Name,UserRoleId,UserRole.Name,accountId FROM User WHERE ContactId =: lstContacts[0].Id];
            System.assertEquals(1, userLi.size());

        Test.stopTest();
    }

    @isTest static void test_usecase_five() {
        createTestData();
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());

        Test.startTest();
            List<Contact> lstContacts = [Select Id,FirstName,LastName,Email from contact];
    
            Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
            ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
    
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();  
    
            objPCC.selectedUserType = 'Delivery Expert';
            objPCC.selectedLoginType = 'Dedicated License';
            objPCC.createCommunityUser();
            
            System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        Test.stopTest();    
    }
    
    @isTest static void test_usecase_six() {
        createTestData();
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());

        Test.startTest();
            List<Contact> lstContacts = [Select Id,FirstName,LastName,Email from contact];
    
            Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
            ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
    
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();  
    
            objPCC.selectedLoginType = 'Dedicated License';
            objPCC.createCommunityUser();
            
            objPCC.isUserActive = false;
            objPCC.updateCommunityUser();
            objPCC.isUserActive = true;
            objPCC.updateCommunityUser();
            
            System.assertEquals(true, objPCC.isUserActive);
            
            objPCC.newMethod();
        Test.stopTest();    
    }
    
    @isTest static void test_usecase_seven() {
    
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'acc@testemail.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, null, 'Record',null, '', 1);
        insert contactList;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
    
        ApexPages.currentPage().getParameters().put('code', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E');
        Apexpages.currentpage().getparameters().put('Id', contactList[0].Id);
        ApexPages.currentPage().getParameters().put('state', contactList[0].Id);
        
        
        
        ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
        
        contactList[0].Email = 'rajeshkamath123@gmail.com';
        update contactList;
        
        objPCC = new ProvisionCommunityUserController();
        
        contactList[0].FirstName = 'Test1';
        update contactList;
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            objPCC = new ProvisionCommunityUserController();
            objPCC.SaveTokens();
            objPCC.AuthorizeToGoogle();
            
            System.assertEquals(contactList[0].Id, objPCC.strContactId);
            System.assertEquals(true, objPCC.isLightningExperience);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_eight() {
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        ProvisionCommunityUserController.wrapperUserName objWrapperUserName = new ProvisionCommunityUserController.wrapperUserName(lstContacts[0].FirstName, lstContacts[0].LastName);
        ProvisionCommunityUserController.EmailsWrapper objEmailWrapper = new ProvisionCommunityUserController.EmailsWrapper(lstContacts[0].Email);        
        ProvisionCommunityUserController.PhonesWrapper objPhonesWrapper = new ProvisionCommunityUserController.PhonesWrapper('9876543210', 'mobile');        
        ProvisionCommunityUserController.wrapperUserMessageBody objFieldAssignmentWrapper = new ProvisionCommunityUserController.wrapperUserMessageBody(objWrapperUserName, lstContacts[0].FirstName.trim().substring(0,1)+lstContacts[0].LastName.replaceAll('\\s+', '')+'@10kview-test.com', 'Trekbin1234567', false, new list<ProvisionCommunityUserController.EmailsWrapper>{objEmailWrapper}, new list<ProvisionCommunityUserController.PhonesWrapper>{objPhonesWrapper}, true);
        
        Test.startTest();
            ProvisionCommunityUserController  objPCC = new ProvisionCommunityUserController();
            objPCC.strInputPrimaryEmailFromUI = lstContacts[0].Email;
            objPCC.createUser();
        	System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        	System.assertEquals(false,objPCC.displayCreateUserButton);
        Test.stopTest(); 
    }
    
    @isTest static void test_usecase_nine() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
            
            ProvisionCommunityUserController.wrapperUpdateUserMessageBody  objWrapperUserName = new ProvisionCommunityUserController.wrapperUpdateUserMessageBody (true);
            
            objPCC.suspendUser();
            System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        	System.assertEquals(true, objPCC.displayEnableButton);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_ten() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
            
            ProvisionCommunityUserController.wrapperUpdateUserMessageBody  objWrapperUserName = new ProvisionCommunityUserController.wrapperUpdateUserMessageBody (false);
            
            objPCC.UnsuspendUser();
        	
        	System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        	System.assertEquals(false, objPCC.displayEnableButton);
        Test.stopTest();
    }
    @isTest static void test_usecase_eleven() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
            
            ProvisionCommunityUserController.wrapperUpdateUserMessageBody  objWrapperUserName = new ProvisionCommunityUserController.wrapperUpdateUserMessageBody (false);
            objPCC.getgoogleUsersCMT();
            objPCC.selectedGoogleUsersCMT = 'testGmail@10kview-test.com';
            objPCC.doDataTransferDeleteUser();
            
        	System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        	System.assertEquals(true, objPCC.displayCreateUserButton);
        Test.stopTest();
    }
    
    @isTest static void test_usecase_twelve() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, '', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        
        Test.startTest();
             ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
             ProvisionCommunityUserController.wrapperUserName objWrapperUserName = new ProvisionCommunityUserController.wrapperUserName(lstContacts[0].FirstName, lstContacts[0].LastName);
             ProvisionCommunityUserController.EmailsWrapper objEmailWrapper = new ProvisionCommunityUserController.EmailsWrapper(lstContacts[0].Email);        
             ProvisionCommunityUserController.PhonesWrapper objPhonesWrapper = new ProvisionCommunityUserController.PhonesWrapper('9876543210', 'mobile');        
             ProvisionCommunityUserController.wrapperUserMessageBody objFieldAssignmentWrapper = new ProvisionCommunityUserController.wrapperUserMessageBody(objWrapperUserName, lstContacts[0].LastName.replaceAll('\\s+', '')+'@10kview-test.com', 'Trekbin1234567', false, new list<ProvisionCommunityUserController.EmailsWrapper>{objEmailWrapper}, new list<ProvisionCommunityUserController.PhonesWrapper>{objPhonesWrapper}, true);
            
            objPCC.createUser();
            objPCC.strInputPrimaryEmailFromUI = '';
            lstContacts[0].Phone = '9876543210';
            
            System.assertEquals(lstContacts[0].Id, objPCC.strContactId); 
        Test.stopTest();
    }
    
    @isTest static void test_usecase_thirteen() {
        
        Test.setMock(HttpCalloutMock.class, new MockResponse_GmailDirectoryAPI());
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                                            'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                                            'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                                            null, 'Net 30', 'aagarwal@10kview.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                                            1);
        insert accList;
        
        List<Contact> lstContacts = TestDataFactory_Contacts.generatecontacts(accList, 'Test1', 'Record','aagarwal@10kview.com', '', 1);
        insert lstContacts;
        
        List<GoogleAuthSettings__c> googleAuthLi = TestDataFactory_CustomSettings.generateGoogleAuthSettings('GoogleAuthToken', '45360365731-phc9n6lqkiousd35gj5iqo2masenfspo.apps.googleusercontent.com',
                                                                                    'pkKZJzJMePDFfP_IXaaqvGEB', 'AIzaSyDtYjdhQ8yyAHRochVxDFvvFetrNxx4j9E', '10kview-test.com');
        insert googleAuthLi;
        
        Apexpages.currentpage().getparameters().put('Id', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('state', lstContacts[0].Id);
        ApexPages.currentPage().getParameters().put('sfdcIFrameOrigin', 'test');
        
        Test.startTest();
            ProvisionCommunityUserController objPCC = new ProvisionCommunityUserController();
            
            objPCC.createUser();
            objPCC.selectedUserType = 'Services Client';
            objPCC.selectedLoginType = 'Login Pool';
            objPCC.selectedRoleLevel = 'User';
            
            objPCC.createCommunityUser();
            
            objPCC.selectedUserType = 'Product Client';
            objPCC.selectedLoginType = 'Delivery Expert';
            objPCC.createCommunityUser();
            
            objPCC.selectedUserType = 'Delivery Expert';
            objPCC.selectedLoginType = 'Login Pool';
            objPCC.createCommunityUser();
            
            objPCC.selectedUserType = 'Services & Product Client';
            objPCC.selectedLoginType = 'Dedicated License';
            objPCC.createCommunityUser();
            
            objPCC.selectedUserType = 'Services & Product Client';
            objPCC.selectedLoginType = 'Login Pool';
            objPCC.createCommunityUser();
            
            System.assertEquals(lstContacts[0].Id, objPCC.strContactId);
        Test.stopTest();
    }
}