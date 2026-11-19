suppressPackageStartupMessages({
  source("scripts/lib/common.R")
})

load_required_packages(c("ggplot2", "dplyr", "readr", "patchwork"))

root <- get_repo_root()
# Source: data/tables/fecal_biomarkers.csv (same data as the "Biomarkers" sheet of
# microbiome_metabolomics_data.xlsx; EF/CF relabelled SynF/CtrlF) and data/tables/demographics.csv (sex).
# Values at an assay limit are plotted as reported: calprotectin 2330 mg/kg, sIgA 60,500 mg/kg, AAT 10 mg/g.
biomarkers <- readr::read_csv(file.path(root, "data/tables/fecal_biomarkers.csv"), show_col_types = FALSE)
demographics <- readr::read_csv(file.path(root, "data/tables/demographics.csv"), show_col_types = FALSE) |>
  dplyr::select(subject_id, sex)

VISIT_LABELS <- c(V1 = "Baseline", V3 = "2 mo", V5 = "4 mo", V6 = "6 mo")
GROUP_COLS <- c("CtrlF" = "#1FAF6B", "SynF" = "#3EA6E0")
panels <- list(
  calprotectin = list(title = "Calprotectin", ylab = "F-Calprotectin\n(mg/kg of dry stool)", log = TRUE),
  AAT          = list(title = "A1-antitrypsin", ylab = "AAT (mg/g of dry stool)", log = TRUE),
  sIgA         = list(title = "Secretory IgA", ylab = "sIgA (mg/kg of dry stool)", log = TRUE),
  pH           = list(title = "pH", ylab = "pH", log = FALSE)
)

df <- biomarkers |>
  dplyr::left_join(demographics, by = "subject_id") |>
  dplyr::mutate(
    group_feeding = factor(group_feeding, levels = c("CtrlF", "SynF")),
    visit_label = factor(VISIT_LABELS[visit], levels = VISIT_LABELS)
  )

# Group comparison at each post-baseline visit: ANCOVA of the outcome on feeding group, adjusted for the
# baseline (V1) value and sex. Concentrations are log-transformed (outcome and baseline); pH is not.
# Manuscript Methods also adjust for study centre, which is not part of the shared data, so p-values can
# differ slightly: with this model AAT at 6 months gives p = 0.052 where the manuscript figure shows *.
group_test <- function(marker, visit_code, log_scale) {
  tf <- if (log_scale) log else identity
  baseline <- df |>
    dplyr::filter(visit == "V1", !is.na(.data[[marker]])) |>
    dplyr::transmute(subject_id, baseline = tf(.data[[marker]]))
  x <- df |>
    dplyr::filter(visit == visit_code, !is.na(.data[[marker]])) |>
    dplyr::transmute(subject_id, group_feeding, sex, y = tf(.data[[marker]])) |>
    dplyr::inner_join(baseline, by = "subject_id")
  fit <- summary(lm(y ~ group_feeding + baseline + sex, data = x))$coefficients["group_feedingSynF", ]
  data.frame(marker = marker, visit = visit_code, n = nrow(x),
             estimate = unname(fit["Estimate"]), p_value = unname(fit["Pr(>|t|)"]))
}

tests <- dplyr::bind_rows(lapply(names(panels), function(m) {
  dplyr::bind_rows(lapply(c("V3", "V5", "V6"), function(v) group_test(m, v, panels[[m]]$log)))
})) |>
  dplyr::mutate(label = vapply(p_value, add_significance, character(1)))

dir.create(file.path(root, "output/tables"), recursive = TRUE, showWarnings = FALSE)
readr::write_csv(tests, file.path(root, "output/tables/fecal_biomarkers_group_tests.csv"))

make_panel <- function(marker) {
  p <- panels[[marker]]
  d <- df |> dplyr::filter(!is.na(.data[[marker]]))
  rng <- range(d[[marker]])
  pad <- diff(rng) * 0.05
  bracket <- tests |>
    dplyr::filter(marker == !!marker) |>
    dplyr::mutate(x = match(VISIT_LABELS[visit], VISIT_LABELS), y = rng[2] + pad)
  ggplot2::ggplot(d, ggplot2::aes(x = visit_label, y = .data[[marker]], fill = group_feeding)) +
    ggplot2::geom_boxplot(position = ggplot2::position_dodge(width = 0.8), width = 0.7, outlier.shape = NA,
                          colour = "grey20", linewidth = 0.3, median.linewidth = 1.2) +
    ggplot2::geom_point(ggplot2::aes(colour = group_feeding),
                        position = ggplot2::position_jitterdodge(jitter.width = 0.15, dodge.width = 0.8, seed = 1),
                        size = 0.8, show.legend = FALSE) +
    ggplot2::geom_segment(data = bracket, ggplot2::aes(x = x - 0.2, xend = x + 0.2, y = y, yend = y),
                          inherit.aes = FALSE, linewidth = 0.3) +
    ggplot2::geom_text(data = bracket, ggplot2::aes(x = x, y = y + pad * 0.3, label = label),
                       inherit.aes = FALSE, size = 3.2, vjust = 0) +
    ggplot2::scale_fill_manual(values = GROUP_COLS, name = NULL) +
    ggplot2::scale_colour_manual(values = GROUP_COLS) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.02, 0.12))) +
    ggplot2::labs(title = p$title, x = NULL, y = p$ylab) +
    ggplot2::theme_classic(base_size = 9) +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 9, hjust = 0.05),
                   legend.position = "top", axis.line.x = ggplot2::element_blank(),
                   axis.ticks.x = ggplot2::element_blank())
}

fig <- patchwork::wrap_plots(lapply(names(panels), make_panel), ncol = 1) +
  patchwork::plot_layout(guides = "collect") +
  patchwork::plot_annotation(tag_levels = "a") &
  ggplot2::theme(legend.position = "top", plot.tag = ggplot2::element_text(face = "bold", size = 12))

save_pdf(fig, file.path(root, "output/figures/manuscript/Fig3_fecal_biomarkers.pdf"), width = 5.2, height = 9)
print(tests |> dplyr::mutate(p_value = signif(p_value, 3), estimate = round(estimate, 3)))
