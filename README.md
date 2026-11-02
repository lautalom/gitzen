# gitzen

A set of consistent, memorable git aliases and helper functions for **bash**,
built for distros where bash is the login shell (Omarchy, CachyOS, Arch, ...).

Forked from [davidde/git](https://github.com/davidde/git), whose zsh plugin
inspired the tag map. This fork is bash-only.

Many popular git shortcuts are inconsistent out of the box
(`gcm` stealing `git commit -m`, `gl` meaning `git pull`, ...). Here every
alias follows one logic, and quite a few extra functions are added.


## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/lautalom/gitzen/main/install.sh | bash
```

Or from a clone:

```bash
git clone https://github.com/lautalom/gitzen.git
cd gitzen
./install.sh
```

The installer appends a managed block to `~/.bashrc`:

```bash
# >>> gitzen >>>
source "/path/to/gitzen.plugin.bash"
# <<< gitzen <<<
```

Open a new terminal (or `source ~/.bashrc`) and try `gs`, `glo`, `gaa`, `galias`.
Remove it with `./install.sh --uninstall`.

Manual install: add `source ~/path/to/gitzen/gitzen.plugin.bash` to the end of `~/.bashrc`.

### Omarchy

Omarchy defines `g`, `gcm`, `gcam` and `gcad` in its default aliases. Since
`~/.bashrc` sources those first, this plugin's definitions win, except `gcad`,
which is kept so Omarchy's `git commit -a --amend` still works.

### Notes

- `gstshl` maps to `git diff stash@{0}` (`git stash show` has no `-l` flag).
- `galias` reads this README from `$GITZEN_DIR` if set, otherwise from the
  directory containing `gitzen.plugin.bash`.


## Aliases cheatsheet

| Alias           | Command                                                   |
|:----------------|:----------------------------------------------------------|
| **g**           | git                                                       |
| **ga**          | git add                                                   |
| **gaa**         | git add --all                                             |
| **gai**         | git add --interactive                                     |
| **galias**      | git_list_aliases                                          |
| **gam**         | git commit --amend -m                                     |
| **gama**        | git commit --amend -am                                    |
| **gan**         | git commit --amend --no-edit                              |
| **gana**        | git commit --amend --no-edit -a                           |
| **gap**         | git add --patch                                           |
| **gb**          | git branch                                                |
| **gba**         | git branch --all                                          |
| **gbd**         | git branch --delete                                       |
| **gbdf**        | git branch --delete --force                               |
| **gbl**         | git blame                                                 |
| **gbll**        | git_blame_line \<file> [\<from line>] [\<to line>]        |
| **gbls**        | git branch --list                                         |
| **gbs**         | git bisect                                                |
| **gbsb**        | git bisect bad                                            |
| **gbsg**        | git bisect good                                           |
| **gbsr**        | git bisect reset                                          |
| **gbss**        | git bisect start                                          |
| **gc**          | git commit --verbose                                      |
| **gcad**        | git commit -a --amend                                     |
| **gcam**        | git commit -am                                            |
| **gcame**       | git commit --allow-empty-message -am ""                   |
| **gcamg**       | git commit --gpg-sign -am                                 |
| **gcams**       | git commit --signoff -am                                  |
| **gcamu**       | git commit -am "Update"                                   |
| **gcem**        | git commit --allow-empty -m                               |
| **gcf**         | git config                                                |
| **gcfg**        | git config --global                                       |
| **gcfl**        | git config --local                                        |
| **gcfls**       | git config --list                                         |
| **gcl**         | git_clone_and_cd                                          |
| **gcm**         | git commit -m                                             |
| **gcmg**        | git commit --gpg-sign -m                                  |
| **gcms**        | git commit --signoff -m                                   |
| **gcnt**        | git_count                                                 |
| **gco**         | git checkout                                              |
| **gcob**        | git checkout -b                                           |
| **gcobb**       | "checkout branch before": git checkout -                  |
| **gcoc**        | git_checkout_child [\<n>]                                 |
| **gcod**        | git checkout develop                                      |
| **gcof**        | git checkout -f                                           |
| **gcom**        | git checkout $(git_main_branch)                           |
| **gcop**        | git_checkout_parent [\<n>]                                |
| **gcp**         | git cherry-pick                                           |
| **gcpa**        | git cherry-pick --abort                                   |
| **gcpc**        | git cherry-pick --continue                                |
| **gcpq**        | git cherry-pick --quit                                    |
| **gcps**        | git cherry-pick --skip                                    |
| **gd**          | git diff                                                  |
| **gds**         | git diff --staged                                         |
| **gdst**        | git diff stash@{0}                                        |
| **gdsth**       | git diff stash@{0} HEAD                                   |
| **gdstp**       | git diff stash@{0}^ stash@{0}                             |
| **gf**          | git fetch                                                 |
| **gfo**         | git fetch origin                                          |
| **gg**          | git log --graph --all                                     |
| **ggb**         | git log --graph --all --simplify-by-decoration            |
| **ggbo**        | git log --graph --all --oneline --simplify-by-decoration  |
| **ggo**         | git log --graph --all --oneline                           |
| **gi**          | git init                                                  |
| **gib**         | git init --bare                                           |
| **gig**         | git update-index --skip-worktree                          |
| **gl**          | glog -10                                                  |
| **glf**         | git_log_file \<file> [\<from line>] [\<to line>]          |
| **glo**         | git log --oneline                                         |
| **gloc**        | git_locate_string \<Line-of-Code> [\<file>]               |
| **glog**        | git log --reverse --name-status                           |
| **glsb**        | git branch --list                                         |
| **glsf**        | git ls-files                                              |
| **glsig**       | git ls-files -v \| grep ^S                                |
| **glsr**        | git remote -v                                             |
| **glss**        | git config -f .gitmodules --name-only --get-regexp path   |
| **glsst**       | git stash list                                            |
| **glst**        | git tag --list                                            |
| **gm**          | git merge                                                 |
| **gmnff**       | git merge --no-ff                                         |
| **gmom**        | git merge origin/$(git_main_branch)                       |
| **gmsq**        | git merge --squash                                        |
| **gmum**        | git merge upstream/$(git_main_branch)                     |
| **gmv**         | git mv                                                    |
| **gph**         | git push                                                  |
| **gphd**        | git push --delete                                         |
| **gphdo**       | git push --delete origin                                  |
| **gphf**        | git push --force-with-lease                               |
| **gphff**       | git push --force                                          |
| **gpht**        | git push && git push --tags                               |
| **gphu**        | git push -u                                               |
| **gphuo**       | git push -u origin                                        |
| **gphuom**      | git push -u origin main                                   |
| **gpl**         | git pull                                                  |
| **gpla**        | git pull --autostash                                      |
| **gplr**        | git pull --rebase                                         |
| **gplrs**       | git pull --recurse-submodules                             |
| **gr**          | git reset                                                 |
| **grb**         | git rebase                                                |
| **grbm**        | git rebase $(git_main_branch)                             |
| **gre**         | git restore                                               |
| **grea**        | git restore .                                             |
| **grem**        | git remote                                                |
| **grema**       | git remote add                                            |
| **gremao**      | git remote add origin                                     |
| **gremls**      | git remote -v                                             |
| **gremrm**      | git remote rm                                             |
| **gremrmo**     | git remote rm origin                                      |
| **gremset**     | git remote set-url                                        |
| **gremseto**    | git remote set-url origin                                 |
| **gremsh**      | git remote show                                           |
| **gremv**       | git remote -v                                             |
| **grh**         | git_reset_head --mixed                                    |
| **grhard**      | git reset --hard                                          |
| **grhhard**     | git_reset_head --hard                                     |
| **grhk**        | git_reset_head --keep                                     |
| **grhs**        | git_reset_head --soft                                     |
| **grk**         | git reset --keep                                          |
| **grl**         | git reflog                                                |
| **grm**         | git rm                                                    |
| **grs**         | git reset --soft                                          |
| **gs**          | git status                                                |
| **gsh**         | git show                                                  |
| **gshsf**       | git_show_stash_file \<file> [\<stash number>]             |
| **gss**         | git_status_short [\<number of commits>]                   |
| **gst**         | git stash                                                 |
| **gsta**        | git stash apply                                           |
| **gstd**        | git stash drop                                            |
| **gstls**       | git stash list                                            |
| **gstph**       | git stash push                                            |
| **gstpp**       | git stash pop                                             |
| **gstshl**      | git diff stash@{0}                                        |
| **gstshp**      | git stash show -p                                         |
| **gsub**        | git submodule                                             |
| **gsuba**       | git submodule add                                         |
| **gsubf**       | git submodule foreach                                     |
| **gsubfpl**     | git submodule foreach git pull                            |
| **gsubfplom**   | git submodule foreach git pull origin $(git_main_branch)  |
| **gsubi**       | git submodule update --init                               |
| **gsubs**       | git submodule status                                      |
| **gsubu**       | git submodule update --remote --merge                     |
| **gt**          | git tag                                                   |
| **gtam**        | git tag -am                                               |
| **gtd**         | git tag --delete                                          |
| **gtls**        | git tag --list                                            |
| **gtsm**        | git tag -sm                                               |
| **gug**         | git update-index --no-skip-worktree                       |
| **gwta**        | git worktree add                                          |

&nbsp;


-------------------------------------------------------------------------------
> :warning: **Note:**  
> 
> This cheatsheet is optimized for memorability; some descriptions are
> abbreviated. E.g.:
>   - `glog`, `gl` and `glo` use a custom, more verbose `git log` format.
>   - `gg`, `ggo`, `ggb` and `ggbo` use a custom graph format.
>   - `gcl` clones with submodules and then `cd`s into the repository.
>
> Check out all commands with usage and clarifications in your local
> [gitzen.plugin.bash](./gitzen.plugin.bash).
