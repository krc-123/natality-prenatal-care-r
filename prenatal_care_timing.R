# Timing of prenatal care initiation in US births, 2014
# Katie-Rose Chubb
#
# Data: CDC/NCHS Natality Detail File, 2014, as archived by ICPSR (study 36461).
# One row per US birth certificate (about 3.99 million rows).
# The data are not included in this repository. See README.md for how to get them.
#
# Variables used
#   PRECARE  month of pregnancy in which prenatal care began
#            00 = no prenatal care, 01 to 10 = month, 99 = unknown or not stated
#   MRACE6   mother's race, six categories (labelled factor in the ICPSR R file)

library(ggplot2)

# ---- 1. Load ---------------------------------------------------------------
# Point this at the .rda file from the ICPSR download (DS0001).
data_path <- "data/36461-0001-Data.rda"
load(data_path)                         # creates da36461.0001
natality_raw <- as.data.frame(da36461.0001)
rm(da36461.0001)

cat("Rows loaded:", format(nrow(natality_raw), big.mark = ","), "\n")

# ---- 2. Select and clean ---------------------------------------------------
natality_df <- natality_raw[, c("PRECARE", "MRACE6")]
rm(natality_raw)

# PRECARE arrives as a numeric code. 99 is "unknown", so it becomes NA.
natality_df$PRECARE <- as.numeric(as.character(natality_df$PRECARE))
natality_df$PRECARE[natality_df$PRECARE == 99] <- NA

# Collapse month of first visit into trimester. 00 means no care at all.
natality_df$TRIMESTER <- ifelse(natality_df$PRECARE == 0,  "No Care",
                         ifelse(natality_df$PRECARE <= 3,  "1st Trimester",
                         ifelse(natality_df$PRECARE <= 6,  "2nd Trimester",
                         ifelse(natality_df$PRECARE <= 10, "3rd Trimester", NA))))

natality_df$TRIMESTER <- factor(natality_df$TRIMESTER,
  levels = c("1st Trimester", "2nd Trimester", "3rd Trimester", "No Care"))

natality_clean <- na.omit(natality_df)
cat("Rows after removing unknown prenatal care:",
    format(nrow(natality_clean), big.mark = ","), "\n")

# ---- 3. Sample -------------------------------------------------------------
# An 80 percent random sample keeps the plots fast to draw and is more than
# enough to show the shape of the distribution. The seed makes it repeatable.
set.seed(456)
sample_index   <- sample(seq_len(nrow(natality_clean)),
                         size = round(0.8 * nrow(natality_clean)))
natality_sample <- natality_clean[sample_index, ]
cat("Rows in 80% sample:", format(nrow(natality_sample), big.mark = ","), "\n")

# ---- 4. Summary table ------------------------------------------------------
trimester_counts <- as.data.frame(table(natality_sample$TRIMESTER))
names(trimester_counts) <- c("trimester", "births")
trimester_counts$share <- round(100 * trimester_counts$births /
                                  sum(trimester_counts$births), 1)
print(trimester_counts)

median_by_race <- aggregate(PRECARE ~ MRACE6, data = natality_sample,
                            FUN = median)
names(median_by_race) <- c("mother_race", "median_month_care_began")
print(median_by_race)

dir.create("output", showWarnings = FALSE)
write.csv(trimester_counts, "output/trimester_counts.csv", row.names = FALSE)
write.csv(median_by_race,   "output/median_month_by_race.csv", row.names = FALSE)

# ---- 5. Plot: when care begins --------------------------------------------
p1 <- ggplot(natality_sample, aes(x = TRIMESTER, fill = TRIMESTER)) +
  geom_bar(color = "white") +
  scale_fill_manual(values = c(
    "1st Trimester" = "#2C7BB6",
    "2nd Trimester" = "#ABD9E9",
    "3rd Trimester" = "#FDAE61",
    "No Care"       = "#D7191C")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title   = "Timing of Prenatal Care Initiation Among U.S. Births, 2014",
    caption = "Source: CDC/NCHS Natality Detail File, 2014 (ICPSR 36461). 80% random sample.",
    x       = "Trimester Prenatal Care Began",
    y       = "Number of Births",
    fill    = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    plot.caption     = element_text(size = 8, color = "gray50"),
    plot.title       = element_text(face = "bold"))

ggsave("output/precare_by_trimester.png", plot = p1, width = 8, height = 6, dpi = 150)
ggsave("output/precare_by_trimester.pdf", plot = p1, width = 8, height = 6)

# ---- 6. Plot: when care begins, by mother's race --------------------------
p2 <- ggplot(natality_sample, aes(x = MRACE6, y = PRECARE, fill = MRACE6)) +
  geom_boxplot(color = "gray30", outlier.alpha = 0.2, outlier.size = 0.5) +
  labs(
    title   = "Prenatal Care Timing by Mother's Race, U.S. Births 2014",
    caption = "Source: CDC/NCHS Natality Detail File, 2014 (ICPSR 36461). 80% random sample.",
    x       = "Mother's Race",
    y       = "Month Prenatal Care Began (0 = no care)",
    fill    = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    plot.caption     = element_text(size = 8, color = "gray50"),
    plot.title       = element_text(face = "bold"),
    axis.text.x      = element_text(angle = 25, hjust = 1))

ggsave("output/precare_by_race_boxplot.png", plot = p2, width = 8, height = 6, dpi = 150)
ggsave("output/precare_by_race_boxplot.pdf", plot = p2, width = 8, height = 6)

cat("Done. Plots and tables are in output/\n")
