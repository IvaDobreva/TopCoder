<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>activitycancelled</fullName>
        <description>Activity Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Activity_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>storycancelled</fullName>
        <description>Story Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Story_Cancelled</template>
    </alerts>
    <rules>
        <fullName>Activity Cancelled</fullName>
        <actions>
            <name>activitycancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Registration__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Activity Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Story Cancelled</fullName>
        <actions>
            <name>storycancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Registration__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Story Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
