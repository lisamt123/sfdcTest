<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Delivery_Management_of_New_Escalation</fullName>
        <description>Notify Delivery Management of New Escalation</description>
        <protected>false</protected>
        <recipients>
            <recipient>X10K_Delivery</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Escalation_Email_Templates/Notify_Delivery_Management_of_New_Escalation</template>
    </alerts>
    <rules>
        <fullName>Notify Delivery Management of New Escalation</fullName>
        <actions>
            <name>Notify_Delivery_Management_of_New_Escalation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Escalation__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
