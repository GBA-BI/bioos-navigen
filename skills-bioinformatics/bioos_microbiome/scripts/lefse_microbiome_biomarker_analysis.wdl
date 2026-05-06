workflow Tool_LEfSe {

    File input_file

    String? whether_features_1_override
    String whether_features_1 = select_first([whether_features_1_override, "r"])
    String? row_subject_1_override
    String row_subject_1 = select_first([row_subject_1_override, "-1"])
    String? row_subclass_1_override
    String row_subclass_1 = select_first([row_subclass_1_override, "-1"])
    String? row_class_1_override
    String row_class_1 = select_first([row_class_1_override, "1"])
    String? normalization_value_1_override
    String normalization_value_1 = select_first([normalization_value_1_override, "-1.0"])

    String? stratege_muti_class_2_override
    String stratege_muti_class_2 = select_first([stratege_muti_class_2_override, "0"])
    String? one_against_one_2_override
    String one_against_one_2 = select_first([one_against_one_2_override, "0"])
    String? Wilcoxon_test_2_override
    String Wilcoxon_test_2 = select_first([Wilcoxon_test_2_override, "0.05"])
    String? threshold_absolute_value_2_override
    String threshold_absolute_value_2 = select_first([threshold_absolute_value_2_override, "2.0"])
    String? same_name_2_override
    String same_name_2 = select_first([same_name_2_override, "0"])
    String? Anova_test_2_override
    String Anova_test_2 = select_first([Anova_test_2_override, "0.05"])

    String? bar_subclades_3_override
    String bar_subclades_3 = select_first([bar_subclades_3_override, "1"])
    String? dpi_3_override
    String dpi_3 = select_first([dpi_3_override, "150"])

    String? clade_sep_4
    String? point_edge_width_4
    String? labeled_start_lev_4
    String? abrv_stop_lev_4
    String? abrv_start_lev_4
    String? labeled_stop_lev_4

    String? how_many_features_5_override
    String how_many_features_5 = select_first([how_many_features_5_override, "diff"])
    String? feature_name_5
    String? feature_num_5

    call lefse {
        input:
            input_file = input_file,

            whether_features_1 = whether_features_1,
            row_subject_1 = row_subject_1,
            row_subclass_1 = row_subclass_1,
            row_class_1 = row_class_1,
            normalization_value_1 = normalization_value_1,

            stratege_muti_class_2 = stratege_muti_class_2,
            one_against_one_2 = one_against_one_2,
            Wilcoxon_test_2 = Wilcoxon_test_2,
            threshold_absolute_value_2 = threshold_absolute_value_2,
            same_name_2 = same_name_2,
            Anova_test_2 = Anova_test_2,

            bar_subclades_3 = bar_subclades_3,
            dpi_3 = dpi_3,

            clade_sep_4 = clade_sep_4,
            point_edge_width_4 = point_edge_width_4,
            labeled_start_lev_4 = labeled_start_lev_4,
            abrv_stop_lev_4 = abrv_stop_lev_4,
            abrv_start_lev_4 = abrv_start_lev_4,
            labeled_stop_lev_4 = labeled_stop_lev_4,

            how_many_features_5 = how_many_features_5,
            feature_name_5 = feature_name_5,
            feature_num_5 = feature_num_5
    }
}

task lefse {
    File input_file

    String whether_features_1
    String row_subject_1
    String row_subclass_1
    String row_class_1
    String normalization_value_1

    String stratege_muti_class_2
    String one_against_one_2
    String Wilcoxon_test_2
    String threshold_absolute_value_2
    String same_name_2
    String Anova_test_2

    String bar_subclades_3
    String dpi_3

    String? clade_sep_4
    String? point_edge_width_4
    String? labeled_start_lev_4
    String? abrv_stop_lev_4
    String? abrv_start_lev_4
    String? labeled_stop_lev_4

    String how_many_features_5
    String? feature_name_5
    String? feature_num_5

    command <<<
        set -euo pipefail

        echo "[LEfSe] Checking executables..."
        which format_input.py
        which run_lefse.py
        which plot_res.py
        which plot_cladogram.py
        which plot_features.py

        echo "[LEfSe] Formatting input..."
        format_input.py \
            ${input_file} \
            result.in \
            -f ${whether_features_1} \
            -u ${row_subject_1} \
            -s ${row_subclass_1} \
            -c ${row_class_1} \
            -o ${normalization_value_1}

        echo "[LEfSe] Running LEfSe..."
        run_lefse.py \
            result.in \
            result.res \
            -s ${stratege_muti_class_2} \
            -y ${one_against_one_2} \
            -w ${Wilcoxon_test_2} \
            -l ${threshold_absolute_value_2} \
            -e ${same_name_2} \
            -a ${Anova_test_2}

        echo "[LEfSe] Plotting bar plot..."
        plot_res.py \
            result.res \
            bar_plot.pdf \
            --subclades ${bar_subclades_3} \
            --dpi ${dpi_3} \
            --format pdf

        echo "[LEfSe] Plotting cladogram..."
        plot_cladogram.py \
            result.res \
            cladogram_plot.pdf \
            --dpi ${dpi_3} \
            ${'--clade_sep ' + clade_sep_4} \
            ${'--point_edge_width ' + point_edge_width_4} \
            ${'--labeled_start_lev ' + labeled_start_lev_4} \
            ${'--abrv_stop_lev ' + abrv_stop_lev_4} \
            ${'--abrv_start_lev ' + abrv_start_lev_4} \
            ${'--labeled_stop_lev ' + labeled_stop_lev_4} \
            --class_legend_font_size 7 \
            --format pdf

        echo "[LEfSe] Plotting feature plots..."
        plot_features.py \
            result.in \
            result.res \
            features \
            --format pdf \
            --dpi ${dpi_3} \
            -f ${how_many_features_5} \
            ${'--feature_name ' + feature_name_5} \
            ${'--feature_num ' + feature_num_5}

        mkdir -p feature_files
        if ls features1_Bacteria-* >/dev/null 2>&1; then
            mv features1_Bacteria-* feature_files/
        fi
    >>>

    output {
        File formatted_input = "result.in"
        File lefse_result = "result.res"
        File bar_plot = "bar_plot.pdf"
        File cladogram_plot = "cladogram_plot.pdf"
        Array[File] feature_files = glob("feature_files/*")
    }

    runtime {
        docker: "registry-vpc.miracle.ac.cn/nmdc/lefse:v0.1"
        cpu: "10"
        memory: "10GB"
    }
}
