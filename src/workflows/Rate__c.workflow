<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Rate_Name</fullName>
        <field>Name</field>
        <formula>TEXT(Role__c) +
IF(
  NOT(ISNULL(Retainer_Sequence_Number__c)),
  &apos; #&apos; + TEXT(Retainer_Sequence_Number__c),
  &apos;&apos;
)
+
IF(
  NOT(ISNULL(TEXT(Region__c))),
  &apos; - &apos; + TEXT(Region__c),
  &apos;&apos;
)
+ &quot; - &quot; + TEXT(Assignment_Type__c) + &quot; - $&quot; +
IF(NOT(ISBLANK(Hourly_Rate__c)), TEXT(Hourly_Rate__c), null) +
IF(NOT(ISBLANK(Weekly_Rate__c)), TEXT(Weekly_Rate__c), null) +
IF(NOT(ISBLANK(Monthly_Rate__c)), TEXT(Monthly_Rate__c), null)</formula>
        <name>Set Rate Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_T_M_RC_Unique_Key</fullName>
        <field>Unique_Key__c</field>
        <formula>Agreement__c + TEXT(Role__c)  +
IF(
  NOT(ISNULL(TEXT(Region__c))),
  TEXT(Region__c),
  &apos;&apos;
)
+ TEXT(Assignment_Type__c)
+
IF(
  ISBLANK(Rate_Specific_Effective_Date__c),
  null,
  TEXT(Rate_Specific_Effective_Date__c)
)
+
IF(
  ISBLANK(Rate_Specific_Valid_Through__c),
  null,
  TEXT(Rate_Specific_Valid_Through__c)
)
+
TEXT(Retainer_Sequence_Number__c)
+ &quot; - $&quot; + 
IF(NOT(ISBLANK(Hourly_Rate__c)), TEXT(Hourly_Rate__c), null) + 
IF(NOT(ISBLANK(Weekly_Rate__c)), TEXT(Weekly_Rate__c), null) + 
IF(NOT(ISBLANK(Monthly_Rate__c)), TEXT(Monthly_Rate__c), null)</formula>
        <name>Set T&amp;M and RC Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Rate - Actions on Create and Every Edit</fullName>
        <actions>
            <name>Set_Rate_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_T_M_RC_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Rate__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
