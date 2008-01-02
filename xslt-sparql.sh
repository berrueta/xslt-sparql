if [ "aa$M2_REPO" == "aa" ]; then
    echo "Please set the variable \$M2_REPO";
    exit 1;
fi

XSL_FILE=$1
INPUT_FILE=$2

if [ "aa$XSL_FILE" == "aa" ] || [ "bb$INPUT_FILE" == "bb" ]; then
    echo "Syntax: xslt-sparql.sh stylesheet.xsl input-file.xml";
    exit 1;
fi

JAVA=java
JVM_OPTS="-Xmx512M"

$JAVA $JVM_OPTS -classpath \
target/classes:\
$M2_REPO/log4j/log4j/1.2.13/log4j-1.2.13.jar:\
$M2_REPO/xalan/xalan/2.7.0/xalan-2.7.0.jar:\
$M2_REPO/xerces/xercesImpl/2.8.1/xercesImpl-2.8.1.jar:\
$M2_REPO/stax/stax-api/1.0/stax-api-1.0.jar:\
$M2_REPO/antlr/antlr/2.7.5/antlr-2.7.5.jar:\
$M2_REPO/org/codehaus/woodstox/wstx-asl/3.0.0/wstx-asl-3.0.0.jar:\
$M2_REPO/commons-logging/commons-logging/1.1/commons-logging-1.1.jar:\
$M2_REPO/com/hp/hpl/jena/arq/2.1/arq-2.1.jar:\
$M2_REPO/com/hp/hpl/jena/iri/0.5/iri-0.5.jar:\
$M2_REPO/com/hp/hpl/jena/concurrent-jena/1.3.2/concurrent-jena-1.3.2.jar:\
$M2_REPO/com/hp/hpl/jena/jena/2.5.4/jena-2.5.4.jar:\
$M2_REPO/com/ibm/icu/icu4j/3.4.4/icu4j-3.4.4.jar \
org.apache.xalan.xslt.Process -IN $INPUT_FILE -XSL $XSL_FILE


#$M2_REPO/concurrent/concurrent/1.3.4/concurrent-1.3.4.jar:\
