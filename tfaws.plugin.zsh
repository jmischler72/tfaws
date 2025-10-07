readConfig(){
  # Initialize associative array for tf_paths
  typeset -gA tf_paths
  
  # Function to parse YAML-like config
  parse_config() {
    local config_file="$1"
    local in_tf_paths=false
    
    while IFS= read -r line; do
      # Skip empty lines and comments
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      
      # Check if we're entering tf_paths section
      if [[ "$line" =~ ^tf_paths:[[:space:]]*$ ]]; then
        in_tf_paths=true
        continue
      fi
      
      # Check if we're leaving tf_paths section (new top-level key)
      if [[ "$line" =~ ^[^[:space:]] && "$line" != *tf_paths:* ]]; then
        in_tf_paths=false
        continue
      fi
      
      # Parse tf_paths entries
      if [[ "$in_tf_paths" == true && "$line" =~ ^[[:space:]]+([^:]+):[[:space:]]*\"([^\"]+)\"[[:space:]]*$ ]]; then
        local key="${match[1]// /}"  # Remove spaces
        local value="${match[2]}"
        # Evaluate environment variables in the value
        eval "value=\"$value\""
        tf_paths[$key]="$value"
      elif [[ "$in_tf_paths" == true && "$line" =~ ^[[:space:]]+([^:]+):[[:space:]]*([^[:space:]#]+) ]]; then
        local key="${match[1]// /}"  # Remove spaces  
        local value="${match[2]}"
        # Evaluate environment variables in the value
        eval "value=\"$value\""
        tf_paths[$key]="$value"
      fi
    done < "$config_file"
  }
  
  # Read config file .tfaws from home then override with current directory
  if [ -f ~/.tfaws ]; then
    parse_config ~/.tfaws
  fi
  if [ -f .tfaws ]; then
    parse_config .tfaws
  fi
}

current_context() {
  echo "Current AWS Profile: $AWS_PROFILE"
  echo "Current Terraform Path: $TFPATH"
}

change_context() {
  local profile="$1"
  if ! asp "$profile"; then
    return 1
  fi
  if [[ -z "$profile" ]]; then
    unset TFPATH
    echo "Cleared AWS profile and TFPATH"
    return 1
  fi
  echo "Switching context to '$profile'"
  # Extract sso_session value from aws/config for the given profile
  session_name=$(awk -v profile="$profile" '
    $0 ~ "\\[profile "profile"\\]" {found=1; next}
    /^\[profile / {found=0}
    found && $1 == "sso_session" {print $3; exit}
  ' ~/.aws/config)

  awsid "$session_name"
  
  # Get TFPATH from tf_paths configuration
  export TFPATH="${tf_paths[$profile]}"
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
  echo "Not authenticated. Running SSO login for session: $1"
  aws sso login --sso-session $1 
  fi
}

# - Function to configure TFPATH mappings in ~/.tfaws file
config_tfaws() {
  local config_file="$HOME/.tfaws"
  
  # Create template file if it doesn't exist
  if [[ ! -f "$config_file" ]]; then
    echo "Creating template .tfaws file at $config_file"
    
    # Get available AWS profiles
    profiles=($(aws_profiles))
    
    cat > "$config_file" << EOF
# -- tfaws configuration file
# Define Terraform paths for AWS profiles using YAML-like syntax
tf_paths:
  # Format: profile-name: "path/to/terraform/directory"  
  
  # Here are the current AWS profiles available, you can uncomment and modify the paths below, or add your own:
EOF
    # Add each detected profile as a commented template
    for profile in "${profiles[@]}"; do
      echo "  # ${profile}: \"\$HOME/terraform/${profile}\"" >> "$config_file"
    done
    cat >> "$config_file" << 'EOF'
EOF
  fi
  
  # Open the config file in the default editor
  ${=VISUAL:-${EDITOR:-vi}} "$config_file"
}

# - Function to print help information
print_help() {
  cat << 'EOF'
tfaws - Terraform AWS Profile Manager

USAGE:
  tfaws [COMMAND] [PROFILE]

COMMANDS:
  ch <profile>      Switch to the specified AWS profile and set TFPATH, if <profile> empty it clears profile
  ls, list          List and interactively select an AWS profile
  sh, show          Show current AWS profile and Terraform path
  config            Configure Terraform paths for AWS profiles

EXAMPLES:
  tfaws ch dev                 # Switch to 'dev' profile
  tfaws list                   # Interactive profile selection
  tfaws show                   # Show current profile and path
  tfaws config                 # Edit configuration file

CONFIGURATION:
  The plugin uses ~/.tfaws and ./.tfaws files with YAML-like syntax:
  
  tf_paths:
    dev: "$HOME/terraform/dev"
    prod: "$HOME/terraform/prod"
    devops-shared: "/terraform/shared"

  Environment variables like $HOME are automatically expanded.

ALIASES:
  asp                          # Alias for change_context
  terraform                    # Enhanced to use TFPATH when available

EOF
}

tfaws() {
  readConfig
  if [[ $1 == "ls" || $1 == "list" ]]; then
    select_context
  elif [[ $1 == "sh" || $1 == "show" ]]; then
    current_context
  elif [[ $1 == "config" ]]; then
    config_tfaws
  elif [[ $1 == "ch" || $1 == "change" ]]; then
    change_context "$2"
  else
    print_help
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