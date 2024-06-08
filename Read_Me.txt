Microsoft Windows [Version 10.0.22631.3593]
(c) Microsoft Corporation. All rights reserved.

C:\Users\user>cd G:\GITHUB

C:\Users\user>G
'G' is not recognized as an internal or external command,
operable program or batch file.

C:\Users\user>G:

G:\GITHUB>git init
Initialized empty Git repository in G:/GITHUB/.git/

G:\GITHUB>dir
 Volume in drive G is Sipitiek
 Volume Serial Number is 760C-FDE4

 Directory of G:\GITHUB

06/08/2024  10:48 AM    <DIR>          .
06/08/2024  10:37 AM             1,558 Read_Me.txt
               1 File(s)          1,558 bytes
               1 Dir(s)  259,844,796,416 bytes free

G:\GITHUB>git config --global user.name "Morris Lesinko"
warning: user.name has multiple values
error: cannot overwrite multiple values with a single value
       Use a regexp, --add or --replace-all to change user.name.

G:\GITHUB>git config --global user.name
Morris

G:\GITHUB>git config --global user.email
lesinkosipitiek2136@gmail.com

G:\GITHUB>git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        Read_Me.txt

nothing added to commit but untracked files present (use "git add" to track)

G:\GITHUB>git add Read_Me.txt

G:\GITHUB>git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   Read_Me.txt


G:\GITHUB>git commit -m "This is my first commit"
[master (root-commit) be41574] This is my first commit
 1 file changed, 34 insertions(+)
 create mode 100644 Read_Me.txt

G:\GITHUB>git status
On branch master
nothing to commit, working tree clean

G:\GITHUB>git branch
* master

G:\GITHUB>git branch -m main

G:\GITHUB>git branch
* main

G:\GITHUB>git remote add origin   https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git

G:\GITHUB>git status
On branch main
nothing to commit, working tree clean

G:\GITHUB>git remote -v
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (fetch)
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (push)

G:\GITHUB>git push origin main

G:\GITHUB>
G:\GITHUB>
G:\GITHUB>git status
On branch main
nothing to commit, working tree clean

G:\GITHUB>git remote -v
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (fetch)
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (push)

G:\GITHUB>git push origin main
info: please complete authentication in your browser...
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Delta compression using up to 8 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 935 bytes | 935.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git
 * [new branch]      main -> main

G:\GITHUB>git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   Read_Me.txt

no changes added to commit (use "git add" and/or "git commit -a")

G:\GITHUB>git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   Read_Me.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        Buck_Converter.slx
        CUK_Converter.slx
        CUK_Converter.slx.autosave
        Full_Bridge_rectifier.slx
        PV_Array_MPPT.slx
        PV_Array_MPPT.slx.original
        QAM_256.slx

no changes added to commit (use "git add" and/or "git commit -a")

G:\GITHUB>git add.
git: 'add.' is not a git command. See 'git --help'.

The most similar command is
        add

G:\GITHUB>git add .

G:\GITHUB>git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   Buck_Converter.slx
        new file:   CUK_Converter.slx
        new file:   CUK_Converter.slx.autosave
        new file:   Full_Bridge_rectifier.slx
        new file:   PV_Array_MPPT.slx
        new file:   PV_Array_MPPT.slx.original
        new file:   QAM_256.slx
        modified:   Read_Me.txt


G:\GITHUB>git commit -m "My second commit"
[main 13303cf] My second commit
 8 files changed, 1 insertion(+), 1 deletion(-)
 create mode 100644 Buck_Converter.slx
 create mode 100644 CUK_Converter.slx
 create mode 100644 CUK_Converter.slx.autosave
 create mode 100644 Full_Bridge_rectifier.slx
 create mode 100644 PV_Array_MPPT.slx
 create mode 100644 PV_Array_MPPT.slx.original
 create mode 100644 QAM_256.slx

G:\GITHUB>git remote -v
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (fetch)
origin  https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git (push)

G:\GITHUB>git push origin main
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 8 threads
Compressing objects: 100% (10/10), done.
Writing objects: 100% (10/10), 152.93 KiB | 9.00 MiB/s, done.
Total 10 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 1 local object.
To https://github.com/MorrisLesinko/ML-and-DL-PR0JECTS.git
   be41574..13303cf  main -> main

G:\GITHUB>
