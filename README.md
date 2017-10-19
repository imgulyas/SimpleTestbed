# LÖVE2D physics testbed #

## Project summary

This project is a port of a C++ physics testbed application using the same physics engine.
It is a simplistic tool to help you test your own sandboxes.
The app was written with the LÖVE2d game engine in Lua.
The underyling physics engine is called Box2d.

This app provides graphics and tools to manipulate the state of your sandbox.

More info on the used softwares:

  * www.lua.org
  * www.love2d.org
  * www.box2d.org
  
## How to run the app

Install love2d, then run app with the following command in terminal:

    $ love /path/to/SimpleTestbed

You will find a number of sandboxes to have fun with by default.

## How to add your own sandboxes:

1. Implement a new sandbox class in a new file by inheriting from the Test class. E.g.:
    MY_SANDBOX=class('MY_SANDBOX', Test)

2. Save it in a .lua file with matching name in the tests/ directory. E.g.:
    tests/MY_SANDBOX.lua

3. Now your sandbox will show up in the application's drop box of sandboxes. Choose it to run it. Have fun tweaking it!
