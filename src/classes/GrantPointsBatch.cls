//                                                              //
// This Batch is written to handle batch job with BatchSize = 1 //
//                                                              //
global class GrantPointsBatch implements Database.Batchable<sObject> 
{
    Id systemRecordTypeId = Schema.SObjectType.Points_Rule__c.RecordTypeInfosByName.get('System Generated').RecordTypeId;
    String query = 'SELECT Id FROM Points_Rule__c WHERE Active__c = true AND Object_API_Name__c != null AND Source_Contact_Field_API_Name__c != null AND RecordTypeId =: systemRecordTypeId '; // WHERE ID = \'a1b2C000000TvS7\' 
    
    global GrantPointsBatch() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Points_Rule__c> pointRulesList) 
    {
        
        String crieteriaBehaviour;
        Id currentPointRuleId = pointRulesList[0].Id;
        
        List<Points_Rule__c> pointRuleList = [SELECT Id, Number_of_Points_Awarded__c, Object_API_Name__c, Source_Contact_Field_API_Name__c, Criteria_Behavior__c, Processing_Error_Message__c,
                                                (SELECT Id, Field_API_Name__c, Field_Value__c, Operator__c FROM Points_Rule_Criteria__r) FROM Points_Rule__c WHERE Id = : currentPointRuleId];
        
        try{
            if((pointRuleList[0].Points_Rule_Criteria__r).size() > 0 )
            {
                Set<String> fieldsToQuery = new Set<String>();
                List<FieldOperatorFieldWrapper> fieldOperatorValueWrappList = new List<FieldOperatorFieldWrapper>();
                fieldsToQuery.add(pointRuleList[0].Source_Contact_Field_API_Name__c);
                String queryString = '';
                String whereClause = ' WHERE ';
                crieteriaBehaviour = pointRuleList[0].Criteria_Behavior__c;
                Datetime dateTimeValue;
                
                for(Points_Rule_Criteria__c pointRuleCriteria : pointRuleList[0].Points_Rule_Criteria__r)
                {
                    Schema.DisplayType fieldDataType = Schema.getGlobalDescribe().get(pointRuleList[0].Object_API_Name__c).getDescribe().fields.getMap().get(pointRuleCriteria.Field_API_Name__c).getDescribe().getType();
                    if(!String.isBlank(pointRuleCriteria.Field_Value__c) && Schema.getGlobalDescribe().get(pointRuleList[0].Object_API_Name__c).getDescribe().fields.getMap().keySet().contains((String)(pointRuleCriteria.Field_Value__c).toLowerCase())) {
                        fieldsToQuery.add(pointRuleCriteria.Field_API_Name__c);
                        fieldsToQuery.add(pointRuleCriteria.Field_Value__c);
                        fieldOperatorValueWrappList.add(new FieldOperatorFieldWrapper(pointRuleCriteria.Field_API_Name__c, fieldDataType, pointRuleCriteria.Operator__c, pointRuleCriteria.Field_Value__c));
                    } else {
                        if(fieldDataType == Schema.DisplayType.DateTime)
                        {
                            Integer day     = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[0].split('/')[0]);
                            Integer month   = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[0].split('/')[1]);
                            Integer year    = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[0].split('/')[2]);
                            Integer hour    = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[1].split(':')[0]);
                            Integer minute  = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[1].split(':')[1]);
                            Integer second  = Integer.valueOf(pointRuleCriteria.Field_Value__c.split(' ')[1].split(':')[2]);
                            dateTimeValue = Datetime.newInstance(year, month, day, hour, minute, second);
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+dateTimeValue.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                        else if(fieldDataType == Schema.DisplayType.Date)
                        {
                            Integer day     = Integer.valueOf(pointRuleCriteria.Field_Value__c.split('/')[0]);
                            Integer month   = Integer.valueOf(pointRuleCriteria.Field_Value__c.split('/')[1]);
                            Integer year    = Integer.valueOf(pointRuleCriteria.Field_Value__c.split('/')[2]);
                            dateTimeValue = Datetime.newInstance(year, month, day);
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+dateTimeValue.format('yyyy-MM-dd')+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                        else if(fieldDataType == Schema.DisplayType.Reference)
                        {
                            if(pointRuleCriteria.Field_Value__c != '' && pointRuleCriteria.Field_Value__c != null ){
                                whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' \''+pointRuleCriteria.Field_Value__c+'\' '+pointRuleList[0].Criteria_Behavior__c+' ';
                            }
                            else{
                                whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+null+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                            }
                        }
                        else if(fieldDataType == Schema.DisplayType.Double || fieldDataType == Schema.DisplayType.Currency || fieldDataType == Schema.DisplayType.Percent)
                        {
                            Double doubleVal = Double.valueOf(pointRuleCriteria.Field_Value__c);
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+doubleVal+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                        else if(fieldDataType == Schema.DisplayType.Integer)
                        {
                            Integer intVal = Integer.valueOf(pointRuleCriteria.Field_Value__c);
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+intVal+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                        else if(fieldDataType == Schema.DisplayType.Boolean)
                        {
                            Boolean boolVal = false;
                            if((pointRuleCriteria.Field_Value__c).equalsIgnoreCase('true')) 
                                boolVal = true;
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' '+boolVal+' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                        else
                        {
                            whereClause += pointRuleCriteria.Field_API_Name__c+' '+pointRuleCriteria.Operator__c+' \''+pointRuleCriteria.Field_Value__c+'\' '+pointRuleList[0].Criteria_Behavior__c+' ';
                        }
                    }
                }
                whereClause = whereClause.removeEnd(crieteriaBehaviour+' ');
                if(whereClause.length() <= 7)
                    whereClause = '' ;
                String fieldsToQueryString = String.join(new List<String>(fieldsToQuery), ', ');
                queryString = 'SELECT ' + fieldsToQueryString + ' FROM ' + pointRuleList[0].Object_API_Name__c + whereClause;
                System.debug(queryString);
                List<sObject> recordList = Database.query(queryString);
                Set<String> sourceRecIdSet = new Set<String>();
                for(Points__c point : [SELECT Id, Source_Record_Id__c FROM Points__c WHERE Points_Rule__c =: currentPointRuleId])
                {
                    sourceRecIdSet.add(point.Source_Record_Id__c);
                }
    
                List<Points__c> pointsList = new List<Points__c>();
                for(sObject record : recordList)
                {
                    sObject obj = record;
                    List<String> objNameList = String.valueOf(pointRuleList[0].Source_Contact_Field_API_Name__c).split('\\.');
                    if(objNameList.size() > 1) {
                        for(Integer count = 0 ; count < objNameList.size() - 1 ; count++) {
                            if(obj != null) {
                                obj = obj.getSObject(objNameList[count]);
                            }
                        }
                    }
                    
                    Boolean crieteriaMet = true;
                    if(!fieldOperatorValueWrappList.isEmpty()) {
                        for(FieldOperatorFieldWrapper wrappObj : fieldOperatorValueWrappList) {
                            System.debug('wrappObj - '+wrappObj);
                            if(wrappObj.fieldDataType == Schema.DisplayType.DateTime) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) == DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) != DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) < DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) <= DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) > DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(DateTime.valueOf(record.get(wrappObj.fieldAPIName)) >= DateTime.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else if(wrappObj.fieldDataType == Schema.DisplayType.Date) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) == Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) != Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) < Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) <= Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) > Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(Date.valueOf(record.get(wrappObj.fieldAPIName)) >= Date.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else if(wrappObj.fieldDataType == Schema.DisplayType.Reference) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) == String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) != String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) < String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) <= String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) > String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) >= String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else if(wrappObj.fieldDataType == Schema.DisplayType.Double || wrappObj.fieldDataType == Schema.DisplayType.Currency || wrappObj.fieldDataType == Schema.DisplayType.Percent) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) == Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) != Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) < Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) <= Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) > Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(Double.valueOf(record.get(wrappObj.fieldAPIName)) >= Double.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else if(wrappObj.fieldDataType == Schema.DisplayType.Integer) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) == Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) != Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) < Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) <= Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) > Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(Integer.valueOf(record.get(wrappObj.fieldAPIName)) >= Integer.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else if(wrappObj.fieldDataType == Schema.DisplayType.Boolean) {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(Boolean.valueOf(record.get(wrappObj.fieldAPIName)) == Boolean.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(Boolean.valueOf(record.get(wrappObj.fieldAPIName)) != Boolean.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            } else {
                                if(wrappObj.operatorSign == '=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) == String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '!=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) != String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) < String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '<=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) <= String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) > String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                } else if(wrappObj.operatorSign == '>=') {
                                    if(!(String.valueOf(record.get(wrappObj.fieldAPIName)) >= String.valueOf(record.get(wrappObj.fieldValue)))) {
                                        crieteriaMet = false;
                                    }
                                }
                            }
                            system.debug('crieteriaMet aasas - '+crieteriaMet);
                        }
                    }
                    System.debug('crieteriaMet - '+crieteriaMet+' and sourceRecIdSet.contains((String)record.get("Id")) - '+sourceRecIdSet.contains((String)record.get('Id')));
                    System.debug('obj - '+obj+' and obj.get(objNameList[objNameList.size() - 1]) - '+obj.get(objNameList[objNameList.size() - 1]));
                    
                    if(crieteriaMet && !sourceRecIdSet.contains((String)record.get('Id')) && obj != null && obj.get(objNameList[objNameList.size() - 1]) != null)
                    {
                        Points__c pointRec = new Points__c();
                        pointRec.Source_Record_Id__c = (String)record.get('Id');
                        pointRec.Contact__c = (String)obj.get(objNameList[objNameList.size() - 1]); 
                        pointRec.Number_of_Points__c = pointRuleList[0].Number_of_Points_Awarded__c;
                        pointRec.Points_Rule__c = currentPointRuleId;
    
                        pointsList.add(pointRec);
                    }
                }
                
                if(!pointsList.isEmpty())
                {
                    insert pointsList;
                }
            }
        }
        catch (exception e){
        
            system.debug(e.getCause()+' : getC : '+e.getLineNumber()+' : getLineNumber : '+e.getMessage()+' : getMessage : '+e.getStackTraceString()+' : getStackTraceString : '+e.getTypeName()+' : getTypeName  : ');
            
            pointRuleList[0].Processing_Error_Message__c = e.getStackTraceString()+' '+e.getMessage();
            pointRuleList[0].Active__c  = false;
            update pointRuleList;
        
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }

    global class FieldOperatorFieldWrapper {
        public String fieldAPIName;
        public Schema.DisplayType fieldDataType;
        public String operatorSign;
        public String fieldValue;

        FieldOperatorFieldWrapper(String fieldAPIName, Schema.DisplayType fieldDataType, String operatorSign, String fieldValue) {
            this.fieldAPIName   = fieldAPIName;
            this.fieldDataType  = fieldDataType;
            this.operatorSign   = operatorSign;
            this.fieldValue     = fieldValue;
        }
    }
    
}