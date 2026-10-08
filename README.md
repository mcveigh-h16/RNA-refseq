# RNA-refseq

Scripts and notebooks for creating and maintaining rRNA reference sequences:
extracting annotated features, identifying duplicate sequences, comparing organism
names, and filtering accession lists.

This catalog is a draft based on the comments and current source code. It has not
been validated by running the workflows. Some files are experimental or contain
incomplete code; the notes below distinguish intended use from current behavior.
Each entry includes space for manual review and additional details.

## Requirements and usage

The repository's Linux runtime environment is **`myenv2`**, located at
`/home/mcveigh/myenv2` on `iebdev21`. The reported run used Python 3.11.
Activate the existing environment before running scripts (Bash-compatible shell):

```bash
source /home/mcveigh/myenv2/bin/activate
cd /home/mcveigh/repos/RNA-refseq
python FeatureSlicer16S-2.py genome.gbk genome.fsa
```

Without activation, use `/home/mcveigh/myenv2/bin/python` explicitly. The
environment lives outside the repository and is not included in version control.
The Windows PyCharm checkout currently uses its own `.venv`; it is separate from
the Linux `myenv2` environment.

The Python sequence scripts import Biopython. The mixed-organism scripts also
import pandas. The notebooks use Jupyter and, depending on the notebook, pandas,
NumPy, and Biopython. Excel exports require a pandas-compatible Excel writer.
Supported package versions still need to be documented.

Install the Python dependencies into the existing Linux environment with:

```bash
/home/mcveigh/myenv2/bin/python -m pip install -r requirements.txt
```

[requirements.txt](requirements.txt) lists the direct script and notebook
dependencies, including an Excel writer and a Jupyter interface/kernel. Versions
are unpinned pending validation in `myenv2`; this is not a snapshot of that
environment. Standard-library modules such as `os` and `sys` need no installation.
External NCBI tools such as `esearch`, `efetch`, `seqfetch`, `srcchk`, and the
internal loading utilities are separate from these Python requirements.
Installing dependencies does not repair the incomplete code or legacy API usage
noted in the inventory below.

FeatureSlicer scripts take a GenBank input file and a FASTA output filename as
positional arguments. For example:

```bash
python FeatureSlicer16S-2.py genome.gbk genome.fsa
```

Prepare the GenBank file beforehand: the genome-download commands in the 16S
scripts are commented out. The scripts inspect feature type and product text,
slice the sequence using feature coordinates, and reverse-complement slices on
the minus strand. They use the feature's start-to-end span rather than extracting
individual parts of a compound location; review suitability for joined features.

Several scripts write fixed filenames in the working directory, including
`genome.out`, `summary.out`, and `notidentical.xlsx`. Use separate working
directories when processing different datasets. Notebook paths and external-tool
commands need to be reviewed for the execution environment.

**Environment details to add:** _Python/package versions, installation steps,
required internal tools, and example datasets._

## Script inventory

### Feature extraction

| Script | Purpose | Main output |
| --- | --- | --- |
| [FeatureSlicer1.1.py](FeatureSlicer1.1.py) | Extract 23S/large-subunit rRNA features. | FASTA |
| [FeatureSlicer1.2.py](FeatureSlicer1.2.py) | Extract cytochrome b CDS nucleotide sequences. | Intended FASTA; code incomplete |
| [FeatureSlicer16S.py](FeatureSlicer16S.py) | Extract all matching 16S rRNA features. | FASTA without deduplication |
| [FeatureSlicer16S-2.py](FeatureSlicer16S-2.py) | Extract 16S rRNA and retain unique sequences. | Unique FASTA and `genome.out` |
| [FeatureSlicer16S-3.py](FeatureSlicer16S-3.py) | Extract unique 16S rRNA with accession/coordinate descriptions. | Unique FASTA and `genome.out` |
| [FeatureSlicer16Sworking.py](FeatureSlicer16Sworking.py) | Experimental 16S extraction variant. | Intended FASTA; code incomplete |
| [FeatureSlicerSSUc.py](FeatureSlicerSSUc.py) | Extract 16S/small-subunit rRNA features. | Intended FASTA; code incomplete |
| [FeatureSlicerSSUm.py](FeatureSlicerSSUm.py) | Extract mitochondrial small-subunit rRNA features. | FASTA |

#### FeatureSlicer1.1.py

Reads GenBank records and selects `rRNA` features with product text matching
`23S ribosomal RNA`, `23S rRNA`, `23S large subunit ribosomal RNA`, or
`large subunit ribosomal RNA`. It extracts the first matching feature per record,
handles strand orientation, and adds the organism name and `23S ribosomal RNA`
to the FASTA description. It prints feature and output counts.

**Review notes:** The append operation runs for subsequent rRNA features while
the match counter remains one, so the first extracted sequence can be appended
more than once. The file also imports `Bio.Alphabet.IUPAC`; compatibility needs
review.

**Manual review / additional details:** _Confirm intended first-feature behavior,
accepted product names, supported environment, and example input/output._

#### FeatureSlicer1.2.py

