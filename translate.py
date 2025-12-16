from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord


def extract_genus_species_name(record):
    header = record.id
    parts = header.split("_")
    # all_sequences.fasta file is written with headers in this format for readability downstream:
    # >ACCESSIONNUMBER:RANGE_GENUS_SPECIES

    # always take last two pieces of header
    if len(parts) >= 2:
        return f"{parts[-2]}_{parts[-1]}"

    # return header if it doesn't have two parts unchanged
    return header


# read the DNA sequences from all_sequences.fasta as SeqRecord objects list
sequences = list(SeqIO.parse("all_sequences.fasta", "fasta"))

# list to store output protein SeqRecord objects
aa_sequences = []


for record in sequences:
    dna_seq = record.seq   # DNA sequence from given fasta

    best_orf = ""          # store the longest ORF found across all frames
    # store which frame (0,1,2) contains the longest ORF
    best_frame = None

    # translate sequence in all three forward reading frames
    for frame in range(3):
        # translate starting at this frame; use table 2 as mitochondrial vertebrate DNA, keep stop codons (to_stop=False)
        protein = dna_seq[frame:].translate(table=2, to_stop=False)

        # split translation into fragments separated by stop codons ("*")
        # each fragment is a potential ORF (no internal stops)
        fragments = str(protein).split("*")

        # find the longest continuous amino-acid stretch (longest ORF) in this frame
        longest_in_frame = max(fragments, key=len)

        # if this ORF is longer than the best one we've seen so far, store it
        if len(longest_in_frame) > len(best_orf):
            best_orf = longest_in_frame
            best_frame = frame

    # convert the longest ORF string back into a Seq object
    best_protein = Seq(best_orf)

    # create a new SeqRecord containing the longest ORF for this sequence
    aa_record = SeqRecord(
        best_protein,
        # keep the same FASTA ID which contains accession number, genus and species name
        id=record.id,
        description=record.description,    # keep full original header if necessary
        annotations={
            "type": "longest ORF",
            "frame": best_frame            # which reading frame the ORF came from
        }
    )
    # add to the list to store output amino acids
    aa_sequences.append(aa_record)

# write everything translated longest-ORF sequences to a FASTA file
SeqIO.write(aa_sequences, "translated.fas", "fasta")
