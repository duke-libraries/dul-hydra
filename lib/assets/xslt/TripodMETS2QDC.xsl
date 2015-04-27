<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:duke="http://library.duke.edu/metadata/terms"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/TR/xlink/">
    <xsl:template match="/">
        <dc xmlns:dcterms="http://purl.org/dc/terms/">
            <xsl:apply-templates select="mets/dmdSec/mdWrap/xmlData"/>
        </dc>
    </xsl:template>
    <xsl:template match="xmlData">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="duke:first_line | duke:refrain">
        <dcterms:alternative><xsl:value-of select="."/></dcterms:alternative>
    </xsl:template>
    <xsl:template match="duke:arranger | duke:artist | duke:choreographer | duke:dedicatee | duke:engraver | duke:illustrator | duke:lithographer | duke:performer | duke:placement_company | duke:producer | duke:sponsor | duke:staging">
        <dcterms:contributor><xsl:value-of select="."/></dcterms:contributor>
    </xsl:template>
    <xsl:template match="duke:company | duke:composer | duke:lyricist">
        <dcterms:creator><xsl:value-of select="."/></dcterms:creator>
    </xsl:template>
    <xsl:template match="duke:interview_date | duke:interviewee_state_of_birth | duke:issue_date">
        <dcterms:date><xsl:value-of select="."/></dcterms:date>
    </xsl:template>
    <xsl:template match="duke:illustrated | duke:instrumentation | duke:setting | duke:time_of_photo | duke:tone">
        <dcterms:description><xsl:value-of select="."/></dcterms:description>
    </xsl:template>
    <xsl:template match="duke:digitized">
        <dcterms:hasVersion><xsl:value-of select="."/></dcterms:hasVersion>
    </xsl:template>
    <xsl:template match="duke:box_number | duke:call_number | duke:folder | duke:interview_number | duke:issue_number | duke:negative_number | duke:oclc_number | duke:print_number | duke:roll_number">
        <dcterms:identifier><xsl:value-of select="."/></dcterms:identifier>
    </xsl:template>
    <xsl:template match="duke:category | duke:source_collection">
        <dcterms:isPartOf><xsl:value-of select="."/></dcterms:isPartOf>
    </xsl:template>
    <xsl:template match="duke:publication">
        <dcterms:source><xsl:value-of select="."/></dcterms:source>
    </xsl:template>
    <xsl:template match="duke:interview_location | duke:interview_state | duke:interviewee_birthplace | duke:interviewee_state_of_birth | duke:pubcity | duke:pubcountry | duke:pubregion | duke:pubstate | duke:site_alignment | duke:venue">
        <dcterms:spatial><xsl:value-of select="."/></dcterms:spatial>
    </xsl:template>
    <xsl:template match="duke:awards | duke:chimpanzee | duke:duke_opponent | duke:people | duke:product | duke:race | duke:season | duke:series | duke:subseries | duke:tag">
        <dcterms:subject><xsl:value-of select="."/></dcterms:subject>
    </xsl:template>
    <xsl:template match="duke:headline">
        <dcterms:title><xsl:value-of select="."/></dcterms:title>
    </xsl:template>
    <xsl:template match="duke:dcmitype | duke:genre | duke:record_type">
        <dcterms:type><xsl:value-of select="."/></dcterms:type>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
