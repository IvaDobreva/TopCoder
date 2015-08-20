<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Activity Assigned</fullName>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Member__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Activity_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Activity Registration Complete</fullName>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/Activity_Registration_Complete</template>
    </alerts>
    <alerts>
        <fullName>No Registered Users</fullName>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/No_Registered_Users</template>
    </alerts>
    <alerts>
        <fullName>No Reviews Received</fullName>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/No_Reviews_Received</template>
    </alerts>
    <alerts>
        <fullName>No Submissions</fullName>
        <protected>false</protected>
        <recipients>
            <field>Publisher__c</field>
            <type>userLookup</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/No_Submissions</template>
    </alerts>
    <rules>
        <fullName>Activity Assigned</fullName>
        <actions>
            <name>Activity Assigned</name>
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
            <name>Activity Registration Complete</name>
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
            <name>No Registered Users</name>
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
            <name>No Reviews Received</name>
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
            <name>No Submissions</name>
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
