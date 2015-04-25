#!/bin/bash

set -o errexit
set -o nounset

INPUT=/bbx/input/biobox.yaml
OUTPUT_YAML=/bbx/output/bbx
OUTPUT=/bbx/output/ray
TASK=$1

#validate yaml
/bbx/bin/biobox-validator/validate-biobox-file --schema=${VALIDATOR}schema.yaml --input=/bbx/input/biobox.yaml

# Parse the read locations from this file
READS=$(sudo /usr/local/bin/yaml2json < ${INPUT} \
        | jq --raw-output '.arguments[] | select(has("fastq")) | .fastq[].value ')

#get fastq entries
FASTQS=$(sudo /usr/local/bin/yaml2json < ${INPUT} | jq --raw-output '.arguments[] | select(has("fastq")) | [.fastq[] | {value,type}]')

#get length of fastq array
LENGTH=$( echo "$FASTQS" | jq  --raw-output 'length')

TMP_DIR=$(mktemp -d)

FASTQ_TYPE=""

for ((COUNTER=0; COUNTER <$LENGTH; COUNTER++))
do
         FASTQ_GZ=$( echo "$FASTQS" | jq --arg COUNTER "$COUNTER"  --raw-output '.['$COUNTER'].value')
         TYPE=$( echo "$FASTQS" | jq --arg COUNTER "$COUNTER"  --raw-output '.['$COUNTER'].type')
         
         if [ $TYPE == "paired" ]; then 
             FASTQ_TYPE="$FASTQ_TYPE -i $FASTQ_GZ"
         else
             FASTQ_TYPE="$FASTQ_TYPE -s $FASTQ_GZ"
         fi
done

# Run the given task
CMD=$(egrep ^${TASK}: /tasks | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

eval $CMD

mkdir -p $OUTPUT_YAML
cat << EOF > ${OUTPUT_YAML}/biobox.yaml
version: 0.9.0
arguments:
  - fasta:
    - id: 1
      value: /ray/Contigs.fasta
      type: contig
    - id: 2
      value: /ray/Scaffolds.fasta
      type: scaffold
EOF
