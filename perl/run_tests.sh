#!/bin/bash

here=$PWD
quattor=../../
maventools=$quattor/maven-tools/build-scripts/src/main/perl/

prove -r -v -I$here/src/main/perl -I$maventools -I/usr/lib/perl src/test/perl/$@
