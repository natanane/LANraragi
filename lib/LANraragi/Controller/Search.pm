package LANraragi::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

use LANraragi::Model::Search;

# Undocumented API matching the Datatables spec.
sub handle_datatables {

    my $self = shift;
    my $req  = $self->req;

    my $draw    = $req->param('draw');
    my $start   = $req->param('start');
    my $length  = $req->param('length');

    # Jesus christ what the fuck datatables
    my $filter    = $req->param('search[value]');
    my $sortindex = $req->param('order[0][column]');
    my $sortorder = $req->param('order[0][dir]');
    my $sortkey   = $req->param("columns[$sortindex][name]");

    if ($sortorder && $sortorder eq 'desc') { $sortorder = 1; }
        else { $sortorder = 0; }

    my ($total, $filtered, @ids) = LANraragi::Model::Search::do_search($filter, $start, $sortkey, $sortorder);

    $self->render(
        json => get_datatables_object($draw, $total, $filtered, @ids)
    );

}

# Public search API with saner parameters.
sub handle_api {

    my $self = shift;
    my $req  = $self->req;

    my $filter    = $req->param('filter');
    my $start     = $req->param('start');
    my $sortkey   = $req->param('sortby');
    my $sortorder = $req->param('order');

    if ($sortorder && $sortorder eq 'desc') { $sortorder = 1; }
        else { $sortorder = 0; }

    my ($total, $filtered, @ids) = LANraragi::Model::Search::do_search($filter, $start, $sortkey, $sortorder);

    $self->render(
        json => get_datatables_object(0, $total, $filtered, @ids)
    );

}

# get_datatables_object($draw, $total, $totalsearched, @pagedkeys)
# Creates a Datatables-compatible json from the given data.
sub get_datatables_object {

    my ( $draw, $total, $filtered, @keys ) = @_;

    # Get archive data from keys 
    my @data = ();
    foreach my $key (@keys) {
        push @data, LANraragi::Model::Search::build_archive_JSON($key->{id});
    }

    # Create json object matching the datatables structure
    return {
        draw => $draw,
        recordsTotal => $total,
        recordsFiltered => $filtered,
        data => \@data
    };
}

1;
