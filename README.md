-----------------------
LÖVE2D physics testbed

It is a physics sandbox written for the LÖVE2d engine, using the Lua scripting language. The underyling physics engine is called Bo
x2d.

For more information:
www.lua.org
www.love2d.org
www.box2d.org

How to add your own tests:

1)
Create a new class, by inheriting my Test class.
MYSUPERTEST=class('MYSUPERTEST', Test)

2)
Save it in a lua file which name matches your class. Eg. MYSUPERTEST.lua

3)
Put this file in the \tests directory

4)
Now your test will show up in the application's drop box.