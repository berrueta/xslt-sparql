<?xml version="1.0"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:results="http://www.w3.org/2005/sparql-results#"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:sparql="XalanExt"
                extension-element-prefixes="sparql"
                version="1.0">

  <xalan:component prefix="sparql">
    <xalan:script lang="javaclass" src="xalan://net.berrueta.xsltsparql.XalanExt"/>
  </xalan:component>

  <xsl:variable name="query"><![CDATA[
    SELECT ?name ?person ?img
    WHERE {
       ?person dcterms:subject   <http://dbpedia.org/resource/Category:Spanish_film_actors> ;
               rdfs:label     ?name ;
               foaf:depiction ?img .
       FILTER (lang(?name)="es")
    }
    ORDER BY ?name   
    LIMIT 20 
  ]]></xsl:variable>

  <xsl:template match="/">
    <html>
      <body>
	<h1>Actors</h1>
	<ul>
	  <xsl:apply-templates select="sparql:sparqlEndpoint(
             concat(sparql:commonPrefixes(), $query),
             'http://dbpedia.org/sparql')"/>
	</ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="results:result">
    <li>
      <xsl:value-of select="results:binding[@name='name']"/>
      <img>
	<xsl:attribute name="src">
	  <xsl:value-of select="results:binding[@name='img']"/>
	</xsl:attribute>
      </img>
    </li>
  </xsl:template>

</xsl:stylesheet>