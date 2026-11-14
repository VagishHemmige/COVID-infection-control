# Analysis plan: Universal face shields and SARS-CoV-2 infections among healthcare personnel and hospitalized patients

Status: draft. The plan records the analysis as it was published [@almohajer2021faceshield]; it is not a plan for new analysis.

## Scope and reporting framework

This document is the authoritative specification of the study's aims, setting, intervention, measures and statistical methods. `ARCHITECTURE.md` documents the implementation, `AGENTS.md` the working conventions, and GitHub Issues the open decisions and implementation status. Neither file supersedes this plan.

The study is a quality-improvement evaluation with an interrupted time series design. Reporting follows SQUIRE 2.0 [@ogrinc2016squire]. The reporting map at the end links each relevant SQUIRE item to a section of this plan. Every method below is taken from the published article [@almohajer2021faceshield] or from the original 2021 analysis code that produced its results.

## 1. Problem description

Between April and early July 2020 the hospital had put in place entry restrictions, symptom and temperature screening, universal masking of healthcare personnel and patients, distancing and limits on meeting size. As Texas reopened, SARS-CoV-2 infections among healthcare personnel and hospital-acquired infections among inpatients rose sharply, with clusters in several units [@almohajer2021faceshield].

## 2. Available knowledge and rationale

Face shields protect the eyes, nose and mouth from droplets, may discourage touching of the face, and may act as a barrier between staff and from staff to patients. They are cheap, reusable and easy to clean. In a simulation study cited by the article, a face shield sharply reduced exposure to a simulated cough at close range [@almohajer2021faceshield].

## 3. Specific aim

To assess whether a policy of universal face shields for all healthcare personnel, added to the existing measures, was associated with a change in SARS-CoV-2 infection among healthcare personnel and hospitalized patients.

## 4. Context

- **Setting:** a quaternary care healthcare system in Houston, Texas, with more than 500 beds and about 8,000 healthcare personnel.
- **Surveillance testing** (from 17 April 2020): healthcare personnel in high-risk units (emergency department, transplant units, COVID-19 units) tested biweekly (the article's word); those in cluster areas (3 or more personnel with COVID-19, or any hospital-acquired infection) tested weekly; other personnel tested on request or after exposure. All patients tested on admission and every 7 days. Testing was voluntary. People with a previous positive test were not tested again.
- **Community transmission:** daily COVID-19 cases in Harris County, from the Harris County Public Health COVID Data Dashboard ("Epi Curve"), are shown alongside the hospital series for comparison. They are not modelled.

## 5. Intervention

From 6 July 2020, every healthcare person wore a face shield on entering the facility, for patient encounters and for encounters with other staff. Goggles were allowed for those who could not tolerate a face shield. Patients were not given face shields or goggles.

## 6. Study of the intervention

Interrupted time series of weekly data:

- **Pre-intervention period:** 17 April to 5 July 2020 (universal masking and surveillance testing).
- **Intervention period:** 6 July to 7 September 2020 (face shields added).
- **Weeks** are numbered as in the surveillance data: week 1 begins 17 April 2020, and week 13, beginning 6 July 2020, is the first intervention week. A week is in the intervention period when its number is 13 or more.

## 7. Measures

- **Healthcare-personnel test positivity:** for each week, the number of healthcare personnel testing positive for SARS-CoV-2 out of the number tested, from the surveillance clinic.
- **Hospital-acquired infection (HAI)**, from the electronic medical record, in patients with no previous positive test:
  - *possible HAI:* first positive test 5 to 13 days after admission;
  - *confirmed HAI:* first positive test 14 or more days after admission.
  
  The HAI count for each week is possible and confirmed HAI together.
- **Patient-days:** inpatient days in each week, the denominator for the HAI rate.
- **Community cases:** daily Harris County cases (section 4).

## 8. Analysis

### 8.1 Weekly estimates

- Proportion of healthcare-personnel tests positive each week, with an exact binomial 95% confidence interval.
- HAI rate per 1,000 patient-days each week, with an exact Poisson 95% confidence interval.

Both are computed with the [{epitools}](https://CRAN.R-project.org/package=epitools) package [@epitools].

### 8.2 Segmented regression

Each outcome is modelled with segmented regression [@almohajer2021faceshield]:

- **Healthcare-personnel positivity:** logistic regression of positive tests out of tests performed (binomial, logit link).
- **HAI:** Poisson regression of weekly HAI counts, with log patient-days as an offset.

Both models have the same terms: an indicator for the intervention period, the week centred at week 13 (`Week2` = week − 13), and their interaction. Centring at week 13 makes the intervention term the difference, at week 13, between the predicted value with and without the intervention. The interaction term is the change in slope after the intervention, on the log-odds scale for positivity and the log scale for HAI.

Reported for each outcome:

- the predicted value at week 13 without and with the intervention, and the P value of the intervention term;
- the P value of the change in slope (the interaction term).

Significance is P < 0.05. The published analysis used R 4.0.2 [@rcore2020].

### 8.3 Exploratory models

The original code also fitted three simpler models for each outcome, which were judged not to fit the data and were not reported in the article:

1. week alone, as a linear trend, ignoring the intervention;
2. the intervention period alone, ignoring time;
3. the intervention period and week, without an interaction (a level change with the same slope before and after).

They are kept to show why the published model (8.2) was chosen. They are labelled exploratory wherever they appear and are never presented as results of the study.

### 8.4 Figures

- **Figure 1:** weekly positivity (A) and HAI rate (B) with 95% confidence intervals, point size proportional to tests performed or patient-days, the fitted segmented regression line, and a vertical line between weeks 12 and 13.
- **Figure 2:** the same series by date, with daily Harris County cases as bars on a second axis.

## 9. Ethical considerations

The study was deemed exempt from institutional review board review [@almohajer2021faceshield]. The analysis uses weekly aggregate counts only; no individual-level data were available or used.

## 10. Disclosure control

The weekly counts are institutional quality-improvement data and are not published in this repository. Numbers reported in the article may be quoted, with their location in the article.

## 11. Limitations to address in reporting

As the article discusses [@almohajer2021faceshield]:

- state measures introduced during the intervention period reduced community transmission and may confound the result, although hospital infections fell faster than community cases;
- adherence to other infection-prevention measures was not assessed;
- without individual-level data, effects by role or by unit cannot be examined;
- testing uptake rose during the surge, which may confound the positivity series;
- face shield tolerability was not measured.

## Reporting map

| SQUIRE 2.0 item | Topic | Plan section |
|---|---|---|
| 4 | Problem description | 1 |
| 5 | Available knowledge | 2 |
| 6 | Rationale | 2 |
| 7 | Specific aims | 3 |
| 8 | Context | 4 |
| 9 | Intervention | 5 |
| 10 | Study of the intervention | 6 |
| 11 | Measures | 7 |
| 12 | Analysis | 8 |
| 13 | Ethical considerations | 9 |

## References

::: {#refs}
:::
