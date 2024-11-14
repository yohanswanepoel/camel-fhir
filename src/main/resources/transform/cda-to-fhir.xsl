<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:fhir="http://hl7.org/fhir">
    <xsl:output method="xml" indent="yes" />

    <!-- Start the JSON output -->
    <xsl:template match="/">
        <xsl:text>{</xsl:text>
        <xsl:text>"resourceType": "Immunization",</xsl:text>
        <xsl:text>"id": "</xsl:text>
        <xsl:value-of select="component/section/entry/substanceAdministration/id/@root"/>
        <xsl:text>"</xsl:text> <!-- Removed the extra comma here -->

        <!-- Apply templates to handle the rest of the fields -->
        <xsl:apply-templates select="component/section/entry/substanceAdministration" />

        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- Mapping specific elements to JSON fields -->
    <xsl:template match="substanceAdministration">
        <xsl:text>,</xsl:text>
        
        <xsl:text>"status": "</xsl:text>
        <xsl:value-of select="statusCode/@code" />
        <xsl:text>",</xsl:text>

        <xsl:text>"vaccineCode": {"coding": [{"system": "</xsl:text>
        <xsl:value-of select="consumable/manufacturedProduct/manufacturedMaterial/code/@codeSystem" />
        <xsl:text>", "code": "</xsl:text>
        <xsl:value-of select="consumable/manufacturedProduct/manufacturedMaterial/code/@code" />
        <xsl:text>", "display": "</xsl:text>
        <xsl:value-of select="consumable/manufacturedProduct/manufacturedMaterial/code/@displayName" />
        <xsl:text>"}]},</xsl:text>

        <xsl:text>"occurrenceDateTime": "</xsl:text>
        <xsl:value-of select="effectiveTime/@value" />
        <xsl:text>",</xsl:text>

        <xsl:text>"lotNumber": "</xsl:text>
        <xsl:value-of select="consumable/manufacturedProduct/manufacturedMaterial/lotNumberText" />
        <xsl:text>",</xsl:text>

        <!-- Check if a patient reference exists in the XML and use it -->
        <xsl:text>"patient": {"reference": "Patient/"
        </xsl:text>
        <xsl:value-of select="ancestor::component/section/entry/substanceAdministration/performer/assignedEntity/id/@root" />
        <xsl:text>"}</xsl:text>

    </xsl:template>

    <!-- Default template to copy all other nodes -->
    <xsl:template match="text() | @*">
        <xsl:copy />
    </xsl:template>
</xsl:stylesheet>