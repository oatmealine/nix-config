precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

// Analys cube
// (c) 2019 FMS_Cat, MIT License

// == tweak these numbers, yee =====================================================================
#define SIZE 0.5
#define FX_NYOOOM 0.0
#define FX_FORWARD 1.0
#define FX_KICK (0.1*exp(-3.0*mod(BEAT,4.0)))
#define FX_TWIST (20.0*exp(-3.0*mod(BEAT-2.0,4.0)))
#define FX_SKEW 0.0
#define FX_DEFORM (0.2*0.0)
#define FX_DEFORM_FREQ 0.1

// == raymarch related constants ===================================================================
#define MARCH_ITER 64
#define MARCH_EPSILON 1E-4
#define MARCH_NEAR 0.01
#define MARCH_FAR 40.0
#define MARCH_MULP 0.6

// == common macros ================================================================================
#define HALF_PI 1.57079632679
#define PI 3.14159265359
#define TAU 6.28318530718
#define BEAT (time*170.0/60.0)
#define saturate(i) clamp(i,0.,1.)
#define linearstep(a,b,t) saturate(((t)-(a))/((b)-(a)))

// == common functions =============================================================================
mat2 rotate2D( float t ) {
  return mat2( cos( t ), -sin( t ), sin( t ), cos( t ) );
}

// == camera =======================================================================================
struct Camera {
  vec3 pos;
  vec3 dir;
  vec3 up;
  float roll;
  float fov;
};

Camera newCamera( vec3 pos, vec3 dir ) {
  Camera camera;
  camera.pos = pos;
  camera.dir = dir;
  camera.up = vec3( 0.0, 1.0, 0.0 );
  camera.roll = 0.0;
  camera.fov = 0.5;
  return camera;
}

// == ray ==========================================================================================
struct Ray {
  vec3 orig;
  vec3 dir;
};

Ray newRay( vec3 ori, vec3 dir ) {
  Ray ray;
  ray.orig = ori;
  ray.dir = dir;
  return ray;
}

Ray rayFromCamera( Camera camera, vec2 p ) {
  vec3 dirX = normalize( cross( camera.dir, camera.up ) );
  vec3 dirY = cross( dirX, camera.dir );
  vec2 pt = rotate2D( camera.roll ) * p;
  return newRay(
    camera.pos,
    normalize( pt.x * dirX + pt.y * dirY + camera.dir / tan( camera.fov ) )
  );
}

vec3 getRayPosition( Ray ray, float len ) {
  return ray.orig + ray.dir * len;
}

// == isect ========================================================================================
struct Intersection {
  Ray ray;
  float len;
  vec3 pos;
};

Intersection newIntersection( Ray ray, float len ) {
  Intersection isect;
  isect.ray = ray;
  isect.len = len;
  isect.pos = getRayPosition( ray, len );
  return isect;
}

// == march result =================================================================================
struct MarchResult {
  float dist;
  vec2 uv;
};

// == distFuncs ====================================================================================
float distFuncBox( vec3 p, vec3 b ) {
  vec3 d = abs( p ) - b;
  return length( max( d, 0.0 ) ) + min( max( d.x, max( d.y, d.z ) ), 0.0 );
}

vec3 deform( vec3 p ) {
  vec3 pt = p;
  pt.xy = rotate2D( FX_SKEW * pt.z ) * pt.xy;
  pt.x *= 1.0 - sqrt( FX_NYOOOM );
  pt.yz = rotate2D( FX_NYOOOM * exp( 5.0 * FX_NYOOOM ) * pt.x ) * pt.yz;
  pt.y += 2.0 * FX_SKEW * pt.x;
  pt += FX_DEFORM * (
    texture2D( tex, FX_DEFORM_FREQ * ( pt.xy ) + 0.5 ).xyz - 0.5
  );
  pt.zx = rotate2D( mod( 2.5 * time + PI, TAU ) + FX_TWIST * pt.y ) * pt.zx;
  pt.xy = rotate2D( 0.6 * sin( 0.9 * time ) ) * pt.xy;
  pt.yz = rotate2D( 0.6 * sin( 1.4 * time ) ) * pt.yz;
  pt -= normalize( pt ) * FX_KICK * sin( 15.0 * length( pt ) - 40.0 * time );
  return pt;
}

