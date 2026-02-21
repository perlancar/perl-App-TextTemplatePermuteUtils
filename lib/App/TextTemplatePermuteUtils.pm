package App::TextTemplatePermuteUtils;

use 5.010001;
use strict;
use warnings;

#use File::Slurper qw(read_text);
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
            schema => 'str*',
            pos => 0,
            cmdline_src => 'stdin_or_file',
        },
        array => {
            schema => 'bool*',
            cmdline_aliases => {a=>{}},
        },
        clipboard => {
            schema => ['str*', in=>['tee','only']],
            cmdline_aliases => {
                Y=>{is_flag=>1, summary=>'Shortcut for --clipboard=tee', code=>sub { $_[0]{clipboard} = 'tee' }},
                y=>{is_flag=>1, summary=>'Shortcut for --clipboard=only', code=>sub { $_[0]{clipboard} = 'only' }},
            },
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
        [200, "OK", join("", @res)];
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
