<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Inventory_Total_Cost</fullName>
        <field>Total_Cost__c</field>
        <formula>Item_Cost__c  *  Quantity_Purchased_Value__c</formula>
        <name>Update Inventory Total Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Inventory Total Cost</fullName>
        <actions>
            <name>Update_Inventory_Total_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
