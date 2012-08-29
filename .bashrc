gitPrompt() {
    perl -e '
        $_ = `git branch --color=never 2> /dev/null`;
        if ($_) {
            ($branch) = /\* (\w+)/s;
            ($p, $r, $c, $g, $b) = ("\e[35m", "\e[31m", "\e[36m", "\e[32m", "\e[0m");
            $status = `git status --color=never -s 2>&1`;
            if ($status =~ /^fatal/) {
                print "$r [ $branch ]$b";
            } else {
                %h = (" M", 0, " D", 0, "??", 0);
                while ($status =~ /^../gms) {
                    $h{$&}++;
                }
                ($mod, $del, $new) = ($h{" M"} + $h{"M "}, $h{" D"} + $h{"D "}, $h{"??"} + $h{"A "});
                ($in, $de) = `git diff --color=never --shortstat` =~ /\d+\D*(\d+)\D*(\d+)/;
                $diff = $in ? "$in+ $de- " : "";
                print "$p [ $branch $diff$c${mod}m $r${del}d $g${new}n $p]$b";
            }
        }
    '
}

export PS1 PS2
umask 027
export MAIL VIEWER PS1 PS2 CHECKMAIL # just in case
export PS1='\n\e[32m\u@\h \e[33m\w\e[0m$(gitPrompt)\n\$ '
alias ls="ls --color"
alias grepc='grep --color=always'
alias npm='http_proxy= https_proxy= npm'
eval `dircolors`
PATH="$PATH:~csesoc/bin/"
