<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>X10K_Way_Training_Enrollment_Notification</fullName>
        <ccEmails>diane@10kview.com</ccEmails>
        <description>10K Way Training Enrollment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Expert_Emails/X10K_Way_Enrollment</template>
    </alerts>
    <rules>
        <fullName>10K Way Enrollment Notification</fullName>
        <actions>
            <name>X10K_Way_Training_Enrollment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Learning__r.Name=&quot;10K Way Introduction Video&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
