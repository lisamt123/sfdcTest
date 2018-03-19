<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DF_2017_10K_Event_Email_inviation</fullName>
        <description>DF 2017 10K Event Email inviation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Invite</template>
    </alerts>
    <alerts>
        <fullName>DF_2017_10K_Event_YES_confirmation</fullName>
        <description>DF 2017 10K Event YES confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>DF_Event_Invite_Reminder</fullName>
        <description>DF Event Invite Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Invite_Reminder</template>
    </alerts>
    <alerts>
        <fullName>X10K_BourbonTrail_Attendee_Thank_You</fullName>
        <description>10K BourbonTrail Attendee Thank You</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_BourbonTrail_Attendee_Thank_You</template>
    </alerts>
    <alerts>
        <fullName>X10K_Bourbon_Trail_Day_Of_Reminder</fullName>
        <description>10K Bourbon Trail Day Of Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Day_Of_Reminder</template>
    </alerts>
    <alerts>
        <fullName>X10K_Bourbon_Trail_Event_Reminder_w_playlist</fullName>
        <description>10K Bourbon Trail Event Reminder w/ playlist</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Event_Reminder_w_playlist</template>
    </alerts>
    <alerts>
        <fullName>X10K_Bourbon_Trail_Invite_Final_Reminder</fullName>
        <description>10K Bourbon Trail Invite Final Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>events@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Dreamforce_2017/X10K_Bourbon_Trail_Invite_Final_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>DF_10K_Event_Member_Status_Update</fullName>
        <field>Status</field>
        <literalValue>Email Sent</literalValue>
        <name>DF 10K Event Member Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Status_Update</fullName>
        <field>Status</field>
        <literalValue>Reminder1 Sent</literalValue>
        <name>Member Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reminder_2_field_update</fullName>
        <field>Status</field>
        <literalValue>Reminder2 Sent</literalValue>
        <name>Reminder 2 field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sent_Thank_You</fullName>
        <field>Status</field>
        <literalValue>Sent Thank You</literalValue>
        <name>Sent Thank You</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>10K Bourbon Trail Reminder</fullName>
        <actions>
            <name>DF_Event_Invite_Reminder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Member_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Reminder1 1019</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - SENDS</value>
        </criteriaItems>
        <description>Dreamforce 2017 - Sends where status = Reminder 1 1019 send email and update member status to Reminder1 Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>10K Bourbon Trail Reminder 2</fullName>
        <actions>
            <name>X10K_Bourbon_Trail_Invite_Final_Reminder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reminder_2_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Final Reminder</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - SENDS</value>
        </criteriaItems>
        <description>Dreamforce 2017 - Sends where status = 	
Final Reminder and send email and update member status to Reminder2 Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>10K BourbonTrail Attendee Thank You</fullName>
        <actions>
            <name>X10K_BourbonTrail_Attendee_Thank_You</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Sent_Thank_You</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - RESPONSES</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Attended</value>
        </criteriaItems>
        <description>Thank you for attending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DF 2017 10K Event Invite</fullName>
        <actions>
            <name>DF_2017_10K_Event_Email_inviation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DF_10K_Event_Member_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Send</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - SENDS</value>
        </criteriaItems>
        <description>Dreamforce 2017 - 10K Event - SENDS where status = Send send email and update member status to Email Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DF 2017 Attendee Day Of Notice</fullName>
        <actions>
            <name>X10K_Bourbon_Trail_Day_Of_Reminder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - RESPONSES</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Sent Day Of Notice</value>
        </criteriaItems>
        <description>Confirmation of address, date and time of event</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DF 2017 Attendee Final Confirmation</fullName>
        <actions>
            <name>X10K_Bourbon_Trail_Event_Reminder_w_playlist</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - RESPONSES</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Sent Final Confirmation</value>
        </criteriaItems>
        <description>Confirmation of attending event, spotify playlist link, etc.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DF 2017 Yes response</fullName>
        <actions>
            <name>DF_2017_10K_Event_YES_confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>equals</operation>
            <value>Dreamforce 2017 - 10K Event - RESPONSES</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Attending</value>
        </criteriaItems>
        <description>When campaign member responds yes (status equals attending), send a confirmation email</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
