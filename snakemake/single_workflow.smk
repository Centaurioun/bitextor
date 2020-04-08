import os
import sys

include: "utils.smk"

validate_args(config)

sys.path.append(os.path.dirname(os.path.abspath(config["bitextor"]) + "/utils"))
from utils.common import open_xz_or_gzip_or_plain

#################################################################
# BASIC PARAMETERS
BITEXTOR = config["bitextor"]
DATADIR = config["dataDir"]
TRANSIENT = config["transientDir"]
PERMANENT = config["permanentDir"]
TMPDIR = config["transientDir"]
if "tempDir" in config:
    TMPDIR = config["tempDir"]

LANGS = set()
LANG1 = ""
LANG2 = ""

if "langs" in config:
    LANGS = set(config["langs"])
if "lang1" in config:
    LANG1 = config["lang1"]
    LANGS.add(LANG1)
if "lang2" in config:
    LANG2 = config["lang2"]
    LANGS.add(LANG2)

ONLY_PREPROCESS = False
ONLY_CRAWL = False
if "onlyCrawl" in config and config["onlyCrawl"]:
    ONLY_CRAWL = True
if "onlyPreprocess" in config and config["onlyPreprocess"]:
    ONLY_PREPROCESS = True

#################################################################
# CRAWLING
CRAWLTARGET = ""
TLD_CRAWL = ""
USERAGENT = ""
CRAWLSIZELIMIT = ""
CRAWLTIMELIMIT = ""
CRAWLWAIT = ""
CRAWLPAGELIMIT = ""
CRAWLFILETYPES = ""
CRAWLJOBS = "-j 2"
CRAWLTIMEOUT = ""
CRAWLDUMPARGS = ""
CONTINUECRAWL = ""
HERITRIXPATH = ""
HERITRIXURL = "https://localhost:8443"
HERITRIXUSER = "admin:admin"

if "crawler" in config:
    CRAWLTARGET = config["crawler"]

if "crawl-tld" in config and config["crawl-tld"]:
    TLD_CRAWL = "-D"

if "crawlerUserAgent" in config:
    USERAGENT = f'-a "{config["crawlerUserAgent"]}"'

if "crawlSizeLimit" in config:
    CRAWLSIZELIMIT = f'-s {config["crawlSizeLimit"]}'

if "crawlTimeLimit" in config:
    if CRAWLTARGET == "heritrix":
        CRAWLTIMELIMIT = config["crawlTimeLimit"]
    else:
        CRAWLTIMELIMIT = f'-t {config["crawlTimeLimit"]}'

if "crawlWait" in config:
    CRAWLWAIT = f'--wait {config["crawlWait"]}'

if "crawlFileTypes" in config:
    CRAWLFILETYPES = f'-f {config["crawlFileTypes"]}'

if "crawlerNumThreads" in config:
    CRAWLJOBS = f'-j {config["crawlerNumThreads"]}'

if "crawlerConnectionTimeout" in config:
    CRAWLTIMEOUT = f'-o {config["crawlerConnectionTimeout"]}'

if "dumpCurrentCrawl" in config:
    CRAWLDUMPARGS = f'-d {config["dumpCurrentCrawl"]}'

if "resumePreviousCrawl" in config:
    CONTINUECRAWL = f'-l {config["resumePreviousCrawl"]}'

if "heritrixPath" in config:
    HERITRIXPATH = config["heritrixPath"]

if "heritrixUrl" in config:
    HERITRIXURL = config["heritrixUrl"]

if "heritrixUser" in config:
    HERITRIXUSER = config["heritrixUser"]

#################################################################
# PREPROCESS
PPROC = "w2p"
GIAWARC = "~/go/bin/giawarc"
PPROC_FILES = ["plain_text.gz", "url.gz", "mime.gz", "normalized_html.gz", "deboilerplate_html.gz"]
if "preprocessor" in config and config["preprocessor"] == "giawarc":
    PPROC = "giawarc"
    PPROC_FILES = ["plain_text.gz", "url.gz", "mime.gz"]
    if "giawarc_executable" in config:
        GIAWARC = config["giawarc_executable"]
