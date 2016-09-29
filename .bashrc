SSH_ENV="$HOME/.ssh/environment"
function start_agent {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  /usr/bin/ssh-add;
}
# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_agent;
  }
else
  start_agent;
fi

###############################################################################

alias gsu='git submodule update'
alias gsui='git submodule update --init'
alias clean_full='git clean -f -x -d'
alias access_ssh='ssh git@git.pressganey.com'
alias gka='gitk --all&'
alias gitk='gitk --all&'
alias gg='git gui&'
alias gfa='git fetch --all'
alias grv='git remote -v'
alias vs='/c/Program\ Files\ \(x86\)/Common\ Files/microsoft\ shared/MSEnv/vslauncher.exe *.sln &'

###############################################################################

function add_submodule {
  repoName=$1
  git submodule add git://git.pressganey.com/$repoName.git
}
###############################################################################

function winmerge {
  "C:\Program Files (x86)\WinMerge\WinMergeU.exe" $1
}

###############################################################################

function pause {
  read -n 1 -s
}

###############################################################################

function who_made_changes_in_a_folder {
  if [[ -z "$1" ]]; then echo "must pass in an author"; return 1; fi
  if [[ -z "$2" ]]; then echo "must pass in a path, can use ."; return 1; fi

  git log --pretty="%H" --author="$1" -- "$2" | while read commit_hash; do git show --oneline --name-only $commit_hash | tail -n+2; done | sort | uniq
}


###############################################################################

function func_usage {
  func_required $'usage: func_usage <message>\n\n  message  message to display when there is a failure' $1
  if [ "$2" == "?" ]; then echo "$1"; return 1;fi
}

###############################################################################

function func_required {
  if [[ -z "$2" ]]; then echo "$1"; return 1; fi
}

###############################################################################
# ---------- Functions ------------
###############################################################################

function move_branch_to_remote {
  branchName=$1
  remoteName=$2
  git checkout $remoteName/$branchName
  git branch -f $branchName
  git checkout $branchName
}

###############################################################################

function gs {
  git remote -v
  git status
}

###############################################################################

function reload {
  source ~/.bashrc
  echo "Reloaded!"
}

###############################################################################

function clone_ssh {
  repoName=$1
  # fix func_usage and func_required
  func_usage "usage: clone_ssh <repositoryName>" $repoName
  if [ "$repoName" == "?" ]; then return 1; fi
  func_required $'usage: clone_ssh <repositoryName>\n  repositoryName must be provided (.git extension should not be included)' $repoName
  if [[ -z "$repoName" ]]; then return 1; fi

  git clone ssh://git@git.pressganey.com/$repoName.git
  cd $repoName/
  git submodule init
  git submodule update
}

###############################################################################

function clone_git {
  repoName=$1
  # fix func_usage and func_required
  func_usage "usage: clone_git <repositoryName>" $repoName
  if [ "$repoName" == "?" ]; then return 1; fi
  func_required $'usage: clone_git <repositoryName>\n  repositoryName must be provided (.git extension should not be included)' $repoName
  if [[ -z "$repoName" ]]; then return 1; fi

  git clone git://git.pressganey.com/$repoName.git
  cd $repoName/
  git submodule init
  git submodule update
}

###############################################################################

function make_submodule_pushable {
  repoName=${PWD##*/}
  git remote set-url origin ssh://git@git.pressganey.com/$repoName.git
}


###############################################################################

function push_submodule {
  push_ssh
  git pull
}
###############################################################################

function push_ssh {
  repoName=${PWD##*/}
  userName=$1
  branchName=$2
  if [[ -n "$userName" ]]
  then
               if [[ -n "$branchName" ]]
               then
                              echo "Pushing to $userName/$branchName"
                              git push ssh://git@git.pressganey.com/$userName/$repoName.git $branchName
               else
                              echo "Pushing to $userName/master"
                              git push ssh://git@git.pressganey.com/$userName/$repoName.git master
               fi
               git fetch ssh://git@git.pressganey.com/$userName/$repoName.git
  else

    while true; do
      read -p "Push to blessed? [y/n] " yn
      case ${yn} in
        [Yy]* ) git push ssh://git@git.pressganey.com/$repoName.git master; break;;
        [Nn]* ) break;;
      esac
    done

    git fetch ssh://git@git.pressganey.com/$repoName.git
  fi
}

###############################################################################

