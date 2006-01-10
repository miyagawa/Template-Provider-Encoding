package Template::Provider::Encoding;

use strict;
our $VERSION = '0.01';

use base qw( Template::Provider );
use Encode;

sub new {
    my $class = shift;
    my $options = shift || {};

    my $self = $class->SUPER::new($options);
    $self->{__no_unicode} = delete $options->{no_unicode};
    $self;
}

sub _load {
    my $self = shift;
    my($data, $error) = $self->SUPER::_load(@_);

    my $encoding = $data->{text} =~ /^\[% USE encoding '([\w\-]+)'/
        ? $1 : 'utf-8';

    if ($self->{__no_unicode}) {
        if ($encoding !~ /^utf-?8$/i) {
            Encode::from_to($data->{text}, $encoding => 'utf-8');
        }
    } else {
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
  use Template;

  my $tt = Template->new(
      LOAD_TEMPLATES => [ Template::Provider::Encoding->new ],
  );

  # By default, everything should be Unicode
  my $author = "\x{5bae}\x{5ddd}";

  # this will emit Unicode flagged string to STDOUT. You might
  # probably want to binmode(STDOUT, ":encoding($enccoding)")
  # before process() call
  $tt->process($template, { author => $author });

  # in your templates
  [% USE encoding 'shift_jis' -%]
  My name is [% author %]. { ... whatever Shift_JIS bytes }

  # ----------------------------------------------------------------

  # If you don't like Unicode flag at all:
  my $tt = Template->new(
      LOAD_TEMPLATES => [ Template::Provider::Encoding->new({ no_unicode => 1 }) ],
  );

  # name in UTF-8 bytes
  my $author = "\xe5\xae\xae\xe5\xb7\x9d";

  # this will emit UTF-8 bytes, not Unicode string
  $tt->process($template, { author => $author });

=head1 DESCRIPTION

Template::Provider::Encoding is a Template Provider subclass to decode
template using its declaration. You have to declare encoding of the
template in the head (1st line) of template using (fake) encoding TT
plugin. Otherwise the template is handled as utf-8.

  [% USE encoding 'utf-8' %]
  Here comes utf-8 strings with [% variable %].

=head1 OPTIONS

Template::Provider::Encoding C<new> method takes following options.

=over 4

=item no_unicode

By default, Template::Provider::Encoding assumes everything is Unicode
and utf-8 flagged. This is the right thing (TM) but reality might not
allow it, when your app talks with various data source and use some
nasty CPAN modules that doen't care UTF-8 flags. In that case you'd
want to add C<no_unicode> option to Template::Provider::Encoding
C<new>, in which case the module handles everything in UTF-8 with no
Unicode flags.

=back

=head1 DIFFERNCE WITH ENCODE PROVIDER

So what's the difference between L<Template::Provider::Encode> and
this module?

This module doesn't touch output encoding of the template and instead
it emits valid Unicode flagged string (or UTF-8 bytes in no-unicode
mode). I think the output encoding conversion should be done by other
piece of code, especially in the framework.

This module doesn't require you to specify encoding in the code, nor
doesn't I<guess> encodings. Instead it forces you to put C<< [% USE
encoding 'foo-bar' %] >> in the top of template files, which is
explicit and, I think, is a good convention.

When you encode template files in UTF-8 and handle all the variables
in UTF-8 bytes (not UTF-8 flagged) on perl level, this module's
C<no_unicode> mode does just the same thing and you don't have to use
this module.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Template::Provider::Encode>

=cut
