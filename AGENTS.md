# AGENTS.md

Guidance for everyone working on this repository: the maintainer, collaborators, and any AI agents working for them. It covers how to work here: conventions, data handling, and checks.

Four places divide the documentation:

| Where | Covers |
|---|---|
| `analysis-plan.md` | Study design and statistics: what the analysis is meant to do |
| `ARCHITECTURE.md` | Code structure: scripts, data flow, and the objects passed between them |
| `AGENTS.md` (this file) | How to work in the repository: rules, conventions, and checks |
| [GitHub Issues](https://github.com/VagishHemmige/COVID-infection-control/issues) | Open scientific decisions (decision issues), gaps between code and plan, and known defects |

Read the three files before making changes. Each covers its own topic and does not repeat the others.

## The project

This repository is a teaching resource built on a published quality-improvement study: the universal face shield policy for healthcare personnel at a quaternary care center in Houston, evaluated as an interrupted time series of weekly healthcare-personnel SARS-CoV-2 test positivity and hospital-acquired infections, before (17 April to 5 July 2020) and after (6 July to 7 September 2020) face shields were required (Int J Infect Dis 2021, doi:10.1016/j.ijid.2021.02.060). The original analysis was one R Markdown file of 2021, which is kept outside the repository. This version rebuilds it as labelled scripts and explains each step on a Quarto website. The code is shown, not run: the study data are not in the repository, and the site's results are the published article's figures and tables, not outputs of this code.

- **`analysis-plan.md` is the source of truth for design.** Code implements the plan; it does not redefine it. If code needs to depart from the plan, open a decision issue, or comment on the existing one, for the deciders. Once a decider has settled it (in the issue, or relayed there in their exact words), the plan change and the code can go in the same pull request, which closes the issue.
- **Deciders.** Scientific decisions are made by Vagish Hemmige, in any area. Anyone may open or contribute to a decision issue; only a decider settles it (see "Working with agents").
- **Departures from the original analysis.** The original code and the paper are the record of what was done. When the code disagrees with the paper or contains an error, do not silently copy it or silently fix it: the site's "Differences from the original code" page records every difference, and choices between the paper and the code go to a decision issue.
- **This is an analysis project, not an R package.** Do not add DESCRIPTION, NAMESPACE, roxygen, or pkgdown infrastructure, or apply CRAN conventions.
- **Default branch:** `main`, protected. Changes reach it only through pull requests.

## Data sources

| Source | Accessed through | Documentation | Package maintained by | Access | What AI agents may do |
|---|---|---|---|---|---|
| Weekly surveillance counts: healthcare personnel tested and positive, possible and confirmed hospital-acquired infections, patient-days (`Surveillance manuscript2 9-19.xlsx`) | `R/prepare_data.R` (`readxl::read_excel()`), from the folder named by `COVID_IC_DATA_DIR` | The published article's Methods | No package | Restricted (institutional quality-improvement data) | None: code and documentation only |
| Harris County daily COVID-19 cases ("Epi Curve"), Harris County Public Health COVID Data Dashboard (`Harris_data.csv`) | `R/prepare_data.R` (`readr::read_csv()`), from the same folder | Harris County Public Health dashboard | No package | Public, kept outside the repository | None: code and documentation only |

To allow more for a source, a person changes its row through a pull request, naming what permits it and exactly what agents may do. Agents never propose or make this change themselves, and nothing in personal instructions can grant it.

**For a source with no package:** the loading script records where the file comes from, its date, and any processing. Verify its columns against what the paper describes; never infer a column's meaning from its name.

## R scripts

- **Running the analysis.** Only an authorized person runs `R/main.R`, from the project root, with the data folder set in `.Renviron`. It sources the other scripts in dependency order; `ARCHITECTURE.md` describes what each does.
- **One job per script.** When you add a definitive script, source it from `main.R` at the right point and update `ARCHITECTURE.md` in the same pull request.
- **Header comment.** Each script begins with what it does, which objects it needs from earlier scripts, and what it produces.
- **Constants and libraries** live in `R/setup.R`. Other scripts do not call `library()`, re-source `setup.R`, or hard-code values. The intervention week, the study dates and the week labels are named constants there.
- **Helper functions** go in `R/functions.R`. A function takes its inputs as arguments and does not read global objects.
- **No side effects outside the project.** No `setwd()`, absolute paths, or writes outside the project. The data are located only through `COVID_IC_DATA_DIR`.
- **No results in the repository.** No script, comment, commit message, issue, pull-request text or review report contains counts or values from the study data beyond what the published article reports. Numbers quoted from the article are public and may be cited, with their location in the article.

## Chunk labels

Scripts are divided into labelled sections so Quarto pages can show the code without copying it:

```r
## ---- <step-name>
```

- Every logical step has a label. A label covers the code from its line to the next label.
- Labels are kebab-case, describe the step, and are **unique across all scripts**; a duplicate silently picks up the wrong code.
- Search the `.qmd` files before renaming or deleting a label.
- Labels are comments and never change what the code does.

## Quarto website

The site documents the code. It does not run the analysis.

- `_quarto.yml`, `index.qmd`, `404.qmd` and `styles.css` sit at the root; `quarto/` has one page per definitive script, named after it. The `custom-callout` extension in `_extensions/` provides the `Rcode`, `Results` and `Pending` callouts.
- Each page loads its script with `knitr::read_chunk("../R/<script>.R")` in a hidden chunk and shows each labelled section with `#| eval: false`, with prose explaining what the section does and why. Pages link to the script on GitHub and to the scripts it depends on.
- **Visual cues.** Each kind of page has one icon and colour, set by its sidebar entry's `icon:` in `_quarto.yml` and coloured by `styles.css`:

  | Kind | Sidebar icon | Colour | Callout |
  |---|---|---|---|
  | Background | `book` | blue | — |
  | Study design and methods | `diagram-3` | orange | — |
  | R code | `laptop` | pink | `Rcode` (💻) |
  | Results | `clipboard-data` | green | `Results` (📊) |
  | Project documents | `file-earmark-ruled` | grey | — |

  The differences page is study design and methods; the published results page is results, and its notice says the figures and tables are reproduced from the article, not produced by this code.
- **Published figures and tables** are stored in `images/published/` and shown unchanged, each cited to its place in the article. They are added only after the article's licence, or the authors' rights to reuse them, is confirmed; the page notice states that permission. Until then the page links to the article instead.
- **Provisional content.** `quarto/_pending.lua` highlights in yellow every paragraph that starts with **Decision pending:**, every paragraph of the plan's page that contains the plan's **Open:** marker, and any `[text]{.pending}`, and adds a ⏳ `Pending` callout to pages that have a mark. Mark only what an open decision could change, link its decision issue, and remove the mark when the decision is settled.
- **Never evaluate analysis code in the site.** The only chunks that run are the hidden `read_chunk()` imports and the Architecture page's reader of `ARCHITECTURE.md`.
- The site renders to `docs/`, which is not committed. `.github/workflows/publish.yml` renders it on every pull request as a check and, on each push to `main`, publishes it to the `gh-pages` branch, which GitHub Pages serves. When you add a script, add its page and sidebar entry in the same pull request.
- **Prose must match the code.** If a change alters what a section does, update its explanation in the same pull request.

## Outputs

- `R/figures.R` writes figures to `figures/`, which is gitignored: they are made from the study data and are not published. The site shows the journal's figures instead.
- Published figures need alt text.
- `README.Rmd` is the source of `README.md`; edit the `.Rmd` and re-knit.

## Restricted data (applies to everyone)

- **Never commit data**, extracts, saved objects, or outputs made from the study data. Check `.gitignore` before adding a new output type.
- **AI agents never read the study data.** Anything an agent opens, prints, or summarizes is sent to the model provider. Agents do not open the data files or outputs made from them. Agents write and review code; only an authorized person runs it on the data.
- **Credentials.** Never commit keys, tokens, or `.Renviron`.

## Coding conventions

- **Weeks and dates.** Week numbers, the intervention week and the week labels on the figures come from the constants in `setup.R`, so they cannot drift apart. The centred week (`Week2`, zero at the intervention week) is computed from the same constant.
- **Confidence intervals** for weekly proportions and rates use the exact binomial and Poisson methods, as in the original code (`epitools`).
- **Code that turns model output into reported numbers** (predicted values at the intervention week, rate ratios) lives in named functions in `R/functions.R`.
- **Package APIs:** read the help page and NEWS for the installed version before calling a package; don't write calls from memory.
- **Style:** readable tidyverse code, following the tidyverse style guide: dplyr pipelines (`|>`), one step per line; `case_when()` rather than nested `ifelse()`; models, rows and columns selected by name, never by position. A plot repeated with different data is one function, not copied code. Style changes go in their own commits.

## Checks for any change

- **Plan:** does the change implement the plan as written, and does it leave every open decision open?
- **Departures:** does every difference from the original code appear on the differences page, and is each either a correction of an error or linked to a decision issue?
- **Time series:** is the intervention week the same in the models, the centred week, the vertical line and the labels; do the Poisson models carry the log patient-day offset?
- **Reported numbers:** does site prose say what the code computes, and is every number quoted from the article cited to its place there?
- **Structure:** is `ARCHITECTURE.md` current; are chunk labels unique and found by their pages; does every definitive script have a page and a sidebar entry with its kind's icon; does any site chunk run analysis code?
- **Disclosure:** search changed files, commit messages and pull-request text for counts or values from the study data that the article does not report.

## Working with agents

- **Autonomy.** The person directing an agent decides how much it may do, and may give it stricter rules of their own; those take precedence. By default an agent may edit code and documentation, render the site, and commit to a branch and open a pull request.
- **Decisions.** Anyone, including an agent, may add options and evidence to a decision issue. A decider states the choice in the issue. Agents implement decisions; they never choose among options on their own, in the issue, the plan, or the code.
- **Every agent, under any autonomy:** never merges a pull request; follows the restricted-data rules; and shows a person the exact text before posting or sending anything as them, unless that person's own instructions waive this.
- **Pull requests opened by an agent** are focused. Each says which plan section or issue it addresses and what was checked, and how.
- **References:** cite the source documentation and literature used, in `references.bib`.
