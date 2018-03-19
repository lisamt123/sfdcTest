public with sharing class ExpertAchievementTriggerHandler {
    
    //used in filtering Achievement_Skill__c records
    private static Set<Id> achievementSet = new Set<Id>();
    private static Set<Id> leadAchievementSet = new Set<Id>();
    
    private static Map<Id, Set<Id>> createContactToAchievementMap(List<Expert_Achievement__c> newExpertAchievements) {
        Map<Id, Set<Id>> contactToAchievementMap = new Map<Id, Set<Id>>();
        for( Expert_Achievement__c expertAchievement : newExpertAchievements) {
            //If Expert_Achievement__c record doesn't contain any contact then don't insert expert skills
            if( expertAchievement.Contact__c != null ) {  
                achievementSet.add(expertAchievement.Achievement__c);
                Set<Id> contactAchievementIdSet = new Set<Id>();
                
                if( contactToAchievementMap.containsKey(expertAchievement.Contact__c) ) {
                    contactAchievementIdSet.addAll(contactToAchievementMap.get(expertAchievement.Contact__c));          
                }
                
                contactAchievementIdSet.add(expertAchievement.Achievement__c);
                contactToAchievementMap.put(expertAchievement.Contact__c, contactAchievementIdSet);
            }
        }
        return contactToAchievementMap;     
    }

    private static Map<Id, Set<Id>> createLeadToAchievementMap(List<Expert_Achievement__c> newExpertAchievements) {
        Map<Id, Set<Id>> leadToAchievementMap = new Map<Id, Set<Id>>();
        for( Expert_Achievement__c expertAchievement : newExpertAchievements) {
            //If Expert_Achievement__c record doesn't contain any lead then don't insert expert skills
            if( expertAchievement.Lead__c != null ) {  
                leadAchievementSet.add(expertAchievement.Achievement__c);
                Set<Id> leadAchievementIdSet = new Set<Id>();
                
                if( leadToAchievementMap.containsKey(expertAchievement.Lead__c) ) {
                    leadAchievementIdSet.addAll(leadToAchievementMap.get(expertAchievement.Lead__c));          
                }
                
                leadAchievementIdSet.add(expertAchievement.Achievement__c);
                leadToAchievementMap.put(expertAchievement.Lead__c, leadAchievementIdSet);
            }
        }
        return leadToAchievementMap;     
    }
    
    private static Map<Id, Set<Id>> createAchievementToSkillMap(List<Achievement_Skill__c> achievementSkillList) {
        Map<Id, Set<Id>> achievementToSkillMap = new Map<Id, Set<Id>>();
        if(achievementSkillList != null) {
            for(Achievement_Skill__c achievementSkill :achievementSkillList) {
                Set<Id> achievementSkillIdSet = new Set<Id>();
                
                if( achievementToSkillMap != null && achievementToSkillMap.containsKey(achievementSkill.Achievement__c) ) {
                    achievementSkillIdSet.addAll(achievementToSkillMap.get(achievementSkill.Achievement__c));       
                }
                
                achievementSkillIdSet.add(achievementSkill.Skill__c);
                achievementToSkillMap.put(achievementSkill.Achievement__c, achievementSkillIdSet);      
            }       
        }
        return achievementToSkillMap;
    }
    
    private static Map<Id, Set<Id>> createContactToSkillMap(Map<Id, Set<Id>> achievementToSkillMap, Map<Id, Set<Id>> contactToAchievementMap) {
        Map<Id, Set<Id>> contactToSkillMap = new Map<Id, Set<Id>>();
        for( Id contactId :contactToAchievementMap.keySet()) {
            Set<Id> contactSkillIdSet = new Set<Id>();
            for(Id achievementId : contactToAchievementMap.get(contactId)) {
                if(achievementToSkillMap != null && achievementToSkillMap.containsKey(achievementId)) {
                    contactSkillIdSet.addAll(achievementToSkillMap.get(achievementId));     
                }
            }
            contactToSkillMap.put(contactId, contactSkillIdSet);
        }
        return contactToSkillMap;
    }

    private static Map<Id, Set<Id>> createLeadToSkillMap(Map<Id, Set<Id>> achievementToSkillMap, Map<Id, Set<Id>> leadToAchievementMap) {
        Map<Id, Set<Id>> leadToSkillMap = new Map<Id, Set<Id>>();
        for( Id leadId :leadToAchievementMap.keySet()) {
            Set<Id> leadSkillIdSet = new Set<Id>();
            for(Id achievementId : leadToAchievementMap.get(leadId)) {
                if(achievementToSkillMap != null && achievementToSkillMap.containsKey(achievementId)) {
                    leadSkillIdSet.addAll(achievementToSkillMap.get(achievementId));     
                }
            }
            leadToSkillMap.put(leadId, leadSkillIdSet);
        }
        return leadToSkillMap;
    }
    
    private static Map<Id, Map<Id, Id>> createOldSkillMap(List<Expert_Skill__c> expertSkillList) {
        Map<Id, Map<Id, Id>> oldSkillMap = new Map<Id, Map<Id, Id>>();
        if(expertSkillList != null) {
            for(Expert_Skill__c expertSkill :expertSkillList) {
                Map<Id, Id> contactOldSkillToExpertSkillMap = new Map<Id, Id>();
                if(oldSkillMap.containsKey(expertSkill.Contact__c)) {
                    contactOldSkillToExpertSkillMap.putAll(oldSkillMap.get(expertSkill.Contact__c));
                }
                
                contactOldSkillToExpertSkillMap.put(expertSkill.Skill__c, expertSkill.Id);
                oldSkillMap.put(expertSkill.Contact__c, contactOldSkillToExpertSkillMap);
            }       
        }
        return oldSkillMap;
    }

    private static Map<Id, Map<Id, Id>> createOldLeadSkillMap(List<Expert_Skill__c> expertSkillList) {
        Map<Id, Map<Id, Id>> oldSkillMap = new Map<Id, Map<Id, Id>>();
        if(expertSkillList != null) {
            for(Expert_Skill__c expertSkill :expertSkillList) {
                Map<Id, Id> leadOldSkillToExpertSkillMap = new Map<Id, Id>();
                if(oldSkillMap.containsKey(expertSkill.Lead__c)) {
                    leadOldSkillToExpertSkillMap.putAll(oldSkillMap.get(expertSkill.Lead__c));
                }
                
                leadOldSkillToExpertSkillMap.put(expertSkill.Skill__c, expertSkill.Id);
                oldSkillMap.put(expertSkill.Lead__c, leadOldSkillToExpertSkillMap);
            }       
        }
        return oldSkillMap;
    }
    
    public static void insertExpertSkillsForExpertAchievements(List<Expert_Achievement__c> newExpertAchievements,Set<Id> achievementSkillIdSet) {
        Map<Id, Set<Id>> contactToAchievementMap = createContactToAchievementMap(newExpertAchievements);
        List<Achievement_Skill__c> achievementSkillList = new List<Achievement_Skill__c>();
        List<Expert_Skill__c> expertSkillList = new List<Expert_Skill__c>();
        
        if(achievementSkillIdSet == null) {
            achievementSkillList =  [Select Achievement__c, Skill__c 
                                    From Achievement_Skill__c 
                                    Where Achievement__c IN :achievementSet
                                    LIMIT :Limits.getLimitQueryRows()]; 
        }
        else {
            achievementSkillList =  [Select Achievement__c, Skill__c 
                                    From Achievement_Skill__c 
                                    Where Achievement__c IN :achievementSet
                                        And Id IN : achievementSkillIdSet
                                    LIMIT :Limits.getLimitQueryRows()]; 
        }
        
        Map<Id, Set<Id>> achievementToSkillMap = createAchievementToSkillMap(achievementSkillList); 
        
        //achievementSkillList have no use now
        achievementSkillList = null;
        
            expertSkillList = [Select Id, Contact__c, Skill__c From Expert_Skill__c Where Contact__c IN :contactToAchievementMap.keySet()
                                      LIMIT :Limits.getLimitQueryRows()];   
        
        Map<Id, Set<Id>> contactToSkillMap = createContactToSkillMap(achievementToSkillMap, contactToAchievementMap);
        Map<Id, Map<Id, Id>> oldSkillMap = createOldSkillMap(expertSkillList);
        
        //expertSkillList have no use now 
        expertSkillList = null;

        List<Expert_Skill__c> expertSkillListToInsert = new List<Expert_Skill__c>();
        List<Endorsement__c> increaseEndorsementList = new List<Endorsement__c>();
        List<Endorsement__c> newEndorsementListToInsert = new List<Endorsement__c>();

        for( Id contactId :contactToSkillMap.keySet()) {
            for( Id skillId :contactToSkillMap.get(contactId)) {

                if(oldSkillMap.containsKey(contactId) && oldSkillMap.get(contactId).keySet().contains(skillId)) {
                    
                } else {
                    expertSkillListToInsert.add(new Expert_Skill__c(Contact__c = contactId, Skill__c = skillId));
                }
            }   
        }
        
        insert expertSkillListToInsert;     
       
        for(Expert_Achievement__c expertAchievement : newExpertAchievements) {
            if(achievementToSkillMap.containsKey(expertAchievement.Achievement__c)) {
                for(Id skillId : achievementToSkillMap.get(expertAchievement.Achievement__c)) {
                    if(oldSkillMap.containsKey(expertAchievement.Contact__c) && oldSkillMap.get(expertAchievement.Contact__c).containsKey(skillId)) {
                        increaseEndorsementList.add(new Endorsement__c(Expert_Skill__c = oldSkillMap.get(expertAchievement.Contact__c).get(skillId),Expert_Achievement__c = expertAchievement.Id, Category__c = 'Salesforce Achievement', Endorsed_By__c = Label.X10K_Community_User));
                    }
                    else {
                        for(Integer i = 0 ; i < expertSkillListToInsert.size() ; i++) {
                            if(skillId == expertSkillListToInsert[i].Skill__c && expertAchievement.Contact__c == expertSkillListToInsert[i].Contact__c) {
                                newEndorsementListToInsert.add(new Endorsement__c(Expert_Skill__c = expertSkillListToInsert[i].Id,Expert_Achievement__c = expertAchievement.Id, Category__c = 'Salesforce Achievement', Endorsed_By__c = Label.X10K_Community_User));
                            }
                        }
                    }
                }
            }
        }
       System.debug('newEndorsementListToInsert'+newEndorsementListToInsert);
        insert increaseEndorsementList;
        insert newEndorsementListToInsert; 
    }

    public static void insertExpertSkillsForLeadExpertAchievements(List<Expert_Achievement__c> newExpertAchievements,Set<Id> achievementSkillIdSet) {
        Map<Id, Set<Id>> leadToAchievementMap = createLeadToAchievementMap(newExpertAchievements);
        //[SELECT count() FROM Expert_Achievement__c WHERE Id IN : newExpertAchievements AND IsDeleted = true ALL ROWS];
        List<Achievement_Skill__c> achievementSkillList = new List<Achievement_Skill__c>();
        List<Expert_Skill__c> expertSkillList = new List<Expert_Skill__c>();
        
        if(achievementSkillIdSet == null) {
            achievementSkillList =  [Select Achievement__c, Skill__c 
                                    From Achievement_Skill__c 
                                    Where Achievement__c IN :leadAchievementSet
                                    LIMIT :Limits.getLimitQueryRows()]; 
        }
        else {
            achievementSkillList =  [Select Achievement__c, Skill__c 
                                    From Achievement_Skill__c 
                                    Where Achievement__c IN :leadAchievementSet
                                        And Id IN : achievementSkillIdSet
                                    LIMIT :Limits.getLimitQueryRows()]; 
        }
        
        Map<Id, Set<Id>> achievementToSkillMap = createAchievementToSkillMap(achievementSkillList); 
        
        //achievementSkillList have no use now
        achievementSkillList = null;
        
            expertSkillList = [Select Id, Lead__c, Skill__c From Expert_Skill__c Where Lead__c IN :leadToAchievementMap.keySet()
                                      LIMIT :Limits.getLimitQueryRows()];   
        
        Map<Id, Set<Id>> leadToSkillMap = createLeadToSkillMap(achievementToSkillMap, leadToAchievementMap);
        Map<Id, Map<Id, Id>> oldSkillMap = createOldLeadSkillMap(expertSkillList);
        
        //expertSkillList have no use now 
        expertSkillList = null;

        List<Expert_Skill__c> expertSkillListToInsert = new List<Expert_Skill__c>();
        List<Endorsement__c> increaseEndorsementList = new List<Endorsement__c>();
        List<Endorsement__c> newEndorsementListToInsert = new List<Endorsement__c>();

        for( Id leadId :leadToSkillMap.keySet()) {
            for( Id skillId :leadToSkillMap.get(leadId)) {

                if(oldSkillMap.containsKey(leadId) && oldSkillMap.get(leadId).keySet().contains(skillId)) {
                    
                } else {
                    expertSkillListToInsert.add(new Expert_Skill__c(Lead__c = leadId, Skill__c = skillId));
                }
            }   
        }
        
        insert expertSkillListToInsert;     
       
        for(Expert_Achievement__c expertAchievement : newExpertAchievements) {
            if(achievementToSkillMap.containsKey(expertAchievement.Achievement__c)) {
                for(Id skillId : achievementToSkillMap.get(expertAchievement.Achievement__c)) {
                    if(oldSkillMap.containsKey(expertAchievement.Lead__c) && oldSkillMap.get(expertAchievement.Lead__c).containsKey(skillId)) {
                        increaseEndorsementList.add(new Endorsement__c(Expert_Skill__c = oldSkillMap.get(expertAchievement.Lead__c).get(skillId),Expert_Achievement__c = expertAchievement.Id, Category__c = 'Salesforce Achievement', Endorsed_By__c = Label.X10K_Community_User));
                    }
                    else {
                        for(Integer i = 0 ; i < expertSkillListToInsert.size() ; i++) {
                            if(skillId == expertSkillListToInsert[i].Skill__c && expertAchievement.Lead__c == expertSkillListToInsert[i].Lead__c) {
                                newEndorsementListToInsert.add(new Endorsement__c(Expert_Skill__c = expertSkillListToInsert[i].Id,Expert_Achievement__c = expertAchievement.Id, Category__c = 'Salesforce Achievement', Endorsed_By__c = Label.X10K_Community_User));
                            }
                        }
                    }
                }
            }
        }

        if(!increaseEndorsementList.isEmpty()){
            insert increaseEndorsementList;
        }
        if(!newEndorsementListToInsert.isEmpty()){
            insert newEndorsementListToInsert; 
        }
    }

    public static void preventDuplicateInsertionForLead(List<Expert_Achievement__c> expertAchievementList)
    {
        Map<Id, Set<Id>> leadToAchievementMap = new Map<Id, Set<Id>>();
        Set<Id> leadIdSet = new Set<Id>();
        for(Expert_Achievement__c ea : expertAchievementList)
        {
            leadIdSet.add(ea.Lead__c);
        }

        List<Lead> leadList = [SELECT Id, 
                                (SELECT Id, Achievement__c 
                                    FROM Expert_Achievements__r) 
                                FROM Lead 
                                WHERE Id IN : leadIdSet];

        for(Lead leadRec : leadList)
        {
            Set<Id> achieveSet = leadToAchievementMap.get(leadRec.Id);
            Set<Id> eaSet = new Set<Id>();
            for(Expert_Achievement__c eaRec : leadRec.Expert_Achievements__r)
            {
                eaSet.add(eaRec.Achievement__c);
            }
            leadToAchievementMap.put(leadRec.Id, eaSet);
        }

        for(Expert_Achievement__c eaRec : expertAchievementList)
        {
            if((leadToAchievementMap.get(eaRec.Lead__c)).contains(eaRec.Achievement__c))
            {
                eaRec.Achievement__c.addError('You can\'t select Achievement which already exist.');
            }
        }
    }

    public static void preventDuplicateInsertionForContact(List<Expert_Achievement__c> expertAchievementList)
    {
        Map<Id, Set<Id>> contactToAchievementMap = new Map<Id, Set<Id>>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Expert_Achievement__c ea : expertAchievementList)
        {
            contactIdSet.add(ea.Contact__c);
        }

        List<Contact> contactList = [SELECT Id, 
                                        (SELECT Id, Achievement__c 
                                            FROM Expert_Achievements__r) 
                                        FROM Contact 
                                        WHERE Id IN : contactIdSet];

        for(Contact contactRec : contactList)
        {
            Set<Id> achieveSet = contactToAchievementMap.get(contactRec.Id);
            Set<Id> eaSet = new Set<Id>();
            for(Expert_Achievement__c eaRec : contactRec.Expert_Achievements__r)
            {
                eaSet.add(eaRec.Achievement__c);
            }
            contactToAchievementMap.put(contactRec.Id, eaSet);
        }

        for(Expert_Achievement__c eaRec : expertAchievementList)
        {
            if((contactToAchievementMap.get(eaRec.Contact__c)).contains(eaRec.Achievement__c))
            {
                eaRec.Achievement__c.addError('You can\'t select Achievement which already exist.');
            }
        }
    }

    public static void updateAchievementCountOnLead(List<Expert_Achievement__c> expertAchievementList) {
        Set<Id> leadIdSet = new Set<Id>();
        for(Expert_Achievement__c expertAchievement : expertAchievementList) {
            if(expertAchievement.Lead__c != null) {
                leadIdSet.add(expertAchievement.Lead__c);
            }
        }
        if(leadIdSet.size() > 0) {

            List<Lead> leadsList = [SELECT Id,Achievement_Count__c,
                                        ( SELECT Id,Name 
                                          From Expert_Achievements__r  
                                        )
                                    From Lead 
                                    WHERE Id IN : leadIdSet];
            for(Lead lead : leadsList) {
                lead.Achievement_Count__c = lead.Expert_Achievements__r.size();
            }
            update leadsList;
        }
    }
}