MarchResult distFunc( vec3 p ) {
  MarchResult result;

  vec3 pt = p;
  pt = deform( pt );
  result.dist = distFuncBox( pt, vec3( SIZE ) );

  vec3 spt = vec3( 1.0 );

  if ( FX_FORWARD > 0.0 ) {
    vec3 ptIfs = p;
    ptIfs.z = mod( ptIfs.z - 16.0 * time + 3.0 * sin( HALF_PI * BEAT + 0.5 ), 6.0 ) - 3.0;
    for ( int i = 0; i < 6; i ++ ) {
      float fi = float( i );
      spt *= sign( ptIfs );
      ptIfs = abs( ptIfs ) - vec3( 3.2, 4.5, 1.2 ) / max( 1E-2, FX_FORWARD ) * pow( 0.5, fi );
      ptIfs.xy = rotate2D( 1.1 ) * ptIfs.xy;
      ptIfs.zx = rotate2D( 2.1 ) * ptIfs.zx;
    }

    ptIfs = deform( ptIfs );

    float distIfs = distFuncBox( ptIfs, vec3( SIZE ) );

    if ( result.dist < distIfs ) {
      spt = vec3( 1.0 );
    } else {
      result.dist = distIfs;
      pt = ptIfs;
    }
  }

  vec3 abspt = abs( pt );
  float n = max( abspt.x, max( abspt.y, abspt.z ) );

  result.uv = 0.5 + (
    ( n == abspt.z ) ? ( pt.xy * vec2( sign( pt.z ), 1.0 ) ) :
    ( n == abspt.x ) ? ( pt.zy * vec2( -sign( pt.x ), 1.0 ) ) :
    ( pt.xz * vec2( 1.0, -sign( pt.y ) ) )
  ) * spt.x * spt.y * spt.z * 0.5 / SIZE;

  return result;
}

vec3 normalFunc( vec3 p, float dd ) {
  vec2 d = vec2( 0.0, dd );
  return normalize( vec3(
    distFunc( p + d.yxx ).dist - distFunc( p - d.yxx ).dist,
    distFunc( p + d.xyx ).dist - distFunc( p - d.xyx ).dist,
    distFunc( p + d.xxy ).dist - distFunc( p - d.xxy ).dist
  ) );
}

vec3 normalFunc( vec3 p ) {
  return normalFunc( p, MARCH_NEAR );
}

// == main procedure ===============================================================================
void main() {
  vec2 p = v_texcoord - 0.5;
  Camera camera = newCamera( vec3( 0.0, 0.0, 0.0 ), vec3( 0.0, 0.0, -1.0 ) );
  camera.fov = 0.6 + 0.9 * FX_FORWARD * ( 0.5 + 0.5 * sin( HALF_PI * BEAT - 0.5 ) );
  camera.pos.z = 0.5 + 1.5 / camera.fov;
  Ray ray = rayFromCamera( camera, p );

  Intersection isect;
  float rayLen = MARCH_NEAR;
  vec3 rayPos = getRayPosition( ray, rayLen );
  MarchResult result;
  for ( int i = 0; i < MARCH_ITER; i ++ ) {
    result = distFunc( rayPos );
    if ( abs( result.dist ) < MARCH_NEAR ) { break; }
    rayLen += result.dist * MARCH_MULP;
    if ( MARCH_FAR < rayLen ) { break; }
    rayPos = getRayPosition( ray, rayLen );
  }

  vec3 bg = vec3( 0.0 );

  if ( abs( result.dist ) < MARCH_NEAR ) {
    vec3 normal = normalFunc( rayPos );
    float edge = linearstep( 0.498, 0.499, abs( result.uv.x - 0.5 ) );
    edge += linearstep( 0.495, 0.497, abs( result.uv.y - 0.5 ) );
    vec2 uv = result.uv;
    vec4 tex = texture2D( tex, uv );
    float fog = exp( -0.2 * max( 0.0, rayLen - 3.0 ) );
    gl_FragColor = vec4( fog * mix(
      0.1 + 0.1 * normal + 0.8 * tex.rgb,
      1.0 + 1.0 * sin( vec3( 0.0, 1.0, 2.0 ) + 10.0 * length( result.uv - 0.5 ) - 10.0 * time ),
      edge
    ), 1.0 );
  } else {
    discard;
    //gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
  }
}
