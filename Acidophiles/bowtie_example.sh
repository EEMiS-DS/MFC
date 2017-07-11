sbatch -p node -t 2:00:00 -A b2013127 \
-J bowtie2_SSU_${i} -e bowtie2_SSU_${i}.err -o bowtie2_SSU_${i}.out \
--mail-type=ALL --mail-user=domenico.simone@lnu.se<<'EOF'
#!/bin/bash

# load required modules
# please notice: we want samtools version 1.3!!!
module load bowtie2
module load samtools/1.3

bowtie2 \
-f \
--end-to-end \
-x ${bowtiedb} \
-1 ${i}.SSU.reads.R1.fasta \
-2 ${i}.SSU.reads.R2.fasta \
--no-unal \
-p 16 | samtools sort - > ${i}.SSU.sorted.bam

rm ${i}.SSU.reads.R?.fasta

EOF
