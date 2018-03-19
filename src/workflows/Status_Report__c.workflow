<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Maintain_Status_Report_Name</fullName>
        <field>Status_Report_Name__c</field>
        <formula>Project__r.Name + &apos; - Weekly Status Report for &apos; + TEXT(MONTH(Start_Date__c)) + &apos;/&apos; + TEXT(DAY(Start_Date__c)) + &apos; - &apos; + TEXT(MONTH(End_Date__c)) + &apos;/&apos; + TEXT(DAY(End_Date__c))</formula>
        <name>Maintain Status Report Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Maintain Status Report Name</fullName>
        <actions>
            <name>Maintain_Status_Report_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
