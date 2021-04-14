#!/usr/bin/perl -w
use LWP::UserAgent 'get', 'agent', 'decoded_content';
use Term::ANSIColor;
use strict;

# LEMBRAR: Colocar todos os resultados da busca em um arquivo de texto, e mostrar os resultados caso o usuário queira.
# LEMBRAR: Adicionar expressoes regulares para formatar os resultados de acordo com o usuário.
# Version: 0.2 BETA | Coded by: HatsuZ [BR]
# Update history: 
# [!] Date format => DD/MM/YYYY
# 14/09/2018:
#   Optimized program
# 03/02/2019:
#   Lib 'Config' removed.
#   Optimized code
# [!] Please, If my program has a english error, contact me. [!]

system('clear');
if(abs($?) != $?){
  system('cls');
}

&_print('RED', "\tPirate Search 0.2\n");

print <<HERE;
             ___          
            /   \\\\        
       /\\\\ | . . \\\\       
     ////\\\\|     ||       
   ////   \\\\ ___//\\       
  ///      \\\\      \\      
 ///       |\\\\      \\     
///        | \\\\  \\   \\    
/          |  \\\\  \\   \\   
           |   \\\\ /   /   
           |    \\/   /    
           |     \\\\/|     
           |      \\\\|     
           |       \\\\     
           |        |     
           |________|\n
HERE

my (@qnt, $var, $agent, $response);

&_print('RED', '[!]') and print " Enter your search: "; chomp($var = <STDIN>);
&_error($var);

&_print('YELLOW', '[!]') and print " Searching...\n";
$var =~ s/\s/\%20/;
$agent = LWP::UserAgent->new;
$agent->agent('Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:2.0) Treco/20110515 Fireweb Navigator/2.4');
$response = $agent->get("https://thepiratebay.org/search/$var/0/99/0");

unless($response->decoded_content !~ m/No hits\./i){
  &_print('RED', '[!]') and print " No results.\n";
  exit 0;
}

&_print('RED', '[!]') and print " Enter the quantity of max results: "; chomp($var = <STDIN>);
&_error($var);

open(WRITE_HTML, '>:encoding(UTF-8)', 'html.txt'); print WRITE_HTML $response->decoded_content; close(WRITE_HTML);

open(READ_HTML, '<:encoding(UTF-8)', 'html.txt'); flock(READ_HTML, 1);

print "\n";

while(<READ_HTML>){
  last if $var - 1 <= $#qnt;
  if($_ =~ m/<a href=("|')\/torrent\/(.+)\/(.+)("|')(.+)>(.+)<\/a>/i){
    push(@qnt, "https://www.thepiratebay.org/torrent/$2/$3");
    print $#qnt + 1 . ' - ' and &_print('GREEN', 'Title') and print ": $6\n";
    $var++;
  }
  if($_ =~ m/<font class=("|')detDesc("|')>(.*?)(\d+\.\d+|\d+)&nbsp;(B|KiB|MiB|GiB|TiB)(.*?)/i){
    print "Size: $4 $5 ";
  }
  if($_ =~ m/<a class=("|')detDesc("|') href=("|')\/user\/(.+)\/("|')/i){
    print "/ Uploader: $4\n";
    $var--;
  }elsif($_ =~ m/<i>Anonymous<\/i>/i){
    print "/ Uploader: Anonymous\n";
    $var--;
  }
}

close(READ_HTML); unlink 'html.txt';

&_print('RED', "\n[!]") and print " See some title ? (y|N): ";
chomp($var = <STDIN>); exit 0 unless $var;

if($var =~ /y/i){
  &_print('RED', '[!]') and print ' Enter the number (ENTER for exit): ';
  chomp($var = <STDIN>); exit 0 unless $var;
  $response = $agent->get($qnt[$var - 1]);
  if($response->decoded_content =~ m/<a(.*?)href="magnet(.*?)"(.*?)>/i){
    &_print('GREEN', "\n[*]") and print " Magnet link: magnet$2\n";
  }
  if($response->decoded_content =~ m/<dd>(\d+)<\/dd>/i){
    &_print('GREEN', '[*]') and print " Seeders: $1\n";
  }
}else{
  exit 0;
}

sub _print {
  print color($_[0]), $_[1], color('reset');
}

sub _error {
  unless($_[0]){
    &_print('RED', '[!]') and print " You didn't enter anything.\n";
    exit 0;
  }
}
