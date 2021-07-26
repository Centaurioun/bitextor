#################################################################
### DOCALIGN ####################################################
# DICTIONARY-BASED ##############################################
rule dic_docsegalign_lettr2idx:
    input:
        text1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/tokenised.gz",
        text2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/tokenised.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.idx.xz",
    shell:
        """
        {PROFILING} python3 {WORKFLOW}/bitextor_buildidx.py  --lang1 {SRC_LANG} --lang2 {TRG_LANG} -m 15 --text1 {input.text1} --text2 {input.text2} | xz -T 0 > {output}
        """


rule dic_docsegalign_idx2ridx_l1tol2:
    input:
        idx=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.idx.xz",
        dic=expand("{dic}", dic=DIC),
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.1.ridx.xz",
    shell:
        """
        xzcat -T 0 -f {input.idx} \
            | {PROFILING} python3 {WORKFLOW}/bitextor_idx2ridx.py -d {input.dic} --lang1 {SRC_LANG} --lang2 {TRG_LANG} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_idx2ridx_l2tol1:
    input:
        idx=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.idx.xz",
        dic=expand("{dic}", dic=DIC),
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.2.ridx.xz",
    shell:
        """
        xzcat -T 0 -f {input.idx} \
            | {PROFILING} python3 {WORKFLOW}/bitextor_idx2ridx.py -d {input.dic} --lang1 {TRG_LANG} --lang2 {SRC_LANG} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_ridx2imagesetoverlap:
    input:
        ridx=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.ridx.xz",
        debpl_html_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/{HTML_FILE}",
        debpl_html_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/{HTML_FILE}",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.imgoverlap.xz",
    shell:
        """
        xzcat -T 0 -f {input.ridx} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_imagesetoverlap.py --html1 {input.debpl_html_l1} --html2 {input.debpl_html_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_imagesetoverlap2structuredistance:
    input:
        imagesetoverlap=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.imgoverlap.xz",
        debpl_html_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/{HTML_FILE}",
        debpl_html_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/{HTML_FILE}",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.structuredistance.xz",
    shell:
        """
        xzcat -T 0 -f {input.imagesetoverlap} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_structuredistance.py --html1 {input.debpl_html_l1} --html2 {input.debpl_html_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_structuredistance2urldistance:
    input:
        structuredistance=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.structuredistance.xz",
        debpl_html_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/{HTML_FILE}",
        debpl_html_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/{HTML_FILE}",
        url_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/url.gz",
        url_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/url.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urldistance.xz",
    priority: 8
    shell:
        """
        xzcat -T 0 -f {input.structuredistance} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_urlsdistance.py \
                --html1 {input.debpl_html_l1} --html2 {input.debpl_html_l2} \
                --url1 {input.url_l1} --url2 {input.url_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_urldistance2mutuallylinked:
    input:
        urldistance=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urldistance.xz",
        debpl_html_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/{HTML_FILE}",
        debpl_html_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/{HTML_FILE}",
        url_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/url.gz",
        url_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/url.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.mutuallylinked.xz",
    shell:
        """
        xzcat -T 0 -f {input.urldistance} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_mutuallylinked.py \
                --html1 {input.debpl_html_l1} --html2 {input.debpl_html_l2} \
                --url1 {input.url_l1} --url2 {input.url_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_mutuallylinked2urlscomparison:
    input:
        mutuallylinked=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.mutuallylinked.xz",
        url_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/url.gz",
        url_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/url.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urlscomparison.xz",
    shell:
        """
        xzcat -T 0 -f {input.mutuallylinked} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_urlscomparison.py --url1 {input.url_l1} --url2 {input.url_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_urlscomparison2urlsoverlap:
    input:
        urlscomparison=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urlscomparison.xz",
        debpl_html_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/{HTML_FILE}",
        debpl_html_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/{HTML_FILE}",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urlsoverlap.xz",
    shell:
        """
        xzcat -T 0 -f {input.urlscomparison} \
            | {PROFILING} python3 {WORKFLOW}/features/bitextor_urlsetoverlap.py --html1 {input.debpl_html_l1} --html2 {input.debpl_html_l2} \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_urlsoverlap2rank:
    input:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.urlsoverlap.xz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{{num}}.rank.xz",
    shell:
        """
        xzcat -T 0 -f {input} \
            | {PROFILING} python3 {WORKFLOW}/bitextor_rank.py -m {WORKFLOW}/data/model/keras.model -w {WORKFLOW}/data/model/keras.weights \
            | xz -T 0 > {output}
        """


rule dic_docsegalign_aligndocumentsBitextor:
    input:
        rank1=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.1.rank.xz",
        rank2=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.2.rank.xz",
        url_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/url.gz",
        url_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/url.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.bitextor.06_01.matches",
    shell:
        """
        {PROFILING} python3 {WORKFLOW}/bitextor_align_documents.py \
            --lines1 $(zcat {input.url_l1} | wc -l) --lines2 $(zcat {input.url_l2} | wc -l) \
            -n 1 -i converge -r /dev/null {input.rank1} {input.rank2} > {output}
        """


#################################################################
### SEGALIGN ####################################################
# HUNALIGN ######################################################

docalign_str = ""  # Default: externalMT as docalign

if DOCALIGN == "DIC":
    docalign_str = "bitextor."


rule dic_docsegalign_matches2hunalign:
    input:
        indices=f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.{docalign_str}06_01.matches",
        plain1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/sentences.gz",
        plain2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/sentences.gz",
        url_l1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/url.gz",
        url_l2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/url.gz",
        tok1=f"{DATADIR}/shards/{SRC_LANG}/{{shard}}/{{src_batch}}/tokenised.gz",
        tok2=f"{DATADIR}/shards/{TRG_LANG}/{{shard}}/{{trg_batch}}/tokenised.gz",
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.hunalign.docalign.{docalign_str}06_02.matches.xz",
    params:
        c1=1 if DOCALIGN == "DIC" else 2,
        c2=2 if DOCALIGN == "DIC" else 3,
    shell:
        """
        cut -f {params.c1},{params.c2} {input.indices} \
            | LC_ALL=C sort -nk1 \
            | {PROFILING} python3 {WORKFLOW}/bitextor_build_docalign.py \
                --columns1 {input.url_l1} {input.plain1} {input.tok1} --columns2 {input.url_l2} {input.plain2} {input.tok2} \
            | awk -F\'\t\' \'{{print $2,$6,$3,$7,$4,$8}}\' OFS=\'\t\' \
            | xz -T 0 -f > {output} # Format: url1 <tab> url2 <tab> text1 <tab> text2 <tab> tok1 <tab> tok2
        """


rule dic_docsegalign_hunaligndic:
    input:
        expand("{dic}", dic=DIC),
    output:
        f"{DATADIR}/hunalign_dic",
    run:
        with open(output[0], "wt") as outw:
            with open(input[0], "rt") as inr:
                header = inr.readline().strip()
                langs = header.split("\t")
                if langs[0] == LANG1 and langs[1] == LANG2:
                    inverse = True
                else:
                    inverse = False
                for inline in inr:
                    columns = inline.strip().split("\t")
                    if inverse:
                        outw.write(f"{columns[1]} @ {columns[0]}\n")
                    else:
                        outw.write(f"{columns[0]} @ {columns[1]}\n")


rule dic_docsegalign_alignsegments_hunalign:
    input:
        hunaligndic=rules.dic_docsegalign_hunaligndic.output,
        hunalign_matches=rules.dic_docsegalign_matches2hunalign.output,
    output:
        f"{TRANSIENT}/{SRC_LANG}_{TRG_LANG}/{{shard}}/{SRC_LANG}{{src_batch}}_{TRG_LANG}{{trg_batch}}.hunalign.06_02.segalign.xz",
    shell:
        """
        xzcat -T 0 {input.hunalign_matches} \
            | {PROFILING} python3 {WORKFLOW}/bitextor_align_segments.py {DEFERRED} {MMHSUM_PATH} -d {input.hunaligndic} -t {TMPDIR} \
                --hunalign "hunalign" --hunalign-thresh {SEGALIGN_THRESHOLD} \
            | xz -T 0 > {output}
        """
