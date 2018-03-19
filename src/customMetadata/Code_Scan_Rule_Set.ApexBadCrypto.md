<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>ApexBadCrypto</label>
    <protected>false</protected>
    <values>
        <field>Rule_Description__c</field>
        <value xsi:type="xsd:string">The rule makes sure you are using randomly generated IVs and keys for Crypto calls. Hard-wiring these values greatly compromises the security of encrypted data.</value>
    </values>
    <values>
        <field>Severity__c</field>
        <value xsi:type="xsd:string">Low</value>
    </values>
    <values>
        <field>State__c</field>
        <value xsi:type="xsd:string">Disabled</value>
    </values>
</CustomMetadata>
