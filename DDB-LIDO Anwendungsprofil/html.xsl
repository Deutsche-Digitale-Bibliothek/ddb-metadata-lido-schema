<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:profile="http://www.lido-schema.org/lidoProfile/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:lido="http://www.lido-schema.org" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="profile tei">
<!--
	Copyright (Simon Sendler 2022–2023).
	Licensed under the EUPL–1.2 or later.
-->
	<xsl:variable name="header">
		<head>
            <meta charset="utf-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
		    <style>
		        <xsl:value-of select="unparsed-text-lines('style.css')"/>
		    </style>
            <title><xsl:value-of select="$profile-title" /></title>
        </head>
	</xsl:variable>

	<xsl:template match="tei:text" mode="html">
		<html>
			<xsl:copy-of select="$header"/>
			<body>
		        <xsl:call-template name="make-header" />
			    <xsl:call-template name="make-version-history" />
				<xsl:apply-templates mode="html" />
			</body>
		</html>
	</xsl:template>

    <xsl:template match="tei:abbr" mode="html">
        <abbr>
            <xsl:attribute name="title">
                <xsl:value-of select="./following-sibling::tei:expan[1]" />
            </xsl:attribute>
            <xsl:apply-templates mode="html" />
        </abbr>
    </xsl:template>

    <xsl:template match="tei:anchor" mode="html">
        <span id="{@xml:id}">
            <xsl:apply-templates mode="html" />
        </span>
    </xsl:template>

    <xsl:template match="tei:att" mode="html">
        <code class="attribute">
            <xsl:apply-templates mode="html" />
        </code>
    </xsl:template>

    <xsl:template match="tei:cell" mode="html">
        <td>
            <xsl:apply-templates mode="html" />
        </td>
    </xsl:template>

    <xsl:template match="tei:choice" mode="html">
        <xsl:apply-templates select="tei:corr|tei:abbr|tei:reg|tei:choice" mode="html" />
    </xsl:template>

    <xsl:template match="tei:code" mode="html">
        <pre>
            <xsl:copy-of select="serialize(node())" copy-namespaces="no" />
        </pre>
    </xsl:template>

    <xsl:template match="tei:div" mode="html">
        <xsl:choose>

            <xsl:when test="starts-with(@type, 'guideline_')">
                <section>
                    <xsl:attribute name="class" select="@type" />
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id" select="@xml:id" />
                    </xsl:if>
                    <xsl:apply-templates mode="html" />
                </section>
            </xsl:when>
            <xsl:when test="@type='ap_unit'">
<!--                <div class="ap-unit">-->
                    <xsl:call-template name="manual-doc"></xsl:call-template>
