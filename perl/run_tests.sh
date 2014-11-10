#!/bin/bash

here=$PWD

prove -r -v -I$here/src/main/perl src/test/perl/$@
