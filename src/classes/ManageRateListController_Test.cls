/**
@Name           : ManageRateListController_Test
@Dated          : 23 June, 2016
@Author         :
@Description    : This class is used to test ManageRateListController.   
*/

@isTest
public class ManageRateListController_Test{
    @isTest
    public static void ManageRateTest_one(){
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                             'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                             'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                             null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                             1);
        insert accList;

        //Fetch the Contact that is associated with our Community Contact that was inserted
        List<Contact> contactList = TestDataFactory_Contacts.generatecontacts(accList, 'Test contact', 'lastName', '', '', 1);
        insert contactList;

        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_RETAINER, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        agreementList[0].Rate_Structure__c = 'Monthly';
        agreementList[0].Status__c = 'Active';
        insert agreementList;
        
        //Rates for the Agreement
        List<Rate__c> rateList = new List<Rate__c>();
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_USER_EXPERIENCE, 100, 1));
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_QA, 100, 1));
        rateList.addAll(TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY, Constants.ROLE_ARCHITECT_ONSHORE, 100, 1));
        rateList[0].Region__c = 'Antarctica' ;
        rateList[1].Region__c = 'ANZ' ;
        rateList[2].Region__c = 'Asia' ;
        insert rateList;
        
        List<Project__c> projectList = TestDataFactory_Projects.generateProjects(accList[0].Id, 'Test Project', 2);
        insert projectList;
         
        List<Assignment__c> assignmentList = TestDataFactory_Assignments.generateAssignments(projectList[0].Id, contactList[0].Id, rateList[0].Id, 
                                                                              Constants.ASSIGNMENT_STATUS_ACTIVE, Constants.ROLE_DEVELOPER, 
                                                                              Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, true, 100, 1);
        assignmentList[0].Start_Date__c = Date.today().addYears(1);
        assignmentList[0].End_Date__c = Date.today().addYears(2);
        insert assignmentList;
        
        Test.startTest();

            PageReference pageRef = Page.ManageRateList;
            pageRef.getParameters().put('agreeId', agreementList[0].id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(agreementList.get(0));
            ManageRateListController controller = new ManageRateListController(sc);
            
            controller.cancel();
            //to varify list for each section has filled.
            system.assert(controller.rateTMWrapperList.size()>0);
            system.assert(controller.rateRCWrapperList.size()>0);
            system.assert(controller.rateNRWrapperList.size()>0);
            
            //adding & removing row in TM Section
            controller.deletingSectionType = 'TM';
            controller.removingIndex = controller.rateTMWrapperList[1].index;
            controller.rateTMWrapperList[1].rateObj.Role__c = Constants.ROLE_ARCHITECT_ONSHORE;
            controller.roleSelected();
            controller.removeRow();
            controller.rateTMWrapperList[0].rateObj.Hourly_Rate__c = null;
            controller.rateTMWrapperList[0].rateObj.Region__c = 'Asia' ;    
            controller.save();
            
            //verifying multiple rates for a Role.
            controller.rowType = 'TM';
            controller.removingIndex = controller.rateTMWrapperList[1].index;
            controller.rateTMWrapperList[1].rateObj.Role__c = Constants.ROLE_USER_EXPERIENCE;
            controller.rateTMWrapperList[1].rateObj.Hourly_Rate__c = 200;
            controller.rateTMWrapperList[1].rateObj.Region__c = 'Asia' ; 
            controller.roleSelected();
             
            //adding & removing row in RC Section
            controller.rateTMWrapperList[0].rateObj.Hourly_Rate__c = 20;
            controller.deletingSectionType = 'RC';
            controller.removingIndex = controller.rateRCWrapperList[1].index;
            controller.rateRCWrapperList[1].rateObj.Role__c = Constants.ROLE_ARCHITECT_ONSHORE;
            controller.rateRCWrapperList[1].rateObj.Region__c = 'Asia';
            controller.roleSelected();
            controller.removeRow();
            controller.rateRCWrapperList[0].rateObj.Role__c = null;
            controller.rateRCWrapperList[0].rateObj.Region__c = 'Asia' ; 
            controller.save();
            
            controller.rateTMWrapperList[1].rateObj.Role__c = Constants.ROLE_QA;
            controller.rateTMWrapperList[1].rateObj.Region__c = 'Asia';
             
            // to verify error occured for required fields.
            system.assert([select id from rate__C].size() == 3);
            
            controller.rateRCWrapperList[0].rateObj.Role__c = Constants.ROLE_ARCHITECT_ONSHORE;
            controller.rateRCWrapperList[0].rateObj.Hours_Per_Month__c = 2;
            controller.rateRCWrapperList[0].rateObj.Hourly_Rate__c = 20;
            controller.rateRCWrapperList[0].rateObj.Region__c = 'Asia';
            
            //adding & removing row in NR Section.
            controller.deletingSectionType = 'NR';
            controller.removingIndex = controller.rateNRWrapperList[1].index;
            controller.rateNRWrapperList[1].rateObj.Role__c = Constants.ROLE_ARCHITECT_ONSHORE;
            controller.rateNRWrapperList[1].rateObj.Region__c = 'Asia';
            controller.roleSelected();
            controller.removeRow();
            controller.rateNRWrapperList[0].rateObj.Hours_Per_Month__c = 2;
            controller.rateNRWrapperList[0].rateObj.monthly_rate__c = 220;
            controller.rateNRWrapperList[0].rateObj.Number_of_Months__c= null;
            controller.rateNRWrapperList[0].rateObj.Region__c = 'Asia' ;
            controller.save();
            controller.rateNRWrapperList[0].rateObj.Number_of_Months__c= 2;
            controller.save();
            
            // to verify error occured due to correspoding records not present in TM.
            system.assert([select id from rate__C].size() == 3);
            
            controller.rateNRWrapperList[0].rateObj.Role__c = Constants.ROLE_USER_EXPERIENCE;
            controller.rateRCWrapperList[0].rateObj.Role__c = Constants.ROLE_USER_EXPERIENCE;
            controller.rateRCWrapperList[0].rateObj.Region__c = 'Europe';
            controller.save();
            
            controller.rateNRWrapperList[0].rateObj.Hourly_Rate__c = null;
            controller.rateNRWrapperList[1].rateObj.Hourly_Rate__c = null;
            controller.rateNRWrapperList[1].rateObj.Region__c = 'Europe' ;
            controller.save();
            system.assertEquals([select id from rate__c].size(),4);

        Test.stopTest();
    }
    
    @isTest
    public static void ManageRateTest_two(){
        TestDataFactory factory = new TestDataFactory();    
        
        Id partnerClientrecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
        List<Account> accList = TestDataFactory_Accounts.generateAccounts(partnerClientrecordTypeId, 'Test1', 'Prospect', 15, 'code coverage', 'internal',
                                             'App Cloud;Sales Cloud', 'Enterprise', 'ISV', 'Sensitive Information', 'JIRA', 'GotoMeeting', 'Use 10k portal', 
                                             'code quality with code coverage above 75%', 'NDA aggrement', 'United States', '501 test street', 'test city', 'Florida', '90001', null,
                                             null, 'Net 30', 'test@test.com', 'Test-6', 'HELLO WORLD', 'invoicingNotes', 'Partner Client',
                                             1);
        insert accList;

        List<Agreement__c> agreementList = TestDataFactory_Agreements.generateAgreements('Test Agreement 1', accList[0].Id, Constants.RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS, 'Active', Date.newInstance(System.Today().Year(), System.Today().Month() - 1, 1), Date.newInstance(System.Today().Year() + 1, System.Today().Month() - 1, 1) , 1);
        agreementList[0].Rate_Structure__c = null;
        insert agreementList;
        
        List<Rate__c> rateList = TestDataFactory_Rates.generateRateForAgreement(agreementList[0].id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_QA, 100, 1);
        rateList[0].Region__c = 'Europe' ;
        insert rateList;

        List<Invoice__c> invoiceList = TestDataFactory_Invoices.generateInvoices(accList[0].Id, system.today(),system.today().addDays(-2), system.today(), 2, 1);
        invoiceList[0].Billing_Period_Start_Date__c = Date.today() -20 ;
        invoiceList[0].Billing_Period_End_Date__c = Date.today() -10 ;
        insert invoiceList;

        List<Invoice_Line_Item__c> invoiceLineItemList = TestDataFactory_InvoiceLineItems.generateInvoiceLineItems(invoiceList[0].Id, Constants.RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM, rateList[0].id, 2, 30, 1);
        insert invoiceLineItemList;
        
        Test.startTest();

            PageReference pageRef = Page.ManageRateList;
            pageRef.getParameters().put('id', rateList[0].id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(agreementList.get(0));
            ManageRateListController controller = new ManageRateListController(sc);
            ManageRateListController controller1 = new ManageRateListController();
            controller1.cancel();
            
            // to verify read only functionality of Rate that has Invoice line items
            system.assertEquals(controller.rateTMWrapperList[0].isReadOnly , true);

        Test.stopTest();
    }

}