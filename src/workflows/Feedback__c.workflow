<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Feedback_Email_to_Project_Team_Members</fullName>
        <description>Feedback Email to Project Team Members</description>
        <protected>false</protected>
        <recipients>
            <field>Submitter__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Feedback_Email_Templates/X10K_Expert_to_Expert_Feedback_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Submitted</fullName>
        <description>When survey received, this box will be true.</description>
        <field>Submitted__c</field>
        <literalValue>1</literalValue>
        <name>Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Received</fullName>
        <field>Status__c</field>
        <literalValue>Received</literalValue>
        <name>Update Status to Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Feedback Email to Project Team Members</fullName>
        <actions>
            <name>Feedback_Email_to_Project_Team_Members</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Feedback__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update status to Received when survey values not null</fullName>
        <actions>
            <name>Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Feedback__c.Technical_Skills__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When tech skills are not null, update status to Received. Tech skills is required on survey.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
