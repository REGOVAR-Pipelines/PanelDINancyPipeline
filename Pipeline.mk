# Inspired by a bash pipeline written by Tristan Dubos in 2018

REF=/regovar/database/hg19.fa
INPUTS=/regovar/inputs
OUPUTS=/regovar/outputs

#patsubst: allows to change the extension and/or the path of the files
#wildcard: allows to get a list of files with globbing

all: \
	$(patsubst $(INPUTS)/%.fastq,$(OUTPUTS)/%_snp.vcf, $(wildcard $(INPUTS)/*.fastq)) \
	$(patsubst $(INPUTS)/%.fastq,$(OUTPUTS)/%_indel.vcf, $(wildcard $(INPUTS)/*.fastq))

%.sam: $(REF) %.fastq
	bwa mem -t 4 $^ > $@

%.bam: %.sam
	samtools view -b -S $< > $@

%_sorted.bam: %.bam
	samtools sort $< $@

%_sorted.bai: %_sorted.bam
	samtools index $<

%.mpileup: %_sorted.bam $(REF)
	samtools mpileup -B -f $(REF) -Q 10 $< > $@

%_snp.vcf: %.mpileup
	java -jar VarScan.v2.3.9.jar mpileup2snp $< --min-coverage 40 --min-var-freq 0.01 > $@

%_indel.vcf: %.mpileup
	java -jar VarScan.v2.3.9.jar mpileup2indel $< --min-coverage 40  --min-var-freq 0.01 > $@

.PHONY: all
