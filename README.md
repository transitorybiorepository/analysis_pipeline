# Introduction to Bioinformatics: Short Analysis Pipeline
## Supplementary Data

### DNA analysis pipeline

The DNA analysis pipeline works as follows to recreate the multiple sequence alignment and phylogenetic tree:

1. Download the FASTQ sample files: [samples.zip](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/samples.zip)
2. Download and run the following bash script to convert the FASTQ files to FASTA files. Note, SampleC part1 will be automatically excluded: [fastq_to_fasta.sh](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/fastq_to_fasta.sh)
3. Download and use translate.py to convert all_sequences.fasta into translated amino acid sequence file; translated.fas: [translated.py](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/translate.py)
4. Run translated.fas through multiple sequence alignment (MSA) program MUSCLE, available at EMBL-EBI, using default settings (ClustalW output): [MUSCLE](https://www.ebi.ac.uk/jdispatcher/msa/muscle)
5. Once MUSCLE has completed the MSA, select the 'Results Viewers' section, and using Jalview, select File -> Input Alignment -> From URL and input the resulting link. [Jalview installation](https://www.jalview.org/download/)
6. In Jalview, select 'Percentage Identity'. 
7. Whilst within the 'Results Viewer' section of the MUSCLE output, select the option to send the phylogenetic tree to Simple Phylogeny.
8. In Simple Phylogeny, select tree format as 'Clustal', and distance correction: on, exclude gaps: off, clustering methods: neighbour-joining, percent identity matrix: off.
9. Download the resultant phylogenetic tree .tree file.
10. Using Interactive Tree of Life (iTOL), upload the .tree file and root the tree to JN027068.1 1-472 Lamptera appendix. [iTOL](https://itol.embl.de/)

### High definition figures

Please download and unzip the following zip file for high definition figures of the multiple alignment sequence and phylogenetic tree: [High definition figures](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/HighDefinitionFigures.zip)

### FastQC reports

The FASTQC reports were done using University of Bristol's HPC BluePebble. For security reasons, this script as not been uploaded to the repository. However, FASTQC can be done as follows without a script:

1. Install Java. [Java](https://www.java.com/en/download/manual.jsp)
2. Install an appropriate Java Runtime Environment (JRE). For this study, Eclipse Temurin was used as recommended by FastQC, which is a software development kit for Java that includes a JRE. [Eclipse Temurin](https://adoptium.net/en-GB)
3. Download FastQC. [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
4. Check the INSTALL.txt to see how to run FastQC according to your operating system.
5. Once the application is running, open the FASTQ files to create the reports.

The FastQC reports are available within the repository. Download and unzip the following zip file: [FastQC reports](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/AI_Declaration_and_Prompts.zip)

### AI prompts
AI prompts were used to clarify syntax when creating the bash script. Please download and unzip the following zip file: [AI Declaration and Prompts](https://github.com/transitorybiorepository/analysis_pipeline/blob/main/AI_Declaration_and_Prompts.zip)

### Cover image 
This was drawn by the author using Procreate for iPadOS.
