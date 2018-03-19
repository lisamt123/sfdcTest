<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>AvoidDmlStatementsInLoops</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">Avoid DML statements inside loops to avoid hitting the DML governor limit. Instead, try to batch up the data into a list and invoke your DML once on that list of data outside the loop.</value>
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
