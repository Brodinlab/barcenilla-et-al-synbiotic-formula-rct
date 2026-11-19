suppressPackageStartupMessages({
  source("scripts/lib/common.R")
})

load_required_packages(c("ggplot2", "dplyr", "readr"))

root <- get_repo_root()
# Source: data/tables/igsq13_scores.csv (IGSQ-13 total score per infant and visit; same data as the
# "IGSQ" sheet of Demographics_AEs_outcomes.xlsx). Mean and t-based 95% CI per group and visit.
igsq <- readr::read_csv(file.path(root, "data/tables/igsq13_scores.csv"), show_col_types = FALSE)
visit_age_months <- c(V1 = 0.75, V2 = 1.5, V3 = 2, V4 = 3, V5 = 4, V6 = 6)
df <- igsq |>
  dplyr::group_by(group, visit) |>
  dplyr::summarise(n = sum(!is.na(igsq13_score)), mean = mean(igsq13_score, na.rm = TRUE),
                   se = stats::sd(igsq13_score, na.rm = TRUE) / sqrt(n), .groups = "drop") |>
  dplyr::mutate(age_months = visit_age_months[visit],
                ci_lower = mean - stats::qt(0.975, n - 1) * se, ci_upper = mean + stats::qt(0.975, n - 1) * se)

age_months <- c(0.75, 1.5, 2, 3, 4, 6)
visit_labels <- c("Baseline", "1.5m", "2m", "3m", "4m", "6m")

p <- ggplot2::ggplot(df, ggplot2::aes(x = age_months, y = mean, color = group, group = group)) +
  ggplot2::geom_hline(yintercept = 30, linetype = "dashed", color = "red", alpha = 0.7) +
  ggplot2::geom_hline(yintercept = 23, linetype = "dashed", color = "orange", alpha = 0.7) +
  ggplot2::geom_errorbar(ggplot2::aes(ymin = ci_lower, ymax = ci_upper), width = 0.15, linewidth = 0.8) +
  ggplot2::geom_line(linewidth = 1) +
  ggplot2::geom_point(size = 3) +
  ggplot2::scale_color_manual(values = c("SynF" = "#4A90D9", "CtrlF" = "#5CB85C"), breaks = c("CtrlF", "SynF")) +
  ggplot2::scale_x_continuous(breaks = age_months, labels = visit_labels, limits = c(0, 6.5)) +
  ggplot2::scale_y_continuous(limits = c(13, 32), breaks = seq(13, 31, 2)) +
  ggplot2::labs(
    title = "Mean IGSQ-13 Scores of GI Tolerance",
    x = NULL,
    y = "IGSQ-13 Score (95% CI)",
    color = ""
  ) +
  ggplot2::theme_classic() +
  ggplot2::theme(
    aspect.ratio = 1,
    plot.title = ggplot2::element_text(hjust = 0.5, face = "bold", size = 14),
    legend.position = "right",
    legend.background = ggplot2::element_rect(fill = "white", color = "gray80"),
    axis.text = ggplot2::element_text(size = 10),
    axis.title = ggplot2::element_text(size = 12)
  ) +
  ggplot2::annotate(
    "text", x = 0.5, y = 30.5,
    label = "Clinically meaningful GI discomfort",
    size = 3, hjust = 0, color = "red"
  ) +
  ggplot2::annotate(
    "text", x = 0.5, y = 23.5,
    label = "Potential GI discomfort",
    size = 3, hjust = 0, color = "orange"
  )

out_dir <- file.path(root, "output/figures/manuscript")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave(file.path(out_dir, "Fig2E_igsq13_gi_tolerance.pdf"), plot = p, width = 8, height = 6)

