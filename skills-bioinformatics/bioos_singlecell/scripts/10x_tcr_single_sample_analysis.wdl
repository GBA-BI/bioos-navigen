version 1.0

workflow TCRAnalysis {
    input {
        File contig_annotation_csv
        File clonotypes_csv
        String sample_name
        String output_dir = "res"
    }

    String sample_output_dir = "~{output_dir}/~{sample_name}"

    call DataPreparation {
        input:
            contig_annotation = contig_annotation_csv,
            clonotypes = clonotypes_csv,
            sample = sample_name,
            output_directory = sample_output_dir
    }

    call GenerateFigures {
        input:
            contig_filtered = DataPreparation.contig_filtered,
            clonotypes_annotated = DataPreparation.clonotypes_annotated,
            diversity_metrics = DataPreparation.diversity_metrics,
            imm_tra = DataPreparation.imm_TRA,
            imm_trb = DataPreparation.imm_TRB,
            sample = sample_name,
            output_directory = sample_output_dir
    }

    call PackageResults {
        input:
            output_directory = sample_output_dir,
            sample = sample_name,
            # 传递实际输出文件作为依赖，确保PackageResults在GenerateFigures之后运行
            fig1_png = GenerateFigures.fig1_png
    }

    output {
        # 中间数据文件
        File contig_filtered = DataPreparation.contig_filtered
        File clonotypes_annotated = DataPreparation.clonotypes_annotated
        File diversity_metrics = DataPreparation.diversity_metrics
        File imm_tra = DataPreparation.imm_TRA
        File imm_trb = DataPreparation.imm_TRB
        
        # 图表文件
        File fig1_png = GenerateFigures.fig1_png
        File fig1_pdf = GenerateFigures.fig1_pdf
        File fig2a_png = GenerateFigures.fig2a_png
        File fig2a_pdf = GenerateFigures.fig2a_pdf
        File fig2b_png = GenerateFigures.fig2b_png
        File fig2b_pdf = GenerateFigures.fig2b_pdf
        File fig3_png = GenerateFigures.fig3_png
        File fig3_pdf = GenerateFigures.fig3_pdf
        File fig6_png = GenerateFigures.fig6_png
        File fig6_pdf = GenerateFigures.fig6_pdf
        File fig7_png = GenerateFigures.fig7_png
        File fig7_pdf = GenerateFigures.fig7_pdf
        File fig4_png = GenerateFigures.fig4_png
        File fig4_pdf = GenerateFigures.fig4_pdf
        File fig5_png = GenerateFigures.fig5_png
        File fig5_pdf = GenerateFigures.fig5_pdf
        File? fig8_png = GenerateFigures.fig8_png
        File? fig8_pdf = GenerateFigures.fig8_pdf
        File fig9a_png = GenerateFigures.fig9a_png
        File fig9a_pdf = GenerateFigures.fig9a_pdf
        File fig9b_png = GenerateFigures.fig9b_png
        File fig9b_pdf = GenerateFigures.fig9b_pdf
        File fig9c_png = GenerateFigures.fig9c_png
        File fig9c_pdf = GenerateFigures.fig9c_pdf
        File fig10_png = GenerateFigures.fig10_png
        File fig10_pdf = GenerateFigures.fig10_pdf
        File fig12_png = GenerateFigures.fig12_png
        File fig12_pdf = GenerateFigures.fig12_pdf
        File fig13a_png = GenerateFigures.fig13a_png
        File fig13a_pdf = GenerateFigures.fig13a_pdf
        File fig13b_png = GenerateFigures.fig13b_png
        File fig13b_pdf = GenerateFigures.fig13b_pdf
        File fig13c_png = GenerateFigures.fig13c_png
        File fig13c_pdf = GenerateFigures.fig13c_pdf
        
        # 打包的压缩文件
        File results_tarball = PackageResults.tarball
        File manifest = PackageResults.manifest
        File checksum = PackageResults.checksum
    }
}

task DataPreparation {
    input {
        File contig_annotation
        File clonotypes
        String sample
        String output_directory
    }

    command <<<
        set -euo pipefail
        
        mkdir -p ~{output_directory}
        
        # 创建 R 脚本文件
        cat > /tmp/data_prep.R << 'RSCRIPT'
        library(data.table)
        library(dplyr)
        library(tidyr)
        library(stringr)
        
        args <- commandArgs(trailingOnly = TRUE)
        sample_name <- args[1]
        fig_dir <- args[2]
        contig_file <- args[3]
        clono_file <- args[4]
        
        contig <- fread(contig_file)
        clono  <- fread(clono_file)
        
        cat("样本:", sample_name, "\n")
        cat("原始 contig 行数:", nrow(contig), "\n")
        cat("原始 clonotype 行数:", nrow(clono), "\n")
        
        contig_filt <- contig %>%
          filter(productive == TRUE,
                 high_confidence == TRUE,
                 full_length == TRUE,
                 chain %in% c("TRA", "TRB"))
        
        cat("过滤后 contig:", nrow(contig_filt),
            "| TRA:", sum(contig_filt$chain == "TRA"),
            "| TRB:", sum(contig_filt$chain == "TRB"), "\n")
        
        clono_ann <- clono %>%
          mutate(expansion_group = case_when(
            frequency == 1 ~ "Singleton",
            frequency <= 5 ~ "Small (2-5)",
            frequency <= 20 ~ "Medium (6-20)",
            frequency <= 100 ~ "Large (21-100)",
            TRUE ~ "Hyperexpanded (>100)"
          ))
        
        cat("\n克隆型扩增分组:\n")
        print(table(clono_ann$expansion_group))
        
        contig_filt <- contig_filt %>%
          left_join(
            clono_ann %>% select(clonotype_id, frequency, proportion, expansion_group),
            by = c("raw_clonotype_id" = "clonotype_id")
          )
        
        make_chain_df <- function(ch) {
          contig_filt %>%
            filter(chain == ch) %>%
            group_by(cdr3, v_gene, j_gene, d_gene) %>%
            summarise(Clones = n(), .groups = "drop") %>%
            mutate(Proportion = Clones / sum(Clones)) %>%
            rename(CDR3.aa = cdr3, V.name = v_gene, J.name = j_gene, D.name = d_gene) %>%
            arrange(desc(Clones))
        }
        imm_TRA <- make_chain_df("TRA")
        imm_TRB <- make_chain_df("TRB")
        
        cat("\nTRA 克隆型:", nrow(imm_TRA), "| TRB 克隆型:", nrow(imm_TRB), "\n")
        
        calc_diversity <- function(fregs) {
          p <- fregs / sum(fregs)
          p <- p[p>0]
          n <- length(p)
          ps <- sort(p)
          list(
            Shannon = round(-sum(p * log(p)), 4),
            Slimpson = round(1 - sum(p^2), 4),
            Gini = round(2 * sum((1:n)*ps) / (n * sum(ps)) - (n+1)/n, 4)
          ) 
        }
        
        dTRA <- calc_diversity(imm_TRA$Clones)
        dTRB <- calc_diversity(imm_TRB$Clones)
        div_df <- data.frame(
          chain = c("TRA","TRB"),
          Shannon = c(dTRA$Shannon, dTRB$Shannon),
          Slimpson = c(dTRA$Slimpson, dTRB$Slimpson),
          Gini = c(dTRA$Gini, dTRB$Gini)
        )
        cat("\n多样性指标：\n")
        print(div_df)
        
        fwrite(contig_filt, file.path(fig_dir, paste0(sample_name, "_contig_filtered.csv")))
        fwrite(clono_ann, file.path(fig_dir, paste0(sample_name, "_clonotypes_annotated.csv")))
        fwrite(div_df, file.path(fig_dir, paste0(sample_name, "_diversity_metrics.csv")))
        fwrite(imm_TRA, file.path(fig_dir, paste0(sample_name, "_imm_TRA.csv")))
        fwrite(imm_TRB, file.path(fig_dir, paste0(sample_name, "_imm_TRB.csv")))
        
        cat("\nStep 1 数据准备完成 - 样本:", sample_name, "\n")
        RSCRIPT
        
        # 执行 R 脚本
        Rscript /tmp/data_prep.R "~{sample}" "~{output_directory}" "~{contig_annotation}" "~{clonotypes}"
        
        # 验证输出
        echo "生成的文件："
        ls -la ~{output_directory}/
    >>>

    output {
        File contig_filtered = "~{output_directory}/~{sample}_contig_filtered.csv"
        File clonotypes_annotated = "~{output_directory}/~{sample}_clonotypes_annotated.csv"
        File diversity_metrics = "~{output_directory}/~{sample}_diversity_metrics.csv"
        File imm_TRA = "~{output_directory}/~{sample}_imm_TRA.csv"
        File imm_TRB = "~{output_directory}/~{sample}_imm_TRB.csv"
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/devmode/seurat_harmony_yl:v5"
        memory: "8 GB"
        cpu: 4
        disk: "100 GB"
    }
}

