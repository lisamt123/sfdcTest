<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_10K_Case_Owner_of_Case_Closure</fullName>
        <description>Notify 10K Case Owner of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Closed_Notification_to_10K_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Notify_10K_Case_Owner_of_Case_Re_Opened</fullName>
        <description>Notify 10K Case Owner of Case Re-Opened</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Re_Opened_Notification_to_10K_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact_of_Case_Closure</fullName>
        <description>Notify Case Contact of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Closed_Notification_to_Case_Contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact_of_Case_Re_Opened</fullName>
        <description>Notify Case Contact of Case Re-Opened</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Re_Opened_Notification_to_Case_Contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact_of_New_DoubleClick_Case</fullName>
        <description>Notify Case Contact of New DoubleClick Case</description>
        <protected>false</protected>
        <recipients>
            <field>Additional_Case_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_4__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_5__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Created_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact_of_New_General_Case</fullName>
        <description>Notify Case Contact of New General Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Created_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_New_General_Case_Comment</fullName>
        <description>Notify Case Owner of New General Case Comment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Comment_Notification_to_10K_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Client_of_Case_Closure</fullName>
        <description>Notify DoubleClick Client of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <field>Additional_Case_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_4__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_5__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Closed_Notification_to_Case_Contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Client_of_Case_Re_Opened</fullName>
        <description>Notify DoubleClick Client of Case Re-Opened</description>
        <protected>false</protected>
        <recipients>
            <field>Additional_Case_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_4__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_5__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Re_Opened_Notification_to_Case_Contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Client_of_New_Case_Comment</fullName>
        <description>Notify DoubleClick Client of New Case Comment</description>
        <protected>false</protected>
        <recipients>
            <field>Additional_Case_Contact_1__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_3__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_4__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Additional_Case_Contact_5__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Comment_Notification_to_Client</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Support_Team_of_Case_Closure</fullName>
        <description>Notify DoubleClick Support Team of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <recipient>DoubleClick for Salesforce Support Team</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Closed_Notification_to_10K_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Support_Team_of_Case_Re_Opened</fullName>
        <description>Notify DoubleClick Support Team of Case Re-Opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>DoubleClick for Salesforce Support Team</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Case_Re_Opened_Notification_to_10K_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>Notify_DoubleClick_Support_Team_of_New_DoubleClick_Case</fullName>
        <description>Notify DoubleClick Support Team of New DoubleClick Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>DoubleClick for Salesforce Support Team</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>doubleclicksupport@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Assigned_To_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_General_Support_Contact_of_New_Case_Comment</fullName>
        <description>Notify General Support Contact of New Case Comment</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/New_Case_Comment_Notification_to_Client</template>
    </alerts>
    <alerts>
        <fullName>Notify_Jared_of_New_General_Support_Case</fullName>
        <description>Notify Jared of New General Support Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>diane@10kview.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jared@10kview.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Email_Templates/New_Case_Assigned_To_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Matt_of_New_General_Support_Case</fullName>
        <description>Notify Matt of New General Support Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>matt@10kview.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Case_Email_Templates/New_Case_Assigned_To_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Matt_of_Unmatched_Email_to_Case</fullName>
        <description>Notify Matt of Unmatched Email to Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>matt@10kview.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>community@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Email_Templates/Notify_Matt_of_Unmatched_Email_to_Case</template>
    </alerts>
    <fieldUpdates>
        <fullName>Notify_Case_Contact_Checkbox_Equal_False</fullName>
        <field>Notify_Case_Contact_of_New_Comment__c</field>
        <literalValue>0</literalValue>
        <name>Notify Case Contact Checkbox Equal False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Notify_Case_Owner_Checkbox_Equal_False</fullName>
        <field>Notify_Case_Owner_of_New_Comment__c</field>
        <literalValue>0</literalValue>
        <name>Notify Case Owner Checkbox Equal False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Origin_to_10K_Community</fullName>
        <field>Origin</field>
        <literalValue>10K Community</literalValue>
        <name>Set Case Origin to 10K Community</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Status_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Set Case Status to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Type_To_Support_Request</fullName>
        <field>Type</field>
        <literalValue>Support Request</literalValue>
        <name>Set Case Type To Support Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Case Contact of New DoubleClick Case</fullName>
        <actions>
            <name>Notify_Case_Contact_of_New_DoubleClick_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DoubleClick for Salesforce</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Checked_For_Delete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Contact of New DoubleClick Case Comment</fullName>
        <actions>
            <name>Notify_DoubleClick_Client_of_New_Case_Comment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Case_Contact_Checkbox_Equal_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  RecordType.DeveloperName = &apos;DoubleClick_for_Salesforce&apos;,
  ISCHANGED(Notify_Case_Contact_of_New_Comment__c),
  Notify_Case_Contact_of_New_Comment__c = TRUE
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Contact of New General Case</fullName>
        <actions>
            <name>Notify_Case_Contact_of_New_General_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>General Community Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Checked_For_Delete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Contact of New General Case Comment</fullName>
        <actions>
            <name>Notify_General_Support_Contact_of_New_Case_Comment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Case_Contact_Checkbox_Equal_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  RecordType.DeveloperName = &apos;General_Community_Support&apos;,
  ISCHANGED(Notify_Case_Contact_of_New_Comment__c),
  Notify_Case_Contact_of_New_Comment__c = TRUE
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner and Case Contact of General Case Closure</fullName>
        <actions>
            <name>Notify_10K_Case_Owner_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Case_Contact_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>General Community Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner and Case Contact of General Case Re-Opened</fullName>
        <actions>
            <name>Notify_10K_Case_Owner_of_Case_Re_Opened</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Case_Contact_of_Case_Re_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(    RecordType.DeveloperName = &apos;General_Community_Support&apos;,    ISCHANGED(IsClosed),   ISPICKVAL(PRIORVALUE(Status), &apos;Closed&apos;),   NOT(ISPICKVAL(Status, &apos;Closed&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner of New General Case Comment</fullName>
        <actions>
            <name>Notify_Case_Owner_of_New_General_Case_Comment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Case_Owner_Checkbox_Equal_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
  RecordType.DeveloperName = &apos;General_Community_Support&apos;,
  ISCHANGED(Notify_Case_Owner_of_New_Comment__c),
  Notify_Case_Owner_of_New_Comment__c = TRUE
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify DoubleClick Support Team and Client of Case Closure</fullName>
        <actions>
            <name>Notify_DoubleClick_Client_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_DoubleClick_Support_Team_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DoubleClick for Salesforce</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify DoubleClick Support Team and Client of Case Re-Opened</fullName>
        <actions>
            <name>Notify_DoubleClick_Client_of_Case_Re_Opened</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_DoubleClick_Support_Team_of_Case_Re_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(    RecordType.DeveloperName = &apos;DoubleClick_for_Salesforce&apos;,    ISCHANGED(Status),   ISPICKVAL(PRIORVALUE(Status), &apos;Closed&apos;),   NOT(ISPICKVAL(Status, &apos;Closed&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify DoubleClick Support Team of New DoubleClick Case</fullName>
        <actions>
            <name>Notify_DoubleClick_Support_Team_of_New_DoubleClick_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DoubleClick for Salesforce</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Checked_For_Delete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Jared of New General Support Case</fullName>
        <actions>
            <name>Notify_Jared_of_New_General_Support_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>General Community Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
            <value>Bug Report</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Checked_For_Delete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Matt of New General Support Case</fullName>
        <actions>
            <name>Notify_Matt_of_New_General_Support_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>General Community Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Bug Report</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Is_Checked_For_Delete__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Matt of Unmatched Email to Case</fullName>
        <actions>
            <name>Notify_Matt_of_Unmatched_Email_to_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
  Notify_DoubleClick_Support__c,
  NOT(Is_Checked_For_Delete__c)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Origin for Community Created Cases</fullName>
        <actions>
            <name>Set_Case_Origin_to_10K_Community</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   ISPICKVAL(Origin, &quot;&quot;),   CreatedBy.Is_Portal_User__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Type For Email To Case</fullName>
        <actions>
            <name>Set_Case_Type_To_Support_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DoubleClick for Salesforce</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Status to In Progress</fullName>
        <actions>
            <name>Set_Case_Status_to_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.First_Response_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
