<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ApexCRUDViolation</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">The rule validates you are checking for access permissions before a SOQL/SOSL/DML operation. Since Apex runs in system mode not having proper permissions checks results in escalation of privilege and may produce runtime errors. This check forces you to handle such scenarios.</value>
    </values>
    <values>
        <field>Severity__c</field>
        <value xsi:type="xsd:string">High</value>
    </values>
    <values>
        <field>State__c</field>
        <value xsi:type="xsd:string">Active</value>
    </values>
</CustomMetadata>
