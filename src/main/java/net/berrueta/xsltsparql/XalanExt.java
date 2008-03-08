package net.berrueta.xsltsparql;

import org.apache.log4j.Logger;
import org.apache.xalan.extensions.ExpressionContext;
import org.w3c.dom.Node;

import com.hp.hpl.jena.query.Dataset;
import com.hp.hpl.jena.query.DatasetFactory;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;

public class XalanExt extends JenaSparqlRunner {

	private static final Logger logger = Logger.getLogger(XalanExt.class);

	/**
	 * Taken from D2R Server 
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

	public String commonPrefixes() {
		return COMMON_PREFIXES;
	}

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
