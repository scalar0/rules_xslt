<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml">

  <xsl:template name="BuildIdTag">
    <xsl:param name="id" />
    <xsl:value-of select="concat('id=', string(normalize-space($id)))" />
  </xsl:template>

  <xsl:template name="EmitContentControlIdentity">
    <xsl:param name="id" />
    <xsl:param name="name" />
    <xsl:param name="tagSuffix" select="''" />
    <xsl:variable name="machineTagValue"
      select="if (normalize-space(string($tagSuffix)) != '') then string($tagSuffix) else string($name)" />
    <w:id w:val="{string($id)}" />
    <w:tag w:val="{$machineTagValue}" />
    <w:alias w:val="{string($name)}" />
  </xsl:template>

  <xsl:template name="EmitRichTextContentControlProperties">
    <xsl:param name="id" />
    <xsl:param name="name" />
    <xsl:param name="tagSuffix" select="''" />
    <w:sdtPr>
      <xsl:call-template name="EmitContentControlIdentity">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="name" select="$name" />
        <xsl:with-param name="tagSuffix" select="$tagSuffix" />
      </xsl:call-template>
    </w:sdtPr>
  </xsl:template>

  <xsl:template name="EmitRepeatingSectionContentControlProperties">
    <xsl:param name="id" />
    <xsl:param name="name" />
    <xsl:param name="tagSuffix" select="''" />
    <w:sdtPr>
      <xsl:call-template name="EmitContentControlIdentity">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="name" select="$name" />
        <xsl:with-param name="tagSuffix" select="$tagSuffix" />
      </xsl:call-template>
      <w15:repeatingSection />
    </w:sdtPr>
  </xsl:template>

  <xsl:template name="EmitRichTextRowControl">
    <xsl:param name="id" />
    <xsl:param name="name" />
    <xsl:param name="tagSuffix" select="''" />
    <xsl:param name="rowContent" />
    <xsl:param name="isRepeatingSectionItem" select="false()" />
    <w:sdt>
      <xsl:call-template name="EmitRichTextContentControlProperties">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="name" select="$name" />
        <xsl:with-param name="tagSuffix" select="$tagSuffix" />
      </xsl:call-template>
      <xsl:if test="$isRepeatingSectionItem">
        <w15:repeatingSectionItem />
      </xsl:if>
      <w:sdtContent>
        <xsl:copy-of select="$rowContent" />
      </w:sdtContent>
    </w:sdt>
  </xsl:template>

</xsl:stylesheet>
