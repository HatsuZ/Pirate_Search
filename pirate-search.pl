#!/usr/bin/perl
use Term::ANSIColor;
use LWP::UserAgent;
use warnings;
use Config;
use strict;

sub clear {
  if($Config{osname} =~ /win/i){
    system("cls");
  }else{
    system("clear");
  }
}

sub banner {
print <<HERE;
\n
\t/\     PIRATE SEARCH v1.0
\t||_____-----_____-----_____
\t||   O                  O  \\
\t||    O\\\\    ___    //O    /
\t||       \\\\ /   \\//        \\
\t||         |_O O_|         /
\t||          ^ | ^          \\
\t||        // UUU \\\\        /
\t||    O//            \\\\O   \\
\t||   O                  O  /
\t||_____-----_____-----_____\\
\t||
\t||.
\n\n
HERE
}

clear();
banner();

my ($url, $agent, $qntd, $loop, $search, $results) = undef;
print color("RED"),"[!]",color("reset") . " Digite sua pesquisa: ";
chomp($search = <STDIN>);
while(!$search){
  clear();
  banner();
  print color("RED"),"[!]",color("reset") . " Digite sua pesquisa: ";
  chomp($search = <STDIN>);
}
print color("RED"),"[!]",color("reset") . " Digite a quantidade de resultados: ";
chomp($results = <STDIN>);
while(!$results){
  clear();
  banner();
  print color("RED"),"[!]",color("reset") . " Digite a quantidade de resultados: ";
  chomp($results = <STDIN>);
}
print "\n";
$search =~ s/ /\%20/;
$agent = LWP::UserAgent->new;
$agent->agent("Mozilla/5.0");
$url = "https://thepiratebay.org/search/$search";

my $response = $agent->get($url);
open(SEARCH, ">", "search.txt");
no warnings;
print SEARCH $response->decoded_content;
use warnings;
close(SEARCH);
open(SEARCH, "<", "search.txt");
$loop = 0;
while(<SEARCH>){
  if($loop == $results){
    last;
  }
  if($_ =~ /<a href="\/torrent\/(.*?)\/(.*?)"(.*?)>(.*?)<\/a>/i){
    print color("GREEN"),"Titulo",color("reset") . ": $4";
  }
  if($_ =~ /<font class="detDesc">(.*?)(\d+)&nbsp;(KiB|MiB|GiB)(.*?)<(.*?)/i){
    print color("GREEN")," Tamanho",color("reset") . ": $2$3\n";
	$loop++;
  }
}
close(SEARCH);
unlink "search.txt";
