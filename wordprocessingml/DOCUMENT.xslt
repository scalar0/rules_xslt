<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
                xmlns:wdoc="urn:djd:xslt:wordml:document"
                xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
                xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
                exclude-result-prefixes="wdoc">
  <xsl:template name="EmitWordDocument">
    <xsl:param name="bodyContent" as="node()*" />

    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
      xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
      xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
      xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
      mc:Ignorable="w14 w15">
      <w:body>
        <xsl:sequence select="$bodyContent" />
        <w:sectPr />
      </w:body>
    </w:document>
  </xsl:template>
</xsl:stylesheet>
