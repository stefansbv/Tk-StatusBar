package Tk::StatusBar;

use strict;
use Tk::Frame;

use base qw(Tk::Frame);
use Tk::widgets qw(Frame Label ProgressBar);

use Carp;

Construct Tk::Widget 'StatusBar';

use vars qw($VERSION);
$VERSION = 0.01;

sub ClassInit {
    my ($class, $mw) = @_;
    $class->SUPER::ClassInit($mw);
}

sub Populate {
    my ($self, $args) = @_;

    $self->SUPER::Populate($args);
    $self->{MW}         = $self->parent;
    $self->{SLOTQTY}    = exists $args->{-slotqty} ? delete $args->{-slotqty} : 1;

    # add a spacer frame
    $self->Frame()->pack(-pady => 1);

    # hidden until show() is called
    $self->{HIDDEN} = 1;

    # show the statusbar
    $self->show();
}

sub addLabel {
    my $self = shift;
    my %args = @_;

    my $width           = delete $args{-width};
    my $side            = delete $args{-side}           || 'left';
    my $relief          = delete $args{-relief}         || 'sunken';
    my $borderwidth     = delete $args{-borderwidth}    || 1;
    my $anchor          = delete $args{-anchor}         || 'w';
    my $expand          = delete $args{-expand}         || 1;
    my $command         = delete $args{-command};
    my $event           = delete $args{-event}          || '<Double-Button-1>';

    if ($command && ref($command) ne 'CODE') {
        croak "-command must be a code reference";
    }

    my $n = $self->Label(
        -relief         => $relief,
        -borderwidth    => $borderwidth,
        -anchor         => $anchor,
        %args,
    );

    if (! $width) {
        $n->pack(
            -side       => $side,
            -expand     => $expand,
            -fill       => 'x',
            -padx       => 1,
        );
    }
    else {
        $n->configure(-width => $width);
        $n->pack(
            -side       => $side,
            -padx       => 1,
        );
    }

    if ($command && $event) {
        eval {$n->bind($event, $command)};
        croak "bad event type, keysym, or command" if $@;
    }

    return $n;
}

sub addProgressBar {
    my $self = shift;
    my %args = @_;

    my $length          = $args{-length};
    my $borderwidth     = delete $args{-borderwidth}        || 1;
    my $expand          = delete $args{-expand}             || 1;
    my $relief          = delete $args{-borderwidth}        || 'sunken';
    my $side            = delete $args{-side}               || 'left';

    my $n = $self->ProgressBar(
        -borderwidth    => $borderwidth,
        -length         => $length,
        -width          => 17,
        -troughcolor    => 'systembuttonface',
        %args,
    );

    if (! $length) {
        $n->pack(
            -side       => $side,
            -expand     => $expand,
            -fill       => 'x',
            -padx       => 1,
        );
    }
    else {
        $n->pack(
            -side       => $side,
            -padx       => 1,
        );
    }

    return $n;
}

sub hide {
    my $self = shift;
    if (! $self->{HIDDEN}) {
        $self->packForget;
        $self->{HIDDEN} = 1;
    }
}

sub show {
    my $self = shift;

    if ($self->{HIDDEN}) {
        my %args = (
            -side       => 'bottom',
            -fill       => 'x',
        );

        if ($self->parent->packSlaves) {
            ($args{-before}) = $self->parent->packSlaves;
        }

        $self->pack(%args);
        $self->{HIDDEN} = 0;
    }
}

1;
__END__

=head1 NAME

Tk::StatusBar - A statusbar widget for Perl/Tk

=for category Tk Widget Classes

=head1 SYNOPSIS

	use Tk;
	use Tk::StatusBar;
	
	my $mw = new MainWindow;
	$mw->geometry("640x480");
	
	my $Label1 = "Welcome to the statusbar";
	my $Label2 = "On";
	my $Progress = 0;
	
	$mw->Entry()->pack(-expand => 1, -fill => 'both');
	
	$sb = $mw->StatusBar();
	
	$sb->addLabel(
	    -relief         => 'flat',
	    -textvariable   => \$Label1
	);
	
	$sb->addLabel(
	    -text           => 'double-click that -->',
	    -width          => '20',
	    -anchor         => 'c',
	);
	
	$sb->addLabel(
	    -width          => 4,
	    -anchor         => 'c',
	    -textvariable   => \$Label2,
	    -foreground     => 'blue',
	    -command        => sub {$Label2 = $Label2 eq 'On' ? 'Off' : 'On';},
	);
	
	$sb->addLabel(
	    -width          => 5,
	    -anchor         => 'c',
	    -textvariable   => \$Progress,
	);
	
	$p = $sb->addProgressBar(
	    -length         => 60,
	    -from           => 0,
	    -to             => 100,
	    -variable       => \$Progress,
	);
	
	$mw->repeat('50', sub {
	    if ($Label2 eq 'On') {
	        $Progress = 0 if (++$Progress > 100);
	    }
	});
	
	MainLoop();