Although the header describes 23S extraction, the code selects `CDS` features
whose product is `cytochrome b`. It is intended to extract the first matching
nucleotide sequence per record, reverse-complement minus-strand features, and
write organism/cytochrome b FASTA descriptions. It does not translate the CDS.

**Review notes:** An empty `else:` block prevents execution as written. The code
uses private coordinate attributes and has the same potential repeated-append
behavior as version 1.1.

**Manual review / additional details:** _Confirm this variant's purpose, repair
status, and intended relationship to the rRNA workflows._

#### FeatureSlicer16S.py

Reads GenBank records, extracts every `rRNA` feature whose product is exactly
`16S ribosomal RNA`, and writes FASTA records with organism names and coordinates.
Minus-strand descriptions list the higher coordinate first.

**Review notes:** Despite its header comment, this version does not remove
identical sequences. It uses private coordinate attributes. Its count message
incorrectly reports no features when exactly one match is present.

**Manual review / additional details:** _Confirm whether this version remains in
use and add a representative command and expected output._

#### FeatureSlicer16S-2.py

Reads GenBank records and extracts all `rRNA` features whose product is exactly
`16S ribosomal RNA`. It uses public location coordinates and writes all extracted
records to `genome.out` in FASTA format. It then groups records by exact sequence,
retains the first record in each group, and writes those representatives to the
requested output file. Descriptions contain organism names and coordinates.
Console output lists feature counts, sequence groups, and retained records.

**Review notes:** Deduplication applies across the entire input file, including
different genomes or organisms, rather than restarting for each genome. The
printed `identical seqs` groups also include singleton groups.

**Manual review / additional details:** _Confirm the intended input scope,
representative-selection rule, and downstream use of the coordinate descriptions._

#### FeatureSlicer16S-3.py

Uses the same extraction and whole-input deduplication workflow as version 2.
Its descriptions use the record accession instead of the organism name, with
tab-separated coordinates. Minus-strand descriptions include `complement` before
each coordinate. It writes `genome.out`, a unique-sequence FASTA, and console
reports of groups and retained records.

**Manual review / additional details:** _Document the downstream consumer of
this description format and when to choose version 3 instead of version 2._

#### FeatureSlicer16Sworking.py

An experimental variant intended to extract 16S rRNA and explore duplicate
handling. It selects the same product text as the other 16S scripts and constructs
strand-aware subsequences with organism/coordinate descriptions.

**Review notes:** The `seen` list is never populated, and the script appends that
empty list instead of the extracted sequence record. The resulting collection is
not suitable for the FASTA writer. It also uses private coordinate attributes and
has the same single-feature count-message issue as `FeatureSlicer16S.py`.

**Manual review / additional details:** _Confirm whether to retain this as an
experiment, repair it, or mark it as superseded._

#### FeatureSlicerSSUc.py

Selects the first `rRNA` feature per record whose product is `16S ribosomal RNA`
or `small subunit ribosomal RNA`. It handles strand orientation and is intended
to write FASTA descriptions containing the organism and
`small subunit ribosomal RNA`.

**Review notes:** The header says mitochondrial small-subunit extraction; confirm
the intended meaning of the `c` suffix and biological scope. The output statement
is malformed (`SeqIOwrite` with a trailing dot), and the file imports
`Bio.Alphabet.IUPAC`. It does not filter records by organelle annotation.

**Manual review / additional details:** _Clarify biological scope, repair status,
and accepted product names._

#### FeatureSlicerSSUm.py

Described in its header as mitochondrial small-subunit rRNA extraction. It selects
the first `rRNA` feature per record with product `12S ribosomal RNA`,
`small subunit ribosomal RNA`, or `s-rRNA`. It handles strand orientation, writes
organism/small-subunit FASTA descriptions, and reports additional matching
features and the output count.

**Review notes:** Selection uses product text without checking organelle
annotations. The file imports `Bio.Alphabet.IUPAC`; compatibility needs review.

**Manual review / additional details:** _Add input-selection criteria, supported
environment, and intended handling of multiple matches._

### Duplicate-sequence analysis

#### [FindIdenticalSeq.py](FindIdenticalSeq.py)

A trial of the duplicate-grouping logic used in `FeatureSlicer16S-2.py`. Reads
the fixed FASTA filename `genome.out`, groups records by exact sequence, and keeps
the first record from each group in memory. Prints group sizes, member
descriptions, and representative descriptions. It takes no command-line
arguments and does not write a deduplicated file.

**Manual review / additional details:** _Document whether this standalone report
is still used and provide an example of interpreting its output._

#### [FindIdenticalSeqMixedOrg.py](FindIdenticalSeqMixedOrg.py)

Reads a mixed-organism GenBank file using two positional arguments:

```bash
python FindIdenticalSeqMixedOrg.py input.gbk unique.fsa
```

Collects organism names, rereads the input for each name, and groups that
organism's complete record sequences by exact sequence. Retains the first record
per organism/sequence combination, writes the representatives to FASTA, and
writes accession/organism pairs to the tab-separated `summary.out` file. It
compares full records rather than extracting annotated rRNA features.

