# tfaws - Terraform AWS Profile Manager

A Zsh plugin for Oh My Zsh that simplifies switching between AWS profiles and managing corresponding Terraform directories.

## Features

- 🔄 Switch between AWS profiles with automatic SSO authentication
- 📁 Automatically set Terraform working directory (`TFPATH`) based on profile
- 🎯 Interactive profile selection with fzf support
- ⚙️ Configurable profile-to-path mappings
- 🔗 Enhanced Terraform command with automatic directory switching

## Installation

### Oh My Zsh Custom Plugin

1. Clone this repository into your Oh My Zsh custom plugins directory:
   ```bash
   git clone https://github.com/jmischler72/tfaws.git $ZSH_CUSTOM/plugins/tfaws
   ```

2. Add `aws` and `tfaws` to your plugins list in `~/.zshrc`:
   ```bash
   plugins=(... aws tfaws)
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Usage

### Commands

```bash
tfaws [COMMAND] [PROFILE]
```

#### Available Commands

| Command | Description |
|---------|-------------|
| `ch <profile>` | Switch to the specified AWS profile and set TFPATH |
| `ch` (no profile) | Clear current AWS profile and TFPATH |
| `ls`, `list` | List and interactively select an AWS profile |
| `sh`, `show` | Show current AWS profile and Terraform path |
| `config` | Configure Terraform paths for AWS profiles |

### Examples

```bash
# Switch to 'dev' profile
tfaws ch dev

# Interactive profile selection (uses fzf if available)
tfaws list

# Show current profile and path
tfaws show

# Edit configuration file
tfaws config
```

## Configuration

The plugin uses configuration files with YAML-like syntax to map AWS profiles to Terraform directories:

### Configuration Files

- `~/.tfaws` - Global configuration (applies to all directories)
- `./.tfaws` - Local configuration (overrides global settings for current directory)

### Configuration Format

```yaml
tf_paths:
  dev: "$HOME/terraform/dev"
  staging: "$HOME/terraform/staging"
  prod: "$HOME/terraform/production"
  devops-shared: "/shared/terraform/devops"
```

Environment variables like `$HOME` are automatically expanded.

### Initial Setup

Run `tfaws config` to create a template configuration file with your current AWS profiles:

```bash
tfaws config
```

This will:
1. Create a `~/.tfaws` file if it doesn't exist
2. Pre-populate it with your available AWS profiles as commented templates
3. Open the file in your default editor

## Enhanced Commands

### Terraform Alias

The plugin enhances the `terraform` command to automatically use the configured `TFPATH`:

```bash
# When TFPATH is set, terraform commands run in that directory
terraform plan    # Runs: terraform -chdir="$TFPATH" plan
terraform apply   # Runs: terraform -chdir="$TFPATH" apply

# Format commands work normally (don't use -chdir)
terraform fmt     # Runs: terraform fmt
```

### ASP Alias

The plugin provides an `asp` alias for quick profile switching:

```bash
asp dev      # Same as: tfaws ch dev
```

## Requirements

- Zsh shell
- Oh My Zsh
- AWS CLI v2 with configured profiles
- `fzf` (optional, for enhanced interactive selection)

## Dependencies

The plugin assumes you have AWS profiles configured and uses:
- `aws sts get-caller-identity` - to check authentication status
- `aws sso login` - for SSO authentication
- `aws_profiles` - to list available profiles (assumed to be available)

## How It Works

1. **Profile Switching**: When you switch profiles, the plugin:
   - Uses `asp` (change_context) to set the AWS profile
   - Extracts the SSO session name from `~/.aws/config`
   - Runs `awsid` to ensure authentication
   - Sets `TFPATH` environment variable from configuration

2. **Configuration Loading**: The plugin reads configuration in this order:
   - `~/.tfaws` (global settings)
   - `./.tfaws` (local overrides)

3. **Terraform Integration**: The enhanced `terraform` command:
   - Uses `TFPATH` for most commands via `-chdir`
   - Runs format commands normally (without `-chdir`)
   - Shows current context before execution

## Troubleshooting

### Common Issues

1. **Profile not found**: Ensure your AWS profile exists in `~/.aws/config`
2. **Path not set**: Run `tfaws config` to configure Terraform paths
3. **Authentication failed**: The plugin will automatically run `aws sso login` when needed

### Debug Information

Use `tfaws show` to see current configuration:
```bash
tfaws show
# Output:
# Current AWS Profile: dev
# Current Terraform Path: /home/user/terraform/dev
```

## License

This project is licensed under the terms specified in the LICENSE file.