<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Assignment_Status_to_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Assignment Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Assignment__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Billable_Amount_on_Time_Entry</fullName>
        <field>Total_Billable_Amount__c</field>
        <formula>Hourly_Rate__c * Hours__c</formula>
        <name>Set Billable Amount on Time Entry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Cost_Amount_on_Time_Entry</fullName>
        <field>Total_Cost_Amount__c</field>
        <formula>Hourly_Cost_Rate__c * Hours__c</formula>
        <name>Set Cost Amount on Time Entry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Expert_Goodwill_Amount</fullName>
        <field>Total_Expert_Goodwill_Amount__c</field>
        <formula>Expert_Goodwill_Hours__c * Hourly_Cost_Rate__c</formula>
        <name>Set Expert Goodwill Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Goodwill_Amount</fullName>
        <field>Total_Goodwill_Amount__c</field>
        <formula>Goodwill_Hours__c  *  Hourly_Rate__c</formula>
        <name>Set Goodwill Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Feed_Trekbin_Time_Entries</fullName>
        <apiVersion>40.0</apiVersion>
        <endpointUrl>https://internal-trekbin.cs53.force.com/services/apexrest/TBN_OBMListner</endpointUrl>
        <fields>Assignment__c</fields>
        <fields>Date__c</fields>
        <fields>Description__c</fields>
        <fields>End_Date__c</fields>
        <fields>Expert_Partner_External_Id__c</fields>
        <fields>Hours__c</fields>
        <fields>Id</fields>
        <fields>LastModifiedDate</fields>
        <fields>Project_Billing_Code__c</fields>
        <fields>Project_Id__c</fields>
        <fields>Project__c</fields>
        <fields>Resource_Name__c</fields>
        <fields>Role__c</fields>
        <fields>Start_Date__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>matt@10kview.com</integrationUser>
        <name>Feed Trekbin Time Entries</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Feed Trekbin Time Entries To Trekbin%27s Salesforce Org</fullName>
        <actions>
            <name>Feed_Trekbin_Time_Entries</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <formula>CONTAINS(Assignment__r.Resource__r.Account.Name, &apos;Trekbin&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Billable Amount</fullName>
        <actions>
            <name>Set_Billable_Amount_on_Time_Entry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   NOT(ISBLANK(Assignment__r.Rate__c)),   Assignment__r.Rate__r.Agreement__r.RecordType.DeveloperName != &apos;Retainer&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Cost Amount</fullName>
        <actions>
            <name>Set_Cost_Amount_on_Time_Entry</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Assignment__r.Cost_Rate__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Expert Goodwill Amount</fullName>
        <actions>
            <name>Set_Expert_Goodwill_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  NOT(ISBLANK(Expert_Goodwill_Hours__c)),  NOT(ISBLANK(Assignment__r.Rate__c)),  Assignment__r.Rate__r.Agreement__r.RecordType.DeveloperName != &apos;Retainer&apos;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Goodwill Amount</fullName>
        <actions>
            <name>Set_Goodwill_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   NOT(ISBLANK(Goodwill_Hours__c)),   NOT(ISBLANK(Assignment__r.Rate__c)),   Assignment__r.Rate__r.Agreement__r.RecordType.DeveloperName != &apos;Retainer&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Projected Assignment To Active On First Time Entry</fullName>
        <actions>
            <name>Set_Assignment_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Assignment__r.Status__c, &quot;Projected&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
