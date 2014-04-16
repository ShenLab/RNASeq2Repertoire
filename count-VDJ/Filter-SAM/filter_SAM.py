import sys
import os.path
import optparse
import simplejson as json

def main(options, args):
    if len(args) <= 0:
        print("No filename(s) provided. Failing ungracefully.")
        sys.exit(1)

    filenames = get_input_filenames(args, options.index)
    location  = { "chrom": (options.chrom if options.chrom else None),
                  "min": options.min,
                  "max": options.max }
    if options.config: location = json.load(open(options.config, 'r'))

    match_location = _make_SAM_filter(**location)
    for filename in filenames:
        in_fh, out_fh = open_filehandles(filename,
                                         options.pre,
                                         options.post,
                                         options.output)
        filter_SAM_file(in_fh, out_fh, match_location)
        close_filehandles(in_fh, out_fh)
    return

def _make_SAM_filter(**kwargs):
    chromosome = kwargs.get("chrom", None)
    start_loc  = kwargs.get("min", 0)
    end_loc    = kwargs.get("max", sys.maxint)
    def predicate(sam_line):
        try:
            sam_words = sam_line.split()
            sam_chrom = sam_words[2]
            sam_loc   = int(sam_words[3])

            chrom_match = (chromosome == None) or (sam_chrom == chromosome)
            loc_match = (sam_loc >= start_loc and sam_loc <= end_loc)

            return (chrom_match and loc_match)
        except:
            return False
    return predicate

def filter_SAM_file(in_fh, out_fh, match_location):
    for sam_line in in_fh:
        if match_location(sam_line):
            out_fh.write(sam_line)

def get_input_filenames(filenames, is_index):
    if is_index:
        filenames = [filename.strip()
                     for index_filename in args
                     for filename in open(index_filename)]
    return sorted(filenames)

def open_filehandles(input_filename, pre_suffix, post_suffix, output_dir):
    if input_filename == "-":
        return sys.stdin,sys.stdout

    output_filename = os.path.basename(input_filename)
    output_filename = output_filename[::-1].replace(pre_suffix[::-1],  # Replace first
                                                    post_suffix[::-1], # occurrence from
                                                    1)[::-1]           # the *RHS*!
    output_filename = "{0}/{1}".format(output_dir,
                                       output_filename)

    in_fh  = open(input_filename, 'r')
    out_fh = open(output_filename, 'w')
    return in_fh,out_fh

def close_filehandles(in_fh, out_fh):
    if not in_fh  == sys.stdin:  in_fh.close()
    if not out_fh == sys.stdout: out_fh.close()

def build_option_parser():
    parser = optparse.OptionParser(
        version="%prog 1.0",
        usage="usage: %prog [options] filename [filenames]",
        description="Filter SAM files to genomic region. \"-\" to use as pipe utility.",
        epilog="Andy's free (as in beer, not speech) software!"
        )

    io_options = optparse.OptionGroup(parser, "I/O options")
    io_options.add_option("--pre", type="string", metavar="STR", default=".sam",
                          help="suffix to overwrite in input filenames (dflt: \".sam\")")
    io_options.add_option("--post", type="string", metavar="STR", default=".hits.sam",
                          help="append to output filenames (dflt: \".hits.sam\")")
    io_options.add_option("--output", type="string", metavar="DIR", default=".",
                          help="directory for writing output files (dflt: \".\")")
    parser.add_option_group(io_options)

    filter_options = optparse.OptionGroup(parser, "filter options")
    filter_options.add_option("--chrom", type="string", metavar="STR", default="",
                              help="choose chromosome for genomic region")
    filter_options.add_option("--min", type="int", default=-1*sys.maxint-1, metavar="N",
                              help="beginning of the gnomic region to match")
    filter_options.add_option("--max", type="int", default=sys.maxint, metavar="N",
                              help="end of the genomic region to match")
    filter_options.add_option("--config", type="string", default="",
                              action="store", dest="config", metavar="FILE",
                              help="load filter from JSON file w/ chrom, min, max")
    parser.add_option_group(filter_options)

    parsing_options = optparse.OptionGroup(parser, "parsing options")
    parsing_options.add_option("--format", type="choice",
                               choices=["sam"], default="sam", metavar="{sam}",
                               help="file format \"sam\" (\"bam\" not supported!)")
    parsing_options.add_option("--index", action="store_true", default=False,
                               help="*index* files i.e. each line is an input filename")
    parser.add_option_group(parsing_options)

    return parser

if __name__ == "__main__":
    parser = build_option_parser()
    (options, args) = parser.parse_args()
    main(options, args)
