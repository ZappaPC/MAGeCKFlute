#' Batch effect removal
#'
#' @docType methods
#' @name BatchRemove
#' @rdname BatchRemove
#'
#' @param mat Matrix, or a file path of data.
#' @param batchMat Matrix like data object or a file path of batch table,
#' in which the first two columns are `Samples`(matched colname of mat) and `Batch`, and
#' remaining columns should be Covariates.
#' @param log2trans Boolean, specifying whether do log2 transition before batch removal.
#' @param positive Boolean, specifying whether all values should be positive.
#'
#' @return A list contrains two objects, including \code{data} and \code{p}.
#'
#' @author Wubing Zhang
#'
#' @seealso \code{\link[sva]{ComBat}}
#'
#' @examples
#' data(bladderdata, package = "bladderbatch")
#' dat <- bladderEset[1:50,]
#' pheno = pData(dat)
#' edata = exprs(dat)
#' batchMat = pheno[, c("sample", "batch", "cancer")]
#' batchMat$sample = rownames(batchMat)
#' edata1 = BatchRemove(edata, batchMat)
#'
#' @importFrom sva ComBat
#' @import bladderbatch
#'
#' @export
#'

BatchRemove <- function(mat, batchMat, log2trans=FALSE, positive = FALSE){
  if(is.character(mat) && file.exists(mat)){
    mat = read.table(mat, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  }
  if(is.character(batchMat) && file.exists(batchMat)){
    batchMat = read.table(batchMat, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
  }
  requireNamespace("sva")
  mat = as.matrix(mat)
  if(mode(mat)!="numeric") stop("Numeric data matrix is needed!")
  batch = as.matrix(batchMat)
  rownames(batch) = batch[,1]
  ## load batch matrix
  index=intersect(batch[,1], colnames(mat))
  if(length(index)<2) stop("Less than two samples found in data matrix.")
  dt=mat[,index]
  if(log2trans) dt = log(dt+1)
  ##
  tmp=dt
  var0=numeric()
  for (i in unique(batch[,2])){
    temp=as.character(batch[batch[,2]==i,1])
    if (length(temp)>=2){
      temp2=tmp[,temp]
      var.data.tmp <- apply(temp2, 1,function(x) var(x))
      var.data.tmp0=which(var.data.tmp==0)
      var0=c(var0,var.data.tmp0)
    }
  }
  tmp2 = tmp
  if(length(var0)>0) tmp2=tmp[setdiff(1:nrow(tmp),var0),]
  if(ncol(batch)>2){
    mod = as.data.frame(batch[,3:ncol(batch)])
    mod = model.matrix(~., data=mod)
  }else mod = NULL
  if(length(unique(batch[,2]))<2){
    res = tmp2
  }else{res <- sva::ComBat(tmp2, batch = batch[,2], mod = mod)}
  if(positive) res[res<0] = 0
  if(length(setdiff(colnames(mat), colnames(res)))>0){
    res=cbind(mat[setdiff(1:nrow(tmp),var0), setdiff(colnames(mat),colnames(res))], res)
    colnames(res)[1:length(setdiff(colnames(mat), colnames(res)))] = setdiff(colnames(mat),colnames(res))
  }
  if(length(var0)>0){
    res = rbind(res, mat[var0, colnames(res)])
  }

  # dt2 = matrix(as.numeric(res[,index]), ncol = length(index))
  # colnames(dt2) = index
  # rownames(dt2) = rownames(res)
  dt2 = res[,index]
  pca1 = NULL
  pca2 = NULL
  p1 = NULL

  pca1 = prcomp(t(dt))$x[,1:2]
  pca2 = prcomp(t(dt2))$x[,1:2]

  gg1 = as.data.frame(pca1, stringsAsFactors=FALSE)
  gg1$col = batch[rownames(gg1),2]
  gg1$group = factor("Before batch removal", "Before batch removal")
  gg2 = as.data.frame(pca2,stringsAsFactors=FALSE)
  gg2$col = batch[rownames(gg2),2]
  gg2$group = factor("After batch removal", "After batch removal")
  if(ncol(batch)>2){
    gg1$shape = as.character(batch[rownames(gg1),3])
    gg2$shape = batch[rownames(gg2),3]
  }else{ gg1$shape = "NA"; gg2$shape = "NA" }
  gg = rbind.data.frame(gg1, gg2)

  #====plot PC1 and PC2=====
  p1 = ggplot(gg)
  p1 = p1 + geom_point(aes(x=PC1, y=PC2, color=col, shape=shape),size = 1)
  p1 = p1 + scale_color_discrete(name="Batch", breaks = unique(gg$col))
  p1 = p1 + scale_shape_discrete(name="Batch", breaks = unique(gg$col))
  p1 = p1 + theme_bw(14)+theme(plot.title = element_text(hjust = 0.5,size=12))
  p1 = p1 + facet_grid(~group, switch = "y", scales="free")
  p1 = p1 + theme(legend.title=element_blank())
  # ggsave(file.path(outdir, paste0(prefix, "_PCA_BatchRemoval.png")), p1, width = 10, height = 4)

  ##====Clustering========
  # if(cluster){
  #   filename = file.path(outdir, paste0(prefix, "_hclust_batchremoval.pdf"))
  #   if(is.na(hclust.height) | is.na(hclust.width))
  #     pdf(filename, height=0.5*nrow(batch)+2, width=0.05*nrow(batch)+3)
  #   else
  #     pdf(filename, height=hclust.height, width=hclust.width)
  #   cc2 = cor(dt)
  #   cc=cor(dt2)
  #   if(ncol(batch)>2){
  #     hclustView(cc2, label_cols = batch[rownames(cc2),3], bar_cols = batch[rownames(cc2),2:ncol(batch)], main = "Before batch removal")
  #     hclustView(cc, label_cols = batch[rownames(cc),3], bar_cols = batch[rownames(cc),2:ncol(batch)], main = "After batch removal")
  #
  #   }else{
  #     hclustView(cc2, label_cols = batch[rownames(cc2),2], main = "Before batch removal")
  #     hclustView(cc, label_cols = batch[rownames(cc),2], main = "After batch removal")
  #   }
  #   dev.off()
  # }
  return(list(data=res, p=p1))
}