CLEANHTML = ""
FTFY = ""
LANGID = "cld2"
PARSER = ""
BOILERPIPE = ""
PDFEXTRACT = ""

if "cleanHTML" in config and config["cleanHTML"]:
    CLEANHTML = "--cleanhtml"
if "ftfy" in config and config["ftfy"]:
    FTFY = "--ftfy"
if "langID" in config:
    LANGID = config['langID']
if "parser" in config:
    PARSER = f"--parser {config['parser']}"
if "boilerpipeCleaning" in config and config["boilerpipeCleaning"]==True:
    BOILERPIPE = "--boilerpipe"
if "PDFextract" in config and config["PDFextract"]:
    PDFEXTRACT = "--pdfextract"

SENTTOKS = {} 
CUSTOMNBPS = {}
WORDTOKS = {}
MORPHTOKS = {}

if "sentenceSplitters" in config:
    SENTTOKS = config["sentenceSplitters"]
if "customNBPs" in config:
    CUSTOMNBPS = config["customNBPs"] 
if "wordTokenizers" in config:
    WORDTOKS = config["workTokenizers"]
if "morphologicalAnalysers" in config:
    MORPHTOKS = config["morphologicalAnalysers"]

# sentence splitting and tokenisation
PRUNE_THRESHOLD = "--prune 80"
PRUNE_TYPE = "--prune-type words"

if "pruneThreshold" in config:
    PRUNE_THRESHOLD = f"--prune {config['pruneThreshold']}"
if "pruneType" in config:
    PRUNE_TYPE = f"--prune-type {config['pruneType']}"

#################################################################
# DOCALIGN
DOCALIGN = 'dic'
if 'documentAligner' in config:
    DOCALIGN = config["documentAligner"]
# mt
MT_COMMAND = config['alignerCmd']
DOC_THRESHOLD = 0.1
if "documentAlignerThreshold" in config:
    DOC_THRESHOLD = config["documentAlignerThreshold"]

WORDTOK2 = get_lang_or_default(WORDTOKS, LANG2)
MORPHTOK2 = get_lang_or_default(MORPHTOKS, LANG2)
if WORDTOK2 == "":
    get_default_tokeniser(BITEXTOR, LANG2)
# dic
# TODO
#################################################################
# SEGALIGN
SEGALIGN = 'hunalign'
if "segmentAligner" in config:
    SEGALIGN = config["hunalign"]
# bleualign
BLEU_TRESHOLD = 0.1
if "sentenceAlignerThreshold" in config:
    BLEU_THRESHOLD=config["sentenceAlignerThreshold"]
# hunalign
# TODO
#################################################################
# CLEANING
FIELDS = ['url1','url2','seg1','seg2','aligner']
DEFERRED = False
DEFERRED_FIELDS = []
BIFIXER = False
BIFIXER_FIELDS = []
AGGRESSIVE_DEDUP = ""
BICLEANER = False
BICLEANER_MODEL = ""
BICLEANER_FIELDS = []
BICLEANER_THRESHOLD = 0.0
ELRC = False
ELRC_FIELDS = []
TMX = False
DEDUPED = False
# TODO: add rawCorpus option to generate lang1-lang2.raw.xz ((what is it supposed to be?))
OUTPUT_FILES = ["sent"]

if 'deferredCrawling' in config and config['deferredCrawling']:
    DEFERRED = True
    DEFERRED_FIELDS = ['deferredseg1','checksum1','deferredseg2','checksum2']
if 'bifixer' in config and config['bifixer']:
    BIFIXER = True
    BIFIXER_FIELDS = ['bifixerhash','bifixerscore']
if 'aggressiveDedup' in config and config['aggressiveDedup']:
    AGGRESSIVE_DEDUP = '--aggressive_dedup'
