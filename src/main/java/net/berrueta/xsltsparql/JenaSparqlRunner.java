package net.berrueta.xsltsparql;

import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.ResultSetFormatter;

class JenaSparqlRunner {

	protected Node executeAndSerializeAsXml(QueryExecution qe,
			Query query) throws SAXException, IOException,
			ParserConfigurationException {
		String xmlResult = null;
		if (query.getQueryType() == Query.QueryTypeSelect) {
			xmlResult = ResultSetFormatter.asXMLString(qe.execSelect());
		}
		else if (query.getQueryType() == Query.QueryTypeAsk) {
			xmlResult = ResultSetFormatter.asXMLString(qe.execAsk());
		}
		else {
			throw new IllegalArgumentException("Only SELECT and ASK queries are allowed");
		}
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		Reader reader = new StringReader(xmlResult);
		Document d = dbf.newDocumentBuilder().parse(new InputSource(reader));
		return d.getFirstChild();
	}

}
