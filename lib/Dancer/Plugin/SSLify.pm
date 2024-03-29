#
# This file is part of Dancer-Plugin-SSLify
#
# This software is copyright (c) 2012 by Natal Ngétal.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package Dancer::Plugin::SSLify;
{
  $Dancer::Plugin::SSLify::VERSION = '0.121330';
}

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;

#ABSTRACT: Configure your application to redirect all incoming requests to HTTPS


register sslify => sub {
    hook before => sub {
        my $req = request;
        _redirect_to_ssl($req);
    };
    hook after => sub {
        _set_hsts_header();
    };
};

sub _redirect_to_ssl {
    my $req = shift;

    if ( ! request->secure
        && setting('environment') ne 'development' ) {
        if ( $req->base =~ /http:\/\//
            || $req->header('X-Forwarded-Proto') !~ 'https' ) {
            my $url = 'https://' . $req->host . $req->path;

            return redirect($url);
        }
    }
}

sub _set_hsts_header {
    my $settings    = plugin_setting;
    my $hsts_age    = $settings->{hsts_age} // 31536000;
    my $subdomains  = $settings->{hsts_include_subdomains} // 0;
    my $hsts_policy = "max-age=$hsts_age";

    $hsts_policy .= '; includeSubDomains' if $subdomains;

    header 'Strict-Transport-Security' => $hsts_policy;

    return;
}

register_plugin;

1;


__END__
=pod

=head1 NAME

Dancer::Plugin::SSLify - Configure your application to redirect all incoming requests to HTTPS

=head1 VERSION

version 0.121330

=head1 SYNOPSIS

    use Dancer ':syntax';
    use Dancer::Plugin::SSLify;

    sslify();

    get '/' => sub {
        template index;
    }

=head1 METHODS

=head2 sslify

    sslify();

Redirect all incoming requests to https.

    input: none
    output: none

=encoding UTF-8

=head1 CONFIGURATION

  plugins:
    SSLify:
      hsts_age: 31536000
      hsts_include_subdomains: 0

=head1 CONTRIBUTING

This module is developed on Github at:

L<http://github.com/hobbestigrou/Dancer-Plugin-SSLify>

=head1 ACKNOWLEDGEMENTS

Inspired by flask-sslify developed by Kenneth Reitz

=head1 BUGS

Please report any bugs or feature requests in github.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::SSLify

=head1 SEE ALSO

L<Dancer>

=head1 AUTHOR

Natal Ngétal

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Natal Ngétal.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

