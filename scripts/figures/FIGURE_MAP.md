# Figure map — Chen et al, synbiotic formula RCT trial manuscript (Sep 2026, *Nature Medicine* submission)

This repository contains code and data **only** for the figures below. Microbiome and
metabolomics figures (Fig. 4, Fig. 6, Suppl. Figs. 1-2) have no scripts here yet; their data are in the Supplementary Data.
Run all scripts from the repository root. Order for Fig. 5e–g:
`wgcna_cytof_olink_modules_finegrained.R` → `wgcna_module3_feature_tables.R` →
`wgcna_module_feeding_interaction.R` → `wgcna_finegrained_brown_splitviolin.R`.

| Figure / panel | Script | Output |
|---|---|---|
| Fig. 2a–d growth z-scores | `scripts/figures/fig2/Fig2_growth_zscores_panels_abcd.R` | `Fig2_growth_zscores_panels_abcd.pdf` (data: `data/tables/anthropometrics_zscores.csv`) |
| Fig. 2e IGSQ-13 | `scripts/figures/fig2/Fig2E_igsq13_gi_tolerance.R` | `Fig2E_igsq13_gi_tolerance.pdf` (data: `data/tables/igsq13_scores.csv`) |
| Fig. 3 fecal biomarkers | `scripts/figures/fig3/Fig3_fecal_biomarkers.R` | `Fig3_fecal_biomarkers.pdf` (data: `data/tables/fecal_biomarkers.csv`; tests: `output/tables/fecal_biomarkers_group_tests.csv`, ANCOVA adjusted for baseline and sex, without study centre) |
| Fig. 5a–b PCA + biplot | `scripts/figures/fig5/Fig5_manualgating_pca_biplot_dist10_excluded.R` | `Fig5_manualgating_pca_biplot_dist10_excluded.pdf` |
| Fig. 5c pseudotime by feeding | `scripts/figures/fig5/fig5_pseudotime_manualgating_by_feeding.R` | `fig5_pseudotime_manualgating_by_group.pdf` |
| Fig. 5d Olink volcano (change from baseline) | `scripts/figures/fig5/Fig5_olink_synf_ctrlf_stats.R` | `Fig5_olink_volcano_change_from_baseline.pdf` |
| Fig. 5e WGCNA dendrogram | `scripts/analysis/wgcna_cytof_olink_modules_finegrained.R` | `wgcna_finegrained_dendrogram_modules.pdf` |
| Fig. 5f Module 3 eigengene | `scripts/analysis/wgcna_finegrained_brown_splitviolin.R` (stats: `wgcna_module_feeding_interaction.R`) | `wgcna_finegrained_brown_splitviolin.pdf` |
| Fig. 5g Module 3 kME table | `scripts/figures/fig5/Fig5_wgcna_module3_table.R` (inputs: `wgcna_module3_feature_tables.R`) | `Fig5_wgcna_module3_table.pdf` |
| Fig. 7 URTI episodes | `scripts/figures/fig7/Fig7_urti_episodes.R` | `Fig7_urti_episodes.pdf` (data: `data/tables/URTI_durations.csv`; child-years hardcoded from the manuscript) |
| Suppl. Fig. 4 population trajectories | `scripts/figures/fig5/Fig5_manualgating_spaghetti_by_population.R` | `Fig5_manualgating_spaghetti_by_population.pdf` |
| Suppl. Fig. 5 vaccine volcano | `scripts/figures/supplementary/SupplFig5_vaccine_synf_ctrlf_v5.R` | `SupplFig5_vaccine_volcano_v5.pdf` |

## Not reproducible from this repository
- **Fig. 1** — graphical trial-design drawing.
- **Figs. 4 and 6** — no script in this repository yet.
- **Suppl. Figs. 1 and 3** — not code-generated here / not audited.

## Notes
- Fig. 5a–b: script gives PC1/PC2 = 38.6% / 10.8%; the final figure shows 38.7% / 10.8%.
- `subject_id` is the sponsor's neutral blinded ID (`R00xxx`); see README.
