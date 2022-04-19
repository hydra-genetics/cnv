# vim: syntax=python tabstop=4 expandtab
# coding: utf-8

__author__ = "Jonas Almlöf"
__copyright__ = "Copyright 2021, Jonas Almlöf"
__email__ = "jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule gatk_cnv_collect_read_counts:
    input:
        bam="alignment/samtools_merge_bam/{sample}_{type}.bam",
        bai="alignment/samtools_merge_bam/{sample}_{type}.bam.bai",
        interval=config.get("reference", {}).get("design_intervals_gatk_cnv", ""),
    output:
        temp("cnv_sv/gatk_cnv_collect_read_counts/{sample}_{type}.counts.hdf5"),
    params:
        mergingRule="OVERLAPPING_ONLY",
        extra=config.get("gatk_cnv_collect_read_counts", {}).get("extra", ""),
    log:
        "cnv_sv/gatk_cnv_collect_read_counts/{sample}_{type}.counts.hdf5.log",
    benchmark:
        repeat(
            "cnv_sv/gatk_cnv_collect_read_counts/{sample}_{type}.counts.hdf5.benchmark.tsv",
            config.get("gatk_cnv_collect_read_counts", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("gatk_cnv_collect_read_counts", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("gatk_cnv_collect_read_counts", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("gatk_cnv_collect_read_counts", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("gatk_cnv_collect_read_counts", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("gatk_cnv_collect_read_counts", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("gatk_cnv_collect_read_counts", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("gatk_cnv_collect_read_counts", {}).get("container", config["default_container"])
    conda:
        "../envs/gatk_cnv.yaml"
    message:
        "{rule}: Use gatk_cnv to obtain cnv_sv/gatk_cnv_collect_read_counts/{wildcards.sample}_{wildcards.type}.counts.hdf5"
    shell:
        "(gatk --java-options '-Xmx4g' CollectReadCounts "
        "-I {input.bam} "
        "-L {input.interval} "
        "--interval-merging-rule {params.mergingRule} "
        "{params.extra} "
        "-O {output}) &> {log}"


rule gatk_cnv_collect_allelic_counts:
    input:
        bam="alignment/samtools_merge_bam/{sample}_{type}.bam",
        bai="alignment/samtools_merge_bam/{sample}_{type}.bam.bai",
        interval=config.get("gatk_cnv_collect_allelic_counts", {}).get("SNP_interval", ""),
        ref=config["reference"]["fasta"],
    output:
        temp("cnv_sv/gatk_cnv_collect_allelic_counts/{sample}_{type}.clean.allelicCounts.tsv"),
    params:
        extra=config.get("gatk_cnv_collect_allelic_counts", {}).get("extra", ""),
    log:
        "cnv_sv/gatk_cnv_collect_allelic_counts/{sample}_{type}.clean.allelicCounts.tsv.log",
    benchmark:
        repeat(
            "cnv_sv/gatk_cnv_collect_allelic_counts/{sample}_{type}.clean.allelicCounts.tsv.benchmark.tsv",
            config.get("gatk_cnv_collect_allelic_counts", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("gatk_cnv_collect_allelic_counts", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("gatk_cnv_collect_allelic_counts", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("gatk_cnv_collect_allelic_counts", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("gatk_cnv_collect_allelic_counts", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("gatk_cnv_collect_allelic_counts", {}).get(
            "mem_per_cpu", config["default_resources"]["mem_per_cpu"]
        ),
        partition=config.get("gatk_cnv_collect_allelic_counts", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("gatk_cnv_collect_allelic_counts", {}).get("container", config["default_container"])
    conda:
        "../envs/gatk_cnv.yaml"
    message:
        "{rule}: Use gatk_cnv to obtain cnv_sv/gatk_cnv_collect_allelic_counts/{wildcards.sample}_{wildcards.type}.clean.allelicCounts.tsv"
    shell:
        "(gatk --java-options '-Xmx4g' CollectAllelicCounts "
        "-L {input.interval} "
        "-I {input.bam} "
        "-R {input.ref} "
        "-O {output}"
        "{params.extra}) &> {log}"


rule gatk_cnv_denoise_read_counts:
    input:
        hdf5PoN=config.get("gatk_cnv_denoise_read_counts", {}).get("normal_reference", ""),
        hdf5Tumor="cnv_sv/gatk_cnv_collect_read_counts/{sample}_{type}.counts.hdf5",
    output:
        denoisedCopyRatio=temp("cnv_sv/gatk_cnv_denoise_read_counts/{sample}_{type}.clean.denoisedCR.tsv"),
        stdCopyRatio=temp("cnv_sv/gatk_cnv_denoise_read_counts/{sample}_{type}.clean.standardizedCR.tsv"),
    params:
        extra=config.get("gatk_cnv_denoise_read_counts", {}).get("extra", ""),
    log:
        "cnv_sv/gatk_cnv_denoise_read_counts/{sample}_{type}.clean.denoisedCR.tsv.log",
    benchmark:
        repeat(
            "cnv_sv/gatk_cnv_denoise_read_counts/{sample}_{type}.clean.denoisedCR.tsv.benchmark.tsv",
            config.get("gatk_cnv_denoise_read_counts", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("gatk_cnv_denoise_read_counts", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("gatk_cnv_denoise_read_counts", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("gatk_cnv_denoise_read_counts", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("gatk_cnv_denoise_read_counts", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("gatk_cnv_denoise_read_counts", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("gatk_cnv_denoise_read_counts", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("gatk_cnv_denoise_read_counts", {}).get("container", config["default_container"])
    conda:
        "../envs/gatk_cnv.yaml"
    message:
        "{rule}: Use gatk_cnv to obtain cnv_sv/gatk_cnv_denoise_read_counts/{wildcards.sample}_{wildcards.type}.clean.denoisedCR.tsv"
    shell:
        "(gatk --java-options '-Xmx4g' DenoiseReadCounts "
        "-I {input.hdf5Tumor} "
        "--count-panel-of-normals {input.hdf5PoN} "
        "--standardized-copy-ratios {output.stdCopyRatio} "
        "--denoised-copy-ratios {output.denoisedCopyRatio} "
        "{params.extra}) &> {log}"


rule gatk_cnv_model_segments:
    input:
        denoisedCopyRatio="cnv_sv/gatk_cnv_denoise_read_counts/{sample}_{type}.clean.denoisedCR.tsv",
        allelicCounts="cnv_sv/gatk_cnv_collect_allelic_counts/{sample}_{type}.clean.allelicCounts.tsv",
    output:
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelFinal.seg"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.cr.seg"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.af.igv.seg"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.cr.igv.seg"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.hets.tsv"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelBegin.cr.param"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelBegin.af.param"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelBegin.seg"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelFinal.af.param"),
        temp("cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelFinal.cr.param"),
    params:
        outdir=lambda wildcards, output: os.path.dirname(output[0]),
        outprefix="{sample}_{type}.clean",
        extra=config.get("gatk_cnv_model_segments", {}).get("extra", ""),
    log:
        "cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelFinal.seg.log",
    benchmark:
        repeat(
            "cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.modelFinal.seg.benchmark.tsv",
            config.get("gatk_cnv_model_segments", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("gatk_cnv_model_segments", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("gatk_cnv_model_segments", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("gatk_cnv_model_segments", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("gatk_cnv_model_segments", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("gatk_cnv_model_segments", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("gatk_cnv_model_segments", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("gatk_cnv_model_segments", {}).get("container", config["default_container"])
    conda:
        "../envs/gatk_cnv.yaml"
    message:
        "{rule}: Use gatk_cnv to obtain cnv_sv/gatk_cnv_model_segments/{wildcards.sample}_{wildcards.type}.clean.modelFinal.seg"
    shell:
        "(gatk --java-options '-Xmx4g' ModelSegments "
        "--denoised-copy-ratios {input.denoisedCopyRatio} "
        "--allelic-counts {input.allelicCounts} "
        "--output {params.outdir} "
        "--output-prefix {params.outprefix}"
        "{params.extra}) &> {log}"


rule gatk_cnv_call_copy_ratio_segments:
    input:
        "cnv_sv/gatk_cnv_model_segments/{sample}_{type}.clean.cr.seg",
    output:
        segments=temp("cnv_sv/gatk_cnv_call_copy_ratio_segments/{sample}_{type}.clean.calledCNVs.seg"),
        igv_segments=temp("cnv_sv/gatk_cnv_call_copy_ratio_segments/{sample}_{type}.clean.calledCNVs.igv.seg"),
    params:
        extra=config.get("gatk_cnv_call_copy_ratio_segments", {}).get("extra", ""),
    log:
        "cnv_sv/gatk_cnv_call_copy_ratio_segments/{sample}_{type}.clean.calledCNVs.seg.log",
    benchmark:
        repeat(
            "cnv_sv/gatk_cnv_call_copy_ratio_segments/{sample}_{type}.clean.calledCNVs.seg.benchmark.tsv",
            config.get("gatk_cnv_call_copy_ratio_segments", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("gatk_cnv_call_copy_ratio_segments", {}).get("threads", config["default_resources"]["threads"])
    resources:
        threads=config.get("gatk_cnv_call_copy_ratio_segments", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("gatk_cnv_call_copy_ratio_segments", {}).get("time", config["default_resources"]["time"]),
        mem_mb=config.get("gatk_cnv_call_copy_ratio_segments", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("gatk_cnv_call_copy_ratio_segments", {}).get(
            "mem_per_cpu", config["default_resources"]["mem_per_cpu"]
        ),
        partition=config.get("gatk_cnv_call_copy_ratio_segments", {}).get("partition", config["default_resources"]["partition"]),
    container:
        config.get("gatk_cnv_call_copy_ratio_segments", {}).get("container", config["default_container"])
    conda:
        "../envs/gatk_cnv.yaml"
    message:
        "{rule}: Use gatk_cnv to obtain cnv_sv/gatk_cnv_call_copy_ratio_segments/{wildcards.sample}_{wildcards.type}.clean.calledCNVs.seg"
    shell:
        "(gatk --java-options '-Xmx4g' CallCopyRatioSegments "
        "--input {input} "
        "--output {output.segments} "
        "{params.extra}) &> {log}"