function pull_submodule_from_blessed {
  branchName=$1
  if [[ -z "$branchName" ]]; then echo "You must specify the branch to pull from!"; return 1; fi

  repoName=${PWD##*/}
  git pull git://git.pressganey.com/$repoName.git $branchName
}

###############################################################################

function pull_from {
  repoName=${PWD##*/}
  userName=$1
  branchName=$2
  if [[ -n "$userName" ]]
  then
    if [[ -n "$branchName" ]]
    then
      git pull git://git.pressganey.com/$userName/$repoName.git $branchName
    else
      git pull git://git.pressganey.com/$userName/$repoName.git master
   fi
  else
    echo 'you must specify the user to which to pull from'
  fi
}

###############################################################################

function pull_submodules {
  git submodule foreach 'git checkout master && git pull'
  echo 'You really need to check if this is what you really wanted to do!'
}

###############################################################################

function make_fork {
  user_name=${USER:-${USERNAME}}
  origurl=$(git config --get remote.origin.url)

  git remote rename origin blessed && git remote set-url blessed `echo ${origurl} | sed s,ssh://git@,git://,g`

  if [ $? -ne 0 ]; then
    exit 1;
  fi

  echo Renamed remote \'origin\' as \'blessed\': $(git config --get remote.blessed.url)
  
  git remote add origin ssh://git@git.pressganey.com/${user_name}/$(basename ${origurl})

  if [ $? -ne 0 ]; then
    exit 1;
  fi

  echo Added remote \'origin\': $(git config --get remote.origin.url)

  while true; do
    read -p "Push your fork, \'${user_name}\' to the server? [y/n/f - force] " yn
    case ${yn} in
      [Yy]* ) git push origin refs/heads/*:refs/heads/* refs/tags/*:refs/tags/* -u; break;;
      [Ff]* ) git push origin refs/heads/*:refs/heads/* refs/tags/*:refs/tags/* -u -f; break;;
      [Nn]* ) break;;
    esac
  done
}

###############################################################################

function clone_ssh_personal {
  user_name=${USER:-${USERNAME}}
  repoName=$1
  git clone ssh://git@git.pressganey.com/${user_name}/$repoName.git
  cd $repoName/
  git remote add blessed git://git.pressganey.com/$repoName.git
  git submodule init
  git submodule update
}

###############################################################################

function add_remote {
  local OPTIND
  repoName=${PWD##*/}
  remoteUser=${@: -1}
  useSsh=false
  while getopts ":s" opt ; do
    case $opt in
      s ) 
        useSsh=true
        ;;
      \? )
        useSsh=false
        ;;
    esac
  done
  if [[ -n "$remoteUser" ]]
  then
    echo "$useSsh"
    if $useSsh
      then
        git remote add $remoteUser ssh://git@git.pressganey.com/$remoteUser/$repoName.git
    else
      git remote add $remoteUser git://git.pressganey.com/$remoteUser/$repoName.git
    fi
    echo "fetching"
    git fetch $remoteUser
    echo "Remote '$remoteUser' added"
  else
    echo 'Specify the user to which to add a remote to'
  fi
}

###############################################################################

function for_each_git_repo {
  # try switching to getopts
  echo ""
  for x in `find -name '.git' -maxdepth 2 -printf '%h\n' | sed 's/\.\///'`
  do
    cd $x
               if [ "${1:0:2}" = "-m" ]
               then
      echo "**** ${1:2} for: $x"
               else
      if [[ -n "$1" ]]; then $1; fi
               fi
    if [[ -n "$2" ]]; then $2; fi
    if [[ -n "$3" ]]; then $3; fi
    if [[ -n "$4" ]]; then $4; fi
    if [[ -n "$5" ]]; then $5; fi
    echo ""
    cd ..
  done
}

###############################################################################

function open_build_drop_folder {
    current_dir=`echo ${PWD##*/}`
    drop_folder="\\\\us.pressganey.com\\pgdocs\\Departmental\\IT\\QA\\SurveySolutions\\$current_dir"
    if [[ ! -d ${drop_folder} ]]; then
        drop_folder="\\\\us.pressganey.com\\pgdocs\\Departmental\\IT\\QA\\SurveySolutions\\survey-solutions-$current_dir"
        if [[ ! -d ${drop_folder} ]]; then
            echo Not found!
            return -1
        fi
    fi

    start $drop_folder
}

###############################################################################

function all_git_status {
  for_each_git_repo -m"Doing git status" "git status" "pause"
}

###############################################################################

function all_git_fetch_origin {
  for_each_git_repo -m"Doing git prune/fetch origin" "git remote prune origin" "git fetch origin"
}

###############################################################################

function all_git_pull_and_update_subs {
  for_each_git_repo -m"Getting latest" "git pull" "git submodule update"
}

###############################################################################

function all_git_submodule_init {
  for_each_git_repo -m"Init submodules" "git submodule init"
}

###############################################################################

function all_git_clean {
  for_each_git_repo -m"Cleaning artifacts" "git clean -f -x -d"
}

###############################################################################

function open_IE_to_gitweb() {
  repoName=${PWD##*/} 
  user_name=${USER:-${USERNAME}}

  "C:\Program Files\Internet Explorer\iexplore.exe" gitweb.pressganey.com/$user_name/$repoName.git &
} 

###############################################################################

#function strip_user_names {
#  echo 'not fully implemented'
#  sed 's,git://git\.pressganey\.com/.*/,git://git\.pressganey\.com/,g' .gitmodules -i
#}

#function convert_user_names {
#  if [[ -n "$1" ]]
#  then
#    echo 'not fully implemented'
#    strip_user_names $1
#    sed 's,git://git\.pressganey\.com/`$1`\.git,git://git\.pressganey\.com/heimab/\.git,g' .gitmodules -i
#  else
#    strip_user_names
#    sed 's,git://git\.pressganey\.com/.*/,git://git\.pressganey\.com/heimab/,g' .gitmodules -i
#  fi
#}

function getoptstest()
{
  local OPTIND
  repoName=${PWD##*/}
  remoteUser=$1
  useSsh=false
  while getopts ":s" opt ; do
    case "$opt" in
      s ) 
        useSsh=true
        ;;
      \? )
        useSsh=false
        ;;
    esac
  done
  echo "$useSsh"
}