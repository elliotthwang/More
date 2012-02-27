#!/usr/bin/env perl
use v5.14;
use utf8;
binmode STDOUT, ":utf8";

use URI;
use XML::Feed;
use IO::All;
use Scalar::Util;
use List::MoreUtils qw(uniq);

sub fetch_news_titles {
    my @titles;

    for my $topic (qw(t y w n b s e c m)) {
        my $uri = URI->new("http://news.google.com.tw/news?topic=${topic}&output=rss");

        my $feed = XML::Feed->parse($uri) or next;
        for my $entry ($feed->entries) {
            my $t = $entry->title =~ s/ - .+?$//r =~ s/[_ ]/，/gr =~ s/$/。/r;

            push @titles, $t;
        }
    }

    return @titles;
}

my @old_titles = io("corpus/news.txt")->assert->utf8->chomp->getlines;
my @new_titles = fetch_news_titles();
my @titles = uniq sort @new_titles, @old_titles;

my $out = io("corpus/news.txt")->utf8;
$out->println($_) for @titles;
