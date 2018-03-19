<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>X10K_Way_Training_Enrollment_Notification</fullName>
        <description>10K Way Training Enrollment Notification</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Expert_Emails/X10K_Way_Enrollment</template>
    </alerts>
</Workflow>
