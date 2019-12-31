# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/rli/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gentoo"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export DISABLE_AUTO_TITLE='true'

function restore_backup(){
  project_name=${1:-"b2e2"}
  username=${2:-"romain.libert"}
  migrate=${3:-yes}
  backup_key=${4:-false}
  backup_path_zip=${5:-false}  
  if [ "$project_name" = "b2e2" ]; then
      db_name="backtoearth2"
  else
      db_name=$project_name
  fi  
  echo "Restoring Postgresql backup for :"
  echo "-------------------------------------"
  echo "project_name: $project_name"
  echo "IPA username: $username"  echo "Are you sure ? If so, enter your IPA password:"
  read -s password  
  if ! [[ $password ]]; then
    echo "Exiting"
    return
  fi  
  backup_path=/tmp/file.backup
  backup_dir=/tmp/tmp/backup  
  if [ -f $backup_path ]; then
      rm -f $backup_path
  fi
  if [ -d $backup_dir ]; then
      rm -Rf $backup_dir
  fi  
  if [ $backup_path_zip = false ] ; then
    backup_path_zip=/tmp/file.backup.zip    # Cleaning up
    if [ -f $backup_path_zip ]; then
      rm -f $backup_path_zip
    fi    
    echo "Downloading backup file ..."
    wget --user $username --password $password https://backups.bluesafire.io/app/$project_name -O $backup_path_zip  else;
    echo "Using the already downloaded backup file $backup_path_zip"
  fi  
  if [ ! -f $backup_path_zip ]; then
    echo "Had an issue while downloading backup, exiting."
    return
  fi  
  if [ $backup_key = false ] ; then
    echo "Downloading backup key ..."
    backup_key=$(wget -O - -o /dev/null --user $username --password $password https://backups.bluesafire.io/keys | sed 's/.*"OVH": *"\(.*\)",.*/\1/')
  fi
  echo "Using backup key: $backup_key"  echo "Extracting it ..."
  #echo "Using key $backup_key"
  # -o overwrite files without prompting
  # -a autoconvert any text file
  unzip -o -P $backup_key -a $backup_path_zip -d /tmp  
  if [ ! -d $backup_dir ]; then
    echo "Had an issue while extracting backup, exiting."
      return
  fi  #cp $backup_dir/$project_name/$project_name-$(date +%Y-%m-%d)_*-pg*.backup $backup_path
  cp $backup_dir/$project_name/$project_name-*-pg*.backup $backup_path  
  if [ ! -f $backup_path ]; then
    echo "Could not find the backup file to restore one, exiting."
    return
  fi  # stop potential locks
  psql postgresql://postgres:postgres@localhost:5432/ -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname='$db_name' AND pid <> pg_backend_pid()"  # re-create db
  dropdb $db_name
  createdb $db_name  # restore it
  pg_restore --dbname=$db_name --username='postgres' --clean --verbose "$backup_path"  
  if type "$conda" > /dev/null; then
    previous_env=$CONDA_DEFAULT_ENV
    source deactivate
    source activate $project_name
  else
    if [ -z $VIRTUAL_ENV ]; then
        source `which virtualenvwrapper.sh`
        workon $project_name
    else
        echo "You have virtualenv installed"
        deactivate
        source ~/venv/$project_name/bin/activate
    fi 
  fi  
  echo "Re-creating admin user for '$project_name'..."
  python -m $project_name superuser admin admin  
  echo "Adding also Admin role to '$username' ..."
  sql_cmd="insert into roles (user_id, role_id) select usertable.\"id\", roletable.\"id\" from \"user\" usertable, \"role\" roletable where (usertable.\"username\" like '$username') AND (roletable.\"name\" = 'admin')"
  psql postgresql://postgres:postgres@localhost:5432/$db_name -c $sql_cmd  
  if [ ! "$migrate" ] ; then
    return
  fi  
  echo "Upgrading database..."
  python -m $project_name db upgrade  
  if type "$conda" > /dev/null; then
    source deactivate
    if [[ $previous_env ]]; then
      source activate $previous_env
    fi
  fi
}
export B2E2_CONFIG=/home/rli/.b2e2_settings.py
export TOURBILLON_CONFIG=/home/rli/.tourbillon_settings.py

alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
