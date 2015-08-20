<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set Activity Skill External Id</fullName>
        <field>Activity_Skill__c</field>
        <formula>CE_Activity__r.Id + &apos;&apos; +  Skill__r.Id</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Activity Skill External Id</fullName>
        <actions>
            <name>Set Activity Skill External Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_ActivitySkills__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Rule to concatenate the Activity Id and the Skill Id to create a synthetic id to prevent duplicate ActivitySkill combinations from being entered into the ActivitySkill table</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
