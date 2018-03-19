<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Independent_Contractor_In_India</fullName>
        <description>Independent Contractor In India</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Indian_Lead_Follow_Up</template>
    </alerts>
    <alerts>
        <fullName>Notify_10KDelivery_Of_Expert_Interview_Dates</fullName>
        <description>Notify 10KDelivery Of Expert Interview Dates</description>
        <protected>false</protected>
        <recipients>
            <recipient>X10K_Delivery</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Lead_Interview_Response</template>
    </alerts>
    <alerts>
        <fullName>Request_Lead_For_Expert_Interview_Availability</fullName>
        <description>Request Lead For Expert Interview Availability</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Lead_Interview_Date_Time</template>
    </alerts>
    <alerts>
        <fullName>Request_Lead_For_Expert_Qualification</fullName>
        <description>Request Lead For Expert Qualification</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Lead_Qualification_Survey_Invitation</template>
    </alerts>
    <alerts>
        <fullName>Request_Lead_For_Expert_Qualification_Survey</fullName>
        <description>Request Lead For Expert Qualification Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Lead_Qualification_Survey_Invitation</template>
    </alerts>
    <alerts>
        <fullName>Request_Lead_For_Trailhead_User_ID_Webassessor_Email</fullName>
        <description>Request Lead For Trailhead User ID/Webassessor Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Lead_Email_Templates/Lead_missing_Trailhead_or_SFDC_Cert_info</template>
    </alerts>
    <fieldUpdates>
        <fullName>Parse_Trailhead_User_Id_From_URL</fullName>
        <field>Trailhead_User_Id__c</field>
        <formula>IF( 
CONTAINS(Trailhead_Profile_URL__c, &quot;userId=&quot;), 
MID(Trailhead_Profile_URL__c, FIND(&quot;userId=&quot;, Trailhead_Profile_URL__c) + 7, 18), 
IF( 
CONTAINS(Trailhead_Profile_URL__c, &quot;users/profiles&quot;), 
MID(Trailhead_Profile_URL__c, FIND(&quot;profiles/&quot;, Trailhead_Profile_URL__c) + 9, 18), 
IF(
  CONTAINS(Trailhead_Profile_URL__c, &quot;/me/&quot;),
  MID(Trailhead_Profile_URL__c, FIND(&quot;/me/&quot;, Trailhead_Profile_URL__c) + 4, 18),
  null
)
) 
)</formula>
        <name>Parse Trailhead User Id From URL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Record_Type_to_Customer</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Lead Record Type to Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Record_Type_to_Expert</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Expert</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Lead Record Type to Expert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Record_Type_to_SI_ISV</fullName>
        <field>RecordTypeId</field>
        <lookupValue>SI_ISV</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Lead Record Type to SI / ISV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Lead_Flag_to_False</fullName>
        <field>Product_Lead__c</field>
        <literalValue>0</literalValue>
        <name>Set Product Lead Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Product_Lead_Flag_to_True</fullName>
        <field>Product_Lead__c</field>
        <literalValue>1</literalValue>
        <name>Set Product Lead Flag to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_RecordType_to_DoubleClick</fullName>
        <field>RecordTypeId</field>
        <lookupValue>DoubleClick_for_Salesforce</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set RecordType to DoubleClick</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_To_Interviewing</fullName>
        <field>Status</field>
        <literalValue>Interviewing</literalValue>
        <name>Update Lead Status To Interviewing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_To_Nurturing</fullName>
        <field>Status</field>
        <literalValue>Nurturing</literalValue>
        <name>Update Lead Status To Nurturing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status_To_Validating</fullName>
        <field>Status</field>
        <literalValue>Validating</literalValue>
        <name>Update Lead Status To Validating</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Validating_Date_To_Today</fullName>
        <field>Validating_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Validating Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead Status updates to Validating</fullName>
        <actions>
            <name>Update_Lead_Status_To_Validating</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Validating_Date_To_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Survey returned</description>
        <formula>AND( 
  RecordType.Name = &apos;Delivery Partner&apos;,
  DATETIMEVALUE(TODAY()) &lt; (CreatedDate + 30),
  NOT(ISBLANK( Salesforce_Work_Date__c )),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DSM&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DoubleClick&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Package&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Install&quot;))
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead from India - After Qualification for Independent</fullName>
        <actions>
            <name>Independent_Contractor_In_India</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Lead_Status_To_Nurturing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Delivery Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Validating</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Country</field>
            <operation>equals</operation>
            <value>India</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Salesforce_Work_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notContain</operation>
            <value>DSM,Doubleclick,Package,Install</value>
        </criteriaItems>
        <description>Used to send the leads from India our template response that we don&apos;t work with independent people.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify 10KDelivery Of Expert Interview Dates</fullName>
        <actions>
            <name>Notify_10KDelivery_Of_Expert_Interview_Dates</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify 10KDelivery Of Expert Interview Dates</description>
        <formula>AND(
  RecordType.Name = &apos;Delivery Partner&apos;,
  ISPICKVAL(Status, &apos;Interviewing&apos;),
  NOT(ISBLANK(Interview_Availability_1__c)),
  NOT(ISBLANK(Interview_Availability_2__c)),
  NOT(ISBLANK(Interview_Availability_3__c))
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify 10KDelivery Of No Expert Interview Dates</fullName>
        <actions>
            <name>Update_Lead_Status_To_Nurturing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notify 10KDelivery Of No Expert Interview Dates</description>
        <formula>AND(
  RecordType.Name = &apos;Delivery Partner&apos;,
  ISPICKVAL(Status, &apos;Validating&apos;),
  TODAY() &lt; (Validating_Date__c + 14),
  ISNULL(Interview_Availability_1__c),
  ISNULL(Interview_Availability_2__c),
  ISNULL(Interview_Availability_3__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify 10KDelivery Of No Lead Achievements</fullName>
        <active>true</active>
        <formula>AND(
  RecordType.Name = &apos;Delivery Partner&apos;,
  ISPICKVAL(Status , &apos;New&apos;),
  OR(
    ISNULL( Achievement_Count__c),
    Achievement_Count__c  = 0
  ),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DSM&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DoubleClick&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Package&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Install&quot;))
)</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Lead_Status_To_Nurturing</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Parse Trailhead User Id From URL</fullName>
        <actions>
            <name>Parse_Trailhead_User_Id_From_URL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Trailhead_Profile_URL__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Trailhead_User_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Request Lead For Expert Interview Availability</fullName>
        <actions>
            <name>Request_Lead_For_Expert_Interview_Availability</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Request Lead For Expert Interview Availability</description>
        <formula>AND( 
  RecordType.Name = &apos;Delivery Partner&apos;,
  ISPICKVAL(Status , &quot;Interviewing&quot;),
  NOT(ISBLANK( Salesforce_Work_Date__c )),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DSM&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DoubleClick&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Package&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Install&quot;))
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Request Lead For Expert Qualification</fullName>
        <actions>
            <name>Request_Lead_For_Expert_Qualification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Lead_Status_To_Validating</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Request Lead For Expert Qualification</description>
        <formula>AND(
  RecordType.Name = &quot;Delivery Partner&quot;,
  ISPICKVAL(Status , &quot;New&quot;),
  Achievement_Count__c &gt; 0,
  OR(
    PRIORVALUE(Achievement_Count__c) &lt;= 0,
    ISBLANK(PRIORVALUE(Achievement_Count__c))
  ),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DSM&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;DoubleClick&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Package&quot;)),
  NOT(CONTAINS(TEXT(LeadSource), &quot;Install&quot;))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Request Lead For Trailhead User ID%2FWebassessor Email</fullName>
        <actions>
            <name>Request_Lead_For_Trailhead_User_ID_Webassessor_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 2) AND  (3 AND 4)) AND 5</booleanFilter>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Delivery Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Webassessor_Email__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Trailhead_User_Id__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notContain</operation>
            <value>DSM,Doubleclick,Package,Install</value>
        </criteriaItems>
        <description>Request Lead For Trailhead User ID/Webassessor Email</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Lead Record Type to Customer</fullName>
        <actions>
            <name>Set_Lead_Record_Type_to_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Type__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Lead Record Type to Expert</fullName>
        <actions>
            <name>Set_Lead_Record_Type_to_Expert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Expert</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Type__c</field>
            <operation>equals</operation>
            <value>Expert</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Lead Record Type to SI %2F ISV</fullName>
        <actions>
            <name>Set_Lead_Record_Type_to_SI_ISV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>SI / ISV</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Type__c</field>
            <operation>equals</operation>
            <value>SI / ISV</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Product Lead Flag to False</fullName>
        <actions>
            <name>Set_Product_Lead_Flag_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(    NOT(CONTAINS(TEXT(LeadSource), &quot;DSM&quot;)),   NOT(CONTAINS(TEXT(LeadSource), &quot;Doubleclick&quot;)),   NOT(CONTAINS(TEXT(LeadSource), &quot;Package&quot;)),   NOT(CONTAINS(TEXT(LeadSource ), &quot;Install&quot;))  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Product Lead Flag to True</fullName>
        <actions>
            <name>Set_Product_Lead_Flag_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(   CONTAINS(TEXT(LeadSource), &quot;DSM&quot;),   CONTAINS(TEXT(LeadSource), &quot;Doubleclick&quot;),   CONTAINS(TEXT(LeadSource), &quot;Package&quot;),   CONTAINS(TEXT(LeadSource ), &quot;Install&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set RecordType on DoubleClick Leads</fullName>
        <actions>
            <name>Set_RecordType_to_DoubleClick</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>contains</operation>
            <value>DSM,Doubleclick,Package,Install</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
