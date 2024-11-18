<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fhir="http://hl7.org/fhir"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:uuid="java:java.util.UUID"
    xmlns="urn:hl7-org:v3">
    
    <!-- Output settings -->
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Main template matching FHIR Observation -->
    <xsl:template match="/fhir:Observation">
        <!-- Create CDA Observation -->
        <observation classCode="OBS" moodCode="EVN">
            <templateId root="2.16.840.1.113883.10.20.22.4.2"/>
            <templateId root="2.16.840.1.113883.10.20.22.4.2" extension="2015-08-01"/>
            
            <!-- ID from FHIR resource -->
            <id root="2.16.840.1.113883.4.642" extension="{@id}"/>
            
            <!-- Status code mapping -->
            <statusCode>
                <xsl:attribute name="code">
                    <xsl:choose>
                        <xsl:when test="fhir:status = 'final'">completed</xsl:when>
                        <xsl:when test="fhir:status = 'preliminary'">active</xsl:when>
                        <xsl:when test="fhir:status = 'cancelled'">cancelled</xsl:when>
                        <xsl:otherwise>unknown</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </statusCode>
            
            <!-- Effective time -->
            <effectiveTime value="{translate(fhir:effectiveDateTime, '-:', '')}"/>
            
            <!-- Code from FHIR coding -->
            <code>
                <xsl:apply-templates select="fhir:code/fhir:coding[1]"/>
            </code>
            
            <!-- Value -->
            <xsl:if test="fhir:valueQuantity">
                <value xsi:type="PQ">
                    <xsl:attribute name="value">
                        <xsl:value-of select="fhir:valueQuantity/fhir:value"/>
                    </xsl:attribute>
                    <xsl:attribute name="unit">
                        <xsl:value-of select="fhir:valueQuantity/fhir:unit"/>
                    </xsl:attribute>
                </value>
            </xsl:if>
            
            <!-- Subject reference -->
            <xsl:if test="fhir:subject">
                <subject>
                    <templateId root="2.16.840.1.113883.10.20.22.4.2"/>
                    <patientRole>
                        <id extension="{substring-after(fhir:subject/fhir:reference, 'Patient/')}"/>
                    </patientRole>
                </subject>
            </xsl:if>
        </observation>
    </xsl:template>
    
    <!-- Template for coding -->
    <xsl:template match="fhir:coding">
        <xsl:if test="fhir:system = 'http://loinc.org'">
            <xsl:attribute name="code">
                <xsl:value-of select="fhir:code"/>
            </xsl:attribute>
            <xsl:attribute name="codeSystem">2.16.840.1.113883.6.1</xsl:attribute>
            <xsl:attribute name="displayName">
                <xsl:value-of select="fhir:display"/>
            </xsl:attribute>
            <translation code="{fhir:code}" 
                        codeSystem="2.16.840.1.113883.6.1"
                        displayName="{fhir:display}"/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>