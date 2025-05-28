<!--
	Copyright (Richard Light 2021)
	Copyright (Simon Sendler 2022–2023).
	Licensed under the EUPL–1.2 or later.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:profile="http://www.lido-schema.org/lidoProfile/"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="profile xsi tei xs sch">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="profile-def" select="/profile:lidoProfile"/>
	<xsl:variable name="schema-spec" select="$profile-def/profile:schemaSpec"/>
	<xsl:variable name="profile-elements" select="$schema-spec/*"/>
	<xsl:variable name="constraint-spec" select="$profile-def/profile:constraintSpec"/>
	<xsl:variable name="profile-constraints" select="$constraint-spec/*"/>
	<xsl:variable name="profile-metadata" select="$profile-def/profile:schemaMeta"/>
	<xsl:variable name="profile-docs" select="$profile-def/profile:schemaDoc/*"/>
	<xsl:variable name="profile-title" select="$profile-metadata/profile:title"/>
	<xsl:variable name="profile-author" select="$profile-metadata/profile:author"/>
	<xsl:variable name="profile-contributors" select="$profile-metadata/profile:contributor"/>
	<xsl:variable name="profile-publisher" select="$profile-metadata/profile:publisher"/>
	<xsl:variable name="profile-abstract" select="$profile-metadata/profile:abstract"/>
	<xsl:variable name="profile-revision" select="$profile-metadata/profile:revision/*"/>
	<xsl:variable name="profile-licence" select="$profile-metadata/profile:licence"/>
	<xsl:variable name="profile-date" select="$profile-metadata/profile:date"/>
	<xsl:variable name="profile-urn" select="$profile-metadata/profile:URI"/>
	<xsl:variable name="profile-versions" select="$profile-revision/@n" />
	<xsl:variable name="profile-version" select="format-number(max($profile-versions), '##1.1##')"/>
	<xsl:variable name="lido-version" select="substring($schema-spec/@base, 35, 5)"/>
	<xsl:variable name="lido-base-xsd" select="substring($schema-spec/@base, 40, 9)"/>
	<xsl:variable name="base-uri">https://lido-schema.org/profiles/</xsl:variable>
	<xsl:variable name="prefix">-profile-</xsl:variable>
	<xsl:variable select="$profile-urn/node()" name="urn" />
	<xsl:variable name="separator">-v</xsl:variable>
	<xsl:variable name="profile-id" select="concat($lido-base-xsd, $prefix, $urn, $separator, $profile-version)"/>

	<xsl:include href="html.xsl" />
	<xsl:include href="sch.xsl" />

	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="profile:lidoProfile">
		<xsl:apply-templates select="profile:schemaSpec|profile:schemaDoc"/>
		<xsl:result-document method="xml" href="{concat($profile-id, '.sch')}" indent="true">
			<xsl:apply-templates mode="sch"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="profile:schemaDoc">
			<xsl:result-document method="html" href="{concat($profile-id, '.html')}" indent="true">
				<xsl:apply-templates mode="html"/>
			</xsl:result-document>
	</xsl:template>

	<xsl:template match="profile:schemaSpec">
		<xsl:result-document method="xml" href="{concat($profile-id, '.xsd')}" indent="true">
			<xsl:variable name="source" select="document(@base)"/>
			<xsl:apply-templates select="$source" mode="update"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="*" mode="copy" priority="-1">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*" mode="copy"/>
			<xsl:apply-templates mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*" mode="copy" priority="-1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="@mode" mode="copy"/>
	<!--xsl:template match="@type" mode="copy"/-->
	<!-- type attribute is required in the generated Schema -->
	<xsl:template match="@elttype" mode="copy"/>
	<xsl:template match="@xml:id" mode="copy">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="contains(., ':')">
					<xsl:value-of select="substring-after(., ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!-- Updating the schema with profile elements: -->
	<xsl:template match="*" mode="update" priority="-1">
		<xsl:copy copy-namespaces="no">
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="update"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xs:schema" mode="update">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="xs:annotation" mode="update"/>
			<xsl:apply-templates select="xs:import" mode="update"/>
			<xsl:apply-templates select="$schema-spec/profile:import" mode="update"/>
			<xsl:apply-templates select="*[not(self::xs:annotation or self::xs:import)]"
				mode="update"/>
			<xsl:apply-templates select="$profile-elements[@mode = 'add']" mode="add"/>
			<xsl:apply-templates select="$profile-constraints" mode="add"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="profile:import" mode="update">
		<xs:import>
			<xsl:copy-of select="@*"/>
		</xs:import>
	</xsl:template>

	<xsl:template match="xs:element[string(@id)] | xs:attribute[string(@id)]" mode="update">
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="profile-override"
			select="$profile-elements[@xml:id = $id or @xml:id = concat('lido:', $id)]"/>
		<xsl:choose>
			<xsl:when test="count($profile-override) &gt; 0">
				<xsl:message>Profile override for <xsl:value-of select="$id"/> found.</xsl:message>
				<xsl:choose>
					<xsl:when test="$profile-override[@mode = 'change']">
						<xsl:apply-templates select="." mode="change">
							<xsl:with-param name="profile" select="$profile-override"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$profile-override[@mode = 'replace']">
						<xsl:copy copy-namespaces="no">
							<xsl:apply-templates select="$profile-override/@*" mode="copy"/>
							<xsl:apply-templates select="$profile-override/*" mode="copy"/>
						</xsl:copy>
					</xsl:when>
					<xsl:when test="$profile-override[@mode = 'delete']"/>
					<xsl:otherwise>
						<xsl:copy copy-namespaces="no">
							<xsl:apply-templates select="@*" mode="copy"/>
							<xsl:apply-templates mode="update"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy copy-namespaces="no">
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates mode="update"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:element[string(@ref)]" mode="update">
		<xsl:variable name="ref" select="@ref"/>
		<xsl:variable name="profile-override" select="$profile-elements[@xml:id = $ref]"/>
		<xsl:choose>
			<xsl:when test="count($profile-override) &gt; 0">
				<!--xsl:message>Profile override for <xsl:value-of select="$id"/> found.</xsl:message-->
				<xsl:choose>
					<xsl:when test="$profile-override[@mode = 'replace']">
						<xsl:apply-templates select="$profile-override" mode="copy"/>
					</xsl:when>
					<xsl:when test="$profile-override[@mode = 'delete']"/>
					<xsl:otherwise>
						<xsl:copy copy-namespaces="no">
							<xsl:apply-templates select="@*" mode="copy"/>
							<xsl:apply-templates mode="update"/>
						</xsl:copy>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy copy-namespaces="no">
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates mode="update"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tei:teiHeader" mode="update">
		<xsl:element name="tei:teiHeader">
			<xsl:apply-templates mode="update" />
			<xsl:element name="tei:profileDesc">
				<xsl:element name="tei:abstract">
					<xsl:apply-templates select="$profile-abstract/node()" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="tei:revisionDesc">
				<xsl:for-each select="$profile-revision">
					<xsl:element name="tei:change">
						<xsl:copy-of select="@*" />
						<xsl:apply-templates select="./node()" mode="copy" />
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tei:publisher[parent::tei:publicationStmt]" mode="update">
		<xsl:for-each select="$profile-publisher">
			<xsl:element name="tei:publisher">
				<xsl:apply-templates select="./node()" mode="copy"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tei:authority[parent::tei:publicationStmt]" mode="update" />

	<xsl:template match="tei:date[parent::tei:publicationStmt]/node()" mode="update">
		<xsl:apply-templates select="$profile-date/node()" mode="copy"/>
	</xsl:template>

	<xsl:template match="tei:availability[parent::tei:publicationStmt]" mode="update">
		<xsl:element name="tei:idno">
			<xsl:attribute name="type">URI</xsl:attribute>
			<xsl:variable name="ending">.xsd</xsl:variable>
			<xsl:value-of select="concat($base-uri, $lido-version, $profile-id, $ending)" />
		</xsl:element>
		<xsl:element name="tei:availability">
			<xsl:element name="tei:licence">
				<xsl:copy-of select="$profile-licence/@*" />
				<xsl:apply-templates select="$profile-licence/node()"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tei:title[parent::tei:titleStmt]/node()" mode="update">
		<xsl:apply-templates select="$profile-title/node()" mode="copy"/>
	</xsl:template>

	<xsl:template match="tei:author[parent::tei:titleStmt]" mode="update">
		<xsl:for-each select="$profile-author">
			<xsl:element name="tei:author">
				<xsl:copy-of select="./@xml:id" />
				<xsl:apply-templates select ="./node()" mode="copy"/>
			</xsl:element>
		</xsl:for-each>
		<xsl:for-each select="$profile-contributors">
			<xsl:element name="tei:respStmt">
				<xsl:element name="tei:resp">
					<xsl:value-of select="./@role"/>
				</xsl:element>
				<xsl:element name="tei:name">
					<xsl:copy-of select="./@xml:id" />
					<xsl:apply-templates select ="./node()" mode="copy"/>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="@*" mode="update" priority="-1">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- Change mode:-->
	<!-- ! change does not yet copy all children, cf. adding schematron rules -->
	<xsl:template match="*" mode="change">
		<xsl:param name="profile"/>
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*" mode="change">
				<xsl:with-param name="profile" select="$profile"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="inner-change">
				<xsl:with-param name="profile" select="$profile"/>
			</xsl:apply-templates>
			<!--xsl:apply-templates select="$profile/*" mode="add-if-new">
				<xsl:with-param name="existing-defn" select="."/>
			</xsl:apply-templates-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*" mode="change">
		<xsl:param name="profile"/>
		<xsl:variable name="att-name" select="name()"/>
		<xsl:choose>
			<xsl:when test="string($profile/@*[name() = $att-name])">
				<xsl:copy-of select="$profile/@*[name() = $att-name]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="inner-change">
		<xsl:param name="profile"/>
		<xsl:variable name="elt-name" select="local-name()"/>
		<!--xsl:message>Looking to match <xsl:value-of select="$elt-name"/> in elementSpec</xsl:message-->
		<xsl:choose>
			<xsl:when test="count($profile/*[local-name() = $elt-name]) &gt; 0">
				<xsl:message>Inner change for <xsl:value-of select="$elt-name"/> found</xsl:message>
				<xsl:copy-of select="$profile/*[local-name() = $elt-name]"/>
			</xsl:when>
			<xsl:otherwise>
				<!--xsl:comment> <xsl:value-of select="$elt-name"/> copied </xsl:comment-->
				<xsl:copy copy-namespaces="no">
					<xsl:apply-templates select="@*" mode="change">
						<xsl:with-param name="profile" select="$profile"/>
					</xsl:apply-templates>
					<xsl:apply-templates mode="inner-change">
						<xsl:with-param name="profile" select="$profile"/>
					</xsl:apply-templates>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="add-if-new">
		<xsl:param name="existing-defn"/>
		<xsl:variable name="elt-name" select="name()"/>
		<xsl:if test="not($existing-defn/*[name() = $elt-name])">
			<xsl:apply-templates select="." mode="copy"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="profile:constraintSpec" mode="add">
		<xsl:for-each select="profile:constraint">
			<xsl:element name="xs:annotation">
				<xsl:element name="xs:appinfo">
					<xsl:apply-templates select="@*" mode="copy"/>
					<xsl:apply-templates mode="copy"/>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<!-- Add mode:-->
	<xsl:template match="*" mode="add">
		<!-- !! check that Id doesn't exist and that @type is an allowed one: -->
		<xsl:element name="{concat('xs:', @xml:id)}">
			<xsl:apply-templates select="@*" mode="copy"/>
			<xsl:apply-templates mode="copy"/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
