package net.berrueta.xsltsparql;

import java.io.InputStream;
import java.io.StringBufferInputStream;

import org.apache.log4j.Logger;
import org.apache.xalan.extensions.ExpressionContext;
import org.w3c.dom.Node;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.arp.DOM2Model;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;

public class XalanJenaModelExt extends JenaSparqlRunner {

	private static final Logger logger = Logger.getLogger(XalanJenaModelExt.class);

	public Object readModel(ExpressionContext ec, String url) {
		return readModel(ec, url, null);
	}

	public Object readModel(ExpressionContext ec, String url, String rdfLang) {
		try {
			Model model = ModelFactory.createDefaultModel();
			model.read(url,rdfLang);
			return model;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	public Object readModel(ExpressionContext ec, Node node) {
		try {
			Model model = ModelFactory.createDefaultModel();
			DOM2Model dom2model = DOM2Model.createD2M("", model);
			dom2model.load(node);
			return model;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	public Object addToModel(ExpressionContext ec, Object model, String url) {
		return addToModel(ec, model, url, null);
	}

	public Object addToModel(ExpressionContext ec, Object model, String url, String rdfLang) {
		try {
			Model newModel = ModelFactory.createDefaultModel();
			newModel.add((Model)model);
			newModel.read(url,rdfLang);
			return newModel;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	public Object mergeModels(ExpressionContext ec, Object model1, Object model2) {
		Model newModel = ModelFactory.createDefaultModel();
		newModel.add((Model)model1);
		newModel.add((Model)model2);
		return newModel;
	}

	public Object parseString(ExpressionContext ec, String str) {
		return parseString(ec, str, null);
	}

	public Object parseString(ExpressionContext ec, String str, String rdfLang) {
		logger.debug("Parsing " + str + " as " + rdfLang);
		try {
			Model newModel = ModelFactory.createDefaultModel();
			InputStream is = new StringBufferInputStream(str);
			newModel.read(is, "", rdfLang);
			return newModel;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}	

	public Node sparqlModel(ExpressionContext ec, String queryStr, Object model) {
		try {
			Query query = QueryFactory.create(queryStr);
			QueryExecution qe = QueryExecutionFactory.create(query, (Model) model);
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