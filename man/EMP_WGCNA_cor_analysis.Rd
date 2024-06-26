% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/02.EMP.utilis.R
\name{EMP_WGCNA_cor_analysis}
\alias{EMP_WGCNA_cor_analysis}
\alias{EMP_WGCNA_cor_analysis,EMPT-method}
\alias{EMP_WGCNA_cor_analysis,EMP-method}
\title{EMP_WGCNA_cor_analysis}
\usage{
EMP_WGCNA_cor_analysis(obj, ...)

\S4method{EMP_WGCNA_cor_analysis}{EMPT}(
  obj,
  method = "spearman",
  coldata_to_assay = NULL,
  action = "add",
  ...
)

\S4method{EMP_WGCNA_cor_analysis}{EMP}(
  obj,
  select = NULL,
  method = "spearman",
  action = "add",
  ...
)
}
\arguments{
\item{obj}{EMPT or MultiAssayExperiment object.}

\item{...}{...}

\item{method}{A character string. Methods include pearson (default), spearman.}

\item{coldata_to_assay}{A series of character strings. Select the column from coldata to caculate.}

\item{action}{A character string. Whether to join the new information to the EMPT (add), or just get the detailed result generated here (get).}

\item{select}{A character string. The experiment name in the EMP object.}
}
\value{
EMP object
}
\description{
EMP_WGCNA_cor_analysis
}
\examples{
\dontrun{
data(MAE)
## from one experiment
WGCNA_COR_result <- MAE |>
  EMP_assay_extract('geno_ec')  |> 
  EMP_identify_assay(method = 'edgeR',estimate_group = 'Group') |>
  EMP_WGCNA_cluster_analysis(RsquaredCut = 0.85,mergeCutHeight=0.4)  |>
  EMP_WGCNA_cor_analysis(coldata_to_assay = c('BMI','PHQ9','GAD7','HAMD','SAS','SDS'),
                         method='spearman',action='add') # If want the detailed result, set action = 'get'

## Visualization
MAE |>
  EMP_assay_extract('geno_ec')  |> 
  EMP_identify_assay(method = 'edgeR',estimate_group = 'Group') |>
  EMP_WGCNA_cluster_analysis(RsquaredCut = 0.85,mergeCutHeight=0.4)  |>
  EMP_WGCNA_cor_analysis(coldata_to_assay = c('BMI','PHQ9','GAD7','HAMD','SAS','SDS'),method='spearman') |>
  EMP_heatmap_plot(palette = 'Spectral')

## Filter the interesting module and make the enrichment analysis
MAE |>
  EMP_assay_extract('geno_ec')  |> 
  EMP_identify_assay(method = 'edgeR',estimate_group = 'Group') |>
  EMP_WGCNA_cluster_analysis(RsquaredCut = 0.85,mergeCutHeight=0.4)  |>
  EMP_WGCNA_cor_analysis(coldata_to_assay = c('BMI','PHQ9','GAD7','HAMD','SAS','SDS'),method='spearman') |>
  EMP_heatmap_plot(palette = 'Spectral') |>
  EMP_filter(feature_condition = WGCNA_color == 'brown' ) |> 
  EMP_diff_analysis(method = 'DESeq2',.formula = ~Group) |>
  EMP_enrich_analysis(keyType = 'ec',KEGG_Type = 'MKEGG') |>
  EMP_dotplot()

## from two different experiments
k1 <- MAE |>
  EMP_assay_extract('geno_ec')  |> 
  EMP_identify_assay(method = 'edgeR',estimate_group = 'Group') |>
  EMP_WGCNA_cluster_analysis(RsquaredCut = 0.85,mergeCutHeight=0.4)

k2 <- MAE |>
  EMP_assay_extract('host_gene',pattern = c('A1BG','A1CF','A2MP1','AACS'),pattern_ref = 'feature')

(k1 + k2) |>
  EMP_WGCNA_cor_analysis(method='spearman') |>
  EMP_heatmap_plot(palette = 'Spectral') 
}
}
