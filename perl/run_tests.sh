#!/bin/bash

here=$PWD

cd test/perl
prove -r -v -I$here/src $@
