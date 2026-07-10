<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
                xmlns:wtbl="urn:djd:xslt:wordml:tables"
                exclude-result-prefixes="wtbl">

  <xsl:template name="EmitStandardTableProperties">
    <xsl:param name="styleKey" select="''" />
    <xsl:param name="noBorders" select="false()" />
    <w:tblPr>
      <xsl:if test="string-length(normalize-space($styleKey)) &gt; 0">
        <xsl:call-template name="EmitTableStyle">
          <xsl:with-param name="key" select="$styleKey" />
        </xsl:call-template>
      </xsl:if>
      <w:tblW w:w="0" w:type="auto" />
      <w:tblLayout w:type="autofit" />
      <xsl:if test="$noBorders">
        <w:tblBorders>
          <w:top w:val="nil" />
          <w:left w:val="nil" />
          <w:bottom w:val="nil" />
          <w:right w:val="nil" />
          <w:insideH w:val="nil" />
          <w:insideV w:val="nil" />
        </w:tblBorders>
      </xsl:if>
    </w:tblPr>
  </xsl:template>

  <xsl:template name="EmitStaticHeaderParagraph">
    <xsl:param name="text" />
    <w:p>
      <w:pPr>
        <xsl:call-template name="EmitBodyParagraphProperties">
          <xsl:with-param name="alignment" select="'center'" />
        </xsl:call-template>
      </w:pPr>
      <w:r>
        <w:rPr>
          <xsl:call-template name="EmitRunFormatting">
            <xsl:with-param name="key" select="'StaticLabelText'" />
          </xsl:call-template>
        </w:rPr>
        <w:t>
          <xsl:value-of select="$text" />
        </w:t>
      </w:r>
    </w:p>
  </xsl:template>

  <xsl:template name="EmitStaticHeaderCell">
    <xsl:param name="text" />
    <xsl:param name="gridSpan" select="0" />
    <xsl:param name="widthDxa" select="0" />
    <w:tc>
      <w:tcPr>
        <xsl:if test="number($widthDxa) &gt; 0">
          <w:tcW w:w="{$widthDxa}" w:type="dxa" />
        </xsl:if>
        <xsl:if test="number($gridSpan) &gt; 0">
          <w:gridSpan w:val="{$gridSpan}" />
        </xsl:if>
        <xsl:call-template name="EmitCellShading">
          <xsl:with-param name="key" select="'StaticHeaderCell'" />
        </xsl:call-template>
      </w:tcPr>
      <xsl:call-template name="EmitStaticHeaderParagraph">
        <xsl:with-param name="text" select="$text" />
      </xsl:call-template>
    </w:tc>
  </xsl:template>

  <xsl:template name="EmitApprovalCheckboxCell">
    <xsl:param name="id" />
    <xsl:param name="name" />
    <xsl:param name="tagSuffix" select="''" />
    <xsl:param name="label" />
    <xsl:param name="styleKey" />

    <w:tc>
      <w:p>
        <w:pPr>
          <xsl:call-template name="EmitBodyParagraphProperties">
            <xsl:with-param name="alignment" select="'center'" />
          </xsl:call-template>
        </w:pPr>
        <w:sdt>
          <w:sdtPr>
            <xsl:call-template name="EmitContentControlIdentity">
              <xsl:with-param name="id" select="$id" />
              <xsl:with-param name="name" select="$name" />
              <xsl:with-param name="tagSuffix" select="$tagSuffix" />
            </xsl:call-template>
            <w14:checkbox>
              <w14:checked w14:val="0" />
              <w14:checkedState w14:val="2612" w14:font="MS Gothic" />
              <w14:uncheckedState w14:val="2610" w14:font="MS Gothic" />
            </w14:checkbox>
          </w:sdtPr>
          <w:sdtContent>
            <w:r>
              <w:t>☐</w:t>
            </w:r>
          </w:sdtContent>
        </w:sdt>
        <w:r>
          <w:rPr>
            <xsl:call-template name="EmitRunFormatting">
              <xsl:with-param name="key" select="$styleKey" />
            </xsl:call-template>
          </w:rPr>
          <w:t xml:space="preserve"><xsl:value-of select="concat(' ', $label)" /></w:t>
        </w:r>
      </w:p>
    </w:tc>
  </xsl:template>

</xsl:stylesheet>
