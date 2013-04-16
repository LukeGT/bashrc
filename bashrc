gitPrompt() {
  perl -e '
    $_ = `git branch --color=never 2> /dev/null`;
    if ($_) {
      ($branch) = /\* ([^\n]+)/s;
      ($p, $r, $c, $g, $b) = ("\e[35m", "\e[31m", "\e[36m", "\e[32m", "\e[0m");
      $status = `git status --porcelain -s 2>&1`;
      if ($status =~ /^fatal/) {
        print "$r [ $branch ]$b";
      } else {
        %h = ("M", 0, "D", 0, "?", 0);
        $h{$1}++ while $status =~ /([MADRC?]) /gms;
        ($mod, $del, $new) = ($h{"M"} + $h{"R"}, $h{"D"}, $h{"?"} + $h{"A"} + $h{"C"});
        $shortstat = `git diff --color=never --shortstat`;
        ($in) = $shortstat =~ /(\d+)\D*\+/;
        ($de) = $shortstat =~ /(\d+)\D*-/;
        $diff = ($in ? "$in+ " : "") . ($de ? "$de- " : "");
        $folder = `pwd`;
        $folder =~ s|^.*/||;
        chomp $folder;
        print "\e]2;$folder : $branch\a";
        print "$p [ $branch $diff$c${mod}m $r${del}d $g${new}n $p]$b";
      }
    }
  '
}

svnPrompt() {
  perl -e '
    $_ = `svnversion`;
    if ($_ =~ /\d/) {
      ($revision) = /(\d+)/;
      ($p, $r, $c, $g, $b) = ("\e[35m", "\e[31m", "\e[36m", "\e[32m", "\e[0m");
      $status = `svn st`;
      %s = ("M", 0, "D", 0, "A", 0);
      $h{$&}++ while $status =~ /^./gms;
      ($mod, $del, $new, $con) = ($h{"M"} + $h{"R"} + $h{"~"}, $h{"D"} + $h{"!"}, $h{"A"} + $h{"?"}, $h{"C"});
      $con = "$con CONFLICTS " if $con;
      print "$p [ $revision $con$c${mod}m $r${del}d $g${new}n $p]$b";
    }
  '
}

dots='..'
slashes='..'

for (( i = 0; i <= 20; ++i ))
do
  alias "$dots"="cd $slashes"
  dots="$dots."
  slashes="$slashes/.."
done

export PS1='\n\e[32m\u@\h \e[33m\w\e[0m$(gitPrompt)$(svnPrompt)\n\$ '
alias ls="ls --color"
alias copy="xclip -selection clipboard -i"
alias pste="xclip -selection clipboard -o"
eval `dircolors`
