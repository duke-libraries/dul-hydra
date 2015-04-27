<?xml version="1.0" encoding="UTF-8"?>
<!-- Based on MARC21slim2OAIDC.xsl -->
<xsl:stylesheet version="1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:import href="http://www.loc.gov/standards/marcxml/xslt/MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<xsl:if test="marc:collection">
			<dcCollection>
				<xsl:for-each select="marc:collection">
					<xsl:for-each select="marc:record">
						<dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
							<xsl:apply-templates select="."/>
						</dc>
					</xsl:for-each>
				</xsl:for-each>
			</dcCollection>
		</xsl:if>
		<xsl:if test="marc:record">
			<dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
				<xsl:apply-templates/>
			</dc>
		</xsl:if>
	</xsl:template>
	<xsl:template match="marc:record">
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
		<xsl:for-each select="marc:datafield[@tag=245]">
			<dcterms:title>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abfghk</xsl:with-param>
				</xsl:call-template>
			</dcterms:title>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=100]|marc:datafield[@tag=110]|marc:datafield[@tag=111]|marc:datafield[@tag=700]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
			<dcterms:creator>
				<xsl:value-of select="."/>
			</dcterms:creator>
		</xsl:for-each>
		<dcterms:type>
			<xsl:if test="$leader7='c'">
				<!--Remove attribute 6/04 jer-->
				<!--<xsl:attribute name="collection">yes</xsl:attribute>-->
				<xsl:text>collection</xsl:text>
			</xsl:if>
			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<!--Remove attribute 6/04 jer-->
				<!--<xsl:attribute name="manuscript">yes</xsl:attribute>-->
				<xsl:text>manuscript</xsl:text>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i' or $leader6='j'">sound recording</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</dcterms:type>
		<xsl:for-each select="marc:datafield[@tag=655]">
			<dcterms:type>
				<xsl:value-of select="."/>
			</dcterms:type>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]">
			<dcterms:publisher>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</dcterms:publisher>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
			<dcterms:date>
				<xsl:value-of select="."/>
			</dcterms:date>
		</xsl:for-each>
		<dcterms:language>
			<xsl:value-of select="substring($controlField008,36,3)"/>
		</dcterms:language>
		<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
			<dcterms:format>
				<xsl:value-of select="."/>
			</dcterms:format>
		</xsl:for-each>
		<!--
		<xsl:for-each select="marc:datafield[@tag=520]">
			<dcterms:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=521]">
			<dcterms:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:description>
		</xsl:for-each>
		-->
		<xsl:for-each select="marc:datafield[500&lt;= @tag and @tag&lt;= 599 ][not(@tag=506 or @tag=530 or @tag=540 or @tag=546)]">
			<dcterms:description>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=600]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=610]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=611]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=630]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=650]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=653]">
			<dcterms:subject>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdq</xsl:with-param>
				</xsl:call-template>
			</dcterms:subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=752]">
			<dcterms:coverage>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcd</xsl:with-param>
				</xsl:call-template>
			</dcterms:coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=530]">
			<dcterms:relation>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdu</xsl:with-param>
				</xsl:call-template>
			</dcterms:relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=760]|marc:datafield[@tag=762]|marc:datafield[@tag=765]|marc:datafield[@tag=767]|marc:datafield[@tag=770]|marc:datafield[@tag=772]|marc:datafield[@tag=773]|marc:datafield[@tag=774]|marc:datafield[@tag=775]|marc:datafield[@tag=776]|marc:datafield[@tag=777]|marc:datafield[@tag=780]|marc:datafield[@tag=785]|marc:datafield[@tag=786]|marc:datafield[@tag=787]">
			<dcterms:relation>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ot</xsl:with-param>
				</xsl:call-template>
			</dcterms:relation>
		</xsl:for-each>
<!-- For our purposes, we will not consider the electronic resource URI from the MARC record to be an identifier -->
<!--		<xsl:for-each select="marc:datafield[@tag=856]">
			<dcterms:identifier>
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</dcterms:identifier>
		</xsl:for-each>
-->		<xsl:for-each select="marc:datafield[@tag=020]">
			<dcterms:identifier>
				<xsl:text>URN:ISBN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=506]">
			<dcterms:rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:rights>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=540]">
			<dcterms:rights>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</dcterms:rights>
		</xsl:for-each>
		<!--</dc>-->
	</xsl:template>
</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="..\..\..\..\..\..\..\..\..\..\javadev4\testsets\diacriticu8.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->
