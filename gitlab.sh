#!/usr/local/bin/zsh

declare -A repo_list

repo_list[repo-name-1]="team-name-1"
repo_list[repo-name-2]="team-name-2"

for key val in ${(kv)repo_list}; do

#clone each repo
$(git clone "git@gitlab.something.com:engineering/jobs/$key.git")

touch ./$key/CODEOWNERS
cat > ./$key/CODEOWNERS <<- EOM
# This repository is currently maintained by the following team
* @$val
EOM

$(cd ./$key && git checkout -b 137/sre/DP-0000-branch-name)
$(cd ./$key && git add . && git commit -m "Adding some file")
$(cd ./$key && git push --set-upstream origin 137/sre/DP-0000-branch-name)

done
