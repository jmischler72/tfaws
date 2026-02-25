# tfaws - AWS Profile Manager

A Zsh plugin for Oh My Zsh that simplifies switching between AWS profiles

## Features

- 🔄 Switch between AWS profiles with automatic SSO authentication
- 🎯 Interactive profile selection with fzf support

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
| `<profile>` | Switch to the specified AWS profile, if `<profile>` empty it clears profile |
| `ls, list` | List and interactively select an AWS profile |
| `sh, show` | Show current AWS profile and Terraform path |


### Examples

```bash
# Switch to 'dev' profile
tfaws dev

# Interactive profile selection (uses fzf if available)
tfaws list

# Show current profile and path
tfaws show
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

**Profile Switching**: When you switch profiles, the plugin:
   - Uses `asp` (change_context) to set the AWS profile
   - Extracts the SSO session name from `~/.aws/config`
   - Runs `aws sso login` to ensure authentication

## Troubleshooting

### Common Issues

1. **Profile not found**: Ensure your AWS profile exists in `~/.aws/config`
2. **Authentication failed**: The plugin will automatically run `aws sso login` when needed

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
