package net.berrueta.xsltsparql;

import java.io.IOException;
import java.io.Reader;
import java.io.StringBufferInputStream;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.log4j.Logger;
import org.apache.xalan.extensions.ExpressionContext;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.ResultSetFormatter;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

public class XalanExt {

    private static final Logger logger = Logger.getLogger(XalanExt.class);
    
    /**
     * Taken from D2R Server 
     */
    private static final String COMMON_PREFIXES =
        "PREFIX owl: <http://www.w3.org/2002/07/owl#> " +
        "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>" +
        "PREFIX iswc: <http://annotation.semanticweb.org/iswc/iswc.daml#>" +
        "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>" +
        "PREFIX dctype: <http://purl.org/dc/dcmitype/>" +
        "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" +
        "PREFIX foaf: <http://xmlns.com/foaf/0.1/>" +
        "PREFIX dc: <http://purl.org/dc/elements/1.1/>" + 
        "PREFIX doap: <http://usefulinc.com/ns/doap#>" + 
        "PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>" +
        "PREFIX swrc: <http://swrc.ontoware.org/ontology#> ";
    
    public String commonPrefixes() {
        return COMMON_PREFIXES;
    }
    
    public Node sparqlEndpoint(ExpressionContext ec, String endpoint, String queryStr) {
        // logger.info("Método invocado!, endpoint = \"" + endpoint + "\", " +
        //        "query = \"" + queryStr + "\"");
        try {
            Query query = QueryFactory.create(queryStr);
            QueryExecution qe = QueryExecutionFactory.sparqlService(endpoint, query);
            return executeAndSerializeAsXml(qe);
        } catch (RuntimeException e) {
            logger.error("Runtime error", e);
            throw e;
        } catch (Exception e) {
            logger.error("Error", e);
            throw new RuntimeException(e);
        }
    }

    public Node sparql(ExpressionContext ex, String file, String queryStr) {
	return sparql(ex, file, queryStr, null);
    }
    
    public Node sparql(ExpressionContext ec, String file, String queryStr, String rdfLang) {
        // logger.info("Método invocado!, fichero = \"" + file + "\", " +
        //        "query = \"" + queryStr + "\"");
        try {            
            Query query = QueryFactory.create(queryStr);
            Model model = ModelFactory.createDefaultModel();
            model.read(file,rdfLang);
            QueryExecution qe = QueryExecutionFactory.create(query, model);
            return executeAndSerializeAsXml(qe);
        } catch (RuntimeException e) {
            logger.error("Runtime error", e);
            throw e;
        } catch (Exception e) {
            logger.error("Error", e);
            throw new RuntimeException(e);
        }
    }

    private Node executeAndSerializeAsXml(QueryExecution qe) throws SAXException, IOException, ParserConfigurationException {
        String xmlResult = ResultSetFormatter.asXMLString(qe.execSelect());
        //logger.fatal("RESULT: " + xmlResult);
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        dbf.setNamespaceAware(true);
        Reader reader = new StringReader(xmlResult);
        Document d = dbf.newDocumentBuilder().parse(new InputSource(reader));
        return d.getFirstChild();
    }
    
}
