<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>activityassigned</fullName>
        <description>Activity Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Activity_Assigned</template>
    </alerts>
    <alerts>
        <fullName>activityregistrationcomplete</fullName>
        <description>Activity Registration Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Activity_Registration_Complete</template>
    </alerts>
    <alerts>
        <fullName>noregisteredusers</fullName>
        <description>No Registered Users</description>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/No_Registered_Users</template>
    </alerts>
    <alerts>
        <fullName>noreviewsreceived</fullName>
        <description>No Reviews Received</description>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/No_Reviews_Received</template>
    </alerts>
    <alerts>
        <fullName>nosubmissions</fullName>
        <description>No Submissions</description>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/No_Submissions</template>
    </alerts>
    <rules>
        <fullName>Activity Assigned</fullName>
        <actions>
            <name>activityassigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Activity__c.Assigned_Member__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Activity Registration Complete</fullName>
        <actions>
            <name>activityregistrationcomplete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Activity__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Activity Registration Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>No Registered Users</fullName>
        <actions>
            <name>noregisteredusers</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Activity__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>No Registered Users</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>No Reviews Received</fullName>
        <actions>
            <name>noreviewsreceived</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Activity__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>No Reviews Received</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>No Submissions</fullName>
        <actions>
            <name>nosubmissions</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Activity__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>No Submissions</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
