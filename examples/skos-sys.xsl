<?xml version="1.0"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:results="http://www.w3.org/2005/sparql-results#"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:sparql="XalanExt"
                xmlns:sparqlModel="XalanModelExt"
                extension-element-prefixes="sparql sparqlModel"
                version="2.0">

  <!-- *********************************************************
       An XSLT+SPARQL stylesheet to produce a systematic display
       from a thesaurus encoded in SKOS. The results follows
       the guidelines in section 9.3 of ISO 2788-1986. More
       on this at http://www.w3.org/2006/07/SWD/wiki/SkosDesign/PresentationInformation

       There are some configuration parameters below, you can
       tune them to customize the result. It is also possible to
       edit the markup and the CSS.

       (c) Diego Berrueta, 2008

       ********************************************************* -->

  <!-- KNOWN LIMITATIONS:
       - Definitions and scope notes (SN) are ignored.
       - References to non-preferred labels and top terms are ignored.
       - A definition of the ConceptScheme is required. This concept
         scheme must have pointers to the top concepts
	 (skos:hasTopConcept).
       - The thesaurus must contain explicit skos:narrower relations,
         or a reasoner must be applied beforehand to infer them.
  -->

  <!-- BEGIN of configuration parameters -->

  <!-- The language of thesaurus. Only one language can be displayed at
  a time, so you have to choose what language do you want. Use the
  empty string for the default language -->
  <xsl:param name="lang" select="''"/>

  <!--xsl:param name="rdf-file"
	     select="'file:///Users/berrueta/Documents/transforma-rdf/xslt-sparql/skos/norman-walsh.rdf'"/-->
  <!--xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/ipsv.rdf'"/-->
  <!--xsl:param name="rdf-file"
	     select="'file:///Users/diego/scratch/svn/transforma-rdf/xslt-sparql/skos/gcl2.1.rdf'"/-->
  <!--xsl:param name="rdf-url"
	     select="'http://isegserv.itd.rl.ac.uk/skos/gcl/gcl2.1.rdf'"/-->

  <!-- END of configuration parameters -->

  <xalan:component prefix="sparql">
    <xalan:script lang="javaclass" src="xalan://net.berrueta.xsltsparql.XalanExt"/>
  </xalan:component>

  <xalan:component prefix="sparqlModel">
    <xalan:script lang="javaclass" src="xalan://net.berrueta.xsltsparql.XalanModelExt"/>
  </xalan:component>

  <xsl:template match="/">
<!--    <xsl:variable name="originalModel"
		  select="sparql:readModel($rdf-file)"/> -->
    <xsl:variable name="originalModel"
		  select="sparqlModel:readModel(.)"/>
    <xsl:variable name="complementaryModel"
		  select="sparqlModel:parseString('
			  @prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;.
			  @prefix compl: &lt;http://berrueta.net/skos-compl#&gt;.
			  skos:broader compl:abbr &quot;BT&quot;.
			  skos:narrower compl:abbr &quot;NT&quot;.
			  skos:related compl:abbr &quot;RT&quot;.', 'N3')"/>
    <xsl:variable name="model"
		  select="sparqlModel:mergeModels($originalModel, $complementaryModel)"/>
    <html>
      <head>
	<title>Vocabulary: systematic display</title>
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
	<h1>Vocabulary: systematic display</h1>
	<ul class="vocabulary">
	  <xsl:variable name="nestedBlock">
	  <xsl:apply-templates
	      select="sparqlModel:sparqlModel(concat(sparql:commonPrefixes(),
		      'SELECT ?concept ?prefLabel
	 	       WHERE {
                          ?x skos:hasTopConcept ?concept .
		          ?concept skos:prefLabel ?prefLabel .
		          FILTER (lang(?prefLabel)=&quot;',$lang,'&quot;)
                       }
		       ORDER BY ?prefLabel'), $model)/results:results/results:result"
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

        <!-- prints related terms -->
	<xsl:apply-templates mode="relatedTerms"
			     select="sparqlModel:sparqlModel(concat(sparql:commonPrefixes(),
				     'SELECT ?relatedConcept ?prefLabel
				      WHERE {
				         &lt;',$conceptUri,'&gt; skos:related ?relatedConcept .
				         ?relatedConcept skos:prefLabel ?prefLabel .
				         FILTER (lang(?prefLabel)=&quot;',$lang,'&quot;)
				      }
				      ORDER BY ?prefLabel'), $model)/results:results/results:result">
	  <xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>

        <!-- find every collection which contain at least one
             child (NT) of the current concept -->
        <xsl:variable name="collections"
                      select="sparqlModel:sparqlModel(concat(sparql:commonPrefixes(),
                                     'SELECT DISTINCT ?collection ?collectionLabel
                                      WHERE {
                                         ?collection rdf:type    skos:Collection  .
                                         ?collection rdfs:label  ?collectionLabel .
                                         &lt;',$conceptUri,'&gt; skos:narrower ?child .
                                         ?collection skos:member ?child .
				         FILTER (lang(?collectionLabel)=&quot;',$lang,'&quot;)
                                      }
                                      ORDER BY ?collectionLabel
                                      '), $model)/results:results/results:result" />
        <xsl:for-each select="$collections">
          <li>(<xsl:value-of select="results:binding[@name='collectionLabel']"/>)</li>
          <ul>
            <!-- find every child concept that belong to the current
                 collection -->
            <xsl:variable name="childMembers"
                        select="sparqlModel:sparqlModel(concat(sparql:commonPrefixes(),
				     'SELECT ?concept ?prefLabel
				      WHERE {
				         &lt;',$conceptUri,'&gt; skos:narrower ?concept .
				         ?concept skos:prefLabel ?prefLabel .
                                         &lt;',normalize-space(results:binding[@name='collection']),'&gt; skos:member ?concept .
				         FILTER (lang(?prefLabel)=&quot;',$lang,'&quot;)
				      }
				      ORDER BY ?prefLabel'), $model)/results:results/results:result" />
            <xsl:apply-templates select="$childMembers" mode="prefLabelEntry">	
              <xsl:with-param name="model" select="$model"/>
            </xsl:apply-templates>
          </ul>
        </xsl:for-each>

        <!-- prints all the child concepts which are not in any
             collection -->
        <xsl:variable name="uncollectedNarrowerConcepts"
                      select="sparqlModel:sparqlModel(concat(sparql:commonPrefixes(),
				     'SELECT ?concept ?prefLabel
				      WHERE {
				         &lt;',$conceptUri,'&gt; skos:narrower ?concept .
				         ?concept skos:prefLabel ?prefLabel .
                                         OPTIONAL {
                                           ?collection rdf:type skos:Collection .
                                           ?collection skos:member ?concept
                                         } .
				         FILTER (lang(?prefLabel)=&quot;',$lang,'&quot;) .
                                         FILTER ( !bound(?collection))
				      }
				      ORDER BY ?prefLabel'), $model)/results:results/results:result" />
	<xsl:apply-templates select="$uncollectedNarrowerConcepts" mode="prefLabelEntry">	
	  <xsl:with-param name="model" select="$model"/>
	</xsl:apply-templates>
      </ul>
    </li>
  </xsl:template>

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