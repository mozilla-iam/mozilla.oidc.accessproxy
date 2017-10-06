# How to...

Change OIDCAccessProxy by the app name - must be unique for your IAM account.
Change the GitHub URL for your own repository as well.

```
$ sed 's/\$NAME\$/OIDCAccessProxy/g' roles.yml.tpl > roles.yml
$ sed 's/\$NAME\$/OIDCAccessProxy/g' us-west-2.yml.tpl | sed 's/\$GIT_URL\$/https\:\/\/github\.com\/mozilla\-iam\/mozilla\.oidc\.accessproxy/' > us-west-2.yml
```

Use the same name as `$STACK_NAME` in deploy scripts and fill in other settings as needed:

```
$ vim deploy-dev.sh
...
STACK_NAME=OIDCAccessProxy
...
```

Run the deploy (NOTE: it won't recreate CF templates that already exit):

```
$ ./deploy-dev.sh
```
