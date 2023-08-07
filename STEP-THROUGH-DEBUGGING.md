# Step Through Debugging

# VS Code with Remote-SSH

Assuming you are using VS Code with the Remote-SSH extension installed, it's easy to debug.

The remote EC2 machine (Linux) must have:
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


# Cloud 9

To debug on Cloud 9 you need:

* SAM CLI
* Docker

Then simply:

Replace your "launch.json" with the "launch.json" in the source root directory.
Launch it.

