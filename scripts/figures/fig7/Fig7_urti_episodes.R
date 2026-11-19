suppressPackageStartupMessages({
  source("scripts/lib/common.R")
})

load_required_packages(c("ggplot2", "dplyr", "readr", "patchwork"))

root <- get_repo_root()
# Source: data/tables/URTI_durations.csv -- one row per adverse event (AE) in infants with >=1 AE.
# Event == 1 flags URTI episodes (MedDRA "Upper respiratory tract infection" + "Viral upper
# respiratory tract infection"; 46 CtrlF / 25 SynF, as in the manuscript text for Fig. 7).
# DAYS = days from baseline to episode onset; Duration = episode length (days); count = episode
# number within child.
urti <- readr::read_csv(file.path(root, "data/tables/URTI_durations.csv"), show_col_types = FALSE) |>
  dplyr::filter(Event == 1) |>
  dplyr::mutate(
    group = factor(group, levels = c("CtrlF", "SynF")),
    onset = DAYS,
    end = DAYS + Duration,
    episode = factor(dplyr::case_when(count == 1 ~ "first", count == 2 ~ "second", TRUE ~ "third"),
                     levels = c("first", "second", "third"))
  )

# Child-years of follow-up per arm (Fig. 7c). Not derivable from URTI_durations.csv, which only
# lists children with >=1 AE; taken from the manuscript figure (Poisson regression offset).
child_years <- c(CtrlF = 55.74, SynF = 53.75)
events <- table(urti$group)[names(child_years)]
irate <- as.numeric(events) / child_years
pois <- stats::glm(
  n ~ group + offset(log(cy)),
  family = stats::poisson(),
  data = data.frame(group = factor(names(child_years), levels = c("CtrlF", "SynF")),
                    n = as.numeric(events), cy = as.numeric(child_years))
)
p_pois <- summary(pois)$coefficients["groupSynF", "Pr(>|z|)"]

cols <- c(CtrlF = "#5CB85C", SynF = "#4A90D9")
cols_dark <- c(CtrlF = "#2E8B57", SynF = "#3A6FB5")
cols_box <- c(CtrlF = "#9FD87F", SynF = "#7F9FDF")

# Axis: days from baseline (enrollment at 14-35 d of age); 2/4/6 months ~ 61/122/183 d
x_breaks <- c(0, 61, 122, 183)
x_labels <- c("14-35d", "2mo", "4mo", "6mo")

# Panels a-b: one row per child with URTI, ordered by first onset (earliest at bottom)
swimmer <- function(g) {
  d <- urti |> dplyr::filter(group == g)
  ord <- d |>
    dplyr::group_by(subject_id) |>
    dplyr::summarise(first = min(onset), .groups = "drop") |>
    dplyr::arrange(first, subject_id) |>
    dplyr::mutate(row = dplyr::row_number())
  d <- dplyr::left_join(d, ord, by = "subject_id")
  ggplot2::ggplot(d) +
    ggplot2::geom_hline(yintercept = ord$row, linetype = "dotted", color = "gray75", linewidth = 0.25) +
    ggplot2::geom_segment(ggplot2::aes(x = onset, xend = end, y = row, yend = row),
                          color = cols[[g]], alpha = 0.45, linewidth = 2.4, lineend = "round") +
    ggplot2::geom_point(ggplot2::aes(x = onset, y = row), color = cols_dark[[g]], size = 1.8) +
    ggplot2::scale_x_continuous(breaks = x_breaks, labels = x_labels, limits = c(-5, 190)) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(add = 0.8)) +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_classic(base_size = 8) +
    ggplot2::theme(axis.line.y = ggplot2::element_blank(), axis.text.y = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank())
}
pa <- swimmer("CtrlF") +
  ggplot2::labs(title = "Upper respiratory tract infections", subtitle = "CtrlF") +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 8),
                 plot.subtitle = ggplot2::element_text(color = cols[["CtrlF"]], face = "bold", size = 8))
pb <- swimmer("SynF") +
  ggplot2::labs(subtitle = "SynF") +
  ggplot2::theme(plot.subtitle = ggplot2::element_text(color = cols[["SynF"]], face = "bold", size = 8))

