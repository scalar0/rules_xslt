<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:f="urn:djd:styles"
  exclude-result-prefixes="f xs">

  <!--
    Default path is resolved relative to this common library's base URI.
    Keep WORD_STYLE_MAP.xml in djd_workbook_to_wordml; callers may override StyleMapUri.
  -->
  <xsl:param name="StyleMapUri" select="'../../djd_workbook_to_wordml/WORD_STYLE_MAP.xml'" />
  <xsl:variable name="StyleConfig" select="document($StyleMapUri)/Styles" />

  <xsl:function name="f:lookup-style" as="xs:string">
    <xsl:param name="nodes" as="element()*" />
    <xsl:param name="key" as="xs:string" />
    <xsl:param name="attr" as="xs:string" />
    <xsl:param name="fallback" as="xs:string" />
    <xsl:sequence select="string(($nodes[@key = $key][1]/@*[name() = $attr], $fallback)[1])" />
  </xsl:function>

  <xsl:function name="f:is-true" as="xs:boolean">
    <xsl:param name="value" as="item()?" />
    <xsl:sequence select="lower-case(normalize-space(string($value))) = 'true'" />
  </xsl:function>

  <xsl:function name="f:non-empty" as="xs:string">
    <xsl:param name="value" as="item()?" />
    <xsl:param name="fallback" as="xs:string" />
    <xsl:variable name="s" select="normalize-space(string($value))" />
    <xsl:sequence select="if ($s != '') then $s else $fallback" />
  </xsl:function>

  <xsl:template name="ResolveParagraphStyle">
    <xsl:param name="key" />
    <xsl:value-of select="f:lookup-style($StyleConfig/Paragraph, string($key), 'wordStyle', string($key))" />
  </xsl:template>

  <xsl:template name="ResolveTableStyle">
    <xsl:param name="key" />
    <xsl:value-of select="f:lookup-style($StyleConfig/Table, string($key), 'wordStyle', string($key))" />
  </xsl:template>

  <xsl:template name="EmitParagraphStyle">
    <xsl:param name="key" />
    <xsl:variable name="styleValue">
      <xsl:call-template name="ResolveParagraphStyle">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:variable>
    <w:pStyle w:val="{string($styleValue)}" />
  </xsl:template>

  <xsl:template name="EmitBodyParagraphProperties">
    <xsl:param name="alignment" select="''" />
    <xsl:call-template name="EmitParagraphStyle">
      <xsl:with-param name="key" select="'Body'" />
    </xsl:call-template>
    <xsl:if test="string-length(normalize-space(string($alignment))) &gt; 0">
      <w:jc w:val="{string($alignment)}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="EmitRunFormatting">
    <xsl:param name="key" />
    <xsl:variable name="runConfig" select="$StyleConfig/Run[@key = $key][1]" />
    <xsl:if test="exists($runConfig/@wordStyle)">
      <w:rStyle w:val="{string($runConfig/@wordStyle)}" />
    </xsl:if>
    <xsl:if test="f:is-true($runConfig/@bold)">
      <w:b />
    </xsl:if>
    <xsl:if test="normalize-space(string($runConfig/@color)) != ''">
      <w:color w:val="{string($runConfig/@color)}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="EmitTableStyle">
    <xsl:param name="key" />
    <xsl:variable name="styleValue">
      <xsl:call-template name="ResolveTableStyle">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:variable>
    <w:tblStyle w:val="{string($styleValue)}" />
  </xsl:template>

  <xsl:template name="EmitCellShading">
    <xsl:param name="key" />
    <xsl:variable name="cellConfig" select="$StyleConfig/Cell[@key = $key][1]" />
    <xsl:if test="exists($cellConfig) and normalize-space(string($cellConfig/@fill)) != ''">
      <w:shd
        w:val="{f:non-empty($cellConfig/@pattern, 'clear')}"
        w:color="{f:non-empty($cellConfig/@color, 'auto')}"
        w:fill="{string($cellConfig/@fill)}" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
