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

  <xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/gcl2.1.rdf'"/>
  <xsl:param name="rdf-url"
	     select="'http://isegserv.itd.rl.ac.uk/skos/gcl/gcl2.1.rdf'"/>

  <xsl:template match="/">
    <html>
      <body>
	<h1>Vocabulary</h1>
	<ul>
	  <xsl:apply-templates
	      select="sparql:sparql($rdf-file, concat(sparql:commonPrefixes(),
		      'PREFIX skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;
		      SELECT ?concept ?prefLabel ?altLabel
		      WHERE {{ ?concept skos:prefLabel ?prefLabel
			      } UNION {
			      ?concept skos:altLabel ?altLabel .
			      ?concept skos:prefLabel ?prefLabel
                      }}'))/results:results/results:result"
	      mode="entry">
	    <xsl:sort select="concat(results:binding[@name='altLabel'],results:binding[@name='prefLabel'])"/>
	  </xsl:apply-templates>
	</ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="results:result" mode="entry">
    <li>
      <xsl:choose>
	<xsl:when test="results:binding[@name='altLabel']">
	  <xsl:value-of select="results:binding[@name='altLabel']"/>
	  <xsl:text>USE </xsl:text><xsl:value-of select="results:binding[@name='prefLabel']"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="results:binding[@name='prefLabel']"/>
	  <xsl:variable name="sparqlQuery"
	      select="concat('PREFIX skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;
		      SELECT ?p ?o
		      WHERE { &lt;',normalize-space(results:binding[@name='concept']),'&gt; ?p ?o }')"/>
	  <xsl:message>
	    Ampliando informacion sobre
	    <xsl:value-of select="results:binding[@name='concept']"/>
	    con la consulta
	    <xsl:value-of select="$sparqlQuery"/>
	  </xsl:message>
	  <xsl:apply-templates select="sparql:sparql($rdf-file,$sparqlQuery)/results:results/results:result" mode="description"/>
	</xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="results:result" mode="description">
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>