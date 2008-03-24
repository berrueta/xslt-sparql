/*
 *  Copyright 2008 Diego Berrueta
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *    http://www.apache.org/licenses/LICENSE-2.0
 *    
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package net.berrueta.xsltsparql;

import org.apache.log4j.Logger;
import org.apache.xalan.extensions.ExpressionContext;
import org.w3c.dom.Node;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;

/**
 * An implementation of the simple function set of XSLT+SPARQL. Note
 * that the implementation is not complete because there is no support
 * for var-arg methods
 * 
 * @author berrueta
 *
 */
public class XalanExt extends JenaSparqlRunner {

	private static final Logger logger = Logger.getLogger(XalanExt.class);

	/**
	 * Definition of prefixes for some common RDF namespaces
	 */
	private static final String COMMON_PREFIXES =
		"PREFIX owl: <http://www.w3.org/2002/07/owl#> " +
		"PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> " +
		"PREFIX iswc: <http://annotation.semanticweb.org/iswc/iswc.daml#> " +
		"PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> " +
		"PREFIX dctype: <http://purl.org/dc/dcmitype/> " +
		"PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> " +
		"PREFIX foaf: <http://xmlns.com/foaf/0.1/> " +
		"PREFIX dc: <http://purl.org/dc/elements/1.1/> " + 
		"PREFIX doap: <http://usefulinc.com/ns/doap#> " + 
		"PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#> " +
		"PREFIX skos: <http://www.w3.org/2004/02/skos/core#> " +
		"PREFIX swrc: <http://swrc.ontoware.org/ontology#> ";

	/**
	 * Produces a SPARQL header containing prefix declarations for
	 * some of the most popular RDF namespaces, including RDF (rdf:),
	 * RDF Schema (rdfs:), OWL (owl:), FOAF (foaf:) and others
	 * 
	 * @return A string that contains SPARQL 'PREFIX' declarations for
	 * some of the most popular namespaces
	 */
	public String commonPrefixes() {
		return COMMON_PREFIXES;
	}

	/**
	 * Executes a SPARQL query against an SPARQL endpoint
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param queryStr SPARQL query string
	 * @param endpoint URI of an SPARQL endpoint
	 * @return The document node of the XML document that contains the
	 * results of the query
	 */
	public Node sparqlEndpoint(ExpressionContext ec, String queryStr, String endpoint) {
		try {
			Query query = QueryFactory.create(queryStr);
			QueryExecution qe = QueryExecutionFactory.sparqlService(endpoint, query);
			return executeAndSerializeAsXml(qe, query);
		} catch (RuntimeException e) {
			logger.error("Runtime error", e);
			throw e;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	/**
	 * Executes a SPARQL query
	 * 
	 * @param ex Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param queryStr SPARQL query string
	 * @return The document node of the XML document that contains the
	 * results of the query
	 */
	public Node sparql(ExpressionContext ex, String queryStr) {
		try {
			Query query = QueryFactory.create(queryStr);
			QueryExecution qe = QueryExecutionFactory.create(query);
			return executeAndSerializeAsXml(qe, query);
		} catch (RuntimeException e) {
			logger.error("Runtime error", e);
			throw e;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}	        
	}

	/**
	 * Executes a SPARQL query against the contents of an RDF document
	 * 
	 * @param ex Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param queryStr SPARQL query string
	 * @param file URL of an RDF document, which contents will be used
	 * as default dataset to execute the query
	 * @return The document node of the XML document that contains the
	 * results of the query
	 */
	public Node sparql(ExpressionContext ex, String queryStr, String file) {
		try {            
			Query query = QueryFactory.create(queryStr);
			query.addGraphURI(file);
			//Dataset dataset = DatasetFactory.create(file);
			QueryExecution qe = QueryExecutionFactory.create(query);
			return executeAndSerializeAsXml(qe, query);
		} catch (RuntimeException e) {
			logger.error("Runtime error", e);
			throw e;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

}
