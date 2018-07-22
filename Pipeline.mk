# Inspired by a pipeline written by Tristan Dubos in 2018

all: \
	fichier_brut_snp.vcf \
	fichier_brut_indel.vcf \
	VarScan.v2.3.9.jar

fichier_brut.sam: ref_genome fichier_fastq
	bwa mem -t 4 $^ > $@

fichier_brut.bam: fichier_brut.sam
	samtools view -b -S $< > $@

fichier_brut_sorted.bam: fichier_brut.bam
	samtools sort $< $@

fichier_brut_sorted.bai: fichier_brut_sorted.bam
	samtools index $<

fichier_brut.mpileup: fichier_brut_sorted.bam ref_genome
	samtools mpileup -B -f ref_genome -Q 10 $< > $@

fichier_brut_snp.vcf: fichier_brut.mpileup
	java -jar VarScan.v2.3.9.jar mpileup2snp $< --min-coverage 40 --min-var-freq 0.01 > $@

fichier_brut_indel.vcf: fichier_brut.mpileup
	java -jar VarScan.v2.3.9.jar mpileup2indel $< --min-coverage 40  --min-var-freq 0.01 > $@

VarScan.v2.3.9.jar:
	curl -L https://sourceforge.net/projects/varscan/files/latest/download?source=files -o $@

.PHONY: all
