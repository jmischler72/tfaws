
current_context() {
  echo "Current AWS Profile: $AWS_PROFILE"
}

change_context() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    unset AWS_PROFILE
    echo "Cleared AWS profile context"
    return 0
  fi
  if ! asp "$profile"; then
    return 1
  fi

  echo "Switching context to '$profile'"

  awsid
  current_context
}

# - Function to select a profile
select_context() {
  # Get profiles from aws_profiles command
  if command -v fzf >/dev/null 2>&1; then
    profile=$(aws_profiles | fzf --prompt="Select AWS profile: ")
    if [[ -n "$profile" ]]; then
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
  echo "Not authenticated. Running SSO login for profile: $profile"

  session_name=$(awk -v profile="$profile" '
  $0 ~ "\\[profile "profile"\\]" {found=1; next}
  /^\[profile / {found=0}
  found && $1 == "sso_session" {print $3; exit}
' ~/.aws/config)

  aws sso login --sso-session $session_name
  fi
}

# - Function to print help information
print_help() {
  cat << 'EOF'
tfaws - AWS Profile Manager

USAGE:
  tfaws [COMMAND]

COMMANDS:
  <profile>         Switch to the specified AWS profile, if <profile> empty it clears profile
  ls, list          List and interactively select an AWS profile
  sh, show          Show current AWS profile and Terraform path

EXAMPLES:
  tfaws ch dev                 # Switch to 'dev' profile
  tfaws list                   # Interactive profile selection
  tfaws show                   # Show current profile and path

EOF
}

tfaws() {
  if [[ $1 == "ls" || $1 == "list" ]]; then
    select_context
  elif [[ $1 == "sh" || $1 == "show" ]]; then
    current_context
  elif [[ $1 == "config" ]]; then
    config_tfaws
  elif [[ $1 == "h" || $1 == "help" || $1 == "--help" || $1 == "-h" ]]; then
    print_help
  else
    change_context "$1"
  fi
}

# Alias for existing command to make tfaws work
alias asp='change_context'

# - Rebind terraform aliases to use TFPATH
alias terraform='_tf_alias() { 
  if [[ "$1" == "fmt" || "$1" == "format" ]]; then
    command terraform "$@"
  elif [[ -n "$TFPATH" ]]; then 
    current_context && command terraform -chdir="$TFPATH" "$@"
  else 
    command terraform "$@"
  fi
}; _tf_alias'