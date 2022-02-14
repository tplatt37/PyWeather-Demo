# TO DO:

* Test Manual / CI / Manual /Ci / Manual - does it work?
** The first CI/CD run won't use an Alias - for reasons unknown. 
** For simplicity's sake probably going to leave this as a known issue...
* Test Account Portability
* Docs
* Blow away git - and re-initialize (in case any account number in history!)
* Upload to Github


DONE:
* Make a YAML for the Pipeline/CodeBuild/Deploy (in a subdir named pipeline)
* Use a stock DeploymentConfiguration instead of custom (cicd-template)
* Python3.8 for now - it's easy to install on AL2 / C9
* Parameterize the Secrets Manager secret
* Dynamic Region in the Get Secrets Manager routine.
