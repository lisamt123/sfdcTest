<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Status_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Set Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Total_Budget</fullName>
        <field>Total_Budget__c</field>
        <formula>IF(ISBLANK(Rate__r.Hourly_Rate__c),IF(  AND(ISBLANK(Rate__r.Monthly_Rate__c),ISBLANK(Rate__r.Number_of_Months__c)) , 0 ,  Rate__r.Monthly_Rate__c  *  Rate__r.Number_of_Months__c   ) ,Rate__r.Hourly_Rate__c *  Planned_Hours__c  )</formula>
        <name>Update Total Budget</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Status to Active</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Assignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Projected</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_to_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Assignment__c.Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Status to Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Assignment__c.Automatically_Close__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Assignment__c.End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Total Budget</fullName>
        <actions>
            <name>Update_Total_Budget</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
