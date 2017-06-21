#### Working directory
`/proj/b2016308/nobackup/projects/viraja`.

### Raw reads QC (fastqc)

```bash
mkdir -p /pica/v8/b2013127_nobackup/projects/domeni/aspo/RNA2/fastqc
cd /pica/v8/b2013127_nobackup/projects/domeni/aspo/RNA2/fastqc
sbatch fastqc_wrapper.serial.sh \
"$(ls /proj/b2013127/nobackup/projects/domeni/aspo/RNA2/raw_reads/*fastq.gz)" .
```
with script `fastqc_wrapper.serial.sh` being:

```bash
#!/bin/bash

# should be used as
# fastqc_wrapper_serial.sh regexp_for_files outdir, eg
# sbatch fastqc_wrapper.serial.sh "$(ls /proj/b2013127/INBOX/M.Dopson_16_01/*/*/*.fastq.gz)" /proj/b2013127/nobackup/projects/danypthesis/MFC/raw_reads/

#SBATCH -A b2013127
#SBATCH -J fastqc
#SBATCH -o fastqc.out
#SBATCH -e fastqc.err
#SBATCH -p node
#SBATCH -n 16
#SBATCH -t 80:00
#SBATCH --mail-type=ALL
#SBATCH --mail-type=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load FastQC/0.10.1

infile_regex=$1
outdir=$2

time fastqc -t $(nproc) -o ${outdir} ${infile_regex}
```

### Raw reads low quality end and adapter trimming (trimmomatic)
```bash
cd /pica/v8/b2013127_nobackup/projects/domeni/aspo/RNA/raw_reads
ls *1.fastq.gz > dataset_file_trimmomatic
sbatch --array=1-$(wc -l < dataset_file_trimmomatic) --time=03:00:00 trimmomatic.sh
```

with script `trimmomatic.sh` being:

```bash
#!/bin/bash

# put in command line: array, time

#SBATCH -A b2013127 -p node
#SBATCH -J trimmomatic_%a -o trimmomatic_%a.out -e trimmomatic_%a.err
#SBATCH --mail-type=ALL --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load trimmomatic/0.32

# eg
# infile: 1_101_1.fastq.gz
# infile_base: 1_101_filtered.fastq.gz
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_trimmomatic)
infile_base=$(echo ${infile} | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, "filtered.adapterTrimmed.fastq.gz"}')

time java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE \
-phred33 -threads $(nproc) -trimlog ${infile}.trimlog \
-basein ${infile} -baseout ${infile_base} \
ILLUMINACLIP:$TRIMMOMATIC_HOME/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:20 TRAILING:20 SLIDINGWINDOW:4:25 MINLEN:100

with script `trimmomatic.20.sh` being:

```bash
#!/bin/bash

# put in command line: array, time

#SBATCH -A b2013127 -p node
#SBATCH -J trimmomatic_%a -o trimmomatic_%a.out -e trimmomatic_%a.err
#SBATCH --mail-type=ALL --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load trimmomatic/0.32

# eg
# infile: 1_101_1.fastq.gz
# infile_base: 1_101_filtered.fastq.gz
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_trimmomatic)
infile_base=$(echo ${infile} | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, "filtered.adapterTrimmed.fastq.gz"}')

time java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE \
-phred33 -threads $(nproc) -trimlog ${infile}.trimlog \
-basein ${infile} -baseout ${infile_base} \
ILLUMINACLIP:$TRIMMOMATIC_HOME/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:20 TRAILING:20 SLIDINGWINDOW:4:22 MINLEN:100


with script `trimmomatic.new90.sh` being:

```bash
#!/bin/bash

# put in command line: array, time

#SBATCH -A b2013127 -p node
#SBATCH -J trimmomatic_%a -o trimmomatic_%a.out -e trimmomatic_%a.err
#SBATCH --mail-type=ALL --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load trimmomatic/0.32

# eg
# infile: 1_101_1.fastq.gz
# infile_base: 1_101_filtered.fastq.gz
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_trimmomatic)
infile_base=$(echo ${infile} | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, "filtered.adapterTrimmed.fastq.gz"}')

time java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE \
-phred33 -threads $(nproc) -trimlog ${infile}.trimlog \
-basein ${infile} -baseout ${infile_base} \
ILLUMINACLIP:$TRIMMOMATIC_HOME/adapters/TruSeq3-PE.fa:2:30:10 \
LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:90
### Stats on filtering

`#grep ^Input trimmomatic_*.err | awk '{print $8, $13, $18, $21}'`

DIAMOND

With script being diamond.25.100.sh

#!/bin/bash

# enter in command line: array, time

#SBATCH -A b2016308 -p node
#SBATCH -J diamond_%a -o diamond.25.100_%A_%a.out -e diamond.25.100_%A_%a.err
#SBATCH --mail-type=All --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load diamond/0.8.26

#eg
#infile: adapterTrimmed.fastq.25.100_??.gz
#outfile_base
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_diamond.25.100)
outfile_base=$(echo $infile | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, $3, "diamond.daa"}')

time diamond blastx -d $DIAMOND_NR -q /${infile} -e 0.00001 -a ${outfile_base}.25.100

with script diamond.22.100.sh being:

#!/bin/bash

# enter in command line: array, time

#SBATCH -A b2016308 -p node
#SBATCH -J diamond_%a -o diamond.22.100_%a.out -e diamond.22.100_%a.err
#SBATCH --mail-type=All --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load diamond/0.8.26

#eg
#infile: adapterTrimmed.q22_??.fastq.gz
#outfile_base
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_diamond.22.100)
outfile_base=$(echo $infile | awk 'BEGIN{FS=".";OFS="."}{print $1, $2, $3, $4, $5, "diamond.daa"}')

time diamond blastx -d $DIAMOND_NR -q trim.22.100/${infile} -e 0.00001 -a ${outfile_base}.22.100

with script diamond.20.100.sh being 

#!/bin/bash

# enter in command line: array, time

#SBATCH -A b2016308 -p node
#SBATCH -J diamond_%a -o diamond.20.90_%A_%a.out -e diamond.20.90_%A_%a.err
#SBATCH --mail-type=All --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load diamond/0.8.26

#eg
#infile: adapterTrimmed_??.fastq.gz
#outfile_base
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_diamond.20.90)
outfile_base=$(echo $infile | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, $3, "diamond.daa"}')

time diamond blastx -d $DIAMOND_NR -q trim.20.90/${infile} -e 0.00001 -a ${outfile_base}.20.90

with script diamond.20.100.uncompressed.sh

#!/bin/bash

# enter in command line: array, time

#SBATCH -A b2016308 -p node
#SBATCH -J diamond_%a -o diamond.20.90_%A_%a.out -e diamond.20.90_%A_%a.err
#SBATCH --mail-type=All --mail-user=dp222eq@student.lnu.se,domenico.simone@lnu.se

module load bioinfo-tools
module load diamond/0.8.26

#eg
#infile: adapterTrimmed_??.fastq.gz
#outfile_base
infile=$(sed -n "$SLURM_ARRAY_TASK_ID"p dataset_file_diamond.20.90)
outfile_base=$(echo $infile | awk 'BEGIN{FS="_";OFS="_"}{print $1, $2, $3, "diamond.daa"}')

time diamond blastx -d $DIAMOND_NR -q trim.20.90/${infile} -e 0.00001 -a ${outfile_base}.20.90
