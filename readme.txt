# shellscript


*** steps ***

* Create repo in git hub
* clone repo in local laptop
* start developing
* Add the files to temp area
* commit changes
* push the changes
'''
git add <file-name>

'''
*Comit the changes
'''
git commit -m "why you committed the changes"

'''
git push -u origin main 

'''
git add . ; git commit -m "something" ; git push - origin main

when you git error overwritten by merge after giving git pull follow given belo steps

1.git status(you will get the file modified)
2.git diff common.sh(it will give the change what happened eg:assume mode got change i.e rwx)
2a)now disable all permissions.
2b)give git pull and give permissions to the modified file