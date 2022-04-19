__author__ = "Martin Rippin, Jonas Almlöf"
__copyright__ = "Copyright 2021, Martin Rippin, Jonas Almlöf"
__email__ = "martin.rippin@scilifelab.uu.se, jonas.almlof@scilifelab.uu.se"
__license__ = "GPL-3"


rule config_manta_tn:
    input:
        bam_t="alignment/samtools_merge_bam/{sample}_T.bam",
        bai_t="alignment/samtools_merge_bam/{sample}_T.bam.bai",
        bam_n="alignment/samtools_merge_bam/{sample}_N.bam",
        bai_n="alignment/samtools_merge_bam/{sample}_N.bam.bai",
        ref=config["reference"]["fasta"],
    output:
        scrpt=temp("cnv_sv/manta_run_workflow_tn/{sample}/runWorkflow.py"),
    log:
        "cnv_sv/config_manta_tn/{sample}/runWorkflow.py.log",
    benchmark:
        repeat(
            "cnv_sv/config_manta_tn/{sample}/runWorkflow.py.benchmark.tsv",
            config.get("config_manta_tn", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("config_manta_tn", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("config_manta_tn", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("config_manta_tn", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("config_manta_tn", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("config_manta_tn", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("config_manta_tn", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("config_manta_tn", {}).get("container", config["default_container"])
    conda:
        "../envs/manta.yaml"
    message:
        "{rule}: Generate manta runWorkflow.py for {wildcards.sample}"
    shell:
        "configManta.py "
        "--tumorBam={input.bam_t} "
        "--normalBam={input.bam_n} "
        "--referenceFasta={input.ref} "
        "--runDir=cnv_sv/manta_run_workflow_tn/{wildcards.sample} &> {log}"


rule manta_run_workflow_tn:
    input:
        bam_t="alignment/samtools_merge_bam/{sample}_T.bam",
        bai_t="alignment/samtools_merge_bam/{sample}_T.bam.bai",
        bam_n="alignment/samtools_merge_bam/{sample}_N.bam",
        bai_n="alignment/samtools_merge_bam/{sample}_N.bam.bai",
        ref=config["reference"]["fasta"],
        scrpt="cnv_sv/manta_run_workflow_tn/{sample}/runWorkflow.py",
    output:
        cand_si_vcf=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/candidateSmallIndels.vcf.gz"),
        cand_si_tbi=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/candidateSmallIndels.vcf.gz.tbi"),
        cand_sv_vcf=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/candidateSV.vcf.gz"),
        cand_sv_tbi=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/candidateSV.vcf.gz.tbi"),
        dipl_sv_vcf=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/diploidSV.vcf.gz"),
        dipl_sv_tbi=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/diploidSV.vcf.gz.tbi"),
        som_sv_vcf=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/somaticSV.vcf.gz"),
        som_sv_tbi=temp("cnv_sv/manta_run_workflow_tn/{sample}/results/variants/somaticSV.vcf.gz.tbi"),
        wrk_dir=temp(directory("cnv_sv/manta_run_workflow_tn/{sample}/workspace")),
    log:
        "cnv_sv/manta_run_workflow_tn/{sample}/manta_tn.log",
    benchmark:
        repeat(
            "cnv_sv/manta_run_workflow_tn/{sample}/manta_tn.benchmark.tsv",
            config.get("manta_run_workflow_tn", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("manta_run_workflow_tn", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("manta_run_workflow_tn", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("manta_run_workflow_tn", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("manta_run_workflow_tn", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("manta_run_workflow_tn", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("manta_run_workflow_tn", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("manta_run_workflow_tn", {}).get("container", config["default_container"])
    conda:
        "../envs/manta.yaml"
    message:
        "{rule}: Use manta to call sv in {wildcards.sample}"
    shell:
        "{input.scrpt} "
        "-j {threads} "
        "-g unlimited &> {log}"


rule config_manta_t:
    input:
        bam_t="alignment/samtools_merge_bam/{sample}_T.bam",
        bai_t="alignment/samtools_merge_bam/{sample}_T.bam.bai",
        ref=config["reference"]["fasta"],
    output:
        scrpt=temp("cnv_sv/manta_run_workflow_t/{sample}/runWorkflow.py"),
    log:
        "cnv_sv/config_manta_t/{sample}/runWorkflow.py.log",
    benchmark:
        repeat(
            "cnv_sv/config_manta_t/{sample}/runWorkflow.py.benchmark.tsv",
            config.get("config_manta_t", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("config_manta_t", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("config_manta_t", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("config_manta_t", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("config_manta_t", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("config_manta_t", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("config_manta_t", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("config_manta_t", {}).get("container", config["default_container"])
    conda:
        "../envs/manta.yaml"
    message:
        "{rule}: Generate manta runWorkflow.py for {wildcards.sample}"
    shell:
        "configManta.py "
        "--tumorBam={input.bam_t} "
        "--referenceFasta={input.ref} "
        "--runDir=cnv_sv/manta_run_workflow_t/{wildcards.sample} &> {log}"


rule manta_run_workflow_t:
    input:
        ref=config["reference"]["fasta"],
        scrpt="cnv_sv/manta_run_workflow_t/{sample}/runWorkflow.py",
    output:
        cand_si_vcf=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/candidateSmallIndels.vcf.gz"),
        cand_si_tbi=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/candidateSmallIndels.vcf.gz.tbi"),
        cand_sv_vcf=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/candidateSV.vcf.gz"),
        cand_sv_tbi=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/candidateSV.vcf.gz.tbi"),
        tum_sv_vcf=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/tumorSV.vcf.gz"),
        tum_sv_tbi=temp("cnv_sv/manta_run_workflow_t/{sample}/results/variants/tumorSV.vcf.gz.tbi"),
        wrk_dir=temp(directory("cnv_sv/manta_run_workflow_t/{sample}/workspace")),
    log:
        "cnv_sv/manta_run_workflow_t/{sample}/manta_t.log",
    benchmark:
        repeat(
            "cnv_sv/manta_run_workflow_t/{sample}/manta_t.benchmark.tsv",
            config.get("manta_run_workflow_t", {}).get("benchmark_repeats", 1),
        )
    threads: config.get("manta_run_workflow_t", {}).get("threads", config["default_resources"]["threads"])
    resources:
        mem_mb=config.get("manta_run_workflow_t", {}).get("mem_mb", config["default_resources"]["mem_mb"]),
        mem_per_cpu=config.get("manta_run_workflow_t", {}).get("mem_per_cpu", config["default_resources"]["mem_per_cpu"]),
        partition=config.get("manta_run_workflow_t", {}).get("partition", config["default_resources"]["partition"]),
        threads=config.get("manta_run_workflow_t", {}).get("threads", config["default_resources"]["threads"]),
        time=config.get("manta_run_workflow_t", {}).get("time", config["default_resources"]["time"]),
    container:
        config.get("manta_run_workflow_t", {}).get("container", config["default_container"])
    conda:
        "../envs/manta.yaml"
    message:
        "{rule}: Use manta to call sv in {wildcards.sample}"
    shell:
        "{input.scrpt} "
        "-j {threads} "
        "-g unlimited &> {log}"
