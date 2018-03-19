<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Line_Item_Total_Text</fullName>
        <field>Line_Item_Total_Text__c</field>
        <formula>Line_Item_Total__c</formula>
        <name>Set Line Item Total (Text)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Key</fullName>
        <field>Unique_Key__c</field>
        <formula>Invoice__r.Name + Rate__c + RecordTypeId +
IF(
  RecordType.DeveloperName = &apos;X10K_Goodwill_Invoice_Line_Item&apos;,
  &apos;Goodwill&apos;,
  IF(
    Line_Item_Total__c &lt; 0,
    &apos;Credit&apos; + TEXT(Line_Item_Total__c),
    &apos;&apos;
  )
)</formula>
        <name>Update Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Invoice Line Item - Actions on Created and Every Edit</fullName>
        <actions>
            <name>Set_Line_Item_Total_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Invoice_Line_Item__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Unique Key</fullName>
        <actions>
            <name>Update_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
