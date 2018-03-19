<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>AvoidGlobalModifier</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">Global classes should be avoided (especially in managed packages) as they can never be deleted or changed in signature. Always check twice if something needs to be global. Many interfaces (e.g. Batch) required global modifiers in the past but don’t require this anymore. Don’t lock yourself in.</value>
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
