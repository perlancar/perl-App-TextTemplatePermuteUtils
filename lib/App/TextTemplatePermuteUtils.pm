package App::TextTemplatePermuteUtils;

use 5.010001;
use strict;
use warnings;

#use File::Slurper qw(read_text);
use List::Util ();
use Text::Template::Permute;

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

$SPEC{template_permute} = {
    v => 1.1,
    summary => 'Process a Text::Template::Permute template and output the results',
    args => {
        template => {
            summary => 'The template string',
            schema => 'str*',
            pos => 0,
            cmdline_src => 'stdin_or_file',
        },
        array => {
            summary => 'Return items as array, not as a single string',
            schema => 'bool*',
            cmdline_aliases => {a => {}},
        },
        clipboard => {
            summary => 'Add items to clipboard',
            schema => ['str*', in=>['tee','only']],
            cmdline_aliases => {
                Y => {is_flag=>1, summary=>'Shortcut for --clipboard=tee', code=>sub { $_[0]{clipboard} = 'tee' }},
                y => {is_flag=>1, summary=>'Shortcut for --clipboard=only', code=>sub { $_[0]{clipboard} = 'only' }},
            },
        },
        items => {
            summary => 'Only return this many items',
            schema => 'posint*',
            cmdline_aliases => {n => {}},
        },
        shuffle => {
            summary => 'Shuffle/randomize order or results',
            schema => 'bool*',
            cmdline_aliases => {r => {}},
        },
        separator => {
            summary => 'String to add as separator between items (only when not specifying --array)',
            schema => 'str*',
            cmdline_aliases => {s => {}},
        },
    },
};
sub template_permute {
    my %args = @_;

    my $clipboard = $args{clipboard} // '';

    my $template = $args{template};
    my $ttp = Text::Template::Permute->new;
    $ttp->template($template);
    my @res = $ttp->process;

    if ($args{shuffle}) {
        @res = List::Util::shuffle(@res);
    }
    if ($args{items} && $args{items} < @res) {
        splice @res, $args{items};
    }

    unless ($args{array}) {
        my $separator = $args{separator} // '';
        $separator .= "\n" unless $separator =~ /\R\z/;
        my $res = join $separator, @res;
        @res = ($res);
    }

    if ($clipboard) {
        require Clipboard::Any;
        for my $content (@res) {
            Clipboard::Any::add_clipboard_content(content => $content);
        }
    }

    if ($clipboard eq 'only') {
        [200, "OK"];
    } elsif ($args{array}) {
        [200, "OK", \@res];
    } else {
        [200, "OK", $res[0]];
    }
}

1;
#ABSTRACT: CLI utilities related to Text::Template::Permute

=head1 DESCRIPTION

This distributions provides the following command-line utilities related to
text fragment:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<Text::Template::Permute>
