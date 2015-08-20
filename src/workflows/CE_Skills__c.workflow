<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update Skill Name External</fullName>
        <field>Skill_Name_External__c</field>
        <formula>Name</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Skill Name External Field Update</fullName>
        <actions>
            <name>Update Skill Name External</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CE_Skills__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Rule to copy Skill name field value to Skill Name External field to avoid adding duplicate value to skill table</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