<!--                    <xsl:apply-templates mode="html" />-->
                <!--</div>-->
            </xsl:when>
            <xsl:when test="starts-with(@type, 'ap_')">
                <!--<div>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                    <xsl:variable name="level" select="count(./ancestor::tei:div[starts-with(@type, 'ap_')])"/>
                    <xsl:choose>
                        <xsl:when test="$level &lt; 7">
                            <xsl:element name="h{$level + 2}">
                                <xsl:value-of select="concat(upper-case(substring(@type, 4,1)), substring(@type, 5)) => replace('_', ' ')"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <span>
                                <xsl:value-of select="concat(upper-case(substring(@type, 4,1)), substring(@type, 5)) => replace('_', ' ')"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>

                    <div>
                        <xsl:apply-templates mode="html" />
                    </div>
                </div>-->
            </xsl:when>
            <xsl:otherwise>
                <div>
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id" select="@xml:id" />
                    </xsl:if>
                    <xsl:apply-templates mode="html" />
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:emph" mode="html">
        <i>
            <xsl:apply-templates mode="html" />
        </i>
    </xsl:template>

    <xsl:template match="tei:figure" mode="html">
        <xsl:choose>
            <xsl:when test="./tei:head">
                <figure>
                    <img src="{tei:graphic/@url}" alt="{normalize-space(tei:figDesc)}"></img>
                    <figcaption>
                        <xsl:apply-templates select="tei:head/node()" mode="html" />
                    </figcaption>
                </figure>
            </xsl:when>
            <xsl:otherwise>
                <img src="{tei:graphic/@url}" alt="{normalize-space(tei:figDesc)}"></img>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:foreign" mode="html">
        <i class="foreign">
            <xsl:apply-templates mode="html" />
        </i>
    </xsl:template>

    <xsl:template match="tei:gi" mode="html">
        <code class="element">
            <xsl:apply-templates mode="html" />
        </code>
    </xsl:template>

    <xsl:template match="tei:head" name="tei-head" mode="html">
        <xsl:choose>
            <xsl:when test="parent::tei:table">
                <thead>
                    <xsl:apply-templates mode="html" />
                </thead>
            </xsl:when>
            <xsl:when test="parent::tei:div[@type='ap_unit']">
                <xsl:element name="h2">
                    <xsl:apply-templates mode="html" />
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="level" select="count(./ancestor::tei:div[child::tei:head])"/>
                <xsl:element name="h{$level + 1}">
                    <xsl:apply-templates mode="html" />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:head[not(ancestor::tei:figure)]" mode="nav">
        <li>
            <xsl:value-of select="."/>
            <xsl:if test="child::*[descendant::tei:head]">
                <ul>
                    <xsl:apply-templates mode="nav" select="child::*[descendant::tei:head]"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="*" mode="nav">
        <xsl:apply-templates mode="nav" />
    </xsl:template>

    <xsl:template match="tei:hi" mode="html">
        <b>
            <xsl:apply-templates mode="html" />
        </b>
    </xsl:template>

    <xsl:template match="tei:item" mode="html">
        <li>
            <xsl:apply-templates mode="html" />
        </li>
    </xsl:template>

    <xsl:template match="tei:list" mode="html">
        <ul>
            <xsl:apply-templates mode="html" />
        </ul>
    </xsl:template>

    <xsl:template match="tei:p|sch:p" mode="html">
        <p>
            <xsl:apply-templates mode="html" />
        </p>
    </xsl:template>

    <xsl:template match="tei:ptr" mode="html">
        <a href="{@target}">
            <xsl:apply-templates mode="html" />
        </a>
    </xsl:template>

    <xsl:template match="tei:q" mode="html">
        <q>
            <xsl:apply-templates mode="html" />
        </q>
    </xsl:template>

    <xsl:template match="tei:ref" mode="html">
        <a href="{@target}">
            <xsl:choose>
                <xsl:when test=".//text()">
                    <xsl:apply-templates mode="html" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(@target, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </a>

    </xsl:template>

    <xsl:template match="tei:row" mode="html">
        <tr>
            <xsl:apply-templates mode="html" />
        </tr>
    </xsl:template>

    <xsl:template match="tei:seg" mode="html">
        <span>
            <xsl:copy-of select="@*" />
            <xsl:apply-templates mode="html" />
        </span>
    </xsl:template>

    <xsl:template match="tei:table" mode="html">
        <table>
            <xsl:apply-templates mode="html" />
        </table>
    </xsl:template>

    <xsl:template match="tei:teiHeader" mode="html" />

    <xsl:template match="*" mode="html">
        <xsl:apply-templates mode="html" />
    </xsl:template>

    <xsl:template match="sch:name" mode="html">
        <xsl:choose>
            <xsl:when test="ancestor::sch:rule[@context]">
                <xsl:value-of select="ancestor::sch:rule/@context"/>
            </xsl:when>
            <xsl:otherwise>
                [element in focus]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="profile:document" mode="html">
            <xsl:choose>
                <xsl:when test="@mode">
                    <xsl:for-each select="$profile-elements[@mode = ./@mode]/@xml:id">
                        <xsl:call-template name="auto-docs">
                            <xsl:with-param name="elt" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="@target = 'constraints'">
                    <xsl:call-template name="auto-doc-schematron" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="tokenize(@target, ' ')">
                        <xsl:call-template name="auto-docs">
                            <xsl:with-param name="elt" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

    <xsl:template name="auto-docs">
        <xsl:param name="elt"/>
        <xsl:variable name="corresp-spec" select="$profile-elements[@xml:id = $elt]"/>
        <xsl:if test="$corresp-spec">
           <div class="ap-unit">
               <h2><xsl:value-of select="$corresp-spec/@xml:id"/></h2>
               <div class="ap_description">
                   <h3>Description</h3>
                   <div><xsl:value-of select="$corresp-spec//tei:ab[@type = 'description']"/></div>
                   <xsl:if test="$corresp-spec//xs:attribute">
                       <xsl:for-each select="$corresp-spec//xs:attribute">
                           <xsl:if test=".//tei:ab[@type = 'description']">
                               <div class="ap_attribute">
                                   <h4 class="attribute">
                                       <xsl:value-of select="replace(./@ref, 'lido:', '')"/> attribute
                                   </h4>
                                   <div>
                                       <xsl:value-of select=".//tei:ab[@type = 'description']"/>
                                   </div>
                               </div>
                           </xsl:if>
                       </xsl:for-each>
                   </xsl:if>
               </div>
               <div class="ap_technical-information">
                   <h3>Technical Information</h3>
                   <div class="ap_change-mode">
                       <h4>Change mode</h4>
                       <div><xsl:value-of select="concat(upper-case(substring($corresp-spec/@mode, 1,1)), substring($corresp-spec/@mode, 2))"/></div>
                   </div>
                   <xsl:if test="$corresp-spec//xs:attribute">
                       <div class="ap_attributes">
                           <h4>Attributes</h4>
                           <ul>
                               <xsl:for-each select="$corresp-spec//xs:attribute">
                                   <li>
                                       <xsl:value-of select="replace(./@ref, 'lido:', '')"/>
                                   </li>
                               </xsl:for-each>
                           </ul>
                       </div>
                   </xsl:if>
                   <xsl:if test="$corresp-spec/@minOccurs or $corresp-spec/@maxOccurs">
                       <div class="ap_cardinality">
                           <h4>Cardinality</h4>
                           <div>
                               <xsl:choose>
                                   <xsl:when test="$corresp-spec/@minOccurs">
                                       <xsl:value-of select="$corresp-spec/@minOccurs"/>
                                   </xsl:when>
                                   <xsl:otherwise>1</xsl:otherwise>
                               </xsl:choose>
                               <xsl:text>–</xsl:text>
                               <xsl:choose>
                                   <xsl:when test="$corresp-spec/@maxOccurs">
                                       <xsl:value-of select="$corresp-spec/@maxOccurs"/>
                                   </xsl:when>
                                   <xsl:otherwise>unbounded</xsl:otherwise>
                               </xsl:choose>
                           </div>
                       </div>
                   </xsl:if>
                   <div class="ap_mandatory">
                       <h4>Mandatory</h4>
                       <div>
                           <xsl:choose>
                               <xsl:when test="$corresp-spec/@minOccurs > 0 or not($corresp-spec/@minOccurs)">Yes</xsl:when>
                               <xsl:otherwise>No</xsl:otherwise>
                           </xsl:choose>
                       </div>
                   </div>
                   <div class="ap_repeatable">
                       <h4>Repeatable</h4>
                       <div>
                           <xsl:choose>
                               <xsl:when test="not($corresp-spec/@maxOccurs) or $corresp-spec/@maxOccurs = '1'">No</xsl:when>
                               <xsl:otherwise>Yes</xsl:otherwise>
                           </xsl:choose>
                       </div>
                   </div>
                   <xsl:if test="$corresp-spec//sch:rule[@context = $elt]//sch:extends">
                       <div class="ap_schematron-rules">
                           <h4>Schematron Rules</h4>
                           <div>
                               <xsl:for-each select="$corresp-spec//sch:rule[@context = $elt]//sch:extends">
                                       <xsl:value-of select="./@rule"/>
                               </xsl:for-each>
                           </div>
                       </div>
                   </xsl:if>
               </div>
           </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="manual-doc">
        <div class="ap-unit">
            <h2><xsl:value-of select=".//tei:head"/></h2>
            <xsl:for-each select="tei:div">
                <xsl:choose>
                    <xsl:when test="@type = 'ap_description'">
                        <div class="ap_description">
                            <h3>Description</h3>
                            <div>
                                <xsl:apply-templates mode="html" />
                            </div>
                            <xsl:if test=".//tei:div[contains(@type, '_attribute')]">
                                <xsl:for-each select=".//tei:div[contains(@type, '_attribute')]">
                                    <div class="ap_attribute">
                                        <h4 class="attribute">
                                            <xsl:value-of select="replace(./@type, 'ap_', '') => replace('_', ' ')"/>
                                        </h4>
                                        <div>
                                            <xsl:apply-templates mode="html" />
                                        </div>
                                    </div>
                                </xsl:for-each>
                            </xsl:if>
                        </div>
                    </xsl:when>
                    <xsl:when test="@type = 'ap_label'">
                        <div>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type"/>
                            </xsl:attribute>
                            <h3>Label</h3>
                            <div class="ap_label_value">
                                <xsl:value-of select="."/>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:when test="@type = 'ap_structure'">
                        <div>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type"/>
                            </xsl:attribute>
                            <h3>Structure</h3>
                            <xsl:for-each select="tei:div">
                                <xsl:call-template name="manual-doc-section" />
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:when test="@type = 'ap_technical_information'">
                        <div>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type"/>
                            </xsl:attribute>
                            <h3>Technical information</h3>
                            <xsl:for-each select="tei:div">
                                <xsl:call-template name="manual-doc-section" />
                            </xsl:for-each>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type"/>
                            </xsl:attribute>
                            <h3>Further information</h3>
                            <xsl:for-each select="tei:div">
                                <xsl:call-template name="manual-doc-section" />
                            </xsl:for-each>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="auto-doc-schematron">
        <section class="sch_rules">
            <h2>Schematron rules</h2>
            <xsl:for-each select="$schema-spec/profile:constraintSpec//sch:pattern">
                <div class="sch_pattern">
                    <h3><xsl:value-of select="./sch:title"/></h3>
                    <div>
                        <h4>Description</h4>
                        <div><xsl:apply-templates select="./sch:p" mode="html"/></div>
                    </div>
                    <xsl:for-each select="./sch:rule">
                        <div class="sch_rule">
                            <h4>Rule ID</h4>
                            <div><xsl:value-of select="@id"/></div>

                        <xsl:for-each select="sch:assert|sch:report">
                            <div>
                                <h4>Rule</h4>
                                <div><xsl:value-of select="local-name(.)"/>: <code><xsl:value-of select="@test"/></code></div>
                            </div>
                            <div>
                                <h4>Error or warning thrown</h4>
                                <div><xsl:apply-templates select="." mode="html"/></div>
                            </div>
                        </xsl:for-each>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
        </section>
    </xsl:template>

    <xsl:template name="manual-doc-section">
        <div>
            <xsl:attribute name="class">
                <xsl:value-of select="./@type"/>
            </xsl:attribute>
            <h4>
                <xsl:value-of select="concat(upper-case(substring(./@type, 4,1)), substring(./@type, 5)) => replace('_', ' ')"/>
            </h4>
            <div>
                <xsl:apply-templates mode="html" />
            </div>
        </div>
    </xsl:template>

    <xsl:template name="make-header">
        <header>
            <h1>
                <xsl:value-of select="$profile-title"/>
            </h1>
            <span>An Application Profile for LIDO <xsl:value-of select="substring($lido-version,1,4)"/></span>
            <p><b>This Version: </b> <xsl:value-of select="$profile-version"/></p>
            <p><b>Publication date: </b><xsl:value-of select="$profile-date"/></p>
            <p>
                <b>Authors: </b>
                <xsl:for-each select="$profile-author">
                    <xsl:value-of select="."/>
                    <xsl:if test="following-sibling::profile:author">, </xsl:if>
                </xsl:for-each>
            </p>
            <xsl:if test="$profile-contributors">
                <p>
                    <b>Contributors: </b>
                    <xsl:for-each select="$profile-contributors">
                        <xsl:value-of select="."/>
                        <xsl:if test="./@role"> (<xsl:value-of select="./@role"/>)</xsl:if>
                        <xsl:if test="following-sibling::profile:contributor">, </xsl:if>
                    </xsl:for-each>
                </p>
            </xsl:if>
            <xsl:if test="$profile-publisher">
                <p><b>Publisher: </b> <xsl:apply-templates select="$profile-publisher"/></p>
            </xsl:if>
            <p><b>Licence: </b> <a href="{$profile-licence/@target}" target="_blank"><xsl:value-of select="$profile-licence"/></a></p>
        </header>
    </xsl:template>

    <xsl:template name="make-version-history">
        <section>
            <h2>Version history</h2>
            <xsl:for-each select="$profile-revision">
                <details>
                    <summary>
                        <xsl:value-of select="@n"/>
                    </summary>
                    <div>
                        <xsl:apply-templates mode="html" />
                    </div>
                </details>
            </xsl:for-each>
        </section>
    </xsl:template>

</xsl:stylesheet>