__author__ = 'pbelmann'

import argparse
import yaml
import os
import sys

class Assembler:
    def __init__(self, **entries):
        self.__dict__.update(entries)


if __name__ == "__main__":

    # Parse arguments
    parser = argparse.ArgumentParser(description='Parses input yaml')
    parser.add_argument('-i', '--input_yaml', dest='i', nargs=1,
                        help='YAML input file')
    parser.add_argument('-o', '--output_path', dest='o', nargs=1,
                        help='Output path')
    args = parser.parse_args()

    # get input files
    input_yaml_path = ""
    output_path = ""
    if hasattr(args, 'i'):
        input_yaml_path = args.i[0]
    if hasattr(args, 'o'):
        output_path = args.o[0]

    #serialize yaml with python object
    f = open(input_yaml_path)
    assembler = Assembler(**yaml.safe_load(f))
    f.close()

    #check yaml
    fastqs = []
    for argument in assembler.arguments:
        if argument.has_key("fastq"):
            fastqs = argument["fastq"]
    if (len(fastqs) == 0):
        raise ValueError("YAML is not in a valid format. Please check the definition on bioboxes.")

    #run ray
    output = output_path + "/ray"
    input_type = ""
    command = "mpiexec -n 8 /opt/bin/Ray "
    for fastq in fastqs:
        if (fastq.get("type") == "paired"):
            input_type = "-i"
        elif (fastq.get("type") == "single"):
            input_type = "-s"
        command = command + input_type + " " + fastq.get(
            "value") + " -k 31 -o " + output

    exit = os.system(command)

    if (exit == 0):
        out_dir = output_path + "/bbx"
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)
        yaml_output = out_dir + "/biobox.yaml"
        output_data = {'version': '0.9.0', 'arguments': [
            {"fasta": [
                {"value": "/ray/Contigs.fasta", "type": "contig" , "id" : "1"},
                {"value": "/ray/Scaffolds.fasta", "type": "scaffold", "id": "2"}]}]}
        stream = open(yaml_output, 'w')
        yaml.dump(output_data, default_flow_style=False, stream=stream)
    else:
        sys.exit(1)
