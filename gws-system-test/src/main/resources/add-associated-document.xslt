<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:geo="urn:xml-gov-au:icsm:egeodesy:0.5"
        xmlns:gml="http://www.opengis.net/gml/3.2"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        version="1.0">
    <xsl:param name="description"/>
    <xsl:param name="documentName"/>
    <xsl:param name="contentType"/>
    <xsl:param name="createdDate"/>
    <xsl:param name="fileReference"/>

    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="geo:moreInformation">
        <xsl:copy-of select="."/>
        <xsl:element name="geo:associatedDocument">
            <xsl:element name="geo:Document">
                <xsl:attribute name="gml:id">Document.<xsl:value-of select="$documentName"/></xsl:attribute>
                <xsl:element name="gml:description">
                    <xsl:value-of select="$description"/>
                </xsl:element>
                <xsl:element name="gml:name">
                    <xsl:attribute name="codeSpace">eGeodesy/type</xsl:attribute>
                    <xsl:value-of select="$documentName"/>
                </xsl:element>
                <xsl:element name="gml:boundedBy">
                    <xsl:attribute name="xsi:nil">true</xsl:attribute>
                </xsl:element>
                <xsl:element name="geo:type">
                    <xsl:attribute name="codeSpace">eGeodesy/type</xsl:attribute>
                    <xsl:value-of select="$contentType"/>
                </xsl:element>
                <xsl:element name="geo:createdDate">
                    <xsl:value-of select="$createdDate"/>
                </xsl:element>
                <xsl:element name="geo:body">
                    <xsl:element name="geo:fileReference">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$fileReference"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
