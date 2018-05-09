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

immutable vernum="3.0.2";


int main(string[] args) {
    import std.getopt;

    string[] filePaths;
    string   xorString;
    string   outPath;

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
            writeln(vernum);
            return 0;
        }
        if (args.length == 1) {
            write(helpMsg);
            return 1;
        }
    } catch (GetOptException ex) {
        stderr.write(helpMsg);
        return 1;
    }

    auto files = args[1..$].map!(p => File(p)).array;

    auto limit = files.map!(f => f.size).fold!max;

    immutable bufsize = 32768;

    ubyte[bufsize] inBuffer;
    ubyte[bufsize] outBuffer;

    File outFile = stdout;

    if (outPath != "-" && outPath != "")
        outFile = File(outPath, "w");

    ulong written;
    while (written < limit) {
        if (xorString && xorString != "") {
            for (size_t i=0 ; i<bufsize ; i++)
                outBuffer[i] = xorString[i % xorString.length];
        }
        else {
            outBuffer[] = 0;
        }

        foreach (file ; files) {
            auto read = file.rawRead(inBuffer).length;

            for (size_t i=0 ; i<read ; i++)
                outBuffer[i] ^= inBuffer[i];
        }

        auto toWrite = outBuffer[0 .. min(bufsize, limit-written)];
        outFile.rawWrite(toWrite);
        written += toWrite.length;
    }
    return 0;
}
