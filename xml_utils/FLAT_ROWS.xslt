<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="urn:djd:workbooks"
  exclude-result-prefixes="f xs">

  <xsl:function name="f:field" as="xs:string">
    <xsl:param name="row" as="element()" />
    <xsl:param name="name" as="xs:string" />
    <xsl:sequence select="normalize-space(string($row/*[local-name() = $name][1]))" />
  </xsl:function>

  <xsl:function name="f:first-non-empty" as="xs:string">
    <xsl:param name="rows" as="element()*" />
    <xsl:param name="name" as="xs:string" />
    <xsl:variable name="non-empty" as="xs:string*"
      select="(for $r in $rows return f:field($r, $name))[. != '']" />
    <xsl:sequence select="($non-empty, f:field($rows[1], $name))[1]" />
  </xsl:function>

</xsl:stylesheet>
