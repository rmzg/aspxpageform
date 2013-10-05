package MojoX::ASPXPageForm;
use 5.006;
use strict;
use warnings FATAL => 'all';

use Mojo::Base -base;

use Mojo::UserAgent;

has 'ua' => sub { Mojo::UserAgent->new };

has 'start_url';
has 'start_tx';
has 'dom';
has 'form_eles';
has 'form';

sub form_url {
	my( $self ) = @_;

	return Mojo::URL->new( $self->form->{action} )->to_abs( Mojo::URL->new( $self->start_url ) ) 
}

sub new { 
	my( $class, $url ) = @_;

	my $self = bless {}, $class;
	$self->start_url( $url );


	my $tx = $self->ua->get( $url );
	$self->start_tx( $tx );

	unless( $tx->success ) { 
		die "Error [$url]: ", (join " ", $tx->error), "\n";
	}

	$self->dom( $tx->res->dom );

	$self->form( $tx->res->dom->at("form[name=aspnetForm]") );

	$self->form_eles( {  @{ $self->form->find('input')->map(sub{ $_->{name}, $_ }) }  } );

	return $self;
}

sub build_submit_data {
	my( $self, $extra_data ) = @_;

	my %submit_data;

	for my $ele ( values %{ $self->form_eles } ) { 
		$submit_data{ $ele->{name} } = $ele->{value} unless lc $ele->{type} eq 'submit';
	}

	if( $extra_data ) { 
		for( keys %$extra_data ) { $submit_data{ $_ } = $extra_data->{$_} }
	}

	return \%submit_data;
}

sub submit_form {
	my( $self, $submit_data ) = @_;

	my $tx = $self->ua->build_tx( POST => $self->form_url => form => $submit_data );

	my $form_tx = $self->ua->start( $tx );

	#print $form_tx->req->to_string, "\n";

	return $form_tx;
}

sub click {
	my( $self, $name, $extra_data ) = @_;

	my $submit_data = $self->build_submit_data( $extra_data );
	
	if( $self->form_eles->{$name} ) {
		$submit_data->{ $name } = $self->form_eles->{$name}->{value};
	}
	else {
		die "Failed to find input element [$name]\n";
	}

	return $self->submit_form( $submit_data );

}

sub submit_button_names {
	my( $self ) = @_;

	return map $_->{name}, grep lc $_->{type} eq 'submit', values %{ $self->form_eles };
}

1;


1; # End of MojoX::ASPXPageForm

__END__

=head1 NAME

MojoX::ASPXPageForm - The great new MojoX::ASPXPageForm!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MojoX::ASPXPageForm;

    my $foo = MojoX::ASPXPageForm->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

sub function1 {
}

=head2 function2

sub function2 {
}

=head1 AUTHOR

Robert Grimes, C<< <rmzgrimes at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojox-aspxpageform at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MojoX-ASPXPageForm>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MojoX::ASPXPageForm


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MojoX-ASPXPageForm>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MojoX-ASPXPageForm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MojoX-ASPXPageForm>

=item * Search CPAN

L<http://search.cpan.org/dist/MojoX-ASPXPageForm/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Robert Grimes.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

