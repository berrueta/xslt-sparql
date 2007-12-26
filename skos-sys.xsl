<?xml version="1.0"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:results="http://www.w3.org/2005/sparql-results#"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:sparql="XalanExt"
                extension-element-prefixes="sparql"
                version="2.0">

  <xalan:component prefix="sparql">
    <xalan:script lang="javaclass" src="xalan://net.berrueta.xsltsparql.XalanExt"/>
  </xalan:component>

  <xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/norman-walsh.rdf'"/>
  <!--xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/ipsv.rdf'"/-->
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
	  <xsl:variable name="nestedBlock">
	  <xsl:apply-templates
	      select="sparql:sparqlModel($model, concat(sparql:commonPrefixes(),
		      'SELECT ?concept ?prefLabel
		      WHERE {?x skos:hasTopConcept ?concept .
		      ?concept skos:prefLabel ?prefLabel}
		      ORDER BY ?prefLabel'))/results:results/results:result"
	      mode="prefLabelEntry">
	    <xsl:with-param name="model" select="$model"/>
	  </xsl:apply-templates>
	  </xsl:variable>
	  <xsl:apply-templates select="xalan:nodeset($nestedBlock)" mode="addNumbers"/>
	</ul>
      </body>
    </html>
  </xsl:template>

  <!-- First pass ******************************************* -->

  <xsl:template match="results:result" mode="prefLabelEntry">
    <xsl:param name="model"/>
    <li> 
      <span class="idnumber"></span>
      <span class="prefLabel"><xsl:value-of select="results:binding[@name='prefLabel']"/></span>
      <xsl:variable name="conceptUri"
		    select="normalize-space(results:binding[@name='concept'])"/>
      <ul>
	<xsl:apply-templates mode="relatedTerms"
			     select="sparql:sparqlModel($model, concat(sparql:commonPrefixes(),
				     'SELECT ?relatedConcept ?prefLabel
				     WHERE { &lt;',$conceptUri,'&gt; skos:relatedTerm ?relatedConcept .
				     ?relatedConcept skos:prefLabel ?prefLabel}
				     ORDER BY ?prefLabel'))/results:results/results:result">
	  <xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>
	<xsl:apply-templates mode="prefLabelEntry"
			     select="sparql:sparqlModel($model, concat(sparql:commonPrefixes(),
				     'SELECT ?concept ?prefLabel
				     WHERE { &lt;',$conceptUri,'&gt; skos:narrower ?concept .
				     ?concept skos:prefLabel ?prefLabel}
				     ORDER BY ?prefLabel'))/results:results/results:result">
	  <xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>
      </ul>
    </li>
  </xsl:template>
<!--	  <xsl:variable name="sparqlQuery"
	      select="concat(sparql:commonPrefixes(),
		      'PREFIX compl: &lt;http://berrueta.net/skos-compl#&gt;
		      SELECT ?sndconcept ?abbr ?label
		      WHERE { &lt;',normalize-space(results:binding[@name='concept']),'&gt; ?p ?sndconcept .
		      ?sndconcept skos:prefLabel ?label .
		      ?p compl:abbr ?abbr }
		      ORDER BY ?abbr ?label')"/>
-->

  <xsl:template match="results:result" mode="relatedTerms">
    <li>
      RT <xsl:value-of select="results:binding[@name='prefLabel']"/>
    </li>
  </xsl:template>

  <!-- Second pass ******************************************* -->

  <xsl:template match="span[@class='idnumber']" mode="addNumbers">
    <span class="idnumber">
      <xsl:number count="span[@class='idnumber']" level="any"/>
    </span>
  </xsl:template>

  <!-- identity -->
  <xsl:template match="@*|node()" mode="addNumbers">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="addNumbers"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>