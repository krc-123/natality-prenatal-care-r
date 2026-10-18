# When does prenatal care begin? US births, 2014

An R analysis of the timing of prenatal care across every US birth certificate from 2014, and how that timing differs by the mother's race. It started as graduate coursework at Johns Hopkins and is rebuilt here as a standalone script with its own data instructions.

The question behind it comes from my work: Deaf and hard-of-hearing mothers often enter prenatal care late or fall out of it because nobody arranged an interpreter, and I wanted population-level data on where late entry concentrates before arguing for language access reform in perinatal care.

## What the script does

1. Loads the ICPSR R data file for the 2014 Natality Detail File (about 3.99 million rows, one per birth).
2. Keeps two variables: `PRECARE` (month prenatal care began; 00 is no care, 99 is unknown) and `MRACE6` (mother's race, six categories).
3. Recodes unknown to missing and collapses month of first visit into first, second, or third trimester, or no care.
4. Draws a repeatable 80 percent random sample (seed 456) to keep plotting fast.
5. Writes two summary tables and two charts to `output/`:
   - a bar chart of births by the trimester in which care began
   - a boxplot of the month care began, by mother's race

## What it shows

Most births in 2014 had care beginning in the first trimester, with a long tail into the second and third and a small but real group with no prenatal care at all. In the boxplot, Black and American Indian or Alaska Native mothers have higher medians and wider interquartile ranges than White and Asian mothers, meaning care tends to start later and with more variability. Native Hawaiian and Other Pacific Islander mothers show the widest spread of all.

A birth certificate file is cross-sectional, so this describes patterns and does not establish causes. Linking to other sources would be needed to say anything about why.

## Getting the data

The data are not in this repository because ICPSR's terms do not allow redistribution.

- ICPSR study 36461, Natality Detail File, 2014: https://www.icpsr.umich.edu/web/ICPSR/studies/36461 (R format available; ICPSR member institution login required)
- The same public-use file is also distributed by CDC/NCHS: https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm

Download the R version, put `36461-0001-Data.rda` in a `data/` folder, and run:

```r
install.packages(c("ggplot2", "scales"))
source("prenatal_care_timing.R")
```

## Files

- `prenatal_care_timing.R` the whole analysis
- `output/` tables and charts the script writes (not committed; run the script to produce them)

## Citation

United States Department of Health and Human Services, Centers for Disease Control and Prevention, National Center for Health Statistics. (2016). Natality Detail File, 2014 [United States] (ICPSR 36461). Inter-university Consortium for Political and Social Research. https://doi.org/10.3886/ICPSR36461.v1

## License

MIT for the code. The data belong to NCHS and ICPSR under their own terms.
