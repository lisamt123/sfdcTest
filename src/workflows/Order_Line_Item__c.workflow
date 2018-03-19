<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Total_Points_Redeemed_Text</fullName>
        <field>Total_Points_Redeemed_Text__c</field>
        <formula>IF((Free_Order_Line_Item__c  = &apos;&apos;) , Total_Points_Redeemed__c, 0)</formula>
        <name>Update Total Points Redeemed Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Total Points Redeemed Text</fullName>
        <actions>
            <name>Update_Total_Points_Redeemed_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order_Line_Item__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
