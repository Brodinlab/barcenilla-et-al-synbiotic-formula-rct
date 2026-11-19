## Barcenilla et al, synbiotic formula RCT

This repository contains **processed, analysis-ready tables** and **R scripts** to reproduce the figures in Barcenilla et al, synbiotic formula RCT.

### Repository structure

- `data/tables/`: **base analysis-ready tables** (metadata, CyTOF frequencies, Olink NPX, …)
- `scripts/figures/`: figure scripts (one script per panel)
- `scripts/lib/`: shared helpers (loading tables, common functions)
- `output/`: locally generated figures

### Reproduce figures

See `scripts/figures/FIGURE_MAP.md` for the full manuscript-figure-to-script mapping,
including figures that cannot be reproduced from this repository.

Example:

```bash
Rscript scripts/figures/fig5/Fig5_manualgating_pca_biplot_dist10_excluded.R
```

By default, scripts write PDFs into `output/figures/manuscript/`.

This repository (not the upstream original, which is stale as of
2026-05 and does not reflect the current manuscript) is the canonical source for
figure reproduction going forward.

### Subject IDs

`subject_id` (`R00001`-`R00243`) is the neutral blinded subject ID provided by the trial sponsor. It is
the same ID as `Subject (blinded)` in the supplementary data files (`microbiome_metabolomics_data.xlsx`,
`Demographics_AEs_outcomes.xlsx`), so records can be linked across all data types, here and in the
supplement. The key to the original study identifiers is not part of this repository.
CyTOF, Olink and vaccine samples are linked through `metadata.csv` (`cytof_id`, `olink_id`,
`vaccine_id`).

Only figures shown in the manuscript have code and data here; see `scripts/figures/FIGURE_MAP.md`.
Microbiome and metabolomics data (Figs. 4 and 6) are not yet part of this repository; they are available in the Supplementary Data (`microbiome_metabolomics_data.xlsx`). `data/tables/fecal_biomarkers.csv` (Fig. 3) is taken from the Biomarkers sheet of that file, and `data/tables/demographics.csv` (sex, enrolment age, delivery mode) from the Demographics sheet of `Demographics_AEs_outcomes.xlsx`.

### Data protection

All participant-level tables use only the sponsor-blinded `subject_id`. The key to the original study
identifiers is not part of this repository and no repository history is retained. Calendar dates have
been replaced by day offsets: `study_day` in `metadata.csv` is days since the participant's first sampling
visit, and `Baseline`, `Last_visit`, `AESTDAT` and `AEENDAT` in `URTI_durations.csv` are days since
the participant's baseline visit. The scripts that rebuild `data/tables/` from internal source files are
not included; the tables here are the analysis inputs.
