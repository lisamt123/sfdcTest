<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Assignee_of_New_Task</fullName>
        <description>Notify Assignee of New Task</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Task_Email_Templates/Notify_Assignee_of_New_Task</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Task_Completion_Date</fullName>
        <field>Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Task Completion Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Assignee of New Task</fullName>
        <actions>
            <name>Notify_Assignee_of_New_Task</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sent an email notification to person specified in the Assigned To field on a Task</description>
        <formula>AND(   ISPICKVAL(Status__c, &quot;Ready for Work&quot;),   NOT(ISBLANK(Assigned_To_User__c)),   OR(     ISNEW(),     PRIORVALUE(Assigned_To_User__c) != Assigned_To_User__c   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Completion Date When Task Completed</fullName>
        <actions>
            <name>Set_Task_Completion_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Completed&quot;),   NOT(ISPICKVAL(PRIORVALUE(Status__c), &quot;Completed&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