if 'bicleaner' in config:
    BICLEANER = True
    BICLEANER_MODEL = config['bicleaner']
    BICLEANER_FIELDS = ['bicleaner']
if 'bicleanerThreshold' in config:
    BICLEANER_THRESHOLD = config['bicleanerThreshold']
if 'elrc' in config and config['elrc']:
    ELRC = True
    ELRC_FIELDS = ['lengthratio','numTokensSL','numTokensTL']
if 'tmx' in config and config['tmx']:
    TMX = True
    OUTPUT_FILES.append('not-deduped.tmx')
if 'deduped' in config and config['deduped']:
    OUTPUT_FILES.append('deduped.tmx')
    OUTPUT_FILES.append('deduped.txt')

BEFORE_ELRC_FIELDS = FIELDS + DEFERRED_FIELDS + BIFIXER_FIELDS + BICLEANER_FIELDS
TMX_FIELDS = BEFORE_ELRC_FIELDS + ELRC_FIELDS

BIFIXER_HASH_COLUMN = ''
BIFIXER_SCORE_COLUMN = ''
BICLEANER_CACHE_DEDUP = "3,4"
BICLEANER_SORT = f"LC_ALL=C sort -t $'\t' -k3,4 -T {TMPDIR} --compress-program=gzip |"
DEDUP = 'seg1,seg2'
if 'bifixerhash' in BEFORE_ELRC_FIELDS:
    i = BEFORE_ELRC_FIELDS.index('bifixerhash')
    BIFIXER_HASH_COLUMN = f'{i},{i}'
    BIFIXER_SCORE_COLUMN = f'{i+1},{i+1}'
    BICLEANER_CACHE_DEDUP = f'{i}'
    BICLEANER_SORT = ""
    DEDUP = 'bifixerhash'

BEFORE_ELRC_FIELDS = ','.join(BEFORE_ELRC_FIELDS)
TMX_FIELDS = ','.join(TMX_FIELDS)
#################################################################
# DATASOURCES
HOSTS = set()
WARCS = set()

if "warcs" in config:
    WARCS.union(config["warcs"])

if "hosts" in config:
    HOSTS = HOSTS.union(config["hosts"])

if "hostsFile" in config:
    with open_xz_or_gzip_or_plain(config["hostsFile"]) as f:
        for line in f:
            HOSTS.add(line.strip())

DOMAIN_2_HOSTS = create_domain_key_2_host_map(HOSTS)
# group together the WARCS that are in the same folder (process them individually, or all together?)
TARGET_2_WARCS = parent_folder_2_warcs(WARCS)
# group crawled hosts by domains
TARGET_2_WARCS.update(dict([(domain, [f'{DATADIR}/warc/{host}/{CRAWLTARGET}.warc.gz' for host in hosts]) for (domain, hosts) in DOMAIN_2_HOSTS.items()]))
TARGETS = TARGET_2_WARCS.keys()
#################################################################
OUTPUT = []

if ONLY_CRAWL:
    for domain, hosts in DOMAIN_2_HOSTS:
        for host in hosts:
            OUTPUT.append('{DATADIR}/warc/{host}/{CRAWLTARGET}.warc.gz')
elif ONLY_PREPROCESS:
    OUTPUT = expand('{datadir}/preprocess/{domain}/{pproc}/{lang}/{pproc_file}', datadir=DATADIR, domain=TARGET_2_WARCS, pproc=PPROC, lang=LANGS, pproc_file=PPROC_FILES+["plain_tokenized.gz", "plain_sentences.gz"])
else:
    OUTPUT = expand('{permanent}/{lang1}-{lang2}.{output_file}.xz', permanent=PERMANENT, target=TARGETS, lang1=LANG1, lang2=LANG2, output_file=OUTPUT_FILES)


rule all:
    input: OUTPUT

#################################################################
### CRAWLING ####################################################
rule creepy_download:
    params: url="http://{target}", folder=f"{DATADIR}/warc/{{target}}"
    output: f'{DATADIR}/warc/{{target}}/creepy.warc.gz'
    shell: '''
        mkdir -p {params.folder} {TMPDIR}
        python3 {BITEXTOR}/bitextor-creepy.py {TLD_CRAWL} {CRAWLSIZELIMIT} {CRAWLTIMELIMIT} {CRAWLWAIT} {CRAWLJOBS} {CRAWLTIMEOUT} {CRAWLDUMPARGS} {CONTINUECRAWL} {USERAGENT} {params.url} > {output}
        '''

rule httrack_download:
    params: url="http://{target}", folder=f"{DATADIR}/warc/{{target}}"
    output: f'{DATADIR}/warc/{{target}}/httrack.warc.gz'
    shell: '''
        mkdir -p {params.folder} {TMPDIR}
        echo hostname=$HOSTNAME
        DIRNAME=$(mktemp -d {TMPDIR}/downloaded.{wildcards.target}.XXXXXX)
        {BITEXTOR}/bitextor-httrack.py --url {params.url} --output-path $DIRNAME {CRAWLTIMELIMIT} {CRAWLPAGELIMIT} {USERAGENT} {CRAWLWAIT}
        {BITEXTOR}/bitextor-webdir2warc.sh $DIRNAME > {output}
        rm -rf $DIRNAME
        '''

rule wget_download:
    params: url="http://{target}", folder=f"{DATADIR}/warc/{{target}}"
    output: f'{DATADIR}/warc/{{target}}/wget.warc.gz'
    shell: '''
        mkdir -p {params.folder} {TMPDIR}
        echo hostname=$HOSTNAME
        DIRNAME=$(mktemp -d "{TMPDIR}/downloaded.{wildcards.target}.XXXXXX")
        {BITEXTOR}/bitextor-wget.py --url {params.url} --output-path $DIRNAME {CRAWLTIMELIMIT} {USERAGENT} {CRAWLFILETYPES} {CRAWLWAIT} --warc {output}
        rm -rf $DIRNAME
        '''

rule heritrix_download:
    params: url="http://{target}", folder=f"{DATADIR}/warc/{{target}}"
    output: f'{DATADIR}/warc/{{target}}/heritrix.warc.gz'
    shell: '''
        mkdir -p {params.folder} {TMPDIR}
        echo hostname=$HOSTNAME
        if [ "$(ps aux | grep -i Heritrix | grep -v grep)" == "" ] 
            then {HERITRIXPATH}/bin/heritrix -a {HERITRIXUSER}
        fi
        curl -v -d "action=teardown" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
        curl -v -d "createpath={wildcards.target}&action=create" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine
        DIRNAME=$(mktemp -d "{TMPDIR}/downloaded.{wildcards.target}.XXXXXX")
        cat {BITEXTOR}/crawler-beans.cxml | sed "s@http://example.example/example@{params.url}@g" > $DIRNAME/my-crawler-beans.cxml
        curl -v -T $DIRNAME/my-crawler-beans.cxml -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}/jobdir/crawler-beans.cxml
        curl -v -d "action=build" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
        curl -v -d "action=launch&checkpoint=latest" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
        sleep 2
        curl -v -d "action=unpause" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
        RUNTIME=0
        sleep 15
        while [ -f {HERITRIXPATH}/jobs/{wildcards.target}/latest/warcs/*warc.gz.open ]
        do
            sleep 5
            RUNTIME=$((RUNTIME+5))
            if [ "{CRAWLTIMELIMIT}" != "" ]
            then
                if [ $RUNTIME -gt "{CRAWLTIMELIMIT}" ] 
                then
                    echo "Crawling time limit reached"
                    curl -v -d "action=pause" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
                    curl -v -d "action=checkpoint" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
                    curl -v -d "action=terminate" -k -u {HERITRIXUSER} --anyauth --location {HERITRIXURL}/engine/job/{wildcards.target}
                fi
            fi
        done
        echo "Job {wildcards.target} finished!"
        cat {HERITRIXPATH}/jobs/{wildcards.target}/*/warcs/*warc.gz > {output}
    '''
#################################################################
### PREPROCESS ##################################################
pproc_output = {}
for pproc_file in PPROC_FILES:
    name = pproc_file.split('.')[0]
    for lang in LANGS:
        pproc_output[f"{lang}_{name}"] = f"{DATADIR}/preprocess/{{target}}/{PPROC}/{lang}/{pproc_file}"

rule warc2preprocess:
    input: lambda wildcards: TARGET_2_WARCS[wildcards.target]
    output: **pproc_output
    threads: 2
    params: folder=f'{DATADIR}/preprocess/{{target}}/w2p', pproclangs=",".join(LANGS)
    shell: '''
        mkdir -p {params.folder}
        cat {input} | {BITEXTOR}/bitextor-warc2htmlwarc.py {CLEANHTML} {FTFY} {PDFEXTRACT} --disable-output-gzip | {BITEXTOR}/bitextor-warc2preprocess.py --input - --langs {params.pproclangs} --compression gz --langid {LANGID} {BOILERPIPE} {PARSER} --output-dir {params.folder}
        for lang in {LANGS}; do
            if [ ! -f {params.folder}/$lang/plain_text.gz ]; then
                >&2 echo "WARNING: no \'$lang\' data found in {wildcards.target}. Creating empty files instead"
                mkdir -p {params.folder}/$lang
                touch {params.folder}/$lang/{{plain_text,mime,url,normalized_html,deboilerplate_html}}
                gzip {params.folder}/$lang/{{plain_text,mime,url,normalized_html,deboilerplate_html}}
            fi
        done
    '''

rule giawarc:
    input: lambda wildcards: TARGET_2_WARCS[wildcards.target]
    output: **pproc_output
    params: folder=f'{DATADIR}/preprocess/{{target}}/giawarc'
    threads: 2
    shell: '''
        mkdir -p {params.folder}
        cat {input} | {BITEXTOR}/bitextor-warc2htmlwarc.py {CLEANHTML} {FTFY} {PDFEXTRACT} | ~/go/bin/giawarc -f bilang -l {LANGID} -o {params.folder} -
        for lang in {LANGS}; do
            if [ ! {params.folder}/$lang/plain_text.gz ]; then
                >&2 echo "WARNING: no \'$lang\' data found in {wildcards.target}. Creating empty files instead"
                mkdir -p {params.folder}/$lang
                touch {params.folder}/$lang/{{plain_text,mime,url}}
                gzip {params.folder}/$lang/{{plain_text,mime,url}}
            fi
        done
    '''

# rule shard:
#     # use url.gz as input to avoid having directories as input
#     input: expand("{datadir}/preprocess/{target}/{pproc}/{{lang}}/url.gz", datadir=DATADIR, target=TARGETS, pproc=PPROC)
#     output: expand("{datadir}/preprocess/shards/{{lang}}/{shards}/{batch}/{pproc_file}", datadir=DATADIR, shard=SHARDS, batch=BATCHES, pproc_file=PPROC_FILES)
#     # TODO: defined SHARDS and BATCHES as function of params.n and params.b
#     # definig SHARDS is easy, but what to do with BATCHES?
#     params:
#         n = 8,
#         b = 1024,
#         o = f'{DATADIR}/preprocess/shards/{wildcards.lang}'
#     shell: '''
#         IFS=" " read -a input <<< "{input}"
#         giashard -n {params.n} -b {params.b} -o {params.o} ${{input[@]%/*}}
#         '''

# pproc_rule = rules.warc2preprocess
# if PPROC == "giawarc":
#     pproc_rule = rules.giawarc

