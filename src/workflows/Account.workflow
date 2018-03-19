<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Service_Status_Active_Date_to_Today</fullName>
        <field>Service_Status_Active_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Service Status Active Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Service_Status_Former_Date_to_Null</fullName>
        <field>Service_Status_Former_Date__c</field>
        <name>Set Service Status Former Date to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Service_Status_Former_Date_to_Today</fullName>
        <field>Service_Status_Former_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Service Status Former Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_To_Delivery_Partner</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Delivery_Partner</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type To Delivery Partner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_To_Direct_Client</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Direct_Client</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type To Direct Client</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_To_Partner_Client</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Partner_Client</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type To Partner Client</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Account Record Type On Lead Conversion To Delivery Partner</fullName>
        <actions>
            <name>Update_Record_Type_To_Delivery_Partner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_Type__c</field>
            <operation>equals</operation>
            <value>Delivery Partner</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Account Record Type On Lead Conversion To Direct Client</fullName>
        <actions>
            <name>Update_Record_Type_To_Direct_Client</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_Type__c</field>
            <operation>equals</operation>
            <value>Direct Client</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Account Record Type On Lead Conversion To Partner Client</fullName>
        <actions>
            <name>Update_Record_Type_To_Partner_Client</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Account_Record_Type__c</field>
            <operation>equals</operation>
            <value>Partner Client</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Service Status Active Date</fullName>
        <actions>
            <name>Set_Service_Status_Active_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   ISBLANK(Service_Status_Active_Date__c),   ISPICKVAL(Services_Status__c, &apos;Active&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Service Status Former Date</fullName>
        <actions>
            <name>Set_Service_Status_Former_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   ISBLANK(Service_Status_Former_Date__c),   ISPICKVAL(Services_Status__c, &apos;Former&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Service Status Former Date to Null</fullName>
        <actions>
            <name>Set_Service_Status_Former_Date_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Account become Active again after being Former then null out the Former Date.</description>
        <formula>AND(   TEXT(Services_Status__c) == &apos;Active&apos;,    TEXT(PRIORVALUE(Services_Status__c)) == &apos;Former&apos;,    NOT(ISBLANK(Service_Status_Active_Date__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
