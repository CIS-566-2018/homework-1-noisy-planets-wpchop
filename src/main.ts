import {vec3, vec4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 6,
  'Load Scene': loadScene, // A function pointer, essentially
  color: [255.0, 0.0, 0.0],
  land: [107.0, 109.0, 108.0],
  sea: [32.0, 199.0, 209.0],
  waterLevel: 0.1,
  noise: 5,
  plateau: true,
  shader: 'custom'
};

let icosphere: Icosphere;
let count = 0;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'color');
  gui.addColor(controls, 'land');
  gui.addColor(controls, 'sea');
  gui.add(controls, 'noise', 0,5).step(1);
  gui.add(controls, 'waterLevel', 0, 0.3);
  gui.add(controls, 'plateau');
  gui.add(controls, 'shader', ['lambert', 'custom']);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);
  gl.cullFace(gl.BACK);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const custom = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    count++;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    let col: vec4 = vec4.fromValues(controls.color[0]/255,controls.color[1]/255,controls.color[2]/255, 1.0);
    let landCol: vec4 = vec4.fromValues(controls.land[0]/255,controls.land[1]/255,controls.land[2]/255, 1.0);
    let seaCol: vec4 = vec4.fromValues(controls.sea[0]/255,controls.sea[1]/255,controls.sea[2]/255, 1.0);
    let noise: number = controls.noise;
    let plat: number = 0;
    if (controls.plateau) {plat = 1;}
    let waterLevel: number = controls.waterLevel;
    let shader = lambert;
    if (controls.shader == 'custom') {
      shader = custom;
    }
    renderer.render(camera, shader, col, landCol, seaCol, noise, plat, waterLevel, count, [
      icosphere,
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
