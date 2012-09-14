"BGLScene" is an OpenGL ES scene graph library I created during development of
the game [Fingerpaintball][fpb]. Although it was designed to be a general
purpose library, I only added functionality as I needed it for the game I was
working on. In other words, don't be surprised if functionality that "obviously"
belongs in a scene graph library is missing.

Over a decade ago, I took [Don Greenberg][dpg]'s CS 417/418 at Cornell. We used
OpenGL for our projects, but for education's sake, the professor only permitted
a subset of the OpenGL API: instead of boxes and spheres, we were only allowed
to use triangles, and build any shapes we needed from those. And instead of the
built-in lighting and materials settings, we had to write our own code to
calculate the colors of all the surfaces.

A decade later, when the OpenGL ES specification was derived from OpenGL, it was
optimized for mobile devices by throwing out all of the "unnecessary" parts and
leaving only the bare minimum required to render 3D graphics. Turns out the
parts they left were pretty much the same as the parts I was allowed to use in
class.

The point is, a lot of the credit for this code goes to that course, as the code
we developed there had a lot in common with the code developed here.

Remember this, next time you begrudge an educator for making you do things the
hard way!

[fpb]: http://itunes.apple.com/us/app/fingerpaintball/id404951270
[dpg]: http://www.graphics.cornell.edu/DPG.html
