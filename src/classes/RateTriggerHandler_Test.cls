@isTest
private class RateTriggerHandler_Test {
    
    @isTest static void VerifyRateSequenceNumber() {
        TestDataFactory factory = new TestDataFactory();

        List<Account> accountList = factory.generateAccounts(2);
        insert accountList;

        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accountList, 1);
        insert agreementList;

        List<Rate__c> rateList = new List<Rate__c>();
        
        //Rates for the first Agreement
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_DEVELOPER, 2));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_QA, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY, Constants.ROLE_ARCHITECT_ONSHORE, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_USER_EXPERIENCE, 1));

        //Rates for the second Agreement
        rateList.addAll(factory.generateRateForAgreement(agreementList[1].Id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_DEVELOPER, 3));
        rateList.addAll(factory.generateRateForAgreement(agreementList[1].Id, Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY, Constants.ROLE_DEVELOPER, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[1].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_QA, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[1].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_ARCHITECT_ONSHORE, 1));

        Test.startTest();
        insert rateList;
        Test.stopTest();

        Map<String, Integer> sequenceNumberMap = new Map<String, Integer>();
        String mapKey = '';
        Integer loopCounter = 0;

        //For each Agreement, assemble a Map that sums up the total value of the Sequence Numbers for each Assignment + Type + Role combination
        for(Agreement__c agreement : agreementList) {
            for(Rate__c rate : [SELECT Id, Retainer_Sequence_Number__c, Role__c, Agreement__c, Assignment_Type__c
                                FROM Rate__c
                                WHERE Agreement__c =: agreement.Id]) {
                
                mapKey = rate.Agreement__c + rate.Assignment_Type__c + rate.Role__c;
                if(!sequenceNumberMap.containsKey(mapKey)) {
                    sequenceNumberMap.put(mapKey, Integer.valueOf(rate.Retainer_Sequence_Number__c));
                }
                else {
                    sequenceNumberMap.put(mapKey, sequenceNumberMap.get(mapKey) + Integer.valueOf(rate.Retainer_Sequence_Number__c));
                }
            }

            //Verify the outcomes for the first Agreement
            if(loopCounter == 0) {
                system.assertEquals(3, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_DEVELOPER));
                system.assertEquals(1, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_QA));
                system.assertEquals(null, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + Constants.ROLE_ARCHITECT_ONSHORE));
                system.assertEquals(null, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_USER_EXPERIENCE));
            }
            //Verify the outcomes for the second Agreement
            else if(loopCounter == 1) {
                system.assertEquals(null, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + Constants.ROLE_DEVELOPER));
                system.assertEquals(6, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_DEVELOPER));
                system.assertEquals(null, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + Constants.ROLE_QA));
                system.assertEquals(null, sequenceNumberMap.get(agreement.Id + Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + Constants.ROLE_ARCHITECT_ONSHORE));
            }

            loopCounter++;
        }

        //Now insert some more Rates for the first Agreement, to ensure the trigger properly considers existing data
        rateList = new List<Rate__c>();
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_DEVELOPER, 2));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_NAMEDRESOURCE, Constants.ROLE_QA, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY, Constants.ROLE_USER_EXPERIENCE, 1));
        rateList.addAll(factory.generateRateForAgreement(agreementList[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_PROJECT_LEAD, 1));

        insert rateList;

        //Pick up all the Rates from the first Agreement again, and re-build the same map
        sequenceNumberMap = new Map<String, Integer>(); 
        for(Rate__c rate : [SELECT Id, Retainer_Sequence_Number__c, Role__c, Agreement__c, Assignment_Type__c
                            FROM Rate__c
                            WHERE Agreement__c =: agreementList[0].Id]) {
            
            mapKey = rate.Agreement__c + rate.Assignment_Type__c + rate.Role__c;
            if(!sequenceNumberMap.containsKey(mapKey)) {
                sequenceNumberMap.put(mapKey, Integer.valueOf(rate.Retainer_Sequence_Number__c));
            }
            else {
                sequenceNumberMap.put(mapKey, sequenceNumberMap.get(mapKey) + Integer.valueOf(rate.Retainer_Sequence_Number__c));
            }
        }

        system.assertEquals(10, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_DEVELOPER));
        system.assertEquals(3, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_QA));
        system.assertEquals(null, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + Constants.ROLE_ARCHITECT_ONSHORE));
        system.assertEquals(null, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + Constants.ROLE_ARCHITECT_OFFSHORE));
        system.assertEquals(null, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_USER_EXPERIENCE));
        system.assertEquals(null, sequenceNumberMap.get(agreementList[0].Id + Constants.ASSIGNMENTTYPE_NAMEDRESOURCE + Constants.ROLE_PROJECT_LEAD));
    }
    
    @isTest
    public static void testPreventChangesOnRate(){
        
       /* List<Account> accountList = factory.generateAccounts(2);
        insert accountList;

        List<Agreement__c> agreementList = factory.generateRetainerAgreementsForAccounts(accountList, 1);
        agreementList[0].Valid_Through__c = system.today().addDays(10);
        insert agreementList;
        
        Rate__c rateObj = factory.generateRateForAgreement(agreementList[0].id, 'Time & Materials' , 'Consultant') ;
        insert rateObj;
        
        agreement_rate__C rateAgreement = new agreement_rate__C(); */
    }
}