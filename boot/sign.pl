#!/usr/bin/perl

open(BB, $ARGV[0]) || die "open $ARGV[0]: $!";

binmode BB;
#用binmode读取二进制文件
my $buf;
#定义一个局部变量
read(BB, $buf, 1000);
#读取文件的内容到buf
$n = length($buf);
#buf内容的字节数
if($n > 510){
	print STDERR "boot block too large: $n bytes (max 510)\n";
	exit 1;
}

print STDERR "boot block is $n bytes (max 510)\n";

$buf .= "\0" x (510-$n);
$buf .= "\x55\xAA";

open(BB, ">$ARGV[0]") || die "open >$ARGV[0]: $!";
#里面的>字符表示写。如果文件不存在，就会被创建。如果文件存在，文件被清除清除，
#以前的数据将丢失。你可以写入文件句柄，但不可以读入
#
binmode BB;
print BB $buf;
#将buf的内容输出到文件句柄BB
close BB;
