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
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/ipsv.rdf'"/>
  <!--xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/gcl2.1.rdf'"/-->
  <!--xsl:param name="rdf-url"
	     select="'http://isegserv.itd.rl.ac.uk/skos/gcl/gcl2.1.rdf'"/-->

  <xsl:template match="/">
    <xsl:variable name="originalModel"
		  select="sparql:readModel($rdf-file)"/>
    <xsl:variable name="complementaryModel"
		  select="sparql:parseString('
			  @prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;.
			  @prefix compl: &lt;http://berrueta.net/skos-compl#&gt;.
			  skos:broader compl:abbr &quot;BT&quot;.
			  skos:narrower compl:abbr &quot;NT&quot;.
			  skos:related compl:abbr &quot;RT&quot;.', 'N3')"/>
    <xsl:variable name="model"
		  select="sparql:mergeModels($originalModel, $complementaryModel)"/>
    <html>
      <head>
	<title>Vocabulary</title>
	<style type="text/css">
	  .prefLabel {
	  font-weight:bold;
	  }
	  .description {
	  font-size:-1;
	  }
	</style>
      </head>
      <body>
	<h1>Vocabulary</h1>
	<ul class="vocabulary">
	  <xsl:apply-templates
	      select="sparql:sparqlModel($model, concat(sparql:commonPrefixes(),
		      'SELECT ?concept ?label ?prefLabel
		      WHERE {{ ?concept skos:prefLabel ?label
			      } UNION {
			      ?concept skos:prefLabel ?prefLabel .
			      ?concept skos:altLabel ?label
                      }}'))/results:results/results:result"
	      mode="entry">
	    <xsl:sort select="results:binding[@name='label']"/>
	    <xsl:with-param name="model" select="$model"/>
	  </xsl:apply-templates>
	</ul>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="results:result" mode="entry">
    <xsl:param name="model"/>
    <li>
      <xsl:choose>
	<xsl:when test="results:binding[@name='prefLabel']">
	  <span class="altLabel"><xsl:value-of select="results:binding[@name='label']"/></span>
	  <ul class="use"><li>
	    <xsl:text>USE </xsl:text><xsl:value-of select="results:binding[@name='prefLabel']"/>
	  </li></ul>
	</xsl:when>
	<xsl:otherwise>
	  <span class="prefLabel"><xsl:value-of select="results:binding[@name='label']"/></span>
	  <xsl:variable name="sparqlQuery"
	      select="concat(sparql:commonPrefixes(),
		      'PREFIX compl: &lt;http://berrueta.net/skos-compl#&gt;
		      SELECT ?sndconcept ?abbr ?label
		      WHERE { &lt;',normalize-space(results:binding[@name='concept']),'&gt; ?p ?sndconcept .
		      ?sndconcept skos:prefLabel ?label .
		      ?p compl:abbr ?abbr }
		      ORDER BY ?abbr ?label')"/>
	  <!--xsl:message>
	    Ampliando informacion sobre
	    <xsl:value-of select="results:binding[@name='concept']"/>
	    con la consulta
	    <xsl:value-of select="$sparqlQuery"/>
	  </xsl:message-->
	  <ul class="description">
	    <xsl:apply-templates select="sparql:sparqlModel($model,$sparqlQuery)/results:results/results:result" mode="description"/>
	  </ul>
	</xsl:otherwise>
      </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="results:result" mode="description">
    <li>
      <xsl:value-of select="results:binding[@name='abbr']"/> <xsl:value-of select="results:binding[@name='label']"/>
    </li>
  </xsl:template>

</xsl:stylesheet>