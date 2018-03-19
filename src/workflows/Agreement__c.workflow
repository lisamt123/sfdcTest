<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Agreement_Name</fullName>
        <field>Name</field>
        <formula>IF( AND(Opportunity__c != null ,RecordType.Name !=                &apos;Partnership&apos;) ,
Opportunity__r.Name ,  

Account__r.Name + 
&quot; - &quot; +
RecordType.Name +
&quot; - &quot; +
CASE(MONTH(Effective_Date__c),
1, &quot;Jan&quot;,
2, &quot;Feb&quot;,
3, &quot;Mar&quot;, 
4, &quot;Apr&quot;, 
5, &quot;May&quot;, 
6, &quot;Jun&quot;,
7, &quot;Jul&quot;,
8, &quot;Aug&quot;,
9, &quot;Sep&quot;,
10, &quot;Oct&quot;,
11, &quot;Nov&quot;,
12, &quot;Dec&quot;,
&quot;&quot;) +
&quot; &quot; + 
TEXT(Year(Effective_Date__c)) + 
&quot; to &quot; +
CASE(MONTH(Valid_Through__c),
1, &quot;Jan&quot;,
2, &quot;Feb&quot;,
3, &quot;Mar&quot;, 
4, &quot;Apr&quot;, 
5, &quot;May&quot;, 
6, &quot;Jun&quot;,
7, &quot;Jul&quot;,
8, &quot;Aug&quot;,
9, &quot;Sep&quot;,
10, &quot;Oct&quot;,
11, &quot;Nov&quot;,
12, &quot;Dec&quot;,
&quot;&quot;) +
&quot; &quot; +
TEXT(Year(Valid_Through__c ))  )</formula>
        <name>Set Agreement Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Agreement_Status_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Agreement Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Agreement_Status_to_Expired</fullName>
        <field>Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Set Agreement Status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Rate_Structure_to_Monthly</fullName>
        <field>Rate_Structure__c</field>
        <literalValue>Monthly</literalValue>
        <name>Set Rate Structure to Monthly</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Automatically Activate Agreements</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Agreement__c.Effective_Date__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Agreement_Status_to_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Agreement__c.Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Automatically Expire Agreements</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Agreement__c.Valid_Through__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Agreement_Status_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Agreement__c.Valid_Through__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Maintain Agreement Name Format</fullName>
        <actions>
            <name>Set_Agreement_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &apos;Delivery_Partnership&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Rate Structure On Non-Retainers</fullName>
        <actions>
            <name>Set_Rate_Structure_to_Monthly</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Agreement__c.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Retainer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
