# rbgist
Gist by Ruby

# Usage
* Set up  
Require get token.  `GitHub -> settings -> applications -> Personal access tokens`
```bash
git config --global github.token "Your Token"
```
* Run
```bash
$ ruby rbgist.rb [options ...]
or
$ ln -s /path/to/rbgist.rb /usr/local/bin/gist
$ gist [options ...]
```

# Options
* Show
```bash
(-l | --list) [-i GistId | --id GistId] [-f Filename | --filename Filename]
```

* Create Gist
```bash
(-c | --create) filename... [-d DESC | --description DESC] [--private]
```

* Othe options  
Please refer to the help.
```bash
(-h | --help)
```

# Examples
* List Gists
```bash
gist -l
```

* Show Gist
```bash
gist -l --id <GistId>
```

* Show content of file
```bash
gist -l --id <GistId> -f Example.md
```

* Create private Gist
```bash
gist -c Example.txt -d "Example Description" --private
```