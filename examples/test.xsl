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

  <xsl:template match="/">
<!--    <xsl:apply-templates select="sparql:sparqlEndpoint('http://www4.wiwiss.fu-berlin.de/is-group/sparql', concat(sparql:commonPrefixes(), 'SELECT ?x ?y ?z WHERE { ?x rdfs:label ?z }'))"/> -->
    <xsl:apply-templates
	select="sparql:sparql(concat(sparql:commonPrefixes(),
		'SELECT ?name ?mbox_sha1sum ?homepage
		FROM &lt;http://www.ivan-herman.net/foaf.rdf&gt;
		WHERE { &lt;http://www.ivan-herman.net/Ivan_Herman&gt; foaf:knows ?x .
		?x foaf:name ?name .
		OPTIONAL {
		  ?x foaf:mbox_sha1sum ?mbox_sha1sum .
		  ?x foaf:homepage ?homepage
		}}'))"/>
  </xsl:template>

  <xsl:template match="results:results">
    <html>
      <body>
	<h1>Mis amigos</h1>
	<ul>
	  <xsl:apply-templates select="*"/>
	</ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="results:result">
    <li>
      <xsl:if test="results:binding[@name='homepage']">
	<a>
	  <xsl:attribute name="href">
	    <xsl:value-of select="normalize-space(results:binding[@name='homepage'])"/>
	  </xsl:attribute>
	  <xsl:value-of select="results:binding[@name='name']"/>
	</a>
      </xsl:if>
      <xsl:value-of select="results:binding[@name='name']"/>
      , correo:
      <xsl:value-of select="results:binding[@name='mbox_sha1sum']"/>
    </li>
  </xsl:template>

</xsl:stylesheet>