
#' Title
#'
#' @param feature features
#' @param from from
#' @param to to
#' @param species species 
#' @param OrgDb OrgDb
#'
#' @return data.frame
#'
#' @noRd

.feature_convert_gene <- function(feature, from = "SYMBOL", to = "ENTREZID", species = "none", OrgDb = NULL) {
    if (!(species %in% c("Human", "Mouse", "Pig", "Zebrafish"))) {
        if (is.null(OrgDb)) {
            stop("The species is not within the built-in species range, OrgDb needs to be provided for conversion.")
        }
        result <- AnnotationDbi::select(x = OrgDb, keys = feature, keytype = from, columns = c(to))
        return(result)
    }
    data_df <- switch(species,
                      "Human" = res_Hs,
                      "Mouse" = res_Mm,
                      "Pig" = res_Ss,
                      "Zebrafish" = res_Dr
                      )
    from <- match.arg(from, colnames(data_df))
    to <- match.arg(to, colnames(data_df))
    result <- data_df[data_df[, from] %in% feature, c(from, to)]
    na_feature <- setdiff(feature, result[, 1])
    if (length(na_feature) > 0) {
        result2 <- data.frame(from = na_feature, to = NA)
        colnames(result2) <- colnames(result)
        result <- rbind(result, result2)
    }
    result <- dplyr::distinct(result)
    result <- result[!duplicated(result[, 1]), ]
    return(result)  
}    


#' Title
#'
#' @param EMPT EMPT
#' @param method method
#' @param from from
#' @param to to
#' @param species species 
#' @param OrgDb OrgDb
#'
#' @return data.frame
#'
#' @noRd

.EMP_feature_convert_gene <- function(EMPT,method='mean',from,to,species = "Human", OrgDb = NULL) {
  feature <- NULL
  raw_feature <- .get.row_info.EMPT(EMPT) %>% dplyr::pull(feature)
  ref_data <- .feature_convert_gene(feature=raw_feature, 
                                       from = from, 
                                       to = to, 
                                       species = species, 
                                       OrgDb=OrgDb)
  colnames(ref_data) <- c('feature',to)
  
  raw_rowdata <- .get.row_info.EMPT(EMPT)
  new_rowdata <- dplyr::left_join(raw_rowdata,ref_data,by='feature')
  .get.row_info.EMPT(EMPT) <- new_rowdata
  deposit <- EMPT |> EMP_collapse(estimate_group = to,method = method,collapse_by='row')
  return(deposit)
}



#' Title
#'
#' @param EMPT EMPT
#' @param from from
#' @param to to
#' @param method method 
#'
#' @return EMPT object
#'
#' @noRd


.EMP_feature_convert_cpd <- function(EMPT,method='mean',from,to){
  
  feature <- NULL
  raw_rowdata <- .get.row_info.EMPT(EMPT)
  ref_data <- metaboliteIDmapping_data |> 
    dplyr::select({{from}},{{to}}) |>
    dplyr::rename(feature = {{from}}) |>
    tidyr::drop_na(feature) |>
    dplyr::distinct(feature,.keep_all = TRUE)
  new_rowdata <- dplyr::left_join(raw_rowdata,ref_data,by='feature')
  .get.row_info.EMPT(EMPT) <- new_rowdata
  deposit <- EMPT |> EMP_collapse(estimate_group = to,method = method,collapse_by='row')
  return(deposit)
}


#' Covert featureID of gene experssion or compund abundance
#'
#' @param x EMPT or MultiAssayExperiment object.
#' @param experiment A character string. Experiment name in the MultiAssayExperiment object.
#' @param method A character string. Methods include mean, sum, median, min, max. When multiple annotations appear on features, merge activate.
#' @param from A character string. For metabolite include CAS,DTXSID,DTXCID,SID,CID,KEGG,ChEBI,HMDB,Drugbank. For gene include SYMBOL,ENSEMBL,ENTREZID.
#' @param to A character string. For metabolite include CAS,DTXSID,DTXCID,SID,CID,KEGG,ChEBI,HMDB,Drugbank. For gene include SYMBOL,ENSEMBL,ENTREZID.
#' @param species A character string. Species includ Human,Mouse,Pig,Zebrafish. If converting feature from other species,please use OrgDb. 
#' @param OrgDb Supported OrgDb listed in 'https://bioconductor.org/packages/release/BiocViews.html#___OrgDb' 
#' @param action A character string. A character string. Whether to join the new information to the EMPT (add), or just get the detailed result generated here (get).
#' @rdname EMP_feature_convert
#' @return EMPT object
#' @export
#'
#' @examples
#' #

EMP_feature_convert <- function(x,experiment,method='mean',from,to,species = "Human",OrgDb = NULL,action='add'){
  call <- match.call()
  if (inherits(x,"MultiAssayExperiment")) {
    EMPT <- .as.EMPT(x,
                     experiment = experiment)
  }else if(inherits(x,'EMPT')) {
    EMPT <-x
  }
  
  cpd_names_total <- c("CAS", "DTXSID", "DTXCID", "SID", "CID", "KEGG", "ChEBI", "HMDB", "Drugbank")
  gene_names_total <- c('SYMBOL','ENSEMBL','ENTREZID')
  
  if (from %in% gene_names_total & to %in% gene_names_total) {
    EMPT <- EMPT %>% .EMP_feature_convert_gene(method=method,from = from,to=to,species = species,OrgDb=OrgDb)
  }else if(from %in% cpd_names_total & to %in% cpd_names_total){
    EMPT <- EMPT %>%.EMP_feature_convert_cpd(method=method,from=from,to=to)
  }else {
    stop('Pleast check the parameter from and to!')
  }
  
  .get.history.EMPT(EMPT) <- call
  .get.method.EMPT(EMPT) <- 'feature_covert'
  .get.algorithm.EMPT(EMPT) <- 'feature_covert'
  .get.info.EMPT(EMPT) <- 'EMP_assay_data'
  
  if (action=='add') {
    return(EMPT)
  }else if(action=='get'){
    return(.get.assay.EMPT(EMPT))
  }else{
    stop("action should be one of add or get")
  }
  
}
