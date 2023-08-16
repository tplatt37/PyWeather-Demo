# Step Through Debugging

# VS Code

Assuming you are using VS Code, it's easy to debug.

The machine must have:
* SAM CLI
* Docker
* Python extension

To debug in VSCode:
0. REMOVE the ~/environment/.vscode/launch.json
rm -f ~/environment/.vscode/launch.json
1. Open Folder
2. Go to "Run and Debug" menu
2a. MAKE SURE YOU ARE ON THE TERMINAL TAB AND NOT app.py
3. Look for option to CREATE the launch.json (this will be stored in .vscode folder)
3a. Must use the "AWS SAM: Run and Debug Function Locally" option
4. Locate the appropriate Function section in the launch.json 
5. Find the "PyWeather-Demo" function that references templatey.yaml
6. Modify the name to have "AAA" at the begining
7. Modify the "payload" section to:
"payload": {"path": "/home/ec2-user/environment/PyWeather-Demo/events/event.json"},
8. Then set some breakpoints in the gutter - and run it!
9. In the "Run and Deubg" - near the Green PLAY icon, find the AAA function in the dropdown.
10. Click the green Play icon

If you pick the wrong function you'll get a variety of errors.

## Remote-SSH

It's just as easy to debug using the Remote-SSH extension.  Simply ensure the remote ec2 instance has Docker, Pythong extensions, and SAM CLI installed.