task GenerateFigures {
    input {
        File contig_filtered
        File clonotypes_annotated
        File diversity_metrics
        File imm_tra
        File imm_trb
        String sample
        String output_directory
    }

    command <<<
        set -euo pipefail
        
        mkdir -p ~{output_directory}
        
        # 验证输入文件
        echo "检查输入文件..."
        for f in "~{contig_filtered}" "~{clonotypes_annotated}" "~{diversity_metrics}" "~{imm_tra}" "~{imm_trb}"; do
            if [ ! -f "$f" ]; then
                echo "错误: 输入文件不存在: $f"
                exit 1
            fi
            echo "  ✓ $(basename $f)"
        done
        
        # 创建 R 脚本
        cat > /tmp/generate_figures.R << 'RSCRIPT'
        library(data.table)
        library(dplyr)
        library(tidyr)
        library(stringr)
        library(ggplot2)
        library(patchwork)
        library(scales)
        library(viridis)
        library(RColorBrewer)
        library(pheatmap)
        library(ggseqlogo)
        library(uwot)
        library(circlize)
        library(igraph)
        library(ggraph)
        library(tidygraph)
        library(stringdist)
        library(tibble)
        
        args <- commandArgs(trailingOnly = TRUE)
        sample_name <- args[1]
        fig_dir <- args[2]
        contig_file <- args[3]
        clono_file <- args[4]
        div_file <- args[5]
        tra_file <- args[6]
        trb_file <- args[7]
        
        save_fig <- function(p, name, w = 12, h = 7) {
          full_name <- paste0(sample_name, "_", name)
          base <- file.path(fig_dir, full_name)
          png_file <- paste0(base, ".png")
          pdf_file <- paste0(base, ".pdf")
          
          ggsave(png_file, p, width = w, height = h, dpi = 150, bg = "white")
          cat("[PNG]", png_file, "saved\n")
          
          cairo_pdf(pdf_file, width = w, height = h, family = "sans")
          print(p)
          dev.off()
          cat("[PDF]", pdf_file, "saved\n")
        }
        
        save_pheatmap <- function(mat, title, col_low, col_high, fname, w = 10, h = 8) {
          full_fname <- paste0(sample_name, "_", fname)
          png_path <- file.path(fig_dir, paste0(full_fname, ".png"))
          pdf_path <- file.path(fig_dir, paste0(full_fname, ".pdf"))
          
          png(png_path, width = w * 120, height = h * 120, res = 120)
          pheatmap(mat,
                   color = colorRampPalette(c("white", col_low, col_high))(100),
                   main = paste0(title, "\nSample: ", sample_name),
                   fontsize = 10,
                   cluster_rows = TRUE,
                   cluster_cols = TRUE,
                   border_color = NA)
          dev.off()
          cat("[PNG]", png_path, "saved\n")
          
          cairo_pdf(pdf_path, width = w, height = h)
          pheatmap(mat,
                   color = colorRampPalette(c("white", col_low, col_high))(100),
                   main = paste0(title, "\nSample: ", sample_name),
                   fontsize = 10,
                   cluster_rows = TRUE,
                   cluster_cols = TRUE,
                   border_color = NA)
          dev.off()
          cat("[PDF]", pdf_path, "saved\n")
        }
        
        cat("读取输入文件...\n")
        contig_filt <- fread(contig_file)
        clono_ann   <- fread(clono_file)
        div_df      <- fread(div_file)
        imm_TRA     <- fread(tra_file)
        imm_TRB     <- fread(trb_file)
        
        EXP_LEVELS <- c("Singleton", "Small (2-5)", "Medium (6-20)",
                        "Large (21-100)", "Hyperexpanded (>100)")
        
        EXP_COLORS <- c(
          "Singleton" = "#4DAF4A",
          "Small (2-5)" = "#377EB8",
          "Medium (6-20)" = "#FF7F00",
          "Large (21-100)" = "#E41A1C",
          "Hyperexpanded (>100)" = "#984EA3"
        )
        
        cat("开始生成图表 - 样本:", sample_name, "\n")
        
        # =============================================================================
        # STEP 2: 图1 — V 基因使用频率条形图
        # =============================================================================
        cat("\n── STEP 2: 图1 V基因使用频率 ─────────────────────────────────────────\n")
        
        make_vbar <- function(chain_type, pal) {
          df <- contig_filt %>%
            filter(chain == chain_type, !is.na(v_gene), v_gene != "") %>%
            count(v_gene, name = "n") %>%
            arrange(desc(n)) %>%
            head(20) %>%
            mutate(v_gene = factor(v_gene, levels = rev(v_gene)))
          
          ggplot(df, aes(x = v_gene, y = n, fill = n)) +
            geom_col(show.legend = FALSE) +
            scale_fill_viridis_c(option = pal) +
            coord_flip() +
            labs(title = paste(chain_type, "V Gene Usage (Top 20) -", sample_name),
                 x = "V Gene", y = "Cell Count") +
            theme_bw(base_size = 13) +
            theme(plot.title = element_text(face = "bold"))
        }
        
        p1 <- make_vbar("TRA", "plasma") + make_vbar("TRB", "viridis") +
          plot_annotation(
            title = paste("Figure 1: V Gene Usage Frequency -", sample_name),
            theme = theme(plot.title = element_text(face = "bold", size = 15))
          )
        save_fig(p1, "fig1_vgene_usage", w = 16, h = 8)
        
        # =============================================================================
        # STEP 3: 图2a/2b — V-J 配对频率热图
        # =============================================================================
        cat("\n── STEP 3: 图2 V-J配对热图 ───────────────────────────────────────────\n")
        
        make_vj_matrix <- function(chain_type, top_v = 15, top_j = 10) {
          mat <- contig_filt %>%
            filter(chain == chain_type, v_gene != "", j_gene != "") %>%
            count(v_gene, j_gene) %>%
            pivot_wider(names_from = j_gene, values_from = n, values_fill = 0) %>%
            column_to_rownames("v_gene") %>%
            as.matrix()
          rv <- names(sort(rowSums(mat), decreasing = TRUE))[1:min(top_v, nrow(mat))]
          cj <- names(sort(colSums(mat), decreasing = TRUE))[1:min(top_j, ncol(mat))]
          mat[rv, cj, drop = FALSE]
        }
        
        tra_mat <- make_vj_matrix("TRA", top_v = 15, top_j = 10)
        trb_mat <- make_vj_matrix("TRB", top_v = 15, top_j = 13)
        
        if (nrow(tra_mat) > 0 && ncol(tra_mat) > 0) {
          save_pheatmap(tra_mat,
                      "Figure 2a: TRA V-J Pairing Frequency",
                      "#2166AC", "#053061",
                      "fig2a_TRA_VJ_heatmap", w = 10, h = 8)
        }
        
        if (nrow(trb_mat) > 0 && ncol(trb_mat) > 0) {
          save_pheatmap(trb_mat,
                      "Figure 2b: TRB V-J Pairing Frequency",
                      "#B2182B", "#67001F",
                      "fig2b_TRB_VJ_heatmap", w = 12, h = 8)
        }
        
        # =============================================================================
        # STEP 4: 图3/6/7 — CDR3 长度分布 & 序列 Logo
        # =============================================================================
        cat("\n── STEP 4: 图3/6/7 CDR3特征分析 ─────────────────────────────────────\n")
        
        cdr3_df <- contig_filt %>%
          filter(!is.na(cdr3), cdr3 != "") %>%
          mutate(
            cdr3_len = nchar(cdr3),
            expansion_group = factor(
              ifelse(is.na(expansion_group), "Singleton", expansion_group),
              levels = EXP_LEVELS
            )
          )
        
        p3 <- ggplot(cdr3_df, aes(x = cdr3_len, color = expansion_group, fill = expansion_group)) +
          geom_density(alpha = 0.18, linewidth = 0.9) +
          facet_wrap(~ chain, scales = "free_y",
                     labeller = labeller(chain = c(TRA = "TRA Chain", TRB = "TRB Chain"))) +
          scale_color_manual(values = EXP_COLORS, name = "Expansion Group") +
          scale_fill_manual(values = EXP_COLORS, name = "Expansion Group") +
          scale_x_continuous(breaks = seq(6, 26, 2)) +
          labs(title = paste("Figure 3: CDR3 Length Distribution by Clonal Expansion Group -", sample_name),
               x = "CDR3 Length (aa)", y = "Density") +
          theme_bw(base_size = 13) +
          theme(legend.position = "bottom",
                plot.title = element_text(face = "bold"),
                strip.text = element_text(face = "bold", size = 12))
        save_fig(p3, "fig3_CDR3_length_overlay", w = 14, h = 6)
        
        p6 <- ggplot(cdr3_df, aes(x = cdr3_len, fill = chain)) +
          geom_histogram(binwidth = 1, position = "dodge", alpha = 0.85, color = "white") +
          scale_fill_manual(values = c(TRA = "#E41A1C", TRB = "#377EB8"), name = "Chain") +
          scale_x_continuous(breaks = seq(6, 26, 2)) +
          labs(title = paste("Figure 6: CDR3 Length Distribution (TRA vs TRB) -", sample_name),
               x = "CDR3 Length (aa)", y = "Count") +
          theme_bw(base_size = 13) +
          theme(plot.title = element_text(face = "bold"), legend.position = "top")
        save_fig(p6, "fig6_CDR3_length_histogram", w = 10, h = 6)
        
        trb_seqs <- imm_TRB %>% arrange(desc(Clones)) %>% head(500) %>% pull(CDR3.aa)
        
        if (length(trb_seqs) > 0) {
          len_table <- table(nchar(trb_seqs))
          if (length(len_table) > 0) {
            common_len <- as.integer(names(sort(len_table, decreasing = TRUE)[1]))
            logo_seqs <- trb_seqs[nchar(trb_seqs) == common_len]
            cat("CDR3 Logo: length =", common_len, "aa | n =", length(logo_seqs), "\n")
            
            if (length(logo_seqs) >= 20) {
              p7 <- ggseqlogo(logo_seqs, method = "prob") +
                labs(title = paste0("Figure 7: TRB CDR3 Sequence Logo - ", sample_name, 
                                  " (length = ", common_len, " aa, n = ", length(logo_seqs), ")")) +
                theme_bw(base_size = 13) +
                theme(plot.title = element_text(face = "bold"))
              save_fig(p7, "fig7_CDR3_seqlogo", w = 13, h = 4)
            } else {
              cat("序列数量不足，跳过图7\n")
              file.create(file.path(fig_dir, paste0(sample_name, "_fig7_CDR3_seqlogo.png")))
              file.create(file.path(fig_dir, paste0(sample_name, "_fig7_CDR3_seqlogo.pdf")))
            }
          }
        }
        
        # =============================================================================
        # STEP 5: 图4 — UMAP
        # =============================================================================
        cat("\n── STEP 5: 图4 UMAP降维 ──────────────────────────────────────────────\n")
        
        trb_clono <- clono_ann %>%
          mutate(trb_cdr3 = str_extract(cdr3s_aa, "(?<=TRB:)[^;]+")) %>%
          filter(!is.na(trb_cdr3)) %>%
          arrange(desc(frequency)) %>%
          head(2000) %>%
          mutate(expansion_group = factor(expansion_group, levels = EXP_LEVELS))
        
        cat("UMAP 使用 TRB 克隆型数:", nrow(trb_clono), "\n")
        
        if (nrow(trb_clono) >= 10) {
          AA_LIST <- c("A","C","D","E","F","G","H","I","K","L",
                       "M","N","P","Q","R","S","T","V","W","Y")
          encode_aa <- function(seq) {
            sapply(AA_LIST, function(a) stringr::str_count(seq, a) / max(nchar(seq), 1))
          }
          
          aa_mat <- t(sapply(trb_clono$trb_cdr3, encode_aa))
          aa_mat[is.nan(aa_mat)] <- 0
          
          set.seed(42)
          umap_res <- uwot::umap(aa_mat, n_neighbors = min(30, nrow(aa_mat)-1), 
                                 min_dist = 0.3, n_components = 2, verbose = FALSE)
          umap_df <- data.frame(
            UMAP1 = umap_res[, 1],
            UMAP2 = umap_res[, 2],
            expansion_group = trb_clono$expansion_group,
            Clones = trb_clono$frequency
          )
          
          p4 <- ggplot(umap_df, aes(x = UMAP1, y = UMAP2,
                                    color = expansion_group, size = log1p(Clones))) +
            geom_point(alpha = 0.7) +
            scale_color_manual(values = EXP_COLORS, name = "Expansion Group") +
            scale_size_continuous(range = c(0.5, 5), name = "log(Clones+1)") +
            labs(title = paste("Figure 4: UMAP of TRB CDR3 Amino Acid Composition -", sample_name),
                 subtitle = paste("Top 2000 TRB clonotypes; colored by clonal expansion group\nSample:", sample_name),
                 x = "UMAP 1", y = "UMAP 2") +
            theme_bw(base_size = 13) +
            theme(plot.title = element_text(face = "bold"), legend.position = "right")
          save_fig(p4, "fig4_UMAP_CDR3", w = 11, h = 8)
        } else {
          cat("TRB克隆型数量不足，跳过图4\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig4_UMAP_CDR3.png")))
          file.create(file.path(fig_dir, paste0(sample_name, "_fig4_UMAP_CDR3.pdf")))
        }
        
        # =============================================================================
        # STEP 6: 图5 — Circos弦图
        # =============================================================================
        cat("\n── STEP 6: 图5 Circos弦图 ────────────────────────────────────────────\n")
        
        vj_mat <- imm_TRB %>%
          filter(!is.na(V.name), !is.na(J.name), V.name != "", J.name != "") %>%
          group_by(V.name, J.name) %>%
          summarise(n = sum(Clones), .groups = "drop") %>%
          filter(n >= 5)
        
        if (nrow(vj_mat) > 0) {
          top_v <- vj_mat %>% group_by(V.name) %>% summarise(tot = sum(n)) %>%
            arrange(desc(tot)) %>% head(12) %>% pull(V.name)
          top_j <- vj_mat %>% group_by(J.name) %>% summarise(tot = sum(n)) %>%
            arrange(desc(tot)) %>% head(12) %>% pull(J.name)
          
          vj_sub <- vj_mat %>% filter(V.name %in% top_v, J.name %in% top_j)
          
          if (nrow(vj_sub) > 0) {
            vj_wide <- vj_sub %>%
              pivot_wider(names_from = J.name, values_from = n, values_fill = 0) %>%
              column_to_rownames("V.name") %>%
              as.matrix()
            
            n_v <- nrow(vj_wide); n_j <- ncol(vj_wide)
            if (n_v > 0 && n_j > 0) {
              v_cols <- colorRampPalette(c("#E41A1C","#FF7F00","#FFFF33","#4DAF4A","#377EB8","#984EA3"))(n_v)
              j_cols <- colorRampPalette(c("#A6CEE3","#1F78B4","#B2DF8A","#33A02C","#FB9A99","#E31A1C"))(n_j)
              names(v_cols) <- rownames(vj_wide)
              names(j_cols) <- colnames(vj_wide)
              all_cols <- c(v_cols, j_cols)
              
              draw_circos <- function() {
                circos.clear()
                circos.par(gap.after = c(rep(2, n_v - 1), 8, rep(2, n_j - 1), 8),
                           start.degree = 90, clock.wise = TRUE)
                chordDiagram(vj_wide, grid.col = all_cols,
                           annotationTrack = c("name", "grid"),
                           annotationTrackHeight = c(0.03, 0.05),
                           transparency = 0.3)
                title(paste("Figure 5: TRB V-J Pairing Chord Diagram -", sample_name,
                          "\n(Top 12 V genes × Top 12 J genes)"),
                      cex.main = 1.2, font.main = 2)
                circos.clear()
              }
              
              circos_base <- file.path(fig_dir, paste0(sample_name, "_fig5_circos_VJ"))
              cairo_pdf(paste0(circos_base, ".pdf"), width = 10, height = 10)
              draw_circos()
              dev.off()
              cat("[PDF]", paste0(circos_base, ".pdf"), "saved\n")
              
              png(paste0(circos_base, ".png"), width = 1200, height = 1200, res = 120)
              draw_circos()
              dev.off()
              cat("[PNG]", paste0(circos_base, ".png"), "saved\n")
            }
          }
        } else {
          cat("V-J配对数据不足，跳过图5\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig5_circos_VJ.png")))
          file.create(file.path(fig_dir, paste0(sample_name, "_fig5_circos_VJ.pdf")))
        }
        
        # =============================================================================
        # STEP 7: 图9a/9b/9c — 多样性与克隆分析
        # =============================================================================
        cat("\n── STEP 7: 图9 多样性与克隆分析 ─────────────────────────────────────\n")
        
        top30 <- clono_ann %>%
          arrange(desc(frequency)) %>%
          head(30) %>%
          mutate(expansion_group = factor(expansion_group, levels = EXP_LEVELS))
        
        p9a <- ggplot(top30, aes(x = reorder(clonotype_id, frequency),
                                 y = frequency, fill = expansion_group)) +
          geom_col(width = 0.75) +
          coord_flip() +
          scale_fill_manual(values = EXP_COLORS, name = "Expansion Group") +
          scale_y_continuous(labels = comma) +
          labs(title = paste("Figure 9a: Top 30 Clonotypes by Frequency -", sample_name),
               x = "Clonotype ID", y = "Cell Count") +
          theme_bw(base_size = 12) +
          theme(plot.title = element_text(face = "bold"),
                legend.position = "right",
                axis.text.y = element_text(size = 8))
        save_fig(p9a, "fig9a_clonotype_frequency_bar", w = 12, h = 9)
        
        pie_df <- clono_ann %>%
          mutate(expansion_group = factor(expansion_group, levels = EXP_LEVELS)) %>%
          count(expansion_group) %>%
          mutate(pct = n / sum(n) * 100)
        
        p9b <- ggplot(pie_df, aes(x = expansion_group, y = n, fill = expansion_group)) +
          geom_col(width = 0.7, color = "white", linewidth = 0.5) +
          geom_text(aes(label = paste0(n, "\n(", round(pct, 1), "%)")),
                    vjust = -0.3, size = 3.8, fontface = "bold") +
          scale_fill_manual(values = EXP_COLORS, name = "Expansion Group") +
          scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
          labs(title = paste("Figure 9b: Clonal Size Distribution -", sample_name),
               subtitle = "Number of clonotypes per expansion group",
               x = "Expansion Group", y = "Number of Clonotypes") +
          theme_bw(base_size = 13) +
          theme(plot.title = element_text(face = "bold"),
                axis.text.x = element_text(angle = 20, hjust = 1),
                legend.position = "none")
        save_fig(p9b, "fig9b_clonal_size_bar", w = 10, h = 6)
        
        lorenz_df <- clono_ann %>%
          arrange(desc(frequency)) %>%
          mutate(rank_pct = row_number() / n(),
                 cum_freq = cumsum(frequency) / sum(frequency))
        
        gini_trb <- div_df$Gini[div_df$chain == "TRB"]
        if (length(gini_trb) == 0) gini_trb <- NA
        
        p9c <- ggplot(lorenz_df, aes(x = rank_pct, y = cum_freq)) +
          geom_line(color = "#E41A1C", linewidth = 1.2) +
          geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
          annotate("text", x = 0.3, y = 0.85,
                   label = paste0("Gini = ", gini_trb),
                   size = 5, color = "#E41A1C", fontface = "bold") +
          scale_x_continuous(labels = percent_format()) +
          scale_y_continuous(labels = percent_format()) +
          labs(title = paste("Figure 9c: Lorenz Curve – Clonal Frequency Distribution -", sample_name),
               x = "Cumulative Fraction of Clonotypes",
               y = "Cumulative Fraction of Cells") +
          theme_bw(base_size = 13) +
          theme(plot.title = element_text(face = "bold"))
        save_fig(p9c, "fig9c_cumulative_frequency_curve", w = 8, h = 7)
        
        # =============================================================================
        # STEP 8: 图8 — CDR3序列相似性网络
        # =============================================================================
        cat("\n── STEP 8: 图8 CDR3相似性网络 ───────────────────────────────────────\n")
        
        trb_net_df <- clono_ann %>%
          mutate(trb_cdr3 = str_extract(cdr3s_aa, "(?<=TRB:)[^;]+")) %>%
          filter(!is.na(trb_cdr3)) %>%
          arrange(desc(frequency)) %>%
          head(300) %>%
          mutate(expansion_group = factor(expansion_group, levels = EXP_LEVELS))
        
        seqs <- trb_net_df$trb_cdr3
        n_seq <- length(seqs)
        
        if (n_seq >= 2) {
          edges <- data.frame(from = integer(), to = integer())
          for (i in seq_len(n_seq - 1)) {
            dists <- stringdist(seqs[i], seqs[(i + 1):n_seq], method = "lv")
            matches <- which(dists <= 2) + i
            if (length(matches) > 0)
              edges <- rbind(edges, data.frame(from = i, to = matches))
          }
          cat("找到边数 (edit dist ≤ 2):", nrow(edges), "\n")
          
          if (nrow(edges) > 0) {
            nodes_in_net <- unique(c(edges$from, edges$to))
            node_df <- trb_net_df[nodes_in_net, ]
            idx_map <- setNames(seq_along(nodes_in_net), nodes_in_net)
            
            edges_remap <- data.frame(
              from = idx_map[as.character(edges$from)],
              to = idx_map[as.character(edges$to)]
            )
            edges_remap <- edges_remap[!is.na(edges_remap$from) & !is.na(edges_remap$to), ]
            
            if (nrow(edges_remap) > 0) {
              g <- graph_from_data_frame(
                d = edges_remap,
                vertices = data.frame(
                  name = seq_len(nrow(node_df)),
                  cdr3 = node_df$trb_cdr3,
                  expansion_group = node_df$expansion_group,
                  freq = node_df$frequency
                ),
                directed = FALSE
              )
              tg <- as_tbl_graph(g)
              
              p8 <- ggraph(tg, layout = "fr") +
                geom_edge_link(alpha = 0.35, color = "grey70", linewidth = 0.5) +
                geom_node_point(aes(color = expansion_group, size = log1p(freq)), alpha = 0.85) +
                scale_color_manual(values = EXP_COLORS, name = "Expansion Group", drop = FALSE) +
                scale_size_continuous(range = c(2, 9), name = "log(Freq+1)") +
                labs(title = paste("Figure 8: TRB CDR3 Sequence Similarity Network -", sample_name),
                     subtitle = paste0("Levenshtein distance ≤ 2 | Nodes: ", igraph::vcount(g),
                                     " | Edges: ", igraph::ecount(g))) +
                theme_graph(base_family = "sans", base_size = 12) +
                theme(plot.title = element_text(face = "bold"), legend.position = "right")
              
              save_fig(p8, "fig8_CDR3_similarity_network", w = 11, h = 8)
              cat("Nodes:", igraph::vcount(g), "| Edges:", igraph::ecount(g), "\n")
            }
          } else {
            cat("未找到满足条件的边，跳过图8\n")
            file.create(file.path(fig_dir, paste0(sample_name, "_fig8_CDR3_similarity_network_SKIPPED")))
          }
        } else {
          cat("序列数量不足，跳过图8\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig8_CDR3_similarity_network_SKIPPED")))
        }
        
        # =============================================================================
        # STEP 9: 图10/12 — 克隆扩增气泡图 & 克隆型动态
        # =============================================================================
        cat("\n── STEP 9: 图10/12 克隆扩增与动态 ──────────────────────────────────\n")
        
        top20 <- clono_ann %>%
          arrange(desc(frequency)) %>%
          head(20) %>%
          mutate(rank = row_number(),
                 expansion_group = factor(expansion_group, levels = EXP_LEVELS))
        
        p10 <- ggplot(top20, aes(x = rank, y = expansion_group,
                                 size = frequency, color = proportion)) +
          geom_point(alpha = 0.85) +
          geom_text(aes(label = frequency), size = 2.8, color = "black", vjust = -1.2) +
          scale_size_continuous(range = c(4, 18), name = "Cell Count") +
          scale_color_gradient(low = "#FEE0D2", high = "#CB181D", name = "Proportion") +
          scale_x_continuous(breaks = 1:20, labels = paste0("CT", 1:20)) +
          labs(title = paste("Figure 10: Top 20 Clonotype Expansion Bubble Plot -", sample_name),
               subtitle = "Bubble size = cell count; color = proportion of repertoire",
               x = "Clonotype Rank", y = "Expansion Group") +
          theme_bw(base_size = 12) +
          theme(plot.title = element_text(face = "bold"),
                axis.text.x = element_text(angle = 45, hjust = 1),
                legend.position = "right")
        save_fig(p10, "fig10_clonal_expansion_bubble", w = 14, h = 6)
        
        set.seed(123)
        top10_ids <- clono_ann %>% arrange(desc(frequency)) %>% head(10) %>% pull(clonotype_id)
        
        time_df <- do.call(rbind, lapply(c("T1", "T2", "T3", "T4"), function(tp) {
          clono_ann %>%
            filter(clonotype_id %in% top10_ids) %>%
            mutate(sim_freq = frequency * runif(n(), 0.6, 1.4),
                   sim_prop = sim_freq / sum(sim_freq),
                   timepoint = tp) %>%
            select(clonotype_id, sim_prop, timepoint)
        }))
        
        p12 <- ggplot(time_df, aes(x = timepoint, y = sim_prop,
                                   fill = clonotype_id, group = clonotype_id)) +
          geom_area(alpha = 0.8, position = "stack") +
          scale_fill_brewer(palette = "Paired", name = "Clonotype") +
          scale_y_continuous(labels = percent_format()) +
          labs(title = paste("Figure 12: Clonotype Dynamics Across Time Points -", sample_name),
               subtitle = "Top 10 clonotypes; simulated time-course (T1→T4)\n[NOTE: Simulated data — real analysis requires multi-timepoint samples]",
               x = "Time Point", y = "Relative Proportion") +
          theme_bw(base_size = 13) +
          theme(plot.title = element_text(face = "bold"), legend.position = "right")
        save_fig(p12, "fig12_clonotype_dynamics", w = 11, h = 7)
        
        # =============================================================================
        # STEP 10: 图13a/13b/13c — 抗原特异性分析
        # =============================================================================
        cat("\n── STEP 10: 图13 抗原特异性分析 ─────────────────────────────────────\n")
        
        trb_ag_df <- clono_ann %>%
          mutate(trb_cdr3 = str_extract(cdr3s_aa, "(?<=TRB:)[^;]+")) %>%
          filter(!is.na(trb_cdr3)) %>%
          arrange(desc(frequency))
        
        if (nrow(trb_ag_df) >= 80) {
          top80 <- trb_ag_df %>% head(80)
          dm <- stringdistmatrix(top80$trb_cdr3, top80$trb_cdr3, method = "lv")
          dm_norm <- dm / max(dm)
          rownames(dm_norm) <- colnames(dm_norm) <- paste0("CT", 1:80)
          
          ann_row <- data.frame(Expansion = top80$expansion_group,
                                row.names = paste0("CT", 1:80))
          ann_colors <- list(Expansion = EXP_COLORS)
          
          fig13a_base <- file.path(fig_dir, paste0(sample_name, "_fig13a_TCRdist_heatmap"))
          
          png(paste0(fig13a_base, ".png"), width = 1400, height = 1200, res = 120)
          pheatmap(1 - dm_norm,
                   color = colorRampPalette(rev(brewer.pal(9, "RdYlBu")))(100),
                   annotation_row = ann_row,
                   annotation_colors = ann_colors,
                   show_rownames = FALSE,
                   show_colnames = FALSE,
                   clustering_distance_rows = "euclidean",
                   clustering_distance_cols = "euclidean",
                   main = paste("Figure 13a: TCRdist Proxy Heatmap -", sample_name, "\n(Top 80 TRB Clonotypes)"),
                   fontsize = 11)
          dev.off()
          cat("[PNG]", paste0(fig13a_base, ".png"), "saved\n")
          
          cairo_pdf(paste0(fig13a_base, ".pdf"), width = 12, height = 10)
          pheatmap(1 - dm_norm,
                   color = colorRampPalette(rev(brewer.pal(9, "RdYlBu")))(100),
                   annotation_row = ann_row,
                   annotation_colors = ann_colors,
                   show_rownames = FALSE,
                   show_colnames = FALSE,
                   clustering_distance_rows = "euclidean",
                   clustering_distance_cols = "euclidean",
                   main = paste("Figure 13a: TCRdist Proxy Heatmap -", sample_name, "\n(Top 80 TRB Clonotypes)"),
                   fontsize = 11)
          dev.off()
          cat("[PDF]", paste0(fig13a_base, ".pdf"), "saved\n")
        } else {
          cat("TRB克隆型数量不足80，跳过图13a\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13a_TCRdist_heatmap.png")))
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13a_TCRdist_heatmap.pdf")))
        }
        
        get_kmers <- function(seqs, k = 3) {
          unlist(lapply(seqs, function(s) {
            if (nchar(s) < k) return(character(0))
            substring(s, 1:(nchar(s) - k + 1), k:nchar(s))
          }))
        }
        
        top200_seqs <- trb_ag_df %>% head(200) %>% pull(trb_cdr3)
        
        if (length(top200_seqs) > 0) {
          kmer_df <- as.data.frame(table(get_kmers(top200_seqs, k = 3))) %>%
            arrange(desc(Freq)) %>%
            head(20) %>%
            rename(motif = Var1, count = Freq)
          
          p13b <- ggplot(kmer_df, aes(x = reorder(motif, count), y = count, fill = count)) +
            geom_col(width = 0.75) +
            coord_flip() +
            scale_fill_gradient(low = "#FEE0D2", high = "#CB181D", guide = "none") +
            labs(title = paste("Figure 13b: GLIPH2-like CDR3 3-mer Motif Frequency -", sample_name),
                 subtitle = "Top 20 3-mer motifs in top 200 TRB CDR3 sequences",
                 x = "3-mer Motif", y = "Count") +
            theme_bw(base_size = 13) +
            theme(plot.title = element_text(face = "bold"))
          save_fig(p13b, "fig13b_GLIPH2_motif", w = 10, h = 7)
        } else {
          cat("序列不足，跳过图13b\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13b_GLIPH2_motif.png")))
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13b_GLIPH2_motif.pdf")))
        }
        
        KD_SCALE <- c(A=1.8, R=-4.5, N=-3.5, D=-3.5, C=2.5, Q=-3.5, E=-3.5,
                      G=-0.4, H=-3.2, I=4.5, L=3.8, K=-3.9, M=1.9, F=2.8,
                      P=-1.6, S=-0.8, T=-0.7, W=-0.9, Y=-1.3, V=4.2)
        
        hydro_score <- function(seq) {
          aas <- strsplit(seq, "")[[1]]
          mean(KD_SCALE[aas], na.rm = TRUE)
        }
        
        hydro_df <- trb_ag_df %>%
          mutate(hydro = sapply(trb_cdr3, hydro_score),
                 expansion_group = factor(expansion_group, levels = EXP_LEVELS))
        
        if (nrow(hydro_df) > 0) {
          n_label_df <- hydro_df %>%
            count(expansion_group) %>%
            mutate(label = paste0("n=", n))
          
          large_groups <- c("Singleton", "Small (2-5)", "Medium (6-20)")
          small_groups <- c("Large (21-100)", "Hyperexpanded (>100)")
          
          p13c <- ggplot(hydro_df, aes(x = expansion_group, y = hydro, fill = expansion_group)) +
            geom_violin(data = filter(hydro_df, expansion_group %in% large_groups),
                        alpha = 0.6, trim = FALSE, scale = "width") +
            geom_boxplot(data = filter(hydro_df, expansion_group %in% large_groups),
                         width = 0.1, fill = "white", outlier.shape = NA, linewidth = 0.6) +
            geom_jitter(data = filter(hydro_df, expansion_group %in% small_groups),
                        width = 0.2, size = 3, alpha = 0.8, shape = 21, color = "black") +
            geom_text(data = n_label_df,
                      aes(x = expansion_group, y = max(hydro_df$hydro) + 0.15, label = label),
                      inherit.aes = FALSE, size = 3.5, color = "grey30") +
            scale_fill_manual(values = EXP_COLORS, name = "Expansion Group") +
            labs(title = paste("Figure 13c: CDR3 Hydrophobicity Score Distribution -", sample_name),
                 subtitle = "Kyte-Doolittle scale; proxy for pMHC binding affinity\n(Violin for n≥100; jitter for small groups)",
                 x = "Expansion Group", y = "Mean Hydrophobicity (Kyte-Doolittle)") +
            theme_bw(base_size = 13) +
            theme(plot.title = element_text(face = "bold"),
                  axis.text.x = element_text(angle = 20, hjust = 1),
                  legend.position = "none")
          save_fig(p13c, "fig13c_pMHC_score_distribution", w = 11, h = 6)
        } else {
          cat("数据不足，跳过图13c\n")
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13c_pMHC_score_distribution.png")))
          file.create(file.path(fig_dir, paste0(sample_name, "_fig13c_pMHC_score_distribution.pdf")))
        }
        
        cat("\n所有图表生成完成！样本:", sample_name, "\n")
        
        # 列出所有生成的文件
        files <- list.files(fig_dir, pattern = paste0(sample_name, "_fig"), full.names = TRUE)
        cat("\n生成的图表文件 (", length(files), "个):\n")
        for (f in files) cat("  ", basename(f), "\n")
        RSCRIPT
        
        # 执行 R 脚本
        Rscript /tmp/generate_figures.R \
            "~{sample}" \
            "~{output_directory}" \
            "~{contig_filtered}" \
            "~{clonotypes_annotated}" \
            "~{diversity_metrics}" \
            "~{imm_tra}" \
            "~{imm_trb}"
        
        # 验证输出
        echo ""
        echo "=== 生成的文件列表 ==="
        ls -la ~{output_directory}/~{sample}_fig* 2>/dev/null || echo "警告: 未找到生成的图表文件"
        
        # 确保所有必需文件存在（如果不存在则创建空文件）
        for suffix in fig1_vgene_usage fig2a_TRA_VJ_heatmap fig2b_TRB_VJ_heatmap \
                      fig3_CDR3_length_overlay fig4_UMAP_CDR3 fig5_circos_VJ \
                      fig6_CDR3_length_histogram fig7_CDR3_seqlogo \
                      fig9a_clonotype_frequency_bar fig9b_clonal_size_bar \
                      fig9c_cumulative_frequency_curve fig10_clonal_expansion_bubble \
                      fig12_clonotype_dynamics fig13a_TCRdist_heatmap \
                      fig13b_GLIPH2_motif fig13c_pMHC_score_distribution; do
            for ext in png pdf; do
                f="~{output_directory}/~{sample}_${suffix}.${ext}"
                if [ ! -f "$f" ]; then
                    echo "创建空文件: $f"
                    touch "$f"
                fi
            done
        done
        
        # 图8是可选的
        for ext in png pdf; do
            f="~{output_directory}/~{sample}_fig8_CDR3_similarity_network.${ext}"
            if [ ! -f "$f" ]; then
                touch "$f"
            fi
        done
    >>>

    output {
        File fig1_png = "~{output_directory}/~{sample}_fig1_vgene_usage.png"
        File fig1_pdf = "~{output_directory}/~{sample}_fig1_vgene_usage.pdf"
        File fig2a_png = "~{output_directory}/~{sample}_fig2a_TRA_VJ_heatmap.png"
        File fig2a_pdf = "~{output_directory}/~{sample}_fig2a_TRA_VJ_heatmap.pdf"
        File fig2b_png = "~{output_directory}/~{sample}_fig2b_TRB_VJ_heatmap.png"
        File fig2b_pdf = "~{output_directory}/~{sample}_fig2b_TRB_VJ_heatmap.pdf"
        File fig3_png = "~{output_directory}/~{sample}_fig3_CDR3_length_overlay.png"
        File fig3_pdf = "~{output_directory}/~{sample}_fig3_CDR3_length_overlay.pdf"
        File fig6_png = "~{output_directory}/~{sample}_fig6_CDR3_length_histogram.png"
        File fig6_pdf = "~{output_directory}/~{sample}_fig6_CDR3_length_histogram.pdf"
        File fig7_png = "~{output_directory}/~{sample}_fig7_CDR3_seqlogo.png"
        File fig7_pdf = "~{output_directory}/~{sample}_fig7_CDR3_seqlogo.pdf"
        File fig4_png = "~{output_directory}/~{sample}_fig4_UMAP_CDR3.png"
        File fig4_pdf = "~{output_directory}/~{sample}_fig4_UMAP_CDR3.pdf"
        File fig5_png = "~{output_directory}/~{sample}_fig5_circos_VJ.png"
        File fig5_pdf = "~{output_directory}/~{sample}_fig5_circos_VJ.pdf"
        File? fig8_png = "~{output_directory}/~{sample}_fig8_CDR3_similarity_network.png"
        File? fig8_pdf = "~{output_directory}/~{sample}_fig8_CDR3_similarity_network.pdf"
        File fig9a_png = "~{output_directory}/~{sample}_fig9a_clonotype_frequency_bar.png"
        File fig9a_pdf = "~{output_directory}/~{sample}_fig9a_clonotype_frequency_bar.pdf"
        File fig9b_png = "~{output_directory}/~{sample}_fig9b_clonal_size_bar.png"
        File fig9b_pdf = "~{output_directory}/~{sample}_fig9b_clonal_size_bar.pdf"
        File fig9c_png = "~{output_directory}/~{sample}_fig9c_cumulative_frequency_curve.png"
        File fig9c_pdf = "~{output_directory}/~{sample}_fig9c_cumulative_frequency_curve.pdf"
        File fig10_png = "~{output_directory}/~{sample}_fig10_clonal_expansion_bubble.png"
        File fig10_pdf = "~{output_directory}/~{sample}_fig10_clonal_expansion_bubble.pdf"
        File fig12_png = "~{output_directory}/~{sample}_fig12_clonotype_dynamics.png"
        File fig12_pdf = "~{output_directory}/~{sample}_fig12_clonotype_dynamics.pdf"
        File fig13a_png = "~{output_directory}/~{sample}_fig13a_TCRdist_heatmap.png"
        File fig13a_pdf = "~{output_directory}/~{sample}_fig13a_TCRdist_heatmap.pdf"
        File fig13b_png = "~{output_directory}/~{sample}_fig13b_GLIPH2_motif.png"
        File fig13b_pdf = "~{output_directory}/~{sample}_fig13b_GLIPH2_motif.pdf"
        File fig13c_png = "~{output_directory}/~{sample}_fig13c_pMHC_score_distribution.png"
        File fig13c_pdf = "~{output_directory}/~{sample}_fig13c_pMHC_score_distribution.pdf"
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/devmode/seurat_harmony_yl:v5"
        memory: "16 GB"
        cpu: 8
        disk: "100 GB"
    }
}

