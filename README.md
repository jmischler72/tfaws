# tfaws

**tfaws** is an [Oh My Zsh](https://ohmyz.sh/) plugin that simplifies context switching between AWS and
Terraform. It offers automatic AWS SSO login, automatic profile switching using a `.awsprofile` file, and
links of terraform workspace/folders to profiles

## Features

- **Profile Selector:** Quickly switch AWS profiles via an interactive menu or command argument.
- **Automatic AWS SSO login:** Automatically login to SSO based on the profile selected. (work only if
  configured with ~/.aws/config)
- **Terraform Context:** Automatically set Terraform working directories based on a AWS profile.
- **Auto Profile Switching:** Instantly switch profiles when entering directories containing a `.awsprofile`
  file.

## Installation

1. Clone or copy the plugin into your Oh My Zsh plugins directory.
2. Add `aws` and `tfaws` to the `plugins` array in your `.zshrc`:

```zsh
plugins=(... aws tfaws)
```

3. Reload your shell:

```zsh
source ~/.zshrc
```

## Usage

### Commands

- `tfaws`: Switch to an AWS profile with autologin to sso and link to terraform path (if exists).
- `tfaws ls`: Opens a menu to select an AWS profile/Terraform path (if exists).
- `tfaws sh`: Displays the current AWS profile and Terraform directory.

### Configuration

Export environment variables by modifying your .zshrc file or source a file exporting them

```zsh
# Set Terraform paths for specific AWS profiles
export TFPATH_profile1="$HOME/Documents/terraform-project/profile1"
export TFPATH_profile2="$HOME/Documents/terraform-project/profile2"
```

- **Terraform Path:**  
  Use the environment variable `TFPATH_<profile>` (replace `<profile>` with your AWS profile name, removing any dashes; for example, `profile-1` becomes `profile1`) to specify the Terraform directory for each profile.

- **Auto Profile Switching:**  
  Place a `.awsprofile` file containing the profile name in any directory. When you `cd` or open a terminal
  into that directory, `tfaws` will automatically switch to the specified profile.

  ```sh
  echo "profile1" > ~/Documents/terraform-project/profile1/.awsprofile
  ```

---

Contributions and feedback welcome!
