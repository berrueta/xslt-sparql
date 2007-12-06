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
	select="sparql:sparql('http://www.w3.org/People/Berners-Lee/card', concat(sparql:commonPrefixes(),
		'SELECT ?x ?name ?mbox_sha1sum ?homepage ?seeAlso
		WHERE {
                   &lt;http://www.w3.org/People/Berners-Lee/card#i&gt; foaf:knows ?x .
		   ?x foaf:name ?name .
                   OPTIONAL {
		     ?x foaf:mbox_sha1sum ?mbox_sha1sum .
                   } .
		   OPTIONAL {
		     ?x foaf:homepage ?homepage
		   } .
                   OPTIONAL {
                     ?x rdfs:seeAlso ?seeAlso
                   }
                   }'))"/>
  </xsl:template>

  <xsl:template match="results:results">
    <html>
      <body>
	<h1>Mis amigos</h1>
	<ul>
	  <xsl:apply-templates select="results:result" mode="follow-see-also-if-available"/>
	</ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="results:result" mode="follow-see-also-if-available">
    <xsl:choose>
      <xsl:when test="results:binding[@name='seeAlso']">
        <xsl:variable name="seeAlso" select="normalize-space(results:binding[@name='seeAlso'])"/>
	<xsl:variable name="friendUri" select="normalize-space(results:binding[@name='x'])"/>
	<xsl:message>Following <xsl:value-of select="$seeAlso"/></xsl:message>
	<xsl:variable name="query" select="concat('
	  SELECT ?name ?mbox_sha1sum ?homepage
	  WHERE {
		   &lt;',$friendUri,'&gt; foaf:name ?name .
                   OPTIONAL {
		     &lt;',$friendUri,'&gt; foaf:mbox_sha1sum ?mbox_sha1sum 
                   } .
		   OPTIONAL {
		     &lt;',$friendUri,'&gt; foaf:homepage ?homepage
		   }
                }')"/>
	  <!--xsl:message><xsl:value-of select="$query"/></xsl:message-->
	  <xsl:apply-templates
	     select="sparql:sparql($seeAlso, concat(sparql:commonPrefixes(), $query))//results:result"/>
      </xsl:when>
      <xsl:otherwise>
<!--        <xsl:apply-templates select="."/> -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="results:result">
    <li>
      <xsl:choose>
        <xsl:when test="results:binding[@name='homepage']">
	  <a>
	    <xsl:attribute name="href">
	      <xsl:value-of select="normalize-space(results:binding[@name='homepage'])"/>
	    </xsl:attribute>
	    <xsl:value-of select="results:binding[@name='name']"/>
	  </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="results:binding[@name='name']"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="results:binding[@name='mbox_sha1sum']">
        , correo:
        <xsl:value-of select="results:binding[@name='mbox_sha1sum']"/>
      </xsl:if>
    </li>
  </xsl:template>

</xsl:stylesheet>
