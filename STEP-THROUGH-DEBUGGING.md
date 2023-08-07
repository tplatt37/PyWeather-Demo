# Step Through Debugging

# VS Code

Assuming you are using VS Code, it's easy to debug.

The local machine must have:
* SAM CLI
* Docker

To debug in VSCode:
1. Open Folder
2. Go to "Run and Debug" menu
3. Look for option to CREATE the launch.json (this will be stored in .vscode folder)
4. Locate the appropriate Function section in the launch.json 
5. Modify the "payload" section to:
"payload": {"path": "/home/ec2-user/environment/PyWeather-Demo/events/event.json"},
6. Then set some breakpoints in the gutter - and run it!

## Remote-SSH

It's just as easy to debug using the Remote-SSH extension.  Simply ensure the remote ec2 instance has Docker and SAM CLI installed.


# Cloud 9

To debug on Cloud 9 you need:

* SAM CLI
* Docker

Then simply:

Replace your "launch.json" with the "launch.json" in the source root directory.
Launch it.

