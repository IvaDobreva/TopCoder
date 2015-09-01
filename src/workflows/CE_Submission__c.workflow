<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>activityawarded</fullName>
        <description>Activity Awarded</description>
        <protected>false</protected>
        <recipients>
            <field>Submitting_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Activity_Has_Been_Awarded</template>
    </alerts>
    <alerts>
        <fullName>submissionreviewcomplete</fullName>
        <description>Submission Review Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Submitting_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Crowd_Exchange_Email_Templates/Submission_Review_Complete</template>
    </alerts>
    <rules>
        <fullName>Activity Awarded</fullName>
        <actions>
            <name>activityawarded</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Submission__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Activity Awarded</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Submission Review Complete</fullName>
        <actions>
            <name>submissionreviewcomplete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Submission__c.Notification_Code__c</field>
            <operation>equals</operation>
            <value>Submission Review Complete</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
