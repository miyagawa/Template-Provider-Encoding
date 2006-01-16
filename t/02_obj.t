use strict;
use Test::More;

eval { require DateTime; 1 };
if ($@) {
    plan skip_all => 'require DateTime';
} else {
    plan tests => 1;
}

package main;

use Template;
use Template::Stash::ForceUTF8;

my $tt = Template->new({
    STASH => Template::Stash::ForceUTF8->new,
});

my $dt = DateTime->new(year => 2005, month => 9, day => 12);
$tt->process(\<<EOF, { dt => $dt }, \my $out) or die $tt->error;
[% dt.ymd %]
EOF

like $out, qr/2005-09-12/;

