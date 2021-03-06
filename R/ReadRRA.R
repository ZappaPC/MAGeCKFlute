#' Read gene summary file in MAGeCK-RRA results
#'
#' @docType methods
#' @name ReadRRA
#' @rdname ReadRRA
#' @aliases readrra
#'
#' @param gene_summary A file path or a data frame of gene summary data.
#' @param organism Character, KEGG species code, or the common species name, used to determine
#' the gene annotation package. For all potential values check: data(bods); bods. Default org = "hsa",
#' and can also be "human" (case insensitive).
#'
#' @return A data frame including four columns, named "Official", "EntrezID", "LFC" and "FDR".
#'
#' @author Wubing Zhang
#'
#'
#' @examples
#' data(rra.gene_summary)
#' dd.rra = ReadRRA(rra.gene_summary, organism = "hsa")
#' head(dd.rra)
#'
#' @export
#'

ReadRRA <- function(gene_summary, organism = "hsa"){
  message(Sys.time(), " # Read gene summary file ...")
  if(is.character(gene_summary) && file.exists(gene_summary)){
    dd = read.table(file = gene_summary, header = TRUE)
  }else if(is.data.frame(gene_summary) &&
           all(c("id", "neg.goodsgrna", "neg.lfc", "neg.fdr", "pos.goodsgrna","pos.fdr") %in% colnames(gene_summary))){
    dd = gene_summary
  }else{
    stop("The parameter gene_summary is below standard!")
  }
  idx = grepl("Zhang_", dd$id, ignore.case = TRUE)
  dd = dd[!idx,]
  idx = grepl("^CTRL.", dd$id, ignore.case = TRUE)
  dd = dd[!idx,]

  dd = dd[, c("id", "neg.goodsgrna", "neg.lfc", "neg.fdr", "pos.goodsgrna","pos.fdr")]
  dd$LFC = dd$neg.lfc
  dd$FDR = apply(dd[, 2:6], 1, function(x) {ifelse((max(x[c(1, 4)])>1) & (x[1]>x[4]), x[3], x[5])})
  dd$EntrezID = TransGeneID(dd$id, "Symbol", "Entrez", organism = organism)
  idx = is.na(dd$EntrezID) | duplicated(dd$EntrezID)
  dd = dd[!idx,]
  dd = dd[, c("id", "EntrezID", "LFC", "FDR")]
  colnames(dd)[1] = "Official"
  rownames(dd) = dd$EntrezID
  return(dd)
}
