export M2_REPO=/home/berrueta/.m2/repository

java -classpath \
target/classes:\
$M2_REPO/log4j/log4j/1.2.13/log4j-1.2.13.jar:\
$M2_REPO/xalan/xalan/2.7.0/xalan-2.7.0.jar:\
$M2_REPO/xerces/xercesImpl/2.8.1/xercesImpl-2.8.1.jar:\
$M2_REPO/stax/stax-api/1.0/stax-api-1.0.jar:\
$M2_REPO/org/codehaus/woodstox/wstx-asl/3.0.0/wstx-asl-3.0.0.jar:\
$M2_REPO/commons-logging/commons-logging/1.1/commons-logging-1.1.jar:\
$M2_REPO/net/sourceforge/jena/arq/2.0/arq-2.0.jar:\
$M2_REPO/net/sourceforge/jena/iri/2.4/iri-2.4.jar:\
$M2_REPO/icu4j/icu4j/3.6.1/icu4j-3.6.1.jar:\
$M2_REPO/concurrent/concurrent/1.3.4/concurrent-1.3.4.jar:\
jena.jar \
org.apache.xalan.xslt.Process -IN prueba.xsl -XSL prueba.xsl

