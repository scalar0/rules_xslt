<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">

  <xsl:template name="EmitPreservedTextRun">
    <xsl:param name="text" />
    <xsl:if test="string-length($text) &gt; 0">
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
      </w:r>
    </xsl:if>
  </xsl:template>

  <xsl:template name="RenderTextSegmentsCore">
    <xsl:param name="text" />
    <xsl:param name="enableReferences" select="true()" />
    <xsl:for-each select="tokenize($text, '&#10;')">
      <xsl:call-template name="RenderSegmentContent">
        <xsl:with-param name="text" select="." />
        <xsl:with-param name="enableReferences" select="$enableReferences" />
      </xsl:call-template>
      <xsl:if test="position() != last()">
        <w:r>
          <w:br />
        </w:r>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="RenderPlainTextWithLineBreaks">
    <xsl:param name="text" />
    <xsl:call-template name="RenderTextSegmentsCore">
      <xsl:with-param name="text" select="translate($text, '&#13;', '')" />
      <xsl:with-param name="enableReferences" select="false()" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="EmitBodyParagraphWithText">
    <xsl:param name="text" />
    <w:p>
      <w:pPr>
        <xsl:call-template name="EmitBodyParagraphProperties">
          <xsl:with-param name="alignment" select="''" />
        </xsl:call-template>
      </w:pPr>
      <xsl:call-template name="EmitPreservedTextRun">
        <xsl:with-param name="text" select="$text" />
      </xsl:call-template>
    </w:p>
  </xsl:template>

  <xsl:template name="RenderParagraphLines">
    <xsl:param name="text" />
    <xsl:for-each select="tokenize($text, '&#10;')">
      <xsl:call-template name="EmitBodyParagraphWithText">
        <xsl:with-param name="text" select="." />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="RenderJustificationParagraphs">
    <xsl:param name="text" />
    <xsl:call-template name="RenderParagraphLines">
      <xsl:with-param name="text" select="translate($text, '&#13;', '')" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
