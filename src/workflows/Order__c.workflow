<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_10K_Delivery_Of_New_Order</fullName>
        <description>Notify 10K Delivery Of New Order</description>
        <protected>false</protected>
        <recipients>
            <recipient>X10K_Delivery</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Order_Email_Templates/Notify_10K_Delivery_Of_New_Order</template>
    </alerts>
    <alerts>
        <fullName>To_Contact_when_Order_is_created</fullName>
        <description>To Contact when Order is created</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/To_Contact_when_Order_is_created</template>
    </alerts>
    <alerts>
        <fullName>To_Contact_when_Order_status_updated_to_Fulfilled</fullName>
        <description>To Contact when Order status updated to Fulfilled</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/To_Contact_when_Order_status_updated_to_Fulfilled</template>
    </alerts>
    <alerts>
        <fullName>To_Contact_when_Order_status_updated_to_Processing</fullName>
        <description>To Contact when Order status updated to Processing</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/To_Contact_when_Order_status_updated_to_Processing</template>
    </alerts>
    <rules>
        <fullName>Notify 10K Delivery Of New Order</fullName>
        <actions>
            <name>Notify_10K_Delivery_Of_New_Order</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify 10K Delivery Of New Order</description>
        <formula>AND(
  OR(
    ISNEW(),
    AND(
      NOT(ISNEW()),
      ISCHANGED(Status__c)
    )
  ),
  ISPICKVAL(Status__c, &quot;Submitted&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>To Contact when Order is created</fullName>
        <actions>
            <name>To_Contact_when_Order_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>To Contact when Order status updated to Fulfilled</fullName>
        <actions>
            <name>To_Contact_when_Order_status_updated_to_Fulfilled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Fulfilled</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>To Contact when Order status updated to Processing</fullName>
        <actions>
            <name>To_Contact_when_Order_status_updated_to_Processing</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order__c.Status__c</field>
            <operation>equals</operation>
            <value>Processing</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
