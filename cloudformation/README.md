# How to...
Use the same name as `$STACK_NAME` in deploy scripts and fill in other settings as needed:

```
$ vim parameters.json
...
{
    "ParameterKey": "SSHKeyName",
    "ParameterValue": "infosec-us-west-2-keys",
    "UsePreviousValue": false
},
...
```

Run the deploy (NOTE: it won't recreate CF templates that already exist):

```
$ ./deploy.sh
```
