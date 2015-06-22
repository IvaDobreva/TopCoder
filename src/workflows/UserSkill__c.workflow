<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Member Skill</fullName>
        <field>Member_Skill__c</field>
        <formula>Member__c + &apos;-&apos; +  Skill__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>User Skill - Update Member Skill</fullName>
        <actions>
            <name>Update Member Skill</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 = 1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
