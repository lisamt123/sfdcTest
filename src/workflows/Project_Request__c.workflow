<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Account_Owner_of_a_new_Project_Request</fullName>
        <description>Alert Account Owner of a new Project Request</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Request_Emails/Alert_Account_Owner_of_a_new_Project_Request</template>
    </alerts>
    <alerts>
        <fullName>Alert_Request_Contact_when_Project_Request_Status_is_Changed</fullName>
        <description>Alert Request Contact when Project Request Status is Changed</description>
        <protected>false</protected>
        <recipients>
            <field>Request_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Request_Emails/Alert_Request_Contact_when_Project_Request_Status_is_Changed</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Alert_To_ProjectRequest_Owner_14_days_after_LSCDate</fullName>
        <description>Send Email Alert To ProjectRequest Owner 14 days after LSCDate</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Request_Emails/Alert_ProjectRequestOwner_14_days_after_LastStatusChangeDate</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Closed_Date_to_Current_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Closed Date to Current Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Closed_Date_to_Null</fullName>
        <field>Closed_Date__c</field>
        <name>Set Closed Date to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CurrentDate_Value_Into_LSCDate</fullName>
        <field>Last_Status_Change_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update CurrentDate Value Into LSCDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send Email alert to PROwner 14 days after LSCDate is updated %26 Status Not Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Project_Request__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Email_Alert_To_ProjectRequest_Owner_14_days_after_LSCDate</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Project_Request__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set CurrentDate to LastStatusChangeDate On Each Status Change</fullName>
        <actions>
            <name>Update_CurrentDate_Value_Into_LSCDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(   ISNEW(),   ISCHANGED(Status__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Project Request Closed Date to Null when Status is Changed from Closed</fullName>
        <actions>
            <name>Set_Closed_Date_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Project Request Closed Date to Null when Status is Changed from Closed</description>
        <formula>AND(   ISCHANGED(Status__c),   NOT(ISPICKVAL(Status__c, &quot;Closed&quot;)),   NOT(ISBLANK(Closed_Date__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Project Request Closed Date when Status Is Set To Closed</fullName>
        <actions>
            <name>Set_Closed_Date_to_Current_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Closed&quot;),   ISBLANK(Closed_Date__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
