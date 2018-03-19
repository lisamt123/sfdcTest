<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Error_Email_to_Owner_Point_Rule</fullName>
        <description>Send Error Email to Owner Point Rule</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Points_Email_Templates/Send_Error_Email_to_Owner_Point_Rule</template>
    </alerts>
    <rules>
        <fullName>Send Error Email to Owner Point Rule</fullName>
        <actions>
            <name>Send_Error_Email_to_Owner_Point_Rule</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Points_Rule__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Points_Rule__c.Processing_Error_Message__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
