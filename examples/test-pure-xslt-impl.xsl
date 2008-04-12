<?xml version="1.0"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:results="http://www.w3.org/2005/sparql-results#"
                xmlns:xsltsparql="http://berrueta.net/research/xsltsparql"
                extension-element-prefixes="xsltsparql"
                version="2.0">

  <xsl:import href="pure-xslt-impl.xsl"/>

  <xsl:variable name="query">
    SELECT ?x ?name
    WHERE {
       ?x rdf:type     ?name
    }
    LIMIT 10
  </xsl:variable>

  <!-- <xsl:variable name="endpoint">
    <xsl:value-of select="'http://www4.wiwiss.fu-berlin.de/is-group/sparql'"/>
  </xsl:variable> -->
  <!-- <xsl:variable name="endpoint">
    <xsl:value-of select="'http://dbpedia.org/sparql'"/>
  </xsl:variable> -->
  <xsl:variable name="endpoint">
    <xsl:value-of select="'http://192.168.1.248/~berrueta/phpinfo.php'"/>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="xsltsparql:sparqlEndpoint(concat(xsltsparql:commonPrefixes(), $query), $endpoint)"/>
  </xsl:template>

  <xsl:template match="results:results">
    There are <xsl:value-of select="count(results:result)"/> result(s)
  </xsl:template>

</xsl:stylesheet>