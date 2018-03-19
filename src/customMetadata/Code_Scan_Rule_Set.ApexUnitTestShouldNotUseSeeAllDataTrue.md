<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ApexUnitTestShouldNotUseSeeAllDataTrue</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">Apex unit tests should not use @isTest(seeAllData=true) because it opens up the existing database data for unexpected modification by tests.</value>
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
