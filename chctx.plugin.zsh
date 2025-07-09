source $HOME/.zshrc_priv

# - Rebind terraform aliases to use TFPATH
alias terraform='echo tf_path: $TFPATH && terraform -chdir=$TFPATH $@'
alias tfi='echo tf_path: $TFPATH && terraform -chdir=$TFPATH init '
alias tfp='echo tf_path: $TFPATH && terraform -chdir=$TFPATH plan '
alias tfa='echo tf_path: $TFPATH && terraform -chdir=$TFPATH apply '
alias tfd='echo tf_path: $TFPATH && terraform -chdir=$TFPATH destroy '
alias tfs='echo tf_path: $TFPATH && terraform -chdir=$TFPATH show '

change_context() {
  local profile="$1"
  asp "$profile"
  awsid
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
  echo "Not authenticated. Running SSO login..."
  aws sso login --sso-session $MY_SSO 
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

alias chctx="select_context"
alias shctx='echo aws_profile: $AWS_PROFILE && echo tf_path: $TFPATH'