public without sharing class WebFormsControllerFor10KView {
    
    public Lead objLead						{ get;set; } 
    public boolean isMessageToDisplay		{ get;set; } 
    public String strToast					{ get;set; } 
    public ID existingContactRecordID		{ get;set; }
    public String existingContactRecordName	{ get;set; }
    public ID existingLeadRecordID			{ get;set; }
    public String existingLeadRecordName	{ get;set; }
    public List<SelectOption> options 		{ get;set; }
    public List<String> selectedOption		{ get;set; }
    public String referralCode				{ get;set; }
    public String referralOrigin  			{ get;set; }
    
    private ID leadRecordID;
    
	public WebFormsControllerFor10KView() {
		
		isMessageToDisplay = false;
		strToast = '';
		referralOrigin = ApexPages.currentPage().getParameters().get('rs');
		referralCode = ApexPages.currentPage().getParameters().get('rc');
		System.debug(referralOrigin);
		options = new List<SelectOption>();
		selectedOption = new List<String>();
        
	   Schema.DescribeFieldResult fieldResult = Lead.Salesforce_Products_Used__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple){
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
		
		objLead = new Lead();
	}
	
	//Experts
	public void submitLeadForExperts() {
		
		isMessageToDisplay = false;
		
		strToast = '';
		
		try {			
			Id expertRecordTypeID = Constants.RECORDTYPEID_Expert;
			if(expertRecordTypeID != null) {
				String fields = 'Company,FirstName,LastName,Email,Company,State,Country,Website_Blog_Link__c,Phone,Webassessor_Email__c,Trailhead_User_Id__c,Description';
				Map<String,String> leadToContactfieldsMap = new Map<String,String>();
				leadToContactfieldsMap.put('FirstName','FirstName');
				leadToContactfieldsMap.put('LastName','LastName');
				leadToContactfieldsMap.put('Email','Email');
				leadToContactfieldsMap.put('Description','Description');
				leadToContactfieldsMap.put('Website_Blog__c','Website_Blog_Link__c');
				leadToContactfieldsMap.put('Phone','Phone');
				leadToContactfieldsMap.put('Webassessor_Email__c','Webassessor_Email__c');
				leadToContactfieldsMap.put('LastName','LastName');
				leadToContactfieldsMap.put('Trailhead_User_Id__c','Trailhead_User_Id__c');

				checkEmailAgainstContactORLeadRecords(expertRecordTypeID, 'Expert', '',fields,leadToContactfieldsMap);			
			}			
		}
		catch(Exception e) {		
			strToast = returnExceptionMessage(e);
			isMessageToDisplay = true;
		}		
	}
	
	//Clients
	public void submitLeadForClients() {
		
		isMessageToDisplay = false;
		strToast = '';

		if(selectedOption.size() < 1){
			strToast = 'Please select at least one Product.';
			isMessageToDisplay = true;
			return;
		}
		if(objLead.Salesforce_Edition__c == null){
			strToast = 'Please select a Salesforce Edition.';
			isMessageToDisplay = true;
			objLead.addError('Please select a Salesforce Edition.');
			return;
		}
		objLead.Salesforce_Products_Used__c = '';
		for(String option : selectedOption){
			objLead.Salesforce_Products_Used__c += objLead.Salesforce_Products_Used__c == null ? option.trim() : ';' + option.trim() ;
		}
		try {			
			
			Id customerRecordTypeID = Constants.RECORDTYPEID_Customer;
			if(customerRecordTypeID != null) {	
				String fields = 'Company,FirstName,LastName,Title,Email,Website,Salesforce_Products_Used__c,Salesforce_Edition__c,Num_of_Employees_Focused_on_Salesforce__c,' +
								'Current_Use_of_3rd_Party_SFDC_Resources__c,What_type_of_help_are_you_looking_for__c';

				Map<String,String> leadToContactfieldsMap = new Map<String,String>();
				leadToContactfieldsMap.put('FirstName','FirstName');
				leadToContactfieldsMap.put('LastName','LastName');
				leadToContactfieldsMap.put('Email','Email');
				checkEmailAgainstContactORLeadRecords(customerRecordTypeID, 'Customer', '',fields,leadToContactfieldsMap);
			}	
		} 
		catch(Exception e) {		
			
			strToast = returnExceptionMessage(e);
			isMessageToDisplay = true;
		}
	}
	
	//Partners
	public void submitLeadForPartners() {
		
		isMessageToDisplay = false;
		
		strToast = '';

		if(objLead.Partner_Type__c == null){
			strToast = 'Please select a Partner Type.';
			isMessageToDisplay = true;
			return;
		}
		if(objLead.Partner_Tier__c == null){
			strToast = 'Please select a Partner Tier.';
			isMessageToDisplay = true;
			return;
		}

		try {			
			
			Id partnerRecordTypeID = Constants.RECORDTYPEID_Partner; 
			
			if(partnerRecordTypeID != null) {	
				String leadfields = 'Company,FirstName,LastName,Title,Email,Website,Partner_Type__c,Partner_Tier__c,' + 
								'Num_of_Employees_Focused_on_Salesforce__c,What_type_of_help_are_you_looking_for__c';

				Map<String,String> leadToContactfieldsMap = new Map<String,String>();
				leadToContactfieldsMap.put('FirstName','FirstName');
				leadToContactfieldsMap.put('LastName','LastName');
				leadToContactfieldsMap.put('Email','Email');
				checkEmailAgainstContactORLeadRecords(partnerRecordTypeID, 'SI / ISV','10kview.com',leadfields,leadToContactfieldsMap);
			}
		} 
		catch(DmlException ex){
			strToast = returnExceptionMessage(ex);
			isMessageToDisplay = true;
		}
		catch(Exception e) {		
			
			strToast = returnExceptionMessage(e);
			isMessageToDisplay = true;
		}
	}
	
    private string returnExceptionMessage(Exception e) {
    	
    	String strToastMessage;
    	
    	if(e.getMessage().contains('INVALID_EMAIL_ADDRESS')) {
				
			if(e.getMessage().contains('Webassessor')) {
				
				strToastMessage = 'Please enter a valid email address in the Salesforce Certification Verification Email Address field';
			}
			else {
				
				strToastMessage = 'Please enter a valid email address in the email field';
			}
		}
		else if(e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('Webassessor_Email__c')) {
			
			strToastMessage = 'Please enter a unique email address in the Salesforce Certification Verification Email Address field';
		}
		else {
			
			strToastMessage = String.valueOf(e.getMessage());
		}
		
		return strToastMessage; 		
    }
    
    //Common method
	private void checkEmailAgainstContactORLeadRecords(Id leadRecordTypeID, String strType, String leadSource, String fields, Map<String,String> leadToContactfieldsMap) {
			
		Boolean isError;
		isError = false;
		
		existingContactRecordID = null;
		existingLeadRecordID = null;
		existingContactRecordName = '';
		existingLeadRecordName = '';
		List<String> userNameString = new List<String>();
		userNameString.add(Label.Jared_User_Name);
		userNameString.add(Label.Nick_User_Name);
		Map<String,Id> userNameAndIdMap = new Map<String,Id>();
		for(User selectedUser : [SELECT Id, Name From User WHERE Name IN :userNameString AND Profile.Name = 'System Administrator' AND IsActive = true]){
			userNameAndIdMap.put(selectedUser.Name,selectedUser.Id);
		}
		List<Task> taskList = new List<Task>();
		
		if(objLead.Phone != null) {
			
			Pattern p = Pattern.compile('[-() ]');
			
			String sPhone = p.matcher(objLead.Phone).replaceAll('');
			
			// check length without punctuation
	        /*
	        if (sPhone.length() != 10) {
	        	
	        	isError = true;
			
				isMessageToDisplay = true;
	        	 
        	 	strToast = 'Phone number must have 3 digit area code and 7 digit number';
	        }
	        */
		      
	      	p = Pattern.compile('\\d');
	      	
	      	sPhone = p.matcher(sPhone).replaceAll('');
      	
      		/*
	      	if(sPhone.length() > 0) {
	      		
      			isError = true;
			
				isMessageToDisplay = true;
	        	 
        	 	strToast = 'Phone number must be formatted as (999)999-9999';
	      	}
	      	*/
		}	
			
		List<Contact> lstContactsWithTheMatchedInputEmail = [SELECT Id, FirstName, LastName, Email, Description, Website_Blog__c, Webassessor_Email__c, Twitter_User_Name__c, Trailhead_User_Id__c From Contact WHERE Email = :objLead.Email ORDER BY LastModifiedDate ASC];
		
		
		//Contact Match Found
		if(!lstContactsWithTheMatchedInputEmail.isEmpty()) {
			
			List<Contact> lstMatchedContactsToUpdate = new List<Contact>();	
			
			Contact objContact = lstContactsWithTheMatchedInputEmail[0];
			
			if(objContact.Id != null) {
			
				lstMatchedContactsToUpdate = updateContact(leadToContactfieldsMap,objLead,objContact.Id);
				taskList = createTasks(objContact.Id, strType == 'Expert' ? userNameAndIdMap.get(Label.Jared_User_Name) : userNameAndIdMap.get(Label.Nick_User_Name) , taskList);
			}		
			
			if(!isError) {
			
				if(!lstMatchedContactsToUpdate.isEmpty()) {
					
					update lstMatchedContactsToUpdate;
					
					existingContactRecordID = lstMatchedContactsToUpdate[0].Id;
					existingContactRecordName = lstMatchedContactsToUpdate[0].FirstName+' '+lstMatchedContactsToUpdate[0].LastName;
					
					isMessageToDisplay = true;
						
					strToast = 'Your submission was recorded successfully. Someone will be in touch with you soon.';
				}
				
				if(!taskList.isEmpty()) {
					
					insert taskList;
				}
			}
		}
		else
		{
			List<Lead> lstLeadsWithTheMatchedInputEmail = [SELECT Id, FirstName, LastName, Email, Company, Description, Website_Blog_Link__c, Phone, Webassessor_Email__c, Trailhead_Profile_URL__c, RecordTypeId From Lead WHERE Email = :objLead.Email AND RecordTypeId = :leadRecordTypeID ORDER BY LastModifiedDate ASC];
			
			if(!lstLeadsWithTheMatchedInputEmail.isEmpty()) {
				
				List<Lead> lstMatchedLeadsToUpdate = new List<Lead>();	
			
				Lead objLeadRecordToUpdate = lstLeadsWithTheMatchedInputEmail[0];
			
				if(objLeadRecordToUpdate.Id != null) {
					lstMatchedLeadsToUpdate = updateLead(fields.split(','),objLead,objLeadRecordToUpdate.Id);
					taskList = createTasks(objLeadRecordToUpdate.Id,strType == 'Expert' ? userNameAndIdMap.get(Label.Jared_User_Name) : userNameAndIdMap.get(Label.Nick_User_Name) , taskList);
				}	
				
				if(!isError) {
				
					if(!lstMatchedLeadsToUpdate.isEmpty()) {
						
						update lstMatchedLeadsToUpdate;
						
						existingLeadRecordID = lstMatchedLeadsToUpdate[0].Id;
						existingLeadRecordName = lstMatchedLeadsToUpdate[0].FirstName+' '+lstMatchedLeadsToUpdate[0].LastName;
						
						isMessageToDisplay = true;
						
						strToast = 'Your submission was recorded successfully. Someone will be in touch with you soon.';
					}
	
					if(!taskList.isEmpty()) {
						
						insert taskList;
					}
				}
			}
			else
			{
				objLead.RecordTypeId = leadRecordTypeID;
				if(!String.isBlank(leadSource)){
					objLead.LeadSource = leadSource;
				}
				if(referralCode != null && referralCode != '')
				{
					objLead.LeadSource = 'Employee Referral';
				}
				if(referralOrigin != null && referralOrigin != '')
				{
					if(referralOrigin == 'fb'){
						objLead.Referral_Source__c = 'Facebook';
					}
					else if(referralOrigin == 'li'){
						objLead.Referral_Source__c = 'LinkedIn';
					}
					else if(referralOrigin == 'tw'){
						objLead.Referral_Source__c = 'Twitter';
					}
				}
			
				if(!string.isBlank(strType)) {
					
					objLead.Type__c = strType;
				}
				
				//Specify DML options to ensure the assignment rules are executed
				Database.DMLOptions dmlOpts = new Database.DMLOptions();
				dmlOpts.AssignmentRuleHeader.useDefaultRule = true;
				dmlOpts.EmailHeader.triggerUserEmail = true;
				dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
				objLead.setOptions(dmlOpts);
				
				if(!isError) {

					insert objLead;	

					if(objLead != null) {
						taskList = createTasks(objLead.Id,strType == 'Expert' ? userNameAndIdMap.get(Label.Jared_User_Name) : userNameAndIdMap.get(Label.Nick_User_Name) , taskList);
						
						if(!taskList.isEmpty()) {
						
							insert taskList;
						}
						
						existingLeadRecordID = objLead.Id;
						existingLeadRecordName = objLead.FirstName+' '+objLead.LastName;
							
						isMessageToDisplay = true;

						List<Contact> contactList = [ SELECT Referral_Code__c FROM Contact WHERE Referral_Code__c =: referralCode AND Referral_Code__c != null];
						if(contactList.size() > 0) {
							createReferralRecord(null,objLead.id,contactList[0].id,null);
						}
						List<Lead> leadList = [ SELECT Referral_Code__c FROM Lead WHERE Referral_Code__c =: referralCode AND Referral_Code__c != null];
						if(leadList.size() > 0) {
							createReferralRecord(null,objLead.id,null,leadList[0].id);
						}
						List<Old_Referral_Code__c> oldReferralCodesList = [ SELECT Referral_Code__c,Contact__c,Lead__c FROM Old_Referral_Code__c WHERE Referral_Code__c =: referralCode AND Referral_Code__c != null];
						if(oldReferralCodesList.size() > 0) {
							if(oldReferralCodesList[0].Contact__c != null) {
								createReferralRecord(null,objLead.id,oldReferralCodesList[0].Contact__c,null);
							}
							if(oldReferralCodesList[0].Lead__c != null) {
								createReferralRecord(null,objLead.id,null,oldReferralCodesList[0].Lead__c);
							}
						}	
						strToast = 'Your submission was recorded successfully. Someone will be in touch with you soon.';
						objLead.id = null;
					}
				}
			}
		}
	}

	public List<Lead> updateLead(List<String> fieldsList, Lead selectedLead, Id leadId){
		List<Lead> leadList = new List<Lead>();
		Lead leadToUpdate = new Lead();
		leadToUpdate.put('Id',leadId);
		for(String str: fieldsList){
			leadToUpdate.put(str,selectedLead.get(str));
		}
		leadList.add(leadToUpdate);
		return leadList;
	}

	public List<Contact> updateContact(Map<String,String> leadToContactfieldsMap,Lead selectedLead,Id contactId){
		List<Contact> contactList = new List<Contact>();
		Contact con = new Contact();
		con.put('Id',contactId);
		for(String str: leadToContactfieldsMap.keyset()){
			con.put(str,selectedLead.get(leadToContactfieldsMap.get(str)));
		}
		contactList.add(con);
		return contactList;
	}
	
	public List<Task> createTasks(Id assigne1, Id assigne2, List<Task> taskList){

		taskList.add(new Task(WhoId = assigne1, Status = 'Completed', ActivityDate = system.today(), Subject='Form submitted from 10Kview.com'));
		if(assigne2 != null) {
			taskList.add(new Task(WhoId = assigne1, OwnerId = assigne2, Status = 'Open', Subject='Follow up on 10kview.com form submission'));
		}
		return taskList;
	}
	 
    //Picklist Binded In Partners page
    public List<SelectOption> lstPickListEntryToBind
	{
	    get
	    {
	        List<SelectOption> lstPartnerTierOptions = new List<SelectOption>();
	        
	        Schema.DescribeFieldResult fieldResult = Lead.Partner_Tier__c.getDescribe();
	        
	        List<Schema.PicklistEntry> lstPickListEntry = fieldResult.getPicklistValues();
			
	        for(Schema.PicklistEntry objPLE : lstPickListEntry) {
	        	
	            lstPartnerTierOptions.add(new SelectOption(objPLE.getLabel(), objPLE.getValue()));
	        }
	        
	        return lstPartnerTierOptions;
	    }
	}

	public void createReferralRecord(Id refereeContact,Id refereeLead,Id referredContact,Id referredLead) {
		String refOrg;
		if(referralOrigin != null && referralOrigin != '')
		{
			if(referralOrigin == 'fb'){
				refOrg = 'Facebook';
			}
			else if(referralOrigin == 'li'){
				refOrg = 'LinkedIn';
			}
			else if(referralOrigin == 'tw'){
				refOrg = 'Twitter';
			}
		}
		System.debug(refOrg);
		Referral__c referral = new Referral__c();
		referral.Referee_Contact__c 	= refereeContact;
		referral.Referee_Lead__c 		= refereeLead;
		referral.Referred_By_Contact__c = referredContact;
		referral.Referred_By_Lead__c 	= referredLead;
		if(refOrg != null && refOrg != ''){
			referral.Referral_Source__c  	= refOrg;
		}
		system.debug('==================='+referral);
		insert referral;
	}
}