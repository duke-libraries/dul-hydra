<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:apply-templates/>
        </dc>
    </xsl:template>
    <xsl:template match="Row">
        <xsl:if test="Title">
            <dcterms:title><xsl:value-of select="Title"/></dcterms:title>
        </xsl:if>
        <xsl:if test="ID">
            <dcterms:identifier><xsl:value-of select="ID"/></dcterms:identifier>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>