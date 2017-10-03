/*
 * Entry Point
 * Sets up THREE.js on the DOM and sets up input from the browser.
 * Written by Bryce Summers on 11/22/2016
 */

var renderer;
var root_e_scene;
var root_camera;

var input;
var root_AABB;

function init()
{
    // run some Tests.
    new SEE.Testing();

    // Initialize all of the global material, mesh constructor's, etc.
    SEE.init_style();

    // Camera.
    dim = {x:0, y:0, w:window.innerWidth, h:innerHeight, padding:10};
    // Fixed reolution viewport.
    //var dim = {x:0, y:0, w:1200, h:800, padding:10};

    // Scene Graph.
    root_e_scene = new SEE.E_Scene()

    var zoom = 2
    root_camera = new THREE.OrthographicCamera( dim.w / - 2/zoom, dim.w / 2/zoom, dim.h / 2/zoom, dim.h / - 2/zoom, 1, 600)
    //root_camera = new THREE.PerspectiveCamera( 75, dim.w/dim.h, 0.1, 1000)
    var dist = 300
    //root_camera.position.copy(new THREE.Vector3(dim.w/2, dim.h/2, dist))
    //root_camera.lookAt(new THREE.Vector3(dim.w/2, dim.h/2, 0))
    //root_camera.position.z = 5
    
    //root_camera.position.copy(new THREE.Vector3(dist, dist, dist))// x, z, y is height off of plane.
    //root_camera.lookAt(new THREE.Vector3(0, 0, 0))
    // NOTE: camera position is now controlled in tools such as the i_camera_rotation.

    // Renderer.
    var params = {
        antialias: true,
    };
    
    init_renderer(params);

    renderer.setClearColor( 0xFFFFFF ); // 0xD8C49E, brown

    init_input();
}

function init_renderer(params)
{
    var container = document.getElementById( 'container' );
    renderer = new THREE.WebGLRenderer(params);
    renderer.setPixelRatio( dim.w / dim.h /*window.devicePixelRatio*/ );
    container.appendChild( renderer.domElement );
    // Set the render based on the size of the window.
    onWindowResize();
}

function init_input()
{
    // Initialize the root of the input specification tree.
    input = new SEE.I_All_Main(root_e_scene, root_camera);

    // Provide the scene with a hook into the io tree.
    root_e_scene.setInputRoot(input);

    window.addEventListener( 'resize', onWindowResize, false);

    //window.addEventListener("keypress", onKeyPress);
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mousedown", onMouseDown);
    window.addEventListener("mouseup",   onMouseUp);
    window.addEventListener("wheel",     onMouseWheel);


    // The current system time, used to correctly pass time deltas.
    TIMESTAMP = performance.now();

    // Initialize Time input.
    beginTime();

    TIME_ON = true;
}

function beginTime()
{
    TIMESTAMP = performance.now();
    TIME_ON   = true;
    timestep();
}

function timestep()
{
    if(TIME_ON)
    {
        requestAnimationFrame(timestep)
    }
    else
    {
        return;
    }

    time_new = performance.now()
    var dt = time_new - TIMESTAMP
    TIMESTAMP = time_new

    try
    {
        input.time(dt)
    }
    catch(err)
    { // Stop time on error.
        TIME_ON = false
        throw err
    }

}

// Events.
function onWindowResize( event )
{
    //renderer.setSize( window.innerWidth, window.innerHeight );
    renderer.setSize( dim.w, dim.h );
}

// FIXME: ReWire these input events.
function onKeyDown( event )
{
    // Key codes for event.which.
    var LEFT  = 37
    var RIGHT = 39
    input.key_down(event);
}

function onKeyUp( event )
{
    // Key codes for event.which.
    var LEFT  = 37
    var RIGHT = 39
    input.key_up(event);
}


function onMouseMove( event )
{
    input.mouse_move(translateEvent(event));
}

function onMouseDown( e )//event
{
    //http://stackoverflow.com/questions/2405771/is-right-click-a-javascript-event
    var isRightMB;
    e = e || window.event;

    if ("which" in e)  // Gecko (Firefox), WebKit (Safari/Chrome) & Opera
        isRightMB = e.which == 3; 
    else if ("button" in e)  // IE, Opera 
        isRightMB = e.button == 2; 

    if(isRightMB)
        return

    input.mouse_down(translateEvent(e));
}

function onMouseUp( event )
{
    input.mouse_up(translateEvent(event));
}

// https://developer.mozilla.org/en-US/docs/Web/Events/wheel
function onMouseWheel( event )
{
    input.mouse_wheel(event);
}

function animate()
{
    requestAnimationFrame( animate );
    render();
}

function render()
{
    renderer.render(root_e_scene.getVisual(), root_camera);
}

// Since we are using a fixed size screen, we will need to translate the events.
// FIXME: Consider whether we want to preserve other properties of the mouse events.
function translateEvent(event)
{
    return {x: event.x -= window.innerWidth/2 - dim.w/2,
            y: event.y/* -= window.innerHeight/2 - dim.h/2*/}
}

init();
animate();