process CSVTK_CONCAT {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/csvtk:0.30.0--h9ee0642_0' :
        'biocontainers/csvtk:0.30.0--h9ee0642_0' }"

    input:
    tuple val(meta), path(csv)

    output:
    tuple val(meta), path("${prefix}.${out_extension}"), emit: file_out
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    def delimiter = in_format == "tsv" ? "\t" : (in_format == "csv" ? "," : in_format)
    def out_delimiter = out_format == "tsv" ? "\t" : (out_format == "csv" ? "," : out_format)
    out_extension = out_format == "tsv" ? 'tsv' : 'csv'
    """
    csvtk \\
        cat \\
        $csv \\
        -o ${prefix}_merged.tab.gz \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        csvtk: \$(echo \$( csvtk version | sed -e "s/csvtk v//g" ))
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    out_extension = out_format == "tsv" ? 'tsv' : 'csv'
    """
    touch ${prefix}_merged.tab.gz 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        csvtk: \$(echo \$( csvtk version | sed -e "s/csvtk v//g" ))
    END_VERSIONS
    """
}