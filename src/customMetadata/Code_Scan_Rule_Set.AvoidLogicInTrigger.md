<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>AvoidLogicInTrigger</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">As triggers do not allow methods like regular classes they are less flexible and suited to apply good encapsulation style. Therefore delegate the triggers work to a regular class (often called Trigger handler class).</value>
    </values>
    <values>
        <field>Severity__c</field>
        <value xsi:type="xsd:string">Medium</value>
    </values>
    <values>
        <field>State__c</field>
        <value xsi:type="xsd:string">Active</value>
    </values>
</CustomMetadata>
