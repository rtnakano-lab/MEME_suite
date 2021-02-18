#!/usr/bin/perl
# originally by YUSUKE KIKUCHI
# https://sites.google.com/site/yusukekikuchiwebsite/memo/mpextract_seq
# modified by Ryohei Thomas Nakano

# 使用方法: $ perl /path/to/MPextract_seq.pl

# スクリプトを"MPextract_seq.pl"という名前で保存してください.
# 検索するパターンを改行区切りテキストファイルで作成しておきます.
# スクリプトを実行します.
# 配列ファイルへのパスを入力します.
# パターンファイルへのパスを入力します.
# 入力したパターンをIDに含む配列を抽出します.
# 結果はout.fastaという名前で出力されます.

$seq_out = undef;
$count   = 0;

#Source file
$path1 = $ARGV[0];
#ID file
$path2 = $ARGV[1];
#Output file
$output = $ARGV[2];


#入力ファイルの読み込み、出力ファイルの作成
open( $fh1, "<$path1" ) or die $!;
open( $fh2, "<$path2" ) or die $!;
open( OUT,  ">$output" );
print OUT $seq_out;
close(OUT);

open( OUT, ">>$output" );

#処理時間の計算
use Time::HiRes qw/gettimeofday tv_interval/;
my $start = [gettimeofday];

####メインルーチンここから####

@pttn_in = <$fh2>;

while (<$fh1>) {
    if (/^>/) {
        if ( $count == 1 ) {                                   #配列のIDにパターンが含まれる場合
            print OUT "$name" . "$seq_in";              #IDと配列を出力
        }
        $seq_in = undef;
        $count  = 0;
        $name   = $_;
        @pttn = @pttn_in;                                      #入力したパターンの読み込み
        
        foreach (@pttn) {
            $pattern = $_;
            $pattern =~ s/(\r\n|\n|\r)$//g;
            if ( $name =~ /$pattern/ ) {                       #配列のIDとパターンが一致した場合
                $count = 1;
            }
        }
    }
    
    #塩基配列を格納
    else {
        if ( $count == 1 ) {
            $seq_in = $seq_in . $_;
        }
    }
}

if ( $count == 1 ) {
    print OUT "$name" . "$seq_in";
}

close($fh1);
close($fh2);
close(OUT);

####メインルーチンここまで####

my $end = [gettimeofday];
print "TIME: ", tv_interval( $start, $end ), "\n";