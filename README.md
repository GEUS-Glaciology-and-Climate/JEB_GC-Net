# JEB_GC-Net

# reading logger data
the folder FORTRAN_read_CR10_CR10x contains the codes for reading logger data. This step outputs the files that comprise "*a.dat" should not be necessary to run

# input data
"*a.dat" files that are output from FORTRAN codes from raw data loggers data; mainly pre-CR1000 CR10 and CR10x logger data...

# aws_qc.pro
aws_qc.pro is IDL code developed by Jason Box 1995-2002 for processing of the input data

# output data
"*c.dat" output by aws_qc.pro

"*q.dat" q is for quality... q.dat files output by aws_qc.pro for quality ID code I developed

see also the instrument height adjustments, i.e. when AWS tower was extended or instrument arms moved
