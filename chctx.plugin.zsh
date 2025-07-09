source $HOME/.zshrc_priv

# - Rebind terraform aliases to use TFPATH
alias terraform='_tf_alias() { 
  if [[ -n "$TFPATH" ]]; then 
    echo tf_path: $TFPATH && command terraform -chdir="$TFPATH" "$@"
  else 
    command terraform "$@"
  fi
}; _tf_alias'

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

# - Function to switch AWS profiles from .awsprofile file
switchAwsProfile () {
if [ -f .awsprofile ]; then
  change_context "$(cat .awsprofile)"
fi
}

# - Function to login to AWS SSO if not authenticated
awsid() {
  if ! aws sts get-caller-identity &>/dev/null; then
  echo "Not authenticated. Running SSO login for session: $1"
  aws sso login --sso-session $1 
  fi
}

# - Functions to automatically switch AWS profile when entering a directory
if [[ $- == *i* ]]; then
  switchAwsProfile
fi

cd() {
  builtin cd "$@" && switchAwsProfile
}

# - Function to select a profile
select_context() {
  # Get profiles from aws_profiles command
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
}

chctx() {
  change_context "$@"
}
alias lsctx='select_context'
alias shctx='echo aws_profile: $AWS_PROFILE && echo tf_path: $TFPATH'
