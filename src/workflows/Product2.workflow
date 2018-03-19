<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Product_Name</fullName>
        <field>Name</field>
        <formula>TEXT(Role__c) + &quot; - &quot; + TEXT(Region__c) + &quot; - Time &amp; Materials&quot;</formula>
        <name>Update Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Unique_Key</fullName>
        <field>Unique_Key__c</field>
        <formula>TEXT(Role__c) + &quot; - &quot; + TEXT(Region__c) + &quot; - Time &amp; Materials&quot;</formula>
        <name>Update Product Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Product - Actions on Create and Every Edit</fullName>
        <actions>
            <name>Update_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.RecordTypeId</field>
            <operation>equals</operation>
            <value>Services Product</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
