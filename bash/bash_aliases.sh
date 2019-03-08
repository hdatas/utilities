alias via='vi ~/.bash_aliases'
alias vib='vi ~/.bashrc'
alias srcb='echo "==> Sourcing .bashrc..."; source ~/.bashrc'

function rsynchcd() (
  if [ $# -lt 2 ]; then
      echo "Usage: rsynchost <host#> <jenkins path>"
      echo "Exampe:"
      echo "\trsynchost 21 /var/lib/jenkins/workspace/deploy-server-cluster3/"
      return -1;
  fi
  rsync_path=hcd$1:$2
  echo "rsync --exclude=build* --exclude=cmake-build-* --exclude=.ccls* -avi ./ ${rsync_path}/daelaam/"
  echo "rsync -avi ./thrift/ ${rsync_path}/thrift/"
  cddm && rsync --exclude=build* --exclude=cmake-build-* --exclude=.ccls* -avi ./ ${rsync_path}/daelaam/ &&
      cd .. && rsync -avi ./thrift/ ${rsync_path}/thrift/ && cddm
)

function ipmipower() {
  if [ $# -lt 2 ]; then
      echo "Usage: ipmipower <server number> <off|on|reset|status>"
      return -1
  fi
  echo "ipmitool -I lanplus -H 172.16.3.$1 -U ADMIN -P ADMIN chassis power $2"
  ipmitool -I lanplus -H 172.16.3.$1 -U ADMIN -P ADMIN chassis power $2
}

function ipmiconsole() {
  if [ $# -lt 1 ]; then
      echo "Usage: impiconsole <server number>"
      return -1
  fi
  echo "ipmitool -I lanplus -H 172.16.3.$1 -U ADMIN -P ADMIN sol activate"
  ipmitool -I lanplus -H 172.16.3.$1 -U ADMIN -P ADMIN sol activate
}


#######################################################################
#                          utilities in tmux                          #
#######################################################################


# tmux session layout, must run in a tmux session
function cluster10-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd56' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd57' C-m
  tmux select-layout even-vertical
  tmux rename-window '55,56,57'
  ssh hcd55
}

# tmux session layout, must run in a tmux session
function cluster7-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd40' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd41' C-m
  tmux select-layout even-vertical
  tmux rename-window '39,40,41'
  ssh hcd39
}

# tmux session layout, must run in a tmux session
function cluster5-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd32' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd33' C-m
  tmux select-layout even-vertical
  tmux rename-window '31,32,33'
  ssh hcd31
}

# tmux session layout, must run in a tmux session
function cluster4-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd28' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd29' C-m
  tmux select-layout even-vertical
  tmux rename-window '27,28,29'
  ssh hcd27
}

# tmux session layout, must run in a tmux session
function cluster3-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd20' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd22' C-m
  tmux select-layout even-vertical
  tmux rename-window '19,20,22'
  ssh hcd19
}

# tmux session layout, must run in a tmux session
function cluster1-tmux() {
  # tmux new-window
  # tmux send-keys 'ssh hcd19' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd13' C-m
  tmux split-window -v
  tmux send-keys 'ssh hcd14' C-m
  tmux select-layout even-vertical
  tmux rename-window '12,13,14'
  ssh hcd12
}