rule tokenise:
    input: f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/plain_text.gz'
    # input: lambda wildcards: pproc_rule.output[f"{wildcards.lang}_plain_text"]
    params:
        splitter = lambda wildcards: get_lang_or_default(SENTTOKS, wildcards.lang),
        customnbp = lambda wildcards: get_customnbp(CUSTOMNBPS, wildcards.lang),
        tokeniser = lambda wildcards: get_lang_or_default(WORDTOKS, wildcards.lang),
        lemmatizer = lambda wildcards: get_lang_or_default(MORPHTOKS, wildcards.lang),
    output:
        tok = f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/plain_tokenized.gz',
        sent = f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/plain_sentences.gz'
    shell: '''
        {BITEXTOR}/bitextor-tokenize.py --text {input} --sentence-splitter "{params.splitter}" --word-tokenizer "{params.tokeniser}" --morph-analyser "{params.lemmatizer}" --langcode "{wildcards.lang}" --customnbp "{params.customnbp}" --sentences-output {output.sent} --tokenized-output {output.tok} {PRUNE_THRESHOLD} {PRUNE_TYPE}
        '''
#################################################################
### DOCALIGN ####################################################
# MT ############################################################
rule sentences2extracted:
    input: f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/plain_sentences.gz'
    output: temp(f'{TRANSIENT}/{{target}}/docalign/{LANG1}.extracted.xz')
    params: docalign_folder = f'{TRANSIENT}/{{target}}/docalign'
    shell: '''
        mkdir -p {params.docalign_folder}
        zcat {input} | {BITEXTOR}/document-aligner/utils/extract_lett.py | xz -T 0 -c > {output}
        '''

rule custom_translate:
    input:
        source = rules.sentences2extracted.output,
        target = f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/plain_sentences.gz'
    output: temp(f'{TRANSIENT}/{{target}}/docalign/{LANG1}.customMT.extracted.translated.xz')
    shell: '''
        xzcat -T 0 -f {input.source} \
            | cut -f 2 \
            | {BITEXTOR}/preprocess/bin/cache {MT_COMMAND} \
            | paste <(xzcat -T 0 -f {input.source} | cut -f 1) - \
            | xz -c -T 0 -f > {output}
        '''

rule tokenize_translated:
    input: rules.custom_translate.output
    output: temp(f"{TRANSIENT}/{{target}}/docalign/{LANG1}.customMT.extracted.translated.tokenized")
    shell: '''
        if [ -z "{MORPHTOK2}" ]; then
            xzcat -T 0 -f {input} \
                | cut -f 2 \
                | {WORDTOK2} \
                | awk '{{print tolower($0)}}' \
                | paste <(xzcat -T 0 -f {input} | cut -f 1) - \
                | xz -T 0 -c -f > {output}
        else
            xzcat -T 0 -f {input} \
                | cut -f 2 \
                | {WORDTOK2} \
                | {MORPHTOK2} \
                | awk '{{print tolower($0)}}' \
                | paste <(xzcat -T 0 -f {input} \
                | cut -f 1) - \
                | xz -T 0 -f > {output}
        '''

rule translated2base64:
    input: rules.custom_translate.output
    output: f'{TRANSIENT}/{{target}}/docalign/{LANG1}.translated_sentences.xz'
    shell: "xzcat -T 0 -f {input} | {BITEXTOR}/document-aligner/utils/extracted2base64.py | xz -T 0 -c > {output}"

rule translated_tokenized2base64:
    input: rules.tokenize_translated.output
    output: f'{TRANSIENT}/{{target}}/docalign/{LANG1}.translated_tokenized.xz'
    shell: "xzcat -T 0 -f {input} | {BITEXTOR}/document-aligner/utils/extracted2base64.py | xz -T 0 -c > {output}"