**Review notes:** Identical sequences assigned to different organism names are
retained separately. The final duplicate-group console report uses only the last
organism's dictionary, although the FASTA collects representatives across all
organisms. Pandas is imported but not used.

**Manual review / additional details:** _Confirm organism-name matching rules,
representative selection, and how the summary is consumed._

#### [FindIdenticalSeqMixedOrg2.py](FindIdenticalSeqMixedOrg2.py)

Accepts one GenBank filename:

```bash
python FindIdenticalSeqMixedOrg2.py input.gbk
```

Builds a pandas table containing accession, organism name, and the Biopython
SEGUID checksum of each complete record sequence. Drops duplicate
organism/checksum combinations, retaining the first, and exports the retained
accession/organism columns to `notidentical.xlsx`. Also writes **all input
sequences**, without deduplication, to `<input filename>.fsa`.

**Manual review / additional details:** _Describe how the Excel list is used to
select records and whether this version supersedes the earlier mixed-organism script._

### Notebooks

Open these in Jupyter and review paths and cells before execution. Stored outputs
are examples from prior runs, not validation of a fresh run.

#### [16SrefseqNameChecker.ipynb](16SrefseqNameChecker.ipynb)

Downloads GenBank records using `esearch`/`efetch` with the query
`33175[BioProject] OR 33317[BioProject]`, writing `refseq4.gbk`. Builds a table of
accessions, organism names, and definition lines. For each record, finds words
present in the organism name but absent from the definition line, removes empty
results, and exports a discrepancy report to `differences_df` and an accession
list to `NRacclist.csv`. This is a word-presence comparison for manual review,
not a taxonomic synonym resolver.

Later cells use internal tools (`seqfetch`, `se2bss`, and `asn_cleanup`) to
prepare ASN.1 files, convert the text wrapper to `NRacc.bioseq`, and attempt an
`idload.pl` load and an `idstat` check. The fetch step currently uses the test
list `NRacclist_b.csv`, and comments mark the loading steps as not working yet.

**Manual review / additional details:** _Confirm query scope, discrepancy review
criteria, report filenames, and the supported preparation/loading procedure._

#### [Refseq_InsdNameSearch.ipynb](Refseq_InsdNameSearch.ipynb)

Compares names from INSD type-material records with RefSeq names to identify
candidates for new RefSeq records. Its introductory notes call for accession
downloads and `srcchk` reports prepared beforehand. Reads tab-separated
`missing_names` and `refseq_names` files containing accession, organism, and
type-material columns from hard-coded Windows paths, and skips their first rows.

Merges on full organism names and selects rows without a RefSeq accession,
exporting `missing_type.xlsx`. It then compares the first two words of the
organism names as binomials to narrow the candidates and exports
`missing2_type.xlsx`. The notebook notes that strain-name differences can create
false positives. Later experimental cells include alternative mappings,
inconsistent column references, and undefined variables, so it needs review
before execution from top to bottom.

**Manual review / additional details:** _Add input-generation commands, confirm
header handling and name-normalization rules, and identify the supported cells._

#### [RemoveAccessionsFromList.ipynb](RemoveAccessionsFromList.ipynb)

Reads three line-based accession lists: `GBRefSeq_orig` (existing records),
`16Sacc_anylength` (candidates), and `16Srejectlist.txt` (rejections). First removes
candidates found in the existing-record list, then excludes entries in the reject
list. Prints counts and writes `missingaccesssion.txt` before rejection filtering
and `missingacc_notreject.txt` after rejection filtering. The first filename is
spelled as it appears in the notebook.

Comparisons use complete strings returned by `readlines()`, without stripping
whitespace or normalizing accession versions. Candidate order and repeated
entries are preserved unless excluded by membership in another list.

**Manual review / additional details:** _Specify accession/version conventions,
input sources, and which output feeds the next workflow._

### Shell script

#### [16SNameChecker.sh](16SNameChecker.sh)

Contains environment setup and an internal `idload.pl` loading attempt for
`NRacc.bioseq`, followed by a return-status check. Despite its filename, it does
not perform the notebook's organism-name comparison. It depends on internal
NCBI paths and loading tools.

**Review notes:** The Bash shebang conflicts with C-shell-style commands such as
`setenv`; there are also incomplete assignments and mismatched quotes. Loading
configuration and authentication are embedded in the draft. The intended shell,
target, and configuration need review before use.

**Manual review / additional details:** _Document the intended relationship to
the name-checker notebook and the supported execution procedure._

## Maintainer review checklist

- [ ] Review each description against its intended scientific use.
- [ ] Mark each file as maintained, experimental, or superseded.
- [ ] Add tested Python, Biopython, pandas, and notebook environments.
- [ ] Add small example inputs and expected outputs.
- [ ] Confirm duplicate-selection rules and accepted feature product names.
- [ ] Document input preparation and downstream consumers of each output.
- [ ] Clarify which notebook cells and internal loading steps are supported.

See [skills.md](skills.md) for project maintenance and troubleshooting conventions.
