#!/bin/bash


set id_user = $USER
set id_pwfile = /home/$USER/.y
set id_pswd = `cat $id_pwfile`
set id_loader_dir = idload

# Run the Python script

#------------------------------------------------------------------
# Environmental stuff.
#------------------------------------------------------------------

set path = ( /net/idflow02/export/d0/gbutils $path )
set path = ( /netopt/genbank/subtool/b
source /am/ncbiapdata/database_env/id_env.csh

setenv IDLOADSEQENTRY "idloadseqentry -O AllowGiFarPtr,AllowSought,AllowAlignFarPtr,UseIdDates,TrialNoLoad"

#idload.pl -a NRacc.bioseq -d `pwd` -l `pwd`/$id_loader_dir -P $id_pswd -o NCBI-LegRefSeq

source /am/ncbiapdata/database_env/id_env.csh"
setenv IDLOADSEQENTRY "idloadseqentry -O AllowGiFarPtr,AcceptDate,AllowGiFarPtr,AllowSought,AcceptSeqVer,IgnoreDeadHistory,IgnoreInvalidHist"
idload.pl -a NRacc.bioseq -d `pwd` -l `pwd`/idload -P till1620 -o SWISSPROT"

#idload.pl -a NRacc.bioseq -d `pwd` -l `pwd`/idload -P till1620 -o NCBI-LegRefSeq

set retval = $status
if ($retval != 0) then
    echo "$0 : FATAL : Non-zero ID-load status : retval = $retval : file = NRacc.bioseq : one or more of the NR records might not have loaded"
    exit 20
endif


exit 0
