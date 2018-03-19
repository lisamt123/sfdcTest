<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Community_Users_If_Their_Username_Changes</fullName>
        <description>Notify Community Users If Their Username Changes</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Notify_Community_Users_If_Their_Username_Changes</template>
    </alerts>
    <alerts>
        <fullName>X10K_Communities_New_Member_Welcome_Email</fullName>
        <description>10K Communities: New Member Welcome Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Community_Email_Templates/X10K_Communities_New_Expert_Welcome_Email</template>
    </alerts>
    <alerts>
        <fullName>X10K_Connect_New_User_Email</fullName>
        <ccEmails>diane@10kview.com</ccEmails>
        <description>10K Connect - New User Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Community_Email_Templates/X10K_Connect_New_Client_User_Email</template>
    </alerts>
    <rules>
        <fullName>10K Communities%3A New Member Welcome Email</fullName>
        <actions>
            <name>X10K_Communities_New_Member_Welcome_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(Profile.Name,&quot;Delivery Partner&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>10K Connect - New User Email</fullName>
        <actions>
            <name>X10K_Connect_New_User_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>CONTAINS(Profile.Name,&quot;Client&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Community Users If Their Username Changes</fullName>
        <actions>
            <name>Notify_Community_Users_If_Their_Username_Changes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(    Is_Portal_User__c,   ISCHANGED(Username) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