rule mt_matches:
    input:
        l1=rules.tokenize_translated.output,
        l2=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/plain_tokenized.gz'
    output: f'{TRANSIENT}/{{target}}/{LANG1}-{LANG2}.matches'
    shell: "python3 {BITEXTOR}/document-aligner/compute_matches.py --lang1 {input.l1} --lang2 {input.l2} --output-matches {output} --threshold {DOC_THRESHOLD}"
# DIC ###########################################################
# TODO
#################################################################
### SEGALIGN ####################################################
# BLEUALIGN #####################################################
rule bleualign:
    input:
        indices=rules.mt_matches.output,
        plain1=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/plain_sentences.gz',
        plain2=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/plain_sentences.gz',
        url1=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/url.gz',
        url2=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/url.gz',
        translated1=rules.translated2base64.output
    output:
        f'{TRANSIENT}/{{target}}/segalign.xz'
    threads: 2
    shell: '''
        cut -f 2,3 {input.indices} | # assuming indices come from mt-docalign
        LC_ALL=C sort -nk1 | 
        python3 {BITEXTOR}/bitextor-build-docalign.py --columns1 {input.url1} {input.plain1} {input.translated1} --columns2 {input.url2} {input.plain2} |
        awk -F '\t' '{{print $2,$6,$3,$7,$4}} OFS='\t' |
        {BITEXTOR}/bleualign-cpp/bleualign_cpp --bleu-threhsold {BLEU_TRESHOLD} |
        xz -T 0 -c > {output}
        '''
# HUNALIGN ######################################################
# TODO
#################################################################
### FILTERING AND CLEANING ######################################
rule deferred_documents:
    input:
        html=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/normalized_html.gz',
        url=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/url.gz'
    output:
        text=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/html5lib_plain_text.xz',
        deferred=f'{DATADIR}/preprocess/{{target}}/{PPROC}/{{lang}}/deferred_documents.xz'
    shell: '''
        touch {output.text}.touch && xz {output.text}.touch && mv {output.text}.touch.xz {output.text}
        touch {output.deferred}.touch && xz {output.deferred}.touch && mv {output.deferred}.touch.xz {output.deferred}
        paste <(zcat {input.html}) <(zcat {input.url}) \
            | python3 {BITEXTOR}/standoff/deferred-documents.py \
            | awk '{{ print $1 | "xz > {output.text}"; print $3 | "xz > {output.deferred}" }}'
        '''

deferred_input = rules.bleualign.output
# if SEGALIGN == "hunalign":
#     deferred_input = rules.hunalign.output

rule deferred_segments:
    input:
        deferred_input,
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/html5lib_plain_text.xz',
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/url.gz',
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG1}/deferred_documents.xz',
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/html5lib_plain_text.xz',
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/url.gz',
        f'{DATADIR}/preprocess/{{target}}/{PPROC}/{LANG2}/deferred_documents.xz'
    output: temp(f'{TRANSIENT}/{{target}}/deferred')
    shell: '''
        xzcat -T 0 -f {input[0]} \
            | python3 {BITEXTOR}/standoff/deferred-sentences.py <(paste <(xzcat {input[1]} {input[4]}) <(zcat {input[2]} {input[5]}) <(xzcat {input[3]} {input[6]})) \
            > {output}
        '''

bifixer_input = rules.deferred_segments.output
if not DEFERRED:
    bifixer_input = rules.deferred_segments.input[0]

rule bifixer:
    input: f'{TRANSIENT}/{{target}}/segalign.xz'
    output: temp(f'{TRANSIENT}/{{target}}/bifixer')
    shell: '''
        xzcat -T 0 -f {input} \
            | python3 {BITEXTOR}/bifixer/bifixer/bifixer.py -q - - {LANG1} {LANG2} {AGGRESSIVE_DEDUP} \
            | LC_ALL=C sort -t $'\t' -k{BIFIXER_HASH_COLUMN} -k{BIFIXER_SCORE_COLUMN}nr -T {TMPDIR} --compress-program=gzip -n -r \
            > {output}
        '''

