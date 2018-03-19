<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>AvoidDirectAccessTriggerMap</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">Avoid directly accessing Trigger.old and Trigger.new as it can lead to a bug. Triggers should be bulkified and iterate through the map to handle the actions for each item separately.</value>
    </values>
    <values>
        <field>Severity__c</field>
        <value xsi:type="xsd:string">Low</value>
    </values>
    <values>
        <field>State__c</field>
        <value xsi:type="xsd:string">Active</value>
    </values>
</CustomMetadata>
