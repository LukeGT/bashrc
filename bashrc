if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SSH_SESSION=1
fi

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

for i in `seq 20`
do
  alias "$dots"="cd $slashes"
  dots="$dots."
  slashes="$slashes/.."
done

if [ -n "$SSH_SESSION" ]; then
  PROMPT_COLOR=36
else
  PROMPT_COLOR=32
fi

export PS1='\n\e[${PROMPT_COLOR}m\u@\h \e[33m\w\e[0m\n\$ '
export EDITOR='vim'

# Fancy less
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

alias ls="ls --color=auto"
alias copy="xclip -selection clipboard -i"
alias pste="xclip -selection clipboard -o"
eval `dircolors`

# Go stuff
export GOPATH=$HOME/gopath

# Add any symlink'd directories in ~/bin to the PATH
export PATH="$PATH:$(find ~/bin -type l -xtype d | xargs -r realpath | tr '\n' ':' | sed s/.$//)"

# Perforce stuff
export P4DIFF=/usr/local/google/home/lukegt/bin/fdiff
alias g4h='cd /google/src/head/depot/google3'
alias g4w='cd `find-work.py`'

g4g () {
  cd `folder-finder.py $@`
}
