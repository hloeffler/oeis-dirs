#!/bin/sh
wget https://oeis.org/stripped.gz
wget https://oeis.org/names.gz
gunzip --keep names.gz stripped.gz
