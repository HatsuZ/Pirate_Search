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
\t/\     PIRATE SEARCH v2.0
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

foreach(glob "*.txt"){
  if($_ eq "torrents.txt"){
    unlink "torrents.txt";
  }
  if($_ eq "search.txt"){
    unlink "search.txt";
  }
  if($_ eq "info.txt"){
    unlink "info.txt";
  }
}

my ($url, $num , $_num, $agent, $qntd, $loop, $search, $results) = undef;
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
$loop = 1;
while(<SEARCH>){
  if($loop == $results + 1){
    last;
  }
  if($_ =~ /<a href="\/torrent\/(.*?)\/(.*?)"(.*?)>(.*?)<\/a>/i){
    open(TORRENTS, ">>", "torrents.txt");
	print TORRENTS "https://www.thepiratebay.org/torrent/$1/$2\n";
	close(TORRENTS);
    print "$loop - " . color("GREEN"),"Titulo",color("reset") . ": $4";
  }
  if($_ =~ /<font class="detDesc">(.*?)(\d+)&nbsp;(KiB|MiB|GiB)(.*?)<(.*?)/i){
    print color("GREEN")," Tamanho",color("reset") . ": $2$3\n";
	$loop++;
  }
}
if(! -e "torrents.txt"){
  print color("RED"),"[!]",color("reset") . " Nenhum resultado :(\n";
  print color("GREEN"),"\n[*]",color("reset") . " Pirate Search v2.0\n";
  close(SEARCH);
  unlink "search.txt";
  exit;
}
close(SEARCH);
print "\n";
print color("RED"),"[!]",color("reset") . " Ver informacao de algum (y|n): ";
chomp($num = <STDIN>);
while(!$num){
  clear();
  banner();
  print color("RED"),"[!]",color("reset") . " Ver informacao de algum (y|n): ";
  chomp($num = <STDIN>);
}
if($num =~ /y/i){
  print color("RED"),"[!]",color("reset") . " Digite o numero: ";
  chomp($_num = <STDIN>);
  while(!$_num){
    print color("RED"),"[!]",color("reset") . " Digite o numero: ";
    chomp($_num = int(<STDIN>));
  }
  open(TORRENT, "<", "torrents.txt");
  my $new_agent = LWP::UserAgent->new;
  $new_agent->agent("Mozilla/5.0");
  while(<TORRENT>){
    if($. == $_num){
	  my $new_response = $new_agent->get($_);
	  open(INFO, ">", "info.txt");
	  no warnings;
	  print INFO $new_response->decoded_content;
	  use warnings;
	  close(INFO);
	  open(INFO, "<", "info.txt");
	  while(<INFO>){ 
	    if($_ =~ /<a(.*?)href="magnet(.*?)"(.*?)>/i){
	  	  print color("GREEN"),"\n[*]",color("reset") . " Magnet link: magnet$2\n";
		  last;
		}
	  }
	  close(INFO);
	}
  }
  close(TORRENT);
}else{
  print color("GREEN"),"\n[*]",color("reset") . " Pirate Search v2.0\n";
  exit;
}
