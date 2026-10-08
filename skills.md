# RNA-refseq skills and working guide

This repository contains scripts and notebooks for creating and maintaining
rRNA reference sequences. This file records project workflows and maintenance
conventions.

## Runtime environment

- Use the existing `myenv2` virtual environment for Linux runs on `iebdev21`:
  `/home/mcveigh/myenv2` (Python 3.11 in the reported run).
- In a Bash-compatible shell, activate it with
  `source /home/mcveigh/myenv2/bin/activate`, or invoke
  `/home/mcveigh/myenv2/bin/python` directly.
- The Linux checkout is `/home/mcveigh/repos/RNA-refseq`. Synchronize local
  changes there before running the updated scripts.
- Windows PyCharm currently uses the separate repository-local `.venv`.
  Do not assume its packages or Python version match Linux `myenv2`.

## Feature extraction

- The `FeatureSlicer*.py` scripts extract annotated features from GenBank files.
  Inspect the selected variant before running it; feature selection and output
  descriptions differ between scripts.
- `FeatureSlicer16S-2.py` extracts features whose product is
  `16S ribosomal RNA`, handles forward and reverse strands, and writes unique
  sequences to the requested FASTA file.
- Run it in a Python environment with Biopython installed:

  ```bash
  python FeatureSlicer16S-2.py genome.gbk genome.fsa
  ```

- This script also writes `genome.out` in the working directory. Use a separate
  working directory for validation to avoid overwriting existing outputs.

## Biopython maintenance

- Read strand orientation with `feature.location.strand`, not `feature.strand`.
- When updating coordinate handling, use `int(feature.location.start)` and
  `int(feature.location.end)`. Some older variants still use private location
  attributes and should be reviewed when updating those scripts.
- Preserve the distinction between slice coordinates and displayed coordinates:
  the current 16S-2 script adds one to the start for its output description.
- Preserve reverse-complement behavior, feature selection, FASTA descriptions,
  and duplicate handling unless the requested change explicitly affects them.
- Check all FeatureSlicer variants when applying a shared compatibility fix.

## Validation and troubleshooting

- Review the diff and keep compatibility changes focused.
- For extraction changes, validate forward- and reverse-strand features,
  duplicate sequences, and records with no matching features using small inputs.
- To identify the call that emits a warning, run in a temporary working directory:

  ```bash
  python -W error /path/to/FeatureSlicer16S-2.py genome.gbk genome.fsa
  ```

  This makes warnings raise exceptions so their tracebacks identify the caller.
- When a remote run still reports code that was changed locally, check the
  script path in the traceback and synchronize the updated files to that host.
- Report which checks were performed and whether the scripts were actually run.

## Other repository workflows

- Review `FindIdenticalSeq*.py` variants before using them for sequence duplicate
  analysis; do not assume their inputs and grouping behavior are identical.
- Inspect notebook cells, input paths, and active kernels before executing the
  name-checking, accession-search, and accession-removal notebooks.
- Keep generated sequence files, local environment files, and credentials out
  of changes intended for version control.