=head1 DESCRIPTION

This module implements a configurable statusbar. The statusbar can be configured
with any number of label sections and progressbar sections.  Each label and/or
progressbar section can be configured and controlled independantly.  The entire
statusbar can be hidden or displayed as needed.

=head1 WIDGET-SPECIFIC OPTIONS

The StatusBar widget can take all of the same arguements allowable by a Tk::Frame.

=head1 WIDGET METHODS

The following methods are used to create widgets that are placed inside
the StatusBar. Widgets are ordered in the same order they are created, left to right.

=over 4

=item I<$sb>-E<gt>B<addLabel>(I<options>)	

B<-width> --
Sets a fixed width for the label.  If no width is specifid, the label will expand
as needed to fill the remainder of the statusbar.  If more than one label section
exists without a fixed width, they will equally share the space of the statusbar.

B<-side> --
Be default, all widgets are packed from the left.  If you would like to alter
the packing order, you can choose to pack an item on the right.  Default is 'left'.

B<-relief> --
Specifies the 3-D effect desired for the widget. Acceptable values are B<raised>,
B<sunken>, B<flat>, B<ridge>, B<solid>, and B<groove>. The value indicates how the
interior of the widget should appear relative to its exterior; for example, raised
means the interior of the widget should appear to protrude from the screen, relative
to the exterior of the widget.  Default is 'sunken'.

B<-borderwidth> --
Specifies a non-negative value indicating the width of the 3-D border to draw around
the outside of the label. The value may have any of the forms acceptable to
Tk_GetPixels.  Default is 1.

B<-anchor> --
Specifies how the text in a label is to be displayed. Must be one of the values B<e>,
B<w>, B<center>. For example, 'center' means display the information such that it is centered
in the label area. Default is 'w'.

B<-command> --
Specifies a perl/Tk callback to associate with the label area. 

B<-event> --
The event associated with the -command.  Any valid event pattern defined in the Tk/bind
man page should be valid.  If no callback is specified by the -command option, this
value is ignored.  Default is '<Double-Button-1>'.

=item I<$sb>-E<gt>B<addProgressBar>(I<options>)

B<-length> --
Specifies the desired narrow dimension of the ProgressBar in screen units (i.e. any of
the forms acceptable to Tk_GetPixels).  If specified, sets a fixed length for the progress
bar.  If no length is specifid, the progress bar will expand as needed to fill the remainder
of the statusbar.  If more than one statusbar section exists without a fixed width, those
sections will equally share the space of the statusbar.

B<-borderwidth> --
Specifies a non-negative value indicating the width of the 3-D border to draw around
the outside of the progress bar. The value may have any of the forms acceptable to
Tk_GetPixels.  Default is 1.

B<-relief> --
Specifies the 3-D effect desired for the widget. Acceptable values are B<raised>,
B<sunken>, B<flat>, B<ridge>, B<solid>, and B<groove>. The value indicates how the
interior of the widget should appear relative to its exterior; for example, raised
means the interior of the widget should appear to protrude from the screen, relative
to the exterior of the widget.  Default is 'sunken'.

B<-side> --
Be default, all widgets are packed from the left.  If you would like to alter
the packing order, you can choose to pack an item on the right.  Default is 'left'.

=item I<$sb>-E<gt>B<Hide>()

Hides the statusbar.

=item I<$sb>-E<gt>B<Show>()

Shows the statusbar if previously hidden.

=back

=head1 TODO

=over 4

=item o Allow icons to be embedded in the status bar.

=item o Improvement this documentation.

=back

=head1 INSTALLATION

	perl Makefile.PL
	make
	make install

=head1 AUTHOR

Shawn Zabel -- zabel@higherprime.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Shawn Zabel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