# Panel c: incidence summary (text table)
fmt <- function(x, d) formatC(x, format = "f", digits = d)
pc <- ggplot2::ggplot() +
  ggplot2::annotate("text", x = 0.5, y = 5, label = "Number of URTI episodes:", fontface = "bold", size = 2.8) +
  ggplot2::annotate("text", x = c(0.38, 0.64), y = 4, label = c("CtrlF", "SynF"), fontface = "bold",
                    size = 2.6, color = cols) +
  ggplot2::annotate("text", x = 0.3, y = 3, label = "Child years:", hjust = 1, size = 2.4) +
  ggplot2::annotate("text", x = 0.31, y = 3, label = fmt(child_years[["CtrlF"]], 2), hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.57, y = 3, label = fmt(child_years[["SynF"]], 2), hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.3, y = 2, label = "Events:", hjust = 1, size = 2.4) +
  ggplot2::annotate("text", x = 0.31, y = 2, label = events[["CtrlF"]], hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.57, y = 2, label = events[["SynF"]], hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.3, y = 1, label = "Incidence rates:", hjust = 1, size = 2.4) +
  ggplot2::annotate("text", x = 0.31, y = 1, label = fmt(irate[1], 3), hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.57, y = 1, label = fmt(irate[2], 3), hjust = 0, size = 2.4) +
  ggplot2::annotate("text", x = 0.8, y = 2, label = paste0("p=", fmt(p_pois, 3)), fontface = "bold",
                    hjust = 0, size = 2.4) +
  ggplot2::scale_x_continuous(limits = c(0, 1)) +
  ggplot2::scale_y_continuous(limits = c(0.3, 5.5)) +
  ggplot2::theme_void()

# Panel d: episode duration by episode number, CtrlF and SynF side by side on a shared y-axis
dd <- urti |> dplyr::filter(!is.na(Duration))
dodge <- ggplot2::position_dodge(width = 0.8)
pd <- ggplot2::ggplot(dd, ggplot2::aes(x = episode, y = Duration, fill = group, color = group)) +
  ggplot2::geom_boxplot(ggplot2::aes(color = NULL), color = "black", alpha = 0.7, width = 0.7,
                        outlier.shape = NA, linewidth = 0.3, position = dodge) +
  ggplot2::geom_point(position = ggplot2::position_jitterdodge(jitter.width = 0.15, jitter.height = 0,
                                                               dodge.width = 0.8),
                      size = 1.1, alpha = 0.9, show.legend = FALSE) +
  ggplot2::scale_fill_manual(values = cols_box, name = NULL) +
  ggplot2::scale_color_manual(values = cols_dark, guide = "none") +
  ggplot2::scale_y_continuous(limits = c(0, 40), expand = ggplot2::expansion(mult = c(0, 0.02))) +
  ggplot2::labs(title = "Duration of URTI episodes", x = NULL, y = "URTI duration (days)") +
  ggplot2::theme_classic(base_size = 8) +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 8, hjust = 0.5),
                 legend.position = "bottom", legend.key.size = ggplot2::unit(0.3, "cm"))

design <- "
AAAAABBBBBDDD
AAAAABBBBBDDD
AAAAACCCCCDDD
AAAAACCCCCDDD
AAAAACCCCCDDD
"
p <- pa + pb + pc + pd +
  patchwork::plot_layout(design = design) +
  patchwork::plot_annotation(tag_levels = list(c("a", "b", "c", "d")),
                             theme = ggplot2::theme(plot.tag = ggplot2::element_text(face = "bold", size = 12)))

out_dir <- file.path(root, "output/figures/manuscript")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
ggplot2::ggsave(file.path(out_dir, "Fig7_urti_episodes.pdf"), plot = p, width = 10, height = 5)

# Console summary for checking against the manuscript text
message(sprintf("Events CtrlF/SynF: %d/%d; IRR (SynF/CtrlF) = %.3f; Poisson p = %.3f",
                events[["CtrlF"]], events[["SynF"]], irate[2] / irate[1], p_pois))
first <- urti |> dplyr::filter(episode == "first", !is.na(Duration))
message(sprintf("First-episode duration, SynF vs CtrlF: Wilcoxon p = %.3f; t-test p = %.3f",
                suppressWarnings(stats::wilcox.test(Duration ~ group, first)$p.value),
                stats::t.test(Duration ~ group, first)$p.value))
