# CIS 566 Project 1: Noisy Planets

### Wenli Zhao
### wenliz
- Resources:
  - [simplex noise](http://staffwww.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf)
- live demo: coming soon!
![](planet1.png)
- Features:
  - For my planet, I used a 3D simplex noise function. Simplex noise is similar to Perlin, but allows for higher dimensions and lower computational overhead. I composed five samples of the noise at different frequencies to give it a more "terrain-like" effect. I achieved a plateau-like top by clampng the noise, scaling it by the normal and actually carving "in" the planet. 
  - In order to correctly compute the normals of the terrain, rather than using a very computationally expensive method such as sampling noise function 6 times in the x, y, and z directions to get the terrain height in neigboring points, I used something recommended by Byumjin Kim. He suggested the dFdx and dFdy function in the fragment shader. That's why I have the noise function copied in the fragment sahder as well. These functions compute the position of the neighboring fragments. This led to some visual artifacts such as lack of anti-aliasing and normals that aren't quite correct at intersections where the normal is not smooth. However, the tradeoff for performance was extremely worth it on my machine.
  - Under a certain height, I considered the terrain "water" and added wave-like movement to the water. I say wave-like because I used some sinusoidal functions and kind of arbitrarily wrote a function that moved the water in a periodic manner.
  - There are also a lot of toggle-able features. My "plateau" doesn't quite work at the moment, so all planets have plateaus, but you can adjust the color of the land, the sea, the level of the water and the noisy-ness of the planet!! (The original idea was to be able to change from plateau to mountanous.)

## Objective
- Continue practicing WebGL and Typescript
- Experiment with noise functions to procedurally generate the surface of a planet
- Review surface reflection models

## Base Code
You'll be using the same base code as in homework 0.

## Assignment Details
- Update the basic scene from your homework 0 implementation so that it renders
an icosphere once again. We recommend increasing the icosphere's subdivision
level to 6 so you have more vertices with which to work.
- Write a new GLSL shader program that incorporates various noise functions and
noise function permutations to offset the surface of the icosphere and modify
the color of the icosphere so that it looks like a planet with geographic
features. Try making formations like mountain ranges, oceans, rivers, lakes,
canyons, volcanoes, ice caps, glaciers, or even forests. We recommend using
3D noise functions whenever possible so that you don't have UV distortion,
though that effect may be desirable if you're trying to make the poles of your
planet stand out more.
- Implement various surface reflection models (e.g. Lambertian, Blinn-Phong,
Matcap/Lit Sphere, Raytraced Specular Reflection) on the planet's surface to
better distinguish the different formations (and perhaps even biomes) on the
surface of your planet. Make sure your planet has a "day" side and a "night"
side; you could even place small illuminated areas on the night side to
represent cities lit up at night.
- Add GUI elements via dat.GUI that allow the user to modify different
attributes of your planet. This can be as simple as changing the relative
location of the sun to as complex as redistributing biomes based on overall
planet temperature. You should have at least three modifiable attributes.
- Have fun experimenting with different features on your planet. If you want,
you can even try making multiple planets! Your score on this assignment is in
part dependent on how interesting you make your planet, so try to
experiment with as much as you can!

For reference, here is a planet made by your TA Dan last year for this
assignment:

![](danPlanet.png)

Notice how the water has a specular highlight, and how there's a bit of
atmospheric fog near the horizon of the planet. This planet used only simple
Fractal Brownian Motion to create its mountainous shapes, but we expect you all
can do something much more exciting! If we were to grade this planet by the
standards for this year's version of the assignment, it would be a B or B+.

## Useful Links
- [Implicit Procedural Planet Generation](https://static1.squarespace.com/static/58a1bc3c3e00be6bfe6c228c/t/58a4d25146c3c4233fb15cc2/1487196929690/ImplicitProceduralPlanetGeneration-Report.pdf)
- [Curl Noise](https://petewerner.blogspot.com/2015/02/intro-to-curl-noise.html)
- [GPU Gems Chapter on Perlin Noise](http://developer.download.nvidia.com/books/HTML/gpugems/gpugems_ch05.html)
- [Worley Noise Implementations](https://thebookofshaders.com/12/)


## Submission
Commit and push to Github, then submit a link to your commit on Canvas.

For this assignment, and for all future assignments, modify this README file
so that it contains the following information:
- Your name and PennKey
- Citation of any external resources you found helpful when implementing this
assignment.
- A link to your live github.io demo (we'll talk about how to get this set up
in class some time before the assignment is due)
- At least one screenshot of your planet
- An explanation of the techniques you used to generate your planet features.
Please be as detailed as you can; not only will this help you explain your work
to recruiters, but it helps us understand your project when we grade it!

## Extra Credit
- Use a 4D noise function to modify the terrain over time, where time is the
fourth dimension that is updated each frame. A 3D function will work, too, but
the change in noise will look more "directional" than if you use 4D.
- Use music to animate aspects of your planet's terrain (e.g. mountain height,
  brightness of emissive areas, water levels, etc.)
- Create a background for your planet using a raytraced sky box that includes
things like the sun, stars, or even nebulae.
