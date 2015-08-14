<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Activity Awarded</fullName>
        <protected>false</protected>
        <recipients>
            <field>Submitting_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Activity_Has_Been_Awarded</template>
    </alerts>
    <alerts>
        <fullName>Submission Review Complete</fullName>
        <protected>false</protected>
        <recipients>
            <field>Submitting_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Submission_Review_Complete</template>
    </alerts>
    <rules>
        <fullName>Activity Awarded</fullName>
        <actions>
            <name>Activity Awarded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Submission__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Activity Awarded</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Submission Review Complete</fullName>
        <actions>
            <name>Submission Review Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Submission__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Submission Review Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
