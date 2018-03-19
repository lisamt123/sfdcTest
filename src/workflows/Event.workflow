<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>GetFeedback Survey Response%3A Welcome</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Event.Subject</field>
            <operation>startsWith</operation>
            <value>GetFeedback Survey Response: Welcome to 10K Advisors</value>
        </criteriaItems>
        <description>Update due date when event created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
