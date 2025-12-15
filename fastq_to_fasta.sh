cd#!/bin/bash

#start
echo "Script starting."							

#check for samples.zip and unzip it if it exists
if [[ -f samples.zip ]]; then
	echo "Checking for samples.zip file..."
	unzip samples.zip
	echo "Successfully unzipped the samples.zip file!"
	else
	echo "Please ensure you download the samples.zip."							
fi

#defining directories
fasta_files="fasta_files"                    #for concentenated fasta files
invalid_fastq_files="invalid_fastq_files"    #for invalid fastq files
fastq_archive="fastq_archive"                #for fastq files once converted
fasta_archive="fasta_archive"                #for individual fasta files once concentenated
refseq_archive="reference_sequences_archive" #for the unmodified fasta files containing aligned sequences of homologs

#create directories if they do not exist
mkdir -p "$fasta_files" 				  
mkdir -p "$fastq_archive" 				 
mkdir -p "$invalid_fastq_files" 		 
mkdir -p "$fasta_archive"
mkdir -p "$refseq_archive"				 

echo "Proceeding with .FASTQ to .fasta file conversion."

#invalid FASTQ check: check for duplicate headers in every .FASTQ file in current directory
#will work if multi-read FASTQ file
echo "Checking .FASTQ files for duplicate headers on sequence lines..."
for file in ./*.FASTQ; do
	#check for @ on line 2 every 4 lines
	if sed -n '2~4p' "$file" | grep -qE '^@'; then  
		echo "$file has duplicate header(s) - fixing."

		#backup the invalid file to the invalid_fastq_files directory
		cp "$file" "$invalid_fastq_files/$(basename "$file").backup" 
		echo "Unedited invalid $file has been archived in the $invalid_fastq_files directory."

		#delete any line 2 (every 4 lines) containing @ and create a new valid file
		sed '2~4{/^@/d}' "$file" > "${file}.fixed"

		#move valid file into current directory; rename to original file name
		mv "${file}.fixed" "$file"
		echo "$file has been amended to valid FASTQ format."
	else								
		echo "$file has no duplicate headers. Valid .FASTQ file. Proceed." 
	fi
done

#invalid FASTQ check: check for sequence lines that only contain A, T, G, C, N
#will work if multi-read FASTQ file
echo "Checking .FASTQ files for single character DNA sequences..."
for file in *.FASTQ; do
	#check line 2 every 4 lines to see if the same character repeated
	if sed -n '2~4p' "$file" | grep -qE '^([ACGTN])\1*$'; then
		echo "Warning: $file contains a single character DNA sequence line."
		oldname=$(basename "$file")          #extract name of .FASTQ file 
		newname="bad_fastq_${oldname}"       #rename to bad_FASTQ file
		mv "$file" "$invalid_fastq_files/$newname" #archive in the invalid fastq file dir
		echo "Moved and renamed bad .FASTQ file to $invalid_fastq_files/${newname}. It will not be included in any .fasta files moving forward."	
	else
		echo "No single-character DNA sequence lines found in $file."
	fi
done

#extract sequence identifier (header) & DNA sequence from every .FASTQ file in current directory
#will work if multi-read FASTQ file
echo "Extracting headers and DNA sequences from .FASTQ files and converting to .fasta files."
for file in *.FASTQ; do
	#extract the name of the .FASTQ file for new .fasta file
	base=$(basename "$file" .FASTQ) 
	#copy line 1 and 2 every 4 lines from the .FASTQ file to the corresponding .fasta file
    #replace @ with >
	#move to fasta_files directory
	sed -n '1~4{s/^@/>/;p};2~4p' "$file" > "$fasta_files/${base}.fasta"
done

#archive all the .FASTQ files into fastq_archive
echo "Archiving all .FASTQ files to $fastq_archive."
for file in ./*FASTQ; do
	mv "$file" "$fastq_archive"
done

#invalid fasta check: check for empty lines in every file in fasta_files directory
echo "Checking .fasta files for empty lines."
for file in ./fasta_files/*.fasta; do
		#check for lines that are empty only
        if grep -qE "^$" "$file"; then    
            echo "Empty line(s) found in $file - deleting."
			#delete empty lines directly in file
            sed -i '/^$/d' "$file"       
            echo "$file now has valid .fasta format."
        else
        	echo "No empty line(s) found in $file. Proceed."
        fi
done

#replace any spaces in headers with underscores for readibility/consistency in fasta_files directory
#will work if multi-read FASTA file
echo "Looking for spaces in .fasta headers to replace with underscores for readability/consistency."
for file in ./fasta_files/*.fasta; do
		if grep -qE '^>.*[[:space:]]' "$file"; then       #grep: look for lines that contain > (indicative of header) and if it exists; then -
			echo "Found space(s) in $file header - fixing."
			sed -i '/^>/ s/[[:space:]]\+/_/g' "$file"     #sed: look for lines starting with >, substitute space with an underscore, even if it's more than one space together (+)
		else
			echo "No space(s) found in $file header. Proceed."
		fi
done

#delete unnecessary underscores after 'part' in the header for readability/consistency in fasta_files directory
#will work if multi-read FASTA file
echo "Removing unnecessary underscores .fasta headers for readability/consistency."
for file in ./fasta_files/*.fasta; do
		if grep -qE '^>.*_[0-9]' "$file"; then          #grep: look for lines starting with > (header) followed by a number
			echo "Found unnecessary underscore(s) in $file header - fixing."
			sed -i '/^>/ s/_\([0-9]\)/\1/g' "$file"     #sed: look for lines starting with >, delete any underscore that are followed by a number, e.g. part_1, but keep the number and put it back, e.g. part1
		else
			echo "No unnecessary underscores found in $file header. Proceed."
		fi
done

#copy unmodified reference sequence .fasta files to reference_sequences_archive
echo "Archiving all raw reference sequence .fasta files to $refseq_archive."
for file in ./refsequences/*.fasta; do	
	cp "$file" "$refseq_archive"
done

#modify the header line to only contain accession number, genus, species (keeps in style as sampleX_part1)
#keep the rest of the file (reference sequence)
#loop over all files in refsequences directory
echo "Modifying reference sequence .fasta files for use in data analysis downstream."
for file in ./refsequences/*.fasta; do
	tmp=$(mktemp) #temporary file for modified header, easier than making backup file etc as earlier

	#in normal file:
	#find any line beginning with > (header), string 1 = accession number, string 2 = genus, string 3 = species
	#print with underscore seperation
	#very important: next - "stop doing that, do this next"
	#so print rest of file (aligned DNA sequence)
	awk '/^>/ { printf("%s_%s_%s\n", $1, $2, $3); next} { print }' "$file" > "$tmp" #put what awk did in normal file into temp file
	mv "$tmp" "$file"  #replace file with temp file
done	
echo "Reference sequence .fasta files modified for downstream analysis successfully."
#above should work if reference sequences provided have multiple reads in it 

echo "Looking for spaces in .fasta headers to replace with underscores for readability/consistency."
for file in ./fasta_files/*.fasta; do
		if grep -qE '^>.*[[:space:]]' "$file"; then       #grep: look for lines that contain > (indicative of header) and if it exists; then -
			echo "Found space(s) in $file header - fixing."
			sed -i '/^>/ s/[[:space:]]\+/_/g' "$file"     #sed: look at lines starting with >, substitute space with an underscore
		else
			echo "No space(s) found in $file header. Proceed."
		fi
done

#concatenate all of the .fasta files into all_sequences.fasta in fasta_files directory
#for use in multiple sequence alignment
all_sequences="fasta_files/all_sequences.fasta"
> "$all_sequences"                       #create file for all sequences data

echo "Concatenating all individual .fasta files into $all_sequences for downstream analysis."

for file in ./refsequences/*.fasta; do
	mv "$file" "$fasta_files"
done

#cat all fasta files in fasta_files directory
for file in ./fasta_files/*.fasta; do
	cat "$file" >> "$all_sequences"
done

echo "Concatenated all fasta files into $all_sequences successfully!"

#move all_sequences.fasta into current working dir 
#so python script will run no problem
echo "Moving $all_sequences to $(pwd) ready for translation into amino acid sequences."
for file in ./fasta_files/all_sequences.fasta; do
	mv "$all_sequences" ./
done


#archive all seperated .fasta files into fasta_archive
echo "Archiving the individual .fasta files in $fasta_archive."
for file in ./fasta_files/*part*.fasta; do
	cp "$file" "$fasta_archive"
done

#clean up of modified refseq fasta files in fasta_files directory
echo "Archiving the individual modified reference sequences .fasta files to $fasta_archive."
for file in ./fasta_files/refseq*.fasta; do
	mv "$file" "$fasta_archive"
done

#if there's a __MACOSX folder; archive it
if [ -d "__MACOSX" ]; then
	echo "Archiving __MACOSX folder in $fastq_archive."
	mv __MACOSX "$fastq_archive" 
	else
	echo "No '__MACOSX' folder found. Skipping archiving step."
fi

#if the script is re-run for some reason and the __MACOSX folder was previously archived, this will force delete the folder as it cannot be moved
#if the __MACOSX folder is present, re-running the script will prompt the user in the terminal to replace/etc the individual files
if [ -d "__MACOSX" ]; then
	echo "Deleting __MACOSX folder as it has been previously archived."
	rm -rf __MACOSX                          #force delete __MACOSX
fi

#if there's a samples folder; archive it
if [ -d "samples" ]; then
	echo "Archiving samples folder in $fastq_archive."
	mv samples "$fastq_archive"
	else
	echo "No 'samples' folder found. Skipping archival step."
fi

#if there's a refsequences folder; delete it
#unmodified refsequences were previously archived to reference_sequences_archive
#modified refsequences were previously archived to fasta_archive
if [ -d "refsequences" ]; then
	echo "Deleting refsequences folder as its contents have been previously archived to reference_sequences_archive."
	rm -rf refsequences                      #force delete refsequences
	else
	echo "No 'refsequences' folder found. Skipping archival step."
fi

echo "Script complete."