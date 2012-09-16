#!/usr/bin/perl -W

# Quill: LaTeX for Authors
#    Copyright 2012 Matt Conway

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# defaults
%opts = (
    chapter => 'chapter', # the LaTeX section command to use
    nodollar => 0,
);

foreach (@ARGV) {
    if ($_ eq '--no-dollar') {
        $opts{'nodollar'} = 1;
    }
    elsif ($_ =~ /--chapter=.*/) {
        # get the command
        $_ =~ s/(--chapter=)([a-zA-Z\*])/$2/;
        $opts{'chapter'} = $_;
    }
}

while ($line = <STDIN>) {
    if ($line =~ /:noquill\W*$/) {
        $line =~ s/:noquill\W*$//g;
        print $line;
        next;
    }

    # start italics whitespace then _char
    $line =~ s/(^|-|[[:space:]])(_)([[:alnum:][:punct:]])/$1\\emph \{$3/g;

    # end italics (actually, one can end bold with char_ or char*)
    $line =~ s/([[:alnum:][:punct:]])(_)($|-|[[:space:]])/$1\}$3/g;

    # start bold
    $line =~ s/(^|-|[[:space:]])(\*)([[:alnum:][:punct:]])/$1\\textbf \{$3/g;

    # end bold
    $line =~ s/([[:alnum:][:punct:]])(\*)($|-|[[:space:]])/$1\}$3/g;

    # smart double quotes
    $line =~ s/(^|-|[[:space:]])(")([[:alnum:]])/$1``$3/g;
    $line =~ s/([[:print:]])(")($|-|[[:space:]])/$1\''$3/g;
    
    # smart left single quote (right/apostrophe already smart in LaTeX)
    $line =~ s/(^|-|[[:space:]])(')([[:alnum:]])/$1`$3/g;
    
    # 100% should not be a LaTeX comment
    $line =~ s/([[:digit:]])(%)/$1\\%/g;

    # don't make $10 a formula, unless it is supposed to be :)
    if (!$opts{'nodollar'}) {
        # If this line contains formulae starting with $<number>, 
        # don't replace $<number> with \$<number>
        if (!($line =~ /(\$[0-9].*\$)([^0-9]|$)/)) {
            # otherwise, replace $number with \$number
            $line =~ s/(\$)([0-9])/\\\$$2/g;
        }
    }

    # chapters
    if ($line =~ /^####*.*/) {
        $line =~ s/(^####*\W?)(.*)/$2/;
        chomp($line);
        $line = '\\' . $opts{'chapter'} . ' {' . $line . '}';
    }            
    
    # phew
    print $line;
}




