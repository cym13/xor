#!/usr/bin/env rdmd

import std.conv;
import std.range;
import std.stdio;
import std.array;
import std.algorithm;


immutable helpMsg =
"Fast file XOR-ing

Usage: xor [options] FILES...

Arguments:
    FILES   Files to be XOR-ed together.
            Smaller files are padded with NUL bytes.

Options:
    -h, --help          Print this help and exit
    -v, --version       Print the version and exit

    -s, --string STR    XOR against fixed, repeated string
    -o, --output FILE   Write output to FILE ; default: stdout
";

immutable vernum="0.1.0";


int main(string[] args) {
    import std.getopt;

    string[] filePaths;
    string   xorString;
    string   outPath = "-";

    try {
        bool versionWanted;

        auto arguments = getopt(args,
                                std.getopt.config.bundling,
                                std.getopt.config.caseSensitive,
                                "s|string",  &xorString,
                                "o|output",  &outPath,
                                "v|version", &versionWanted);

        if (arguments.helpWanted) {
            write(helpMsg);
            return 0;
        }
        if (versionWanted) {
            write(helpMsg);
            return 0;
        }
    } catch (GetOptException ex) {
        stderr.write(helpMsg);
        return 1;
    }

    if (args.length == 1) {
        write(helpMsg);
        return 1;
    }

    auto files = args[1..$].map!(p => p == "-" ? stdin : File(p))
                           .array;

    auto limit = files.map!(f => f.size).fold!max;

    auto filesContent = files.map!(f => f.byChunk(1)
                                         .joiner
                                         .chain(repeat('\0')));

    auto outBuffer = new char[limit];

    if (xorString && xorString != "")
        outBuffer[] = xorString.repeat.joiner.take(limit).array.to!(char[]);
    else
        outBuffer[] = 0;

    for (ulong i ; i<limit ; i++)
        outBuffer[i] ^= filesContent.frontTransversal
                                    .map!(to!ubyte)
                                    .fold!((a,b) => cast(ubyte)(a^b));

    File outFile = outPath == "-" ? stdout : File(outPath, "w");
    outFile.rawWrite(outBuffer);
    return 0;
}
