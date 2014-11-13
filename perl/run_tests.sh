#!/bin/bash


here=$PWD
rm -Rf target/

quattor=../../
maventools=$quattor/maven-tools/build-scripts/src/main/perl/
export QUATTOR_TEST_TEMPLATE_LIBRARY_CORE=$quattor/template-library-core

prove -r -v -I$here/src/main/perl -I$maventools -I/usr/lib/perl src/test/perl/$@
