#iotop
#Copyright (C) 2013.4.6  archcel

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;

while(1){
    opendir my $DIR , '/proc' or die "can't open the directory:$!\n";
    my @names = readdir $DIR or "can't read dir:$!\n";
    my @names_num;
    foreach (@names){
        if($_ =~ /\d+/){
            push(@names_num, $_);
        }
    }
    close $DIR;

    my $want_to_sort = {};


    for(my $i = 0; $i < 2; $i++){
        foreach my $pro (@names_num){
            my $f;
            if(-e "/proc/$pro/io"){
                open $f, "/proc/$pro/io" or die "can't open file:$!\n";
            }else{
                next;
            }
            my $count = 0;
            while(<$f>){
                my @tmp = split(":", $_);
                $tmp[1] =~ s/^\s+|\s+$//g;
                $tmp[1] = $tmp[1] / 1024.;
                $want_to_sort->{$pro}[$count] = $tmp[1] - $want_to_sort->{$pro}[$count];
                $count++;
                if($count > 1){
                    last;
                }
            }
            close $f;
        }
        if($i == 0){
            sleep(3);
        }
    }

#find top 10

    my %want_to_sort_w = %$want_to_sort;
    print "PID        READIO(KB)\n";
    for(my $i=0; $i < 11; ++$i){
        my $pid_r;
        my $read_io = 0;
        while(my ($key, $value) = each(%$want_to_sort)){
            if($value->[0] > $read_io){
                $read_io = $value->[0];
                $pid_r = $key;
            } 
        }
        delete $want_to_sort->{$pid_r};
        if($pid_r){
            print $pid_r, "        ", $read_io, "\n";
        }
    }
    print "************************\n";
    print "PID        WRITEIO(KB)\n";
    for(my $i=0; $i < 11; ++$i){
        my $pid_w;
        my $write_io = 0;
        while(my ($key, $value) = each(%want_to_sort_w)){
            if($value->[1] > $write_io){
                $write_io = $value->[1];
                $pid_w = $key;
            }
        }
        delete $want_to_sort_w{$pid_w};
        if($pid_w){
            print $pid_w, "        ", $write_io, "\n";
        }
    }
    print "\n";
}
