<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:profile="http://www.lido-schema.org/lidoProfile/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:lido="http://www.lido-schema.org" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="profile tei">
<!--
	Copyright (Simon Sendler 2022–2023).
	Licensed under the EUPL–1.2 or later.
-->
	<xsl:template match="profile:schemaSpec" mode="sch">
	    <sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xml:lang="en">
	        <sch:title>
	            Schematron Constraints for LIDO Application Profile <xsl:value-of select="$profile-title" />
	        </sch:title>
	        <sch:ns uri="http://purl.oclc.org/dsdl/schematron" prefix="sch"/>
	        <sch:ns uri="http://www.lido-schema.org" prefix="lido"/>
	        <sch:ns uri="http://www.w3.org/2002/07/owl#" prefix="owl"/>
	        <sch:ns uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
	        <xsl:apply-templates mode="sch" />
	    </sch:schema>
	</xsl:template>
    
    <xsl:template match="profile:constraintSpec" mode="sch">
        <xsl:apply-templates mode="sch" />
    </xsl:template>
    
    <xsl:template match="profile:constraint" mode="sch">
        <xsl:apply-templates select="@*" mode="copy"/>
        <xsl:apply-templates mode="copy"/>
    </xsl:template>
    
    <xsl:template match="*" mode="sch" />

</xsl:stylesheet>