#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use Plack::Runner;
use Plack::Middleware::Static;
use Text::MultiMarkdown qw/markdown/;
use File::Spec;
use Data::Section::Simple qw/get_data_section/;

my $filename = delete $ARGV[0] or die '$ARGV[0] needs markdown file!';
my $app = sub {
    my $env  = shift;
    my $file = File::Spec->catfile($filename);

    my $html = do {
        local $/;
        open my $fh, "<", $file;
        markdown(<$fh>);
    };
    my $head = get_data_section('head.html');
    $head =~ s{\@TITLE\@}{$file};
    my $foot = get_data_section('foot.html');
    $html = $head . $html . $foot;
    [ 200, [ "Content-Type" => 'text/html; charset=utf-8' ], [$html] ];
};

$app = Plack::Middleware::Static->wrap(
    $app,
    path => qw/(\.jpg|\.png|\.gif)$/,
    root => './'
);

my $runner = Plack::Runner->new;
$runner->parse_options(@ARGV);
$runner->run($app);

__DATA__

@@ head.html
<html>
<head><title>@TITLE@</title></head>
<style type="text/css">
*{ margin:0; padding:0; font-family: arial,sans-serif; }
body{ margin: 0 auto; width: 920px; padding: 0 0 30px; font-size: 14px; line-height: 23px; overflow-y: scroll; }
a{ color: #4183C4; text-decoration: none; }
header {margin: 15px 0 15px;}
header nav{text-align: center;}
article{padding: .7em;border: 1px solid #E9E9E9;background-color: #F8F8F8;}
article h1,article h2,article h3,article h4,article h5,article h6{border:0!important;}
article h1{font-size:170%!important;border-top:4px solid #aaa!important;padding-top:.5em!important;margin-top:1.5em!important;}
article h1:first-child{margin-top:0!important;padding-top:.25em!important;border-top:none!important;}
article h2{font-size:150%!important;margin-top:1.5em!important;border-top:4px solid #e0e0e0!important;padding-top:.5em!important;}
article h3{margin-top:1em!important;}
article hr{border:1px solid #ddd;}
article p{margin:1em 0!important;line-height:1.5em!important;}
article a.absent{color:#a00;}
article ul{margin:1em 0 1em 2em!important;}
article ol{margin:1em 0 1em 2em!important;}
article ul li{margin-top:.5em;margin-bottom:.5em;}
article ul ul,article ul ol,article ol ol,article ol ul{margin-top:0!important;margin-bottom:0!important;}
article blockquote{margin:1em 0!important;border-left:5px solid #ddd!important;padding-left:.6em!important;color:#555!important;}
article dt{font-weight:bold!important;margin-left:1em!important;}
article dd{margin-left:2em!important;margin-bottom:1em!important;}
article table{margin:1em 0!important;}
article table th{border-bottom:1px solid #bbb!important;padding:.2em 1em!important;}
article table td{border-bottom:1px solid #ddd!important;padding:.2em 1em!important;}
article pre{margin:1em 0;font-size:12px;background-color:#eee;border:1px solid #ddd;padding:5px;line-height:1.5em;color:#444;overflow:auto;-webkit-box-shadow:rgba(0,0,0,0.07) 0 1px 2px inset;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}
article pre::-webkit-scrollbar{height:8px;width:8px;}
article pre::-webkit-scrollbar-track-piece{margin-bottom:10px;background-color:#e5e5e5;border-bottom-left-radius:4px 4px;border-bottom-right-radius:4px 4px;border-top-left-radius:4px 4px;border-top-right-radius:4px 4px;}
article pre::-webkit-scrollbar-thumb:vertical{height:25px;background-color:#ccc;-webkit-border-radius:4px;-webkit-box-shadow:0 1px 1px rgba(255,255,255,1);}
article pre::-webkit-scrollbar-thumb:horizontal{width:25px;background-color:#ccc;-webkit-border-radius:4px;}
article pre code{
    font-family: Monaco, Monospace;
    padding:0!important;font-size:12px!important;background-color:#eee!important;border:none!important;
}
article code{
    font-size:12px!important;background-color:#f8f8ff!important;color:#444!important;padding:0 .2em!important;border:1px solid #dedede!important;
}
article a code,article a:link code,article a:visited code{color:#4183c4!important;}
article img{max-width:100%;}
</style>
<body>
<article>

@@ foot.html
</article>
</body>
</html>