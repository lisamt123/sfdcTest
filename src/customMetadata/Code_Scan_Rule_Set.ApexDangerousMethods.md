<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ApexDangerousMethods</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">Checks against calling dangerous methods.

For the time being, it reports:

Against FinancialForce’s Configuration.disableTriggerCRUDSecurity(). Disabling CRUD security opens the door to several attacks and requires manual validation, which is unreliable.
Calling System.debug passing sensitive data as parameter, which could lead to exposure of private data.</value>
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
