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

/**
 * An implementation of the advanced function set of XSLT+SPARQL.
 * 
 * @author berrueta
 *
 */
public class XalanModelExt extends JenaSparqlRunner {

	private static final Logger logger = Logger.getLogger(XalanModelExt.class);

	/**
	 * Creates a new model using the data read from an RDF document
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param documentUrl URL of an RDF document
	 * @return A new model containing the data read from the provided
	 * document
	 */
	public Object readModel(ExpressionContext ec, String documentUrl) {
		return readModel(ec, documentUrl, null);
	}

	/**
	 * Creates a new model using the data read from an RDF document
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param documentUrl URL of an RDF document
	 * @param serializationSyntax Name of the serialization syntax.
	 * Valid values for this parameter are those admitted by Jena
	 * @return A new model with the contents resulting from parsing as
	 * RDF/XML the contents of the subtree provided
	 * @see http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/rdf/model/Model.html#read(java.lang.String,%20java.lang.String)
	 */
	public Object readModel(ExpressionContext ec, String documentUrl, String serializationSyntax) {
		try {
			Model model = ModelFactory.createDefaultModel();
			model.read(documentUrl,serializationSyntax);
			return model;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	/**
	 * Creates a new model using the data from parsing as RDF/XML the
	 * document fragment provided as parameter
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param node Root of the document fragment to be parsed as RDF/XML
	 * @return A new model with the contents resulting from parsing as
	 * RDF/XML the contents of the subtree provided
	 */
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

	/**
	 * Creates a new model merging an existing model and the data read
	 * from an RDF document
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param existingModel An existing model that won't be affected
	 * @param documentUrl URL of an RDF document
	 * @return A new model that contains the dataset that results from merging
	 * the provided model with the contents read from the RDF document
	 */
	public Object addToModel(ExpressionContext ec, Object existingModel, String documentUrl) {
		return addToModel(ec, existingModel, documentUrl, null);
	}

	/**
	 * Creates a new model merging an existing model and the data read
	 * from an RDF document
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param existingModel An existing model that won't be affected
	 * @param documentUrl URL of an RDF document
	 * @param serializationSyntax Name of the serialization syntax.
	 * Valid values for this parameter are those admitted by Jena
	 * @return A new model that contains the dataset that results from merging
	 * the provided model with the contents read from the RDF document
	 * @see http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/rdf/model/Model.html#read(java.lang.String,%20java.lang.String)
	 */
	public Object addToModel(ExpressionContext ec, Object existingModel, String documentUrl, String serializationSyntax) {
		try {
			Model newModel = ModelFactory.createDefaultModel();
			newModel.add((Model)existingModel);
			newModel.read(documentUrl,serializationSyntax);
			return newModel;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}

	/**
	 * Creates a new model with the merged data from two existing models
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param model1 An existing model that won't be affected
	 * @param model2 An existing model that won't be affected
	 * @return A new model that contains the dataset that results from merging
	 * the two models
	 */
	public Object mergeModels(ExpressionContext ec, Object model1, Object model2) {
		Model newModel = ModelFactory.createDefaultModel();
		newModel.add((Model)model1);
		newModel.add((Model)model2);
		return newModel;
	}

	/**
	 * Creates a new model by parsing a string containing RDF data
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param stringToParse A string containing serialized RDF
	 * @return A new model with the contents resulting from parsing
	 * the string as serialized RDF
	 */
	public Object parseString(ExpressionContext ec, String stringToParse) {
		return parseString(ec, stringToParse, null);
	}

	/**
	 * Creates a new model by parsing a string containing RDF data
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param stringToParse A string containing serialized RDF
	 * @param serializationSyntax Name of the serialization syntax.
	 * Valid values for this parameter are those admitted by Jena
	 * @return A new model with the contents resulting from parsing
	 * the string as serialized RDF
	 * @see http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/rdf/model/Model.html#read(java.lang.String,%20java.lang.String)
	 */
	public Object parseString(ExpressionContext ec, String stringToParse, String serializationSyntax) {
		logger.debug("Parsing " + stringToParse + " as " + serializationSyntax);
		try {
			Model newModel = ModelFactory.createDefaultModel();
			InputStream is = new StringBufferInputStream(stringToParse);
			newModel.read(is, "", serializationSyntax);
			return newModel;
		} catch (Exception e) {
			logger.error("Error", e);
			throw new RuntimeException(e);
		}
	}	

	/**
	 * Executes a SPARQL query against an in-memory model
	 * 
	 * @param ec Context provided by the XSLT processor, users
	 * of the extension function won't see this parameter
	 * @param sparqlQuery SPARQL query string
	 * @param model The model that will be queried
	 * @return The document node of the XML document that contains the
	 * results of the query
	 */
	public Node sparqlModel(ExpressionContext ec, String sparqlQuery, Object model) {
		try {
			Query query = QueryFactory.create(sparqlQuery);
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
