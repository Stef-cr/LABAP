# antiSMASH web-server analysis

Biosynthetic gene cluster prediction was performed through the antiSMASH web interface. Because no local script was used, reproducibility depends on recording the web-server configuration and retaining the downloaded result archive.

## Procedure

1. Open the official antiSMASH fungal analysis web server.
2. Upload the MA12 genome in the accepted annotated sequence format used for the published analysis.
3. Select the same analysis options reported in the manuscript.
4. Record the antiSMASH version, database version when displayed, submission date, input file checksum, and job identifier.
5. Download the complete result archive and retain the HTML report, GenBank output, region files, and tabular summaries.

## Metadata to complete before release

- antiSMASH version: `[ADD VERSION]`
- Submission date: `[YYYY-MM-DD]`
- Input file: `[ADD FILE NAME]`
- Input SHA-256: `[ADD CHECKSUM]`
- Detection strictness: `[relaxed/default/strict]`
- Additional analyses selected: `[ADD OPTIONS]`
- Result archive location or supplementary-file identifier: `[ADD LOCATION]`

Do not commit unpublished biological data or large antiSMASH archives unless their release is authorized. A stable archive or supplementary dataset may be referenced instead.
