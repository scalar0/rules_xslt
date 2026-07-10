<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  exclude-result-prefixes="w">

  <xsl:output method="xml" indent="no"/>
  <xsl:mode on-no-match="shallow-copy"/>

  <!-- Principal source document (generated WordML to append). -->
  <xsl:variable
    name="input-doc"
    as="document-node()"
    select="/"/>

  <!-- Template Word document.xml distributed as build input resource. -->
  <xsl:variable
    name="template-doc"
    as="document-node()"
    select="doc('../../template_docx/word/document.xml')"/>

  <!-- Drive output from template tree, not from the generated fragment tree. -->
  <xsl:template match="/">
    <xsl:apply-templates select="$template-doc/node()"/>
  </xsl:template>

  <!--
    Append generated WordprocessingML nodes before template section properties.
    Input `src` can be either:
      - a full w:document
      - a w:body fragment
      - one top-level node (e.g. w:p)
  -->
  <xsl:template match="w:body">
    <xsl:variable
      name="append-nodes"
      as="node()*"
      select="
        if ($input-doc/w:document) then $input-doc/w:document/w:body/node()[not(self::w:sectPr)]
        else if ($input-doc/w:body) then $input-doc/w:body/node()[not(self::w:sectPr)]
        else $input-doc/node()"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()[not(self::w:sectPr)]"/>
      <xsl:sequence select="$append-nodes"/>
      <xsl:apply-templates select="w:sectPr"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
