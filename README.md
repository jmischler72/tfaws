# chctx

**chctx** is an [Oh My Zsh](https://ohmyz.sh/) plugin that streamlines context switching between AWS and
Terraform. It offers automatic AWS SSO login, profile switching, and directory-based context management using
a `.awsprofile` file.

## Features

- **Profile Selector:** Quickly switch AWS profiles via an interactive menu or command argument.
- **Terraform Context:** Automatically set Terraform working directories per AWS profile.
- **AWS SSO Integration:** Seamless SSO login with environment variable configuration.
- **Auto Profile Switching:** Instantly switch profiles when entering directories containing a `.awsprofile`
  file.

## Installation

1. Clone or copy the plugin into your Oh My Zsh plugins directory.
2. Add `aws` and `chctx` to the `plugins` array in your `.zshrc`:

```zsh
plugins=(... aws chctx)
```

3. Reload your shell:

```zsh
source ~/.zshrc
```

## Usage

### Commands

- `chctx`
  - Opens a menu to select an AWS profile.
- `shctx`
  - Displays the current AWS profile and Terraform directory.

### Configuration

Edit your `~/.zshrc_priv` (or similar private config file):

```zsh
# Set your AWS SSO environment variable
export MY_SSO="my-sso"

# Set Terraform paths for specific AWS profiles
export TFPATH_profile1="$HOME/Documents/terraform-project/profile1"
export TFPATH_profile2="$HOME/Documents/terraform-project/profile2"
```

- **Terraform Path:**  
  Use `TFPATH_<profile>` (replace `<profile>` with your AWS profile name, dashes removed) to specify the
  Terraform directory for each profile.

- **AWS SSO:**  
  Set `MY_SSO` to your SSO session name.

- **Auto Profile Switching:**  
  Place a `.awsprofile` file containing the profile name in any directory. When you `cd` or open a terminal
  into that directory, `chctx` will automatically switch to the specified profile.

  ```sh
  echo "profile1" > ~/Documents/terraform-project/profile1/.awsprofile
  ```

---

Contributions and feedback welcome!
