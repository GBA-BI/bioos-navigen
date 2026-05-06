version 1.0

workflow Tool_DESeq2 {
    input {
        File count
        String cn
        String tn
    }
    call DESeq2 {
        input: count=count, cn=cn, tn=tn
    }
}

task DESeq2 {
    input {
        File count
        String cn
        String tn
    }

    command <<<
        set -e
        # 拿到本地化后的真实路径
        #COUNT_FILE=~(inputs.count)

        # 生成 R 脚本
        cat > temp.R <<'R_EOF'
library(DESeq2)
library(pheatmap)
library(SummarizedExperiment)

args <- commandArgs(trailingOnly = TRUE)
inputfile <- args[1]
cn        <- as.numeric(args[2])
tn        <- as.numeric(args[3])

mycounts <- read.csv(inputfile)
rownames(mycounts) <- mycounts[,1]
mycounts <- mycounts[,-1]

condition <- factor(c(rep("control", cn), rep("treat", tn)),
                    levels = c("control","treat"))
colData   <- data.frame(row.names = colnames(mycounts), condition)

dds <- DESeqDataSetFromMatrix(mycounts, colData, design = ~ condition)
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition","control","treat"))
res <- res[order(res$padj),]

write.csv(res, file = "All_results.csv")
diff_gene_deseq2 <- subset(res, padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(diff_gene_deseq2, file = "DEG_treat_vs_control.csv")

pdf("plotMA.pdf", width = 8, height = 8)
plotMA(res)
dev.off()

select <- order(rowMeans(counts(dds, normalized = TRUE)), decreasing = TRUE)[1:20]
ntd  <- normTransform(dds)
df   <- as.data.frame(colData(dds)[, "condition", drop = FALSE])
rownames(df) <- colnames(ntd)

pdf("heatmap.pdf", width = 8, height = 8)
pheatmap(assay(ntd)[select, ],
         cluster_rows = FALSE, show_rownames = FALSE,
         cluster_cols = FALSE, annotation_col = df)
dev.off()

rld <- rlog(dds)
pdf("plotPCA.pdf", width = 8, height = 8)
plotPCA(rld)
dev.off()
R_EOF

        # 运行 R 脚本，参数用真实路径
        Rscript temp.R  ~{count} ~{cn} ~{tn}

        # 整理输出
        mkdir -p result
        cp All_results.csv DEG_treat_vs_control.csv plotMA.pdf plotPCA.pdf heatmap.pdf  result
    >>>

    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/deseq2:new"
        cpu: 4
        memory: "24GB"
    }

    output {
        Array[File] files=glob("result/*")
    }
}
