Description
===========

Simple and fast XOR-ing utility. This is intended mainly for malware analysis
although it has obvious implications in many other projects related to
cryptography and reversing.

Usage
=====

::

    Usage: xor [options] FILES...

    Arguments:
        FILES   Files to be XOR-ed together.
                Smaller files are padded with NUL bytes.

    Options:
        -h, --help          Print this help and exit
        -v, --version       Print the version and exit

        -s, --string STR    XOR against fixed, repeated string
        -o, --output FILE   Write output to FILE ; default: stdout

Dependencies
============

None

License
=======

This program is under the GPLv3 License.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

Author
======

Main developper: Cédric Picard
Email:           cedric.picard@efrei.net
