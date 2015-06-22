<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set Internal Project Skill - External Id</fullName>
        <field>Internal_Project_Skill__c</field>
        <formula>Internal_Project__c + &apos;-&apos; +  Skill__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Internal Project Skill - External Id</fullName>
        <actions>
            <name>Set Internal Project Skill - External Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 = 1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
