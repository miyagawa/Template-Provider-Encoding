package Template::Provider::Encoding;

use strict;
our $VERSION = '0.06';

use base qw( Template::Provider );
use Encode;

sub _load {
    my $self = shift;
    my($data, $error) = $self->SUPER::_load(@_);

    unless (Encode::is_utf8($data->{text})) {
        my $encoding = $data->{text} =~ /^\[% USE encoding '([\w\-]+)'/
            ? $1 : 'utf-8';
        $data->{text} = Encode::decode($encoding, $data->{text});
    }

    return ($data, $error);
}

1;
__END__

=head1 NAME

Template::Provider::Encoding - Explicitly declare encodings of your templates

=head1 SYNOPSIS

  use Template::Provider::Encoding;
  use Template::Stash::ForceUTF8;
  use Template;

  my $tt = Template->new(
      LOAD_TEMPLATES => [ Template::Provider::Encoding->new ],
      STASH => Template::Stash::ForceUTF8->new,
  );

  # Everything should be Unicode
  # (but you can pass UTF-8 bytes as well, thanks to Template::Stash::ForceUTF8)
  my $author = "\x{5bae}\x{5ddd}";

  # this will emit Unicode flagged string to STDOUT. You might
  # probably want to binmode(STDOUT, ":encoding($enccoding)")
  # before process() call
  $tt->process($template, { author => $author });

  # in your templates
  [% USE encoding 'utf-8' -%]
  My name is [% author %]. { ... whatever UTF-8 bytes }

=head1 DESCRIPTION

Template::Provider::Encoding is a Template Provider subclass to decode
template using its declaration. You have to declare encoding of the
template in the head (1st line) of template using (fake) encoding TT
plugin. Otherwise the template is handled as utf-8.

  [% USE encoding 'utf-8' %]
  Here comes utf-8 strings with [% variable %].

=head1 DIFFERNCE WITH OTHER WAYS

=head2 UNICODE option and BOM

Recent TT allows C<UNICODE> option to Template::Provider and by adding
it Provider scans BOM (byte-order mark) to detect UTF-8/UTF-16 encoded
template files. This module does basically the same thing in a
different way, but IMHO adding BOM to template files is a little
painful especially for non-programmers.

=head2 Template::Provider::Encode

L<Template::Provider::Encode> provides a very similar way to detect
Template file encodings and output the template into various
encodings.

This module doesn't touch output encoding of the template and instead
it emits valid Unicode flagged string. I think the output encoding
conversion should be done by other piece of code, especially in the
framework.

This module doesn't require you to specify encoding in the code, nor
doesn't I<guess> encodings. Instead it forces you to put C<< [% USE
encoding 'foo-bar' %] >> in the top of template files, which is
explicit and, I think, is a good convention.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Stash::ForceUTF8>, L<Template::Provider::Encode>

=cut
