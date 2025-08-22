readConfig(){
  # Read config file .tfaws from home then override with current directory
  if [ -f ~/.tfaws ]; then
    source ~/.tfaws
  fi
  if [ -f .tfaws ]; then
    source .tfaws
  fi
}

change_context() {
  local profile="$1"
  asp "$profile"
  if [[ -z "$profile" ]]; then
    return 1
  fi
  # Extract sso_session value from aws/config for the given profile
  session_name=$(awk -v profile="$profile" '
    $0 ~ "\\[profile "profile"\\]" {found=1; next}
    /^\[profile / {found=0}
    found && $1 == "sso_session" {print $3; exit}
  ' ~/.aws/config)

  awsid "$session_name"
  profile_no_dash="${profile//-/}"
  export TFPATH="$(eval echo \$TFPATH_${profile_no_dash})"
}

# - Function to select a profile
select_context() {
  # Get profiles from aws_profiles command
  if command -v fzf >/dev/null 2>&1; then
    profile=$(aws_profiles | fzf --prompt="Select AWS profile: ")
    if [[ -n "$profile" ]]; then
      echo "$profile"
      change_context "$profile"
    fi
  else
    profiles=($(aws_profiles))
    profiles+=("Quit")

    PS3="Select AWS profile: "
    select opt in "${profiles[@]}"; do
      if [[ $REPLY -ge 1 && $REPLY -le ${#profiles[@]} ]]; then
        if [[ $REPLY -eq ${#profiles[@]} ]]; then
          break
        else
          echo "${profiles[$REPLY]}"
          change_context "${profiles[$REPLY]}"
          break
        fi
      else
        echo "Invalid option"
      fi
    done
  fi
}

# - Function to login to AWS SSO if not authenticated
awsid() {
  if ! aws sts get-caller-identity &>/dev/null; then
  echo "Not authenticated. Running SSO login for session: $1"
  aws sso login --sso-session $1 
  fi
}


# - Function to switch AWS profiles from .awsprofile file
switchAwsProfile () {
if [ -f .awsprofile ]; then
  change_context "$(cat .awsprofile)"
fi
}

# - Functions to automatically switch AWS profile when entering a directory
if [[ $- == *i* ]]; then
  switchAwsProfile
fi


tfaws() {
  if [[ $1 == "ls" ]]; then
    select_context
  elif [[ $1 == "sh" ]]; then
    echo aws_profile: $AWS_PROFILE && echo tf_path: $TFPATH
  else
    change_context "$1"
  fi
}

# Alias for existing command to make tfaws work
alias asp='change_context'

cd() {
  builtin cd "$@" && switchAwsProfile
}

# - Rebind terraform aliases to use TFPATH
alias terraform='_tf_alias() { 
  if [[ "$1" == "fmt" || "$1" == "format" ]]; then
    command terraform "$@"
  elif [[ -n "$TFPATH" ]]; then 
    echo tf_path: $TFPATH && command terraform -chdir="$TFPATH" "$@"
  else 
    command terraform "$@"
  fi
}; _tf_alias'