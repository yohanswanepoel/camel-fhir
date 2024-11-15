<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fhir="http://hl7.org/fhir"
    xmlns:v3="urn:hl7-org:v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Main template matching FHIR Patient resource -->
    <xsl:template match="/">
        <ClinicalDocument xmlns="urn:hl7-org:v3">
            <recordTarget>
                <patientRole>
                    <!-- Map patient identifier -->
                    <id>
                        <xsl:attribute name="root">
                            <xsl:value-of select="/fhir:Patient/fhir:identifier/fhir:system/@value"/>
                        </xsl:attribute>
                        <xsl:attribute name="extension">
                            <xsl:value-of select="/fhir:Patient/fhir:identifier/fhir:value/@value"/>
                        </xsl:attribute>
                    </id>
                    
                    <!-- Map address -->
                    <addr>
                        <streetAddressLine>
                            <xsl:value-of select="/fhir:Patient/fhir:address/fhir:line/@value"/>
                        </streetAddressLine>
                        <city>
                            <xsl:value-of select="/fhir:Patient/fhir:address/fhir:city/@value"/>
                        </city>
                        <state>
                            <xsl:value-of select="/fhir:Patient/fhir:address/fhir:state/@value"/>
                        </state>
                        <postalCode>
                            <xsl:value-of select="/fhir:Patient/fhir:address/fhir:postalCode/@value"/>
                        </postalCode>
                        <country>
                            <xsl:value-of select="/fhir:Patient/fhir:address/fhir:country/@value"/>
                        </country>
                    </addr>
                    
                    <!-- Map patient demographics -->
                    <patient>
                        <name>
                            <given>
                                <xsl:value-of select="/fhir:Patient/fhir:name/fhir:given/@value"/>
                            </given>
                            <family>
                                <xsl:value-of select="/fhir:Patient/fhir:name/fhir:family/@value"/>
                            </family>
                        </name>
                        
                        <!-- Map administrative gender -->
                        <administrativeGenderCode>
                            <xsl:attribute name="code">
                                <xsl:choose>
                                    <xsl:when test="/fhir:Patient/fhir:gender/@value = 'male'">M</xsl:when>
                                    <xsl:when test="/fhir:Patient/fhir:gender/@value = 'female'">F</xsl:when>
                                    <xsl:when test="/fhir:Patient/fhir:gender/@value = 'other'">UN</xsl:when>
                                    <xsl:otherwise>UNK</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="codeSystem">2.16.840.1.113883.5.1</xsl:attribute>
                        </administrativeGenderCode>
                        
                        <!-- Map birth date -->
                        <birthTime>
                            <xsl:attribute name="value">
                                <xsl:value-of select="translate(/fhir:Patient/fhir:birthDate/@value, '-', '')"/>
                            </xsl:attribute>
                        </birthTime>
                    </patient>
                </patientRole>
            </recordTarget>
        </ClinicalDocument>
    </xsl:template>
</xsl:stylesheet>