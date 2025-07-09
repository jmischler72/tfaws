# chctx

This plugin provides utilities for unifying context between aws and terraform. It also provides features like
auto connecting to aws sso and auto profile switching based on a `.awsprofile` file in a folder

To use it, add `chctx` to the plugins array in your `.zshrc` file:

```zsh
plugins=(... chctx)
```

## Plugin commands

- `chctx`: Opens a select menu listing available profiles. Choose a profile to switch to it. If `<profile>` is
  provided as an argument, switches directly to that profile without showing the menu.
- `shctx`: Show current aws profile and terraform directory

## Configuration

To config a terraform path for a specific aws profile, edit a file in your home dir .zshrc\*priv with the path
to your terraform folder and the naming should be TFPATH\_<profile_without_dash>

To config your sso add to the same file an env_var named MY_SSO

To config the autoswitching in a folder, simply create a `.awsprofile` in any folder, when you create a terminal or cd in this folder it will switch to this context

## Example

```zsh
# ~/.zshrc_priv

# Set your SSO environment variable
MY_SSO="my-sso"

# Set Terraform paths for specific AWS profiles
TFPATH_profile1="$HOME/Documents/terraform-project/profile1"
TFPATH_devopsprod="$HOME/Documents/terraform-project/profile2"
```
