<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Delivery_Owner_of_New_Story</fullName>
        <description>Notify Delivery Owner of New Story</description>
        <protected>false</protected>
        <recipients>
            <field>Delivery_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Delivery_Owner_of_New_Story</template>
    </alerts>
    <alerts>
        <fullName>Notify_Delivery_Owner_of_Story_Ready_for_Deployment</fullName>
        <description>Notify Delivery Owner of Story Ready for Deployment</description>
        <protected>false</protected>
        <recipients>
            <field>Delivery_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Delivery_Owner_of_Story_Ready_for_Deployment</template>
    </alerts>
    <alerts>
        <fullName>Notify_Delivery_Owner_of_Story_Ready_for_Tech_Review</fullName>
        <description>Notify Delivery Owner of Story Ready for Tech Review</description>
        <protected>false</protected>
        <recipients>
            <field>Delivery_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Delivery_Owner_of_Story_Ready_for_Tech_Review</template>
    </alerts>
    <alerts>
        <fullName>Notify_Delivery_Owner_of_Story_Ready_for_Work</fullName>
        <description>Notify Delivery Owner of Story Ready for Work</description>
        <protected>false</protected>
        <recipients>
            <field>Delivery_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Delivery_Owner_of_Story_Ready_for_Work</template>
    </alerts>
    <alerts>
        <fullName>Notify_Functional_Owner_of_New_Story</fullName>
        <description>Notify Functional Owner of New Story</description>
        <protected>false</protected>
        <recipients>
            <field>Functional_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Functional_Owner_of_New_Story</template>
    </alerts>
    <alerts>
        <fullName>Notify_Functional_Owner_of_Story_Ready_for_Review</fullName>
        <description>Notify Functional Owner of Story Ready for Review</description>
        <protected>false</protected>
        <recipients>
            <field>Functional_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Functional_Owner_of_Story_Ready_for_Review</template>
    </alerts>
    <alerts>
        <fullName>Notify_Functional_Owner_of_Story_Ready_for_UAT</fullName>
        <description>Notify Functional Owner of Story Ready for UAT</description>
        <protected>false</protected>
        <recipients>
            <field>Functional_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Functional_Owner_of_Story_Ready_for_UAT</template>
    </alerts>
    <alerts>
        <fullName>Notify_Jared_of_No_Delivery_Owner_of_Story</fullName>
        <description>Notify Jared of No Delivery Owner of Story</description>
        <protected>false</protected>
        <recipients>
            <recipient>matt@10kview.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_Jared_of_No_Delivery_Owner_of_Story</template>
    </alerts>
    <alerts>
        <fullName>Notify_QA_Owner_of_New_Story</fullName>
        <description>Notify QA Owner of New Story</description>
        <protected>false</protected>
        <recipients>
            <field>QA_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_QA_Owner_of_New_Story</template>
    </alerts>
    <alerts>
        <fullName>Notify_QA_Owner_of_Story_Ready_for_QA</fullName>
        <description>Notify QA Owner of Story Ready for QA</description>
        <protected>false</protected>
        <recipients>
            <field>QA_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Story_Email_Templates/Notify_QA_Owner_of_Story_Ready_for_QA</template>
    </alerts>
    <rules>
        <fullName>Notify Delivery Owner of New Story</fullName>
        <actions>
            <name>Notify_Delivery_Owner_of_New_Story</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(   ISNEW(),   ISCHANGED( Delivery_Owner__c )  ),  NOT(ISBLANK( Delivery_Owner__c )) , if(Delivery_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Delivery Owner of Story Ready for Deployment</fullName>
        <actions>
            <name>Notify_Delivery_Owner_of_Story_Ready_for_Deployment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   OR(  ISNEW(),  ISCHANGED(Status__c)  ),   NOT(ISBLANK( Delivery_Owner__c )),   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Ready for Deployment&quot;) ,  if(Delivery_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Delivery Owner of Story Ready for Tech Review</fullName>
        <actions>
            <name>Notify_Delivery_Owner_of_Story_Ready_for_Tech_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   OR(  ISNEW(),  ISCHANGED(Status__c)  ),   NOT(ISBLANK( Delivery_Owner__c )),   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Ready for Tech Review&quot;) ,  if(Delivery_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Delivery Owner of Story Ready for Work</fullName>
        <actions>
            <name>Notify_Delivery_Owner_of_Story_Ready_for_Work</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(  ISNEW(),  ISCHANGED(Status__c)  ),  NOT(ISBLANK( Delivery_Owner__c )),  ISCHANGED(Status__c),  ISPICKVAL(Status__c, &quot;Ready for Work&quot;) , if(Delivery_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Functional Owner of New Story</fullName>
        <actions>
            <name>Notify_Functional_Owner_of_New_Story</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(   ISNEW(),   ISCHANGED(Functional_Owner__c)  ),  NOT(ISBLANK(Functional_Owner__c)), if(Functional_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Functional Owner of Story Ready for Review</fullName>
        <actions>
            <name>Notify_Functional_Owner_of_Story_Ready_for_Review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   OR(   ISNEW(),    ISCHANGED(Status__c)  ),  NOT(ISBLANK(Functional_Owner__c)),  ISPICKVAL(Status__c, &quot;Ready for Review&quot;) , if(Functional_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Functional Owner of Story Ready for UAT</fullName>
        <actions>
            <name>Notify_Functional_Owner_of_Story_Ready_for_UAT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(   OR(  ISNEW(),  ISCHANGED(Status__c)  ),   NOT(ISBLANK( Functional_Owner__c )),   ISCHANGED(Status__c),   ISPICKVAL(Status__c, &quot;Ready for UAT&quot;) ,  if(Functional_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Jared of No Delivery Owner of Story</fullName>
        <actions>
            <name>Notify_Jared_of_No_Delivery_Owner_of_Story</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(  OR(  ISNEW(),  ISCHANGED( Delivery_Owner__c )  ),  ISBLANK( Delivery_Owner__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify QA Owner of New Story</fullName>
        <actions>
            <name>Notify_QA_Owner_of_New_Story</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(   ISNEW(),   ISCHANGED(  QA_Owner__c )  ),  NOT(ISBLANK( QA_Owner__c )) , if(QA_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify QA Owner of Story Ready for QA</fullName>
        <actions>
            <name>Notify_QA_Owner_of_Story_Ready_for_QA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(  OR(  ISNEW(),  ISCHANGED(Status__c)  ),  NOT(ISBLANK(  QA_Owner__c )),  ISCHANGED(Status__c),  ISPICKVAL(Status__c, &quot;Ready for QA&quot;) , if(QA_Owner__c &lt;&gt;  LastModifiedById , true , false ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
