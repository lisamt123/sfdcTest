public with sharing class Constants {

    public static final Id RECORDTYPEID_OPPORTUNITY_SERVICES = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Services Opportunity').RecordTypeId;
    public static final Id RECORDTYPEID_OPPORTUNITY_PRODUCT = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Product Opportunity').RecordTypeId;
    public static final Id RECORDTYPEID_OPPORTUNITY_MSA = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('MSA Opportunity').RecordTypeId;

    public static final Id RECORDTYPEID_RATE_TIMEANDMATERIALS = Schema.SObjectType.Rate__c.RecordTypeInfosByName.get('Time & Materials Rate').RecordTypeId;
    public static final Id RECORDTYPEID_RATE_NAMED_RESOURCE = Schema.SObjectType.Rate__c.RecordTypeInfosByName.get('Named Resource Rate').RecordTypeId;
    public static final Id RECORDTYPEID_RATE_RETAINED_CAPACITY = Schema.SObjectType.Rate__c.RecordTypeInfosByName.get('Retained Capacity Rate').RecordTypeId;

    public static final Id RECORDTYPEID_CONNECTION_PRODICTION = Schema.SObjectType.Connection__c.RecordTypeInfosByName.get('Production/Developer').RecordTypeId;
    public static final Id RECORDTYPEID_CONNECTION_SANDBOX = Schema.SObjectType.Connection__c.RecordTypeInfosByName.get('Sandbox').RecordTypeId;
    public static final Id RECORDTYPEID_CONNECTION_GITHUB = Schema.SObjectType.Connection__c.RecordTypeInfosByName.get('GitHub Repository').RecordTypeId;
    public static final Id RECORDTYPEID_CONNECTION_OTHER = Schema.SObjectType.Connection__c.RecordTypeInfosByName.get('Other').RecordTypeId;

    public static final Id RECORDTYPEID_AGREEMENT_FIXEDFEE = Schema.SObjectType.Agreement__c.RecordTypeInfosByName.get('Fixed Fee SOW').RecordTypeId;
    public static final Id RECORDTYPEID_AGREEMENT_MSA = Schema.SObjectType.Agreement__c.RecordTypeInfosByName.get('MSA').RecordTypeId;
    public static final Id RECORDTYPEID_AGREEMENT_RETAINER = Schema.SObjectType.Agreement__c.RecordTypeInfosByName.get('Retainer').RecordTypeId;
    public static final Id RECORDTYPEID_AGREEMENT_DELIVERYPARTER = Schema.SObjectType.Agreement__c.RecordTypeInfosByName.get('Delivery Partnership').RecordTypeId;
    public static final Id RECORDTYPEID_AGREEMENT_TIMEANDMATERIALS = Schema.SObjectType.Agreement__c.RecordTypeInfosByName.get('Time & Materials SOW').RecordTypeId;

    public static final Id RECORDTYPEID_INVOICE_10KSERVICESINVOICE = Schema.SObjectType.Invoice__c.RecordTypeInfosByName.get('10K Services Invoice').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_10KPRODUCTINVOICE = Schema.SObjectType.Invoice__c.RecordTypeInfosByName.get('10K Product Invoice').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE = Schema.SObjectType.Invoice__c.RecordTypeInfosByName.get('Delivery Partner Invoice').RecordTypeId;

    public static final Id RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM = Schema.SObjectType.Invoice_Line_Item__c.RecordTypeInfosByName.get('10K Services Invoice Line Item').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_10KPRODUCTNVOICELINEITEM = Schema.SObjectType.Invoice_Line_Item__c.RecordTypeInfosByName.get('10K Product Invoice Line Item').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM = Schema.SObjectType.Invoice_Line_Item__c.RecordTypeInfosByName.get('10K Goodwill Invoice Line Item').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_10KCREDITINVOICELINEITEM = Schema.SObjectType.Invoice_Line_Item__c.RecordTypeInfosByName.get('10K Credit Invoice Line Item').RecordTypeId;
    public static final Id RECORDTYPEID_INVOICE_10KEXPENSEINVOICELINEITEM = Schema.SObjectType.Invoice_Line_Item__c.RecordTypeInfosByName.get('10K Expense Invoice Line Item').RecordTypeId;
    
    public static final Id RECORDTYPEID_Achievement = Schema.SObjectType.Achievement__c.RecordTypeInfosByName.get('Trailhead Badge').RecordTypeId;
    
    public static final Id RECORDTYPEID_Expert = Schema.SObjectType.Lead.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
    public static final Id RECORDTYPEID_Customer = Schema.SObjectType.Lead.RecordTypeInfosByName.get('Direct Client').RecordTypeId;
    public static final Id RECORDTYPEID_Partner = Schema.SObjectType.Lead.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
    
    public static final Id RECORDTYPEID_Account_DeliveryPartner = Schema.SObjectType.Account.RecordTypeInfosByName.get('Delivery Partner').RecordTypeId;
    public static final Id RECORDTYPEID_Account_DirectClient = Schema.SObjectType.Account.RecordTypeInfosByName.get('Direct Client').RecordTypeId;
    public static final Id RECORDTYPEID_Account_PartnerClient = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client').RecordTypeId;
    public static final Id RECORDTYPEID_Account_PartnerClientDeliveryPartner = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner Client & Delivery Partner').RecordTypeId;
    
    public static final String ASSIGNMENTTYPE_TIMEANDMATERIALS = 'Time & Materials';
    public static final String ASSIGNMENTTYPE_RETAINEDCAPACITY = 'Retained Capacity';
    public static final String ASSIGNMENTTYPE_NAMEDRESOURCE = 'Named Resource';
    
    public static final String ASSIGNMENT_STATUS_PROJECTED = 'Projected';
    public static final String ASSIGNMENT_STATUS_ACTIVE = 'Active';
    public static final String ASSIGNMENT_STATUS_CLOSED = 'Closed';

    public static final String ROLE_ARCHITECT_ONSHORE = 'Architect';
    public static final String ROLE_ARCHITECT_OFFSHORE = 'Architect';
    public static final String ROLE_CONSULTANT = 'Consultant';
    public static final String ROLE_DEVELOPER = 'Developer';
    public static final String ROLE_QA = 'QA';
    public static final String ROLE_PROJECT_LEAD = 'Technical Lead';
    public static final String ROLE_USER_EXPERIENCE = 'User Experience';
    
    public static final String OPP_STAGE_CLOSED_WON = 'Closed Won';

    public static final String PROJECT_STATUS_PROJECTED = 'Projected';

    public static final String SEND_INVOICE_EMAILTEMPLATE_NAME = 'Send_Invoice';
    public static final String INVOICE_BRANDING_10K_ADVISORS = '10K Advisors';
    public static final String INVOICE_BRANDING_TREKBIN = 'Trekbin';
    
    //Error Message Constants
    public static final String ERROR_NO_AGREEMENT = 'No Agreement Exists!';
    public static final String ERROR_NO_BILLING_CONTACT = 'No Billing Contact Exists!';
    public static final String ERROR_NO_EMAIL_ID = 'No Email Id Found!';
    public static final String ERROR_NO_EMAIL_TEMPLATE = 'No Email Template Found!';
    public static final String ERROR_NO_INVOICE = 'Invoice Not Found!';
    public static final String ERROR_DUPLICATE_AGREEMENT_FOR_PROJECT = 'Duplicate agreement for project!';
    public static final String ERROR_REQUIRED_FIELDS = 'Please provide a value in all fields marked as Required';
    public static final String ERROR_REQUIRED_COST_RATE_FIELDS = 'Please select an Agrement for each Assignment that has a rate value defined for the role.';
    public static final String ERROR_MULTIPLE_TM_RATES = 'Multiple Time & Materials Rates were specified for the following Roles: ';
    // Added By Aks
    public static final String ERROR_SAME_TM_RATES = 'You cannot have the following identical Time & Materials Rates: ';
    
    public static final String ERROR_MULTIPLE_RETAINED_CAPACITY_RATES = 'Multiple Retained Capacity Rates were specified for the following Roles: ';
    public static final String ERROR_RETAINED_CAPACITY_ROLE_MUST_HAVE_CORRESPONDING_TM = 'Each Retained Capacity Role must have a corresponding Time & Materials Rate';
    public static final String ERROR_NAMED_RESOURCE_ROLE_MUST_HAVE_CORRESPONDING_TM = 'Each Named Resource Role must have a corresponding Time & Materials Rate';
    public static final String ERROR_NO_PROJECT_AGREEMENTS = 'There are no Project Agreements related to this Project. Please assign at least one Agreement to the Project before managing Assignments.';
    public static final String ERROR_NO_PROJECT_AGREEMENTS_FOR_COST = 'There are no Project Agreements related to this Project. Please assign at least one Agreement to the Project before managing Cost.';
    
    //Email success Message
    public static final String EMAIL_STATUS_SUCCESS = 'Email Sent Successfully!';
   
}