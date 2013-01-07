<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:apply-templates/>
        </dc>
    </xsl:template>
    <xsl:template match="record">
        <dcterms:title><xsl:value-of select="Title"/></dcterms:title>
        <xsl:for-each select="Subject">
            <xsl:if test=".!=''">
                <dcterms:subject><xsl:value-of select="."/></dcterms:subject>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="Description">
            <xsl:if test=".!=''">
                <dcterms:description><xsl:value-of select="."/></dcterms:description>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="Creator">
            <xsl:if test=".!=''">
                <dcterms:creator><xsl:value-of select="."/></dcterms:creator>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="Date">
            <xsl:if test=".!=''">
                <dcterms:date><xsl:value-of select="."/></dcterms:date>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="Type">
            <xsl:if test=".!=''">
                <dcterms:type><xsl:value-of select="."/></dcterms:type>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="localid">
            <xsl:if test=".!=''">
                <dcterms:identifier><xsl:value-of select="."/></dcterms:identifier>
            </xsl:if>
        </xsl:for-each>        
    </xsl:template>
</xsl:stylesheet>