use strict;
use Test::More 'no_plan';

use Encode;
use Template::Provider::Encoding;
use Template;

my @files = qw( euc-jp.tt utf-8.tt utf-8-wo-encoding.tt );

for my $file (@files) {
    my $tt = Template->new(
        LOAD_TEMPLATES => [ Template::Provider::Encoding->new ],
    );
    my $author = "\x{5bae}\x{5ddd}"; # unicode string
    $tt->process("t/$file", { author => $author }, \my $out) or die $tt->error;

    ok Encode::is_utf8($out), "$file output is utf-8 flagged";
    like $out, qr/\x{5bae}\x{5ddd}/, "$file it includes author name correctly";
    unless ($file =~ /-wo-/) {
        my $encoding = ($file =~ /(.*)\.tt/)[0];
        like $out, qr/encoding=$encoding/, "$file has encoding $encoding";
    }
}

for my $file (@files) {
    my $tt = Template->new(
        LOAD_TEMPLATES => [ Template::Provider::Encoding->new({ no_unicode => 1 }) ],
    );
    my $author = "\xe5\xae\xae\xe5\xb7\x9d"; # utf-8 bytes
    $tt->process("t/$file", { author => $author }, \my $out) or die $tt->error;

    ok !Encode::is_utf8($out), "$file output is not utf-8 flagged";
    my $copy = $out;
    my $decode = Encode::decode("utf-8", $copy, Encode::FB_CROAK);
    ok $decode, "decode it correctly";
    like $out, qr/$author/, "$file it includes author name correctly";
}