task PackageResults {
    input {
        String output_directory
        String sample
        # 添加一个虚拟输入，确保此任务在GenerateFigures完成后运行
        File fig1_png
    }

    command <<<
        set -euo pipefail
        
        echo "当前工作目录: $(pwd)"
        echo "output_directory 参数: ~{output_directory}"
        
        # 直接使用 fig1_png 的路径来定位输出目录
        # fig1_png 的完整路径是 /cromwell-executions/.../execution/res/PT1/PT1_fig1_vgene_usage.png
        # 我们需要找到 res/PT1 这个目录
        
        FIG_PATH="~{fig1_png}"
        echo "FIG_PATH: $FIG_PATH"
        
        # 获取 fig1_png 所在的目录
        ACTUAL_OUTPUT_DIR=$(dirname "$FIG_PATH")
        echo "实际输出目录: $ACTUAL_OUTPUT_DIR"
        
        # 验证目录存在
        if [ ! -d "$ACTUAL_OUTPUT_DIR" ]; then
            echo "错误: 目录不存在: $ACTUAL_OUTPUT_DIR"
            exit 1
        fi
        
        # 切换到父目录进行打包
        parent_dir=$(dirname "$ACTUAL_OUTPUT_DIR")
        sample_dir=$(basename "$ACTUAL_OUTPUT_DIR")
        
        echo "父目录: $parent_dir"
        echo "样本目录: $sample_dir"
        
        cd "$parent_dir"
        
        # 创建压缩包
        tar -czf ~{sample}_TCR_analysis_results.tar.gz "$sample_dir"
        
        # 生成文件清单
        ls -lh "$sample_dir" > ~{sample}_file_manifest.txt
        
        # 计算校验和
        md5sum ~{sample}_TCR_analysis_results.tar.gz > ~{sample}_TCR_analysis_results.md5
        
        echo "打包完成: ~{sample}_TCR_analysis_results.tar.gz"
        echo "文件大小: $(du -h ~{sample}_TCR_analysis_results.tar.gz | cut -f1)"
        echo "包含文件数: $(tar -tzf ~{sample}_TCR_analysis_results.tar.gz | wc -l)"
        
        # 将结果文件移动到当前工作目录（cromwell 期望的位置）
        mv ~{sample}_TCR_analysis_results.tar.gz ~{sample}_file_manifest.txt ~{sample}_TCR_analysis_results.md5 "$OLDPWD/" 2>/dev/null || true
    >>>

    output {
        File tarball = "~{sample}_TCR_analysis_results.tar.gz"
        File manifest = "~{sample}_file_manifest.txt"
        File checksum = "~{sample}_TCR_analysis_results.md5"
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/devmode/seurat_harmony_yl:v5"
        memory: "4 GB"
        cpu: 2
        disk: "200 GB"
    }
}
