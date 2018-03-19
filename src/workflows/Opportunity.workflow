<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Client_Sales_to_Delivery_Handoff_Email</fullName>
        <ccEmails>delivery@10kview.com</ccEmails>
        <description>New Client Sales to Delivery Handoff Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>delivery@10kview.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Opportunity_Emails/New_Client_Sales_to_Delivery_Handoff</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Opportunity_Record_Type_to_Product</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Product_Opportunity</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Opportunity Record Type to Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Probability_on_MSA_Opportunity</fullName>
        <field>Probability</field>
        <formula>CASE(StageName,
  &quot;Qualification&quot;, 0.10,
  &quot;Proposal&quot;, 0.40,
  &quot;Negotiation&quot;, 0.65,
  &quot;Verbal Approval&quot;, 0.90,
  &quot;Closed Won&quot;, 1.00,
  0
)</formula>
        <name>Set Probability on MSA Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Probability_On_Product_Opportunit</fullName>
        <field>Probability</field>
        <formula>IF( ( ISPICKVAL( StageName , &apos;Qualification&apos;) ) , 
0.1, 
IF(( ISPICKVAL( StageName , &apos;Needs Analysis&apos;) ), 
0.35, 
IF(( ISPICKVAL( StageName , &apos;Proposal&apos;) ), 
0.75, 
IF(( ISPICKVAL( StageName , &apos;Negotiation&apos;) ), 
0.90, 
IF(( ISPICKVAL( StageName , &apos;Closed Won&apos;) ), 
1, 
0 
) 
) 
) 
) 
)</formula>
        <name>Update Probability On Product Opportunit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Probability_On_Service_Opportunit</fullName>
        <field>Probability</field>
        <formula>IF( ( ISPICKVAL( StageName , &apos;Qualification&apos;) ) ,
      0.1, 
      IF(( ISPICKVAL( StageName , &apos;Estimation&apos;) ),
          0.4,
          IF(( ISPICKVAL( StageName , &apos;Client Approval&apos;) ),
              0.9,
                 IF(( ISPICKVAL( StageName , &apos;Closed Won&apos;)),
                    1,
                    0
                   )
             )
      )
)</formula>
        <name>Update Probability On Service Opportunit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New Client Sales to Delivery Handoff</fullName>
        <actions>
            <name>New_Client_Sales_to_Delivery_Handoff_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>contains</operation>
            <value>Hamm</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>First Project</value>
        </criteriaItems>
        <description>New Client Sales to Delivery Handoff</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Opportunity Record Type to Product</fullName>
        <actions>
            <name>Set_Opportunity_Record_Type_to_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Product_Opportunity__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Probability on MSA Opportunities</fullName>
        <actions>
            <name>Set_Probability_on_MSA_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(StageName), RecordType.DeveloperName  == &apos;MSA_Opportunity&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Probability On Product Opportunity</fullName>
        <actions>
            <name>Update_Probability_On_Product_Opportunit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(StageName), RecordType.DeveloperName == &apos;Product_Opportunity&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Probability On Service Opportunity</fullName>
        <actions>
            <name>Update_Probability_On_Service_Opportunit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(StageName), RecordType.DeveloperName == &apos;Services_Opportunity&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
