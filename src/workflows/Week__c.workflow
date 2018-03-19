<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Week_Name_Field_Update</fullName>
        <field>Name</field>
        <formula>Year__c + &apos; Week Number &apos;+If(Week_Number__c &lt; 10,&apos;0&apos;+TEXT(Week_Number__c),TEXT(Week_Number__c))+&apos; - &apos; +TEXT(Week_Starts_On__c) + &apos; through &apos; +  TEXT(Week_Ends_On__c)</formula>
        <name>Update Week Name Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Week Name</fullName>
        <actions>
            <name>Update_Week_Name_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
