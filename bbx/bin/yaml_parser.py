__author__ = 'pbelmann'

import argparse
import yaml
import os
import Rx

class Assembler:
    def __init__(self, **entries):
        self.__dict__.update(entries)

if __name__ == "__main__":
    #Parse arguments
    parser = argparse.ArgumentParser(description='Parses input yaml')
    parser.add_argument('-i', '--input_yaml', dest='i', nargs=1,
                        help='YAML input file')
    parser.add_argument('-s', '--schema_yaml', dest='s', nargs=1,
                    help='YAML schema file')
    args = parser.parse_args()

    #get input file
    input_yaml_path = ""
    schema_file = ""
    if hasattr(args, 'i'):
        input_yaml_path = args.i[0]
    if hasattr(args, 's'):
        schema_file = args.s[0]

    #check schema
    data = yaml.load(open(input_yaml_path))
    rx = Rx.Factory({ "register_core_types": True })
    schema = rx.make_schema(yaml.load(open(schema_file)))

    if not schema.check(data):
        raise ValueError("YAML is not in a valid format. Please check the definition on bioboxes.")

    #serialize yaml with python object
    f = open(input_yaml_path)
    assembler = Assembler(**yaml.safe_load(f))
    f.close()

    #run ray
    fastq = assembler.arguments["fastq"]
    output = "/bbx/output"
    input_type = ""
    if(fastq[0].get("type") == "paired"):
        input_type = "-i"
    elif(fastq[0].get("type") == "single"):
        input_type = "-s"

    command = "mpiexec -n 8 /opt/bin/Ray " + input_type + " " + fastq[0].get("path") + " -k 31 -o " + output + "/ray"
    os.system(command)
