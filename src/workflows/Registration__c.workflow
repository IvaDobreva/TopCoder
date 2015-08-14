<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Activity Cancelled</fullName>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Activity_Cancelled</template>
    </alerts>
    <alerts>
        <fullName>Story Cancelled</fullName>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Story_Cancelled</template>
    </alerts>
    <rules>
        <fullName>Activity Cancelled</fullName>
        <actions>
            <name>Activity Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Registration__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Activity Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Story Cancelled</fullName>
        <actions>
            <name>Story Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Registration__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Story Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
