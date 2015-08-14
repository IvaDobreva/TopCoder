<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New Story Published</fullName>
        <protected>false</protected>
        <recipients>
            <recipient>Crowd Exchange Users</recipient>
            <type>group</type>
        </recipients>
        <template>Crowd_Exchange_Email_Templates/New_Story_Published</template>
    </alerts>
    <rules>
        <fullName>Story</fullName>
        <actions>
            <name>New Story Published</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NumberOfPublicActivities__c = 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
