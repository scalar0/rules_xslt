<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="urn:split-xml:fanout"
  exclude-result-prefixes="xs f">

  <xsl:param name="itemIds" as="xs:string" />
  <xsl:param name="itemElement" as="xs:string" select="''" />
  <xsl:param name="idElement" as="xs:string" select="'id'" />
  <xsl:param name="outFileSuffix" as="xs:string" select="'.xml'" />

  <xsl:output method="text" encoding="UTF-8" />

  <xsl:function name="f:matches-id" as="xs:boolean">
    <xsl:param name="item" as="element()" />
    <xsl:param name="id-element" as="xs:string" />
    <xsl:param name="requested-id" as="xs:string" />
    <xsl:sequence
      select="exists($item/*[lower-case(local-name()) = lower-case($id-element)][normalize-space(.) = $requested-id])" />
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="items" as="element()*"
      select="if (normalize-space($itemElement) != '')
              then /*/*[local-name() = $itemElement]
              else /*/*" />
    <xsl:variable name="ids" as="xs:string*"
      select="tokenize($itemIds, ',')[normalize-space(.) != ''] ! normalize-space(.)" />

    <xsl:for-each select="$ids">
      <xsl:variable name="item-id" as="xs:string" select="." />
      <xsl:variable name="matches" as="element()*"
        select="$items[f:matches-id(., $idElement, $item-id)]" />

      <xsl:if test="count($matches) ne 1">
        <xsl:message terminate="yes">
          Array fanout expected exactly one match for '<xsl:value-of select="$item-id" />' by element '<xsl:value-of select="$idElement" />', got <xsl:value-of select="count($matches)" />.
        </xsl:message>
      </xsl:if>

      <xsl:result-document href="{concat($item-id, $outFileSuffix)}" method="xml" indent="no" encoding="UTF-8">
        <xsl:sequence select="$matches[1]" />
      </xsl:result-document>
    </xsl:for-each>

    <xsl:text>fanout-complete</xsl:text>
  </xsl:template>
</xsl:stylesheet>