bicleaner_input = rules.bifixer.output
if not BIFIXER:
    bicleaner_input = rules.bifixer.input

rule bicleaner:
    input: bifixer=bicleaner_input, model=BICLEANER_MODEL
    output: temp(f'{TRANSIENT}/{{target}}/bicleaner')
    threads: 2
    shell: '''
        CAT=cat; if [[ {input.bifixer} == *.xz ]]; then CAT=xzcat; fi
        slang=$(egrep "source_lang" {input.model} | cut -d " " -f 2)
        if [ "$slang" == "{LANG1}" ]; then
            $CAT {input.bifixer} \
                | {BITEXTOR}/preprocess/bin/cache -k {BICLEANER_CACHE_DEDUP} python3 {BITEXTOR}/bicleaner/bicleaner/bicleaner_classifier_lite.py --score-only -q - - {input.model} \
                | paste <(cat {input.bifixer}) - \
                | python3 {BITEXTOR}/bitextor-filterbicleaner.py --threshold {BICLEANER_THRESHOLD} \
                > {output}
        else
            $CAT {input.bifixer} \
                | awk ' BEGIN {{FS="\t"; OFS="\t"}} {{ t = $3; $3 = $4; $4 = t; print;}} ' \
                | {BITEXTOR}/preprocess/bin/cache -k {BICLEANER_CACHE_DEDUP} python3 {BITEXTOR}/bicleaner/bicleaner/bicleaner_classifier_lite.py --score-only -q - - {input.model} \
                | paste <(cat {input.bifixer}) - \
                | python3 {BITEXTOR}/bitextor-filterbicleaner.py --threshold {BICLEANER_THRESHOLD} \
                > {output}
        fi
        '''

elrc_input = rules.bicleaner.output
if not BICLEANER:
    elrc_input = rules.bicleaner.input

rule elrc:
    input: elrc_input
    output: temp(f'{TRANSIENT}/{{target}}/elrc')
    shell: '''
        CAT=cat; if [[ {input} == *.xz ]]; then CAT=xzcat; fi
        $CAT {input} \
            | {BITEXTOR}/bitextor/elrc/filtering.py -c "{BEFORE_ELRC_FIELDS}" -s \
            | xz -T 0 > {output}
        '''

sents_input = rules.elrc.output
if not ELRC:
    sents_input = rules.elrc.input
sents_input_filename = sents_input[0].split('/')[-1] # 'segaligz.xz'/'bifixer'/'bicleaner'/'elrc'

rule sents:
    input: expand("{transient}/{target}/{filename}", transient=TRANSIENT, target=TARGETS, filename=sents_input_filename)
    output: f'{PERMANENT}/{LANG1}-{LANG2}.sent.xz'
    shell: '''
        CAT=cat; if [[ {input[0]} == *.xz ]]; then CAT=xzcat; fi
        $CAT {input} | xz -T 0 -c > {output}
        '''

rule tmx:
    input: rules.sents.output
    output: f'{PERMANENT}/{LANG1}-{LANG2}.not-deduped.tmx.xz'
    shell: '''
        xzcat -T 0 -f {input} \
            | python3 {BITEXTOR}/bitextor-buildTMX.py --lang1 {LANG1} --lang2 {LANG2} -c {TMX_FIELDS} \
            | xz -T 0 -c > {output}
        '''

rule deduped_tmx:
    input: rules.sents.output
    output:
        tmx=f'{PERMANENT}/{LANG1}-{LANG2}.deduped.tmx.xz',
        txt=f'{PERMANENT}/{LANG1}-{LANG2}.deduped.txt.xz'
    shell: '''
        xzcat -T 0 -f {input} \
            | {BICLEANER_SORT} {BITEXTOR}/bitextor-buildTMX.py --lang1 {LANG1} --lang2 {LANG2} -c {TMX_FIELDS} --dedup "{DEDUP}" -f {output.txt} \
            | xz -T 0 -c > {output.tmx}
        '''
