/*
 * measure.scad
 *
 * barware
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */

use <../../lib/shapes.scad>

/* [Shot Glass] */
Height = 40;
Base = 12.7;
Angle = 82;
Wall = .8;
HashSet = 0;
$fn = 90;

/* [Hash Marks] */
Hdepth = 1.1;
Hheight = 1.5;
Hlip = .5;
Hembed = 0.2;

Use_Hash1 = true;
Use_Hash2 = false;

module _dummy() {}

_oz_to_ml = 29.5735;

// _to_ml factor
//  volume, spanlist(angle), space(angle), rotate
hash_sg = [ _oz_to_ml,
           [[.25, [4, 4, 4, 4], 7, -18.5],
            [ .5, [18, 18],     4, -19],
            [  1, [41],         0, -19],
            [1.5, [19, 19, 19], 4, -33],
            [  2, [84],         0, -41] ]];

hash_sg_ml = [ 1,
           [[  5, [5, 5, 5, 5], 10, 0],
            [ 10, [20],         13, 15],
            [ 15, [5, 5, 5, 5], 10, 0],
            [ 20, [50],         10, 0],
            [ 25, [5, 5, 5, 5], 10, 0],
            [ 30, [80],         10, -15],
            [ 40, [90],         10, -20],
            [ 50, [100],        10, -25],
            [ 60, [120],       0, -35]
            ]];
            
hash_2C = [ _oz_to_ml,
           [[1, [5], 0, 0],
            [2, [10], 0, 0],
            [4, [20], 0, 0],
            [8, [40], 0, 0],
            [12, [40, 20], 0, 0] ]];

hash_500ml = [ 1,
           [[ 50, [5, 5, 5, 5, 5, 5, 5], 10, 5],
            [100, [104], 0, 0],
            [150, [5, 5, 5, 5, 5, 5, 5], 10, 5],
            [200, [104], 0, 0],
            [250, [5, 5, 5, 5, 5, 5, 5], 10, 5],
            [300, [104], 0, 0],
            [350, [5, 5, 5, 5, 5, 5, 5], 10, 5],
            [400, [104], 0, 0],
            [450, [5, 5, 5, 5, 5, 5, 5], 10, 5],
            [500, [104], 0, 0] ]];

hash_sets = [hash_sg, hash_2C, hash_sg_ml, hash_500ml];

function cupwall(h, r, a, w) = 
    let (sina = sin(a), cosa = cos(a), tana = tan(a),
         x2 = r + w*sina, y2 = w - w*cosa)
    [ [0,0], [r, 0],
      for (_a = [0 : a/10 : a+.1])
          [r + w*sin(_a), w - w*cos(_a)], 

// flat edge
//      [x2 + h/tana, y2 + h],  
//      [r + h/tana, w + h],

// half round edge
      for (_a = [-(90-a)/2 : (360/$fn) : 180-(90-a)/2])
          [(r+x2)/2 + h/tana + (w/2)*cos(_a), (w+y2)/2 + h + (w/2)*sin(_a)],

      [r, w], [0, w],
      [0, 0] ];

function ml_to_oz(ml) = ml / 29.5735;
function oz_to_ml(oz) = oz * 29.5735;

function r2(h, r, a) = r + h / tan(a);

// measure is mm, 1000/cc
function volume(h, r1, r2) = h*PI*(r1*r1 + r2*r2)/2 / 1000; 

function _vtoh(v, h, r1, r2) = 
let (pi2 = PI*PI, pi3 = PI*PI*PI,
     h2 = h*h, h3 = h*h*h, h6 = h3*h3,
     r12 = r1*r1, r13 = r1*r1*r1, r14 = r12*r12, r15=r12*r13, r16 = r13*r13,
     r22 = r2*r2, r23 = r2*r2*r2, r24 = r2*r2*r2*r2
)
pow((-20 * pi3 * h3 * r16 + 
  60 * pi3 * h3 * r15 * r2 -
  60 * pi3 * h3 * r14 * r22 +
  20 * pi3 * h3 * r13 * r23 +
  54 * pi2 * h2 * r14 * v -
 216 * pi2 * h2 * r13 * r2 * v +
 324 * pi2 * h2 * r12 * r22 * v - 
 216 * pi2 * h2 * r1 * r23 * v +
  54 * pi2 * h2 * r24 * v +
 sqrt(4 * pow((2 * pi2 * h2 * r14 -
           4 * pi2 * h2 * r13 * r2 +
           2 * pi2 * h2 * r12 * r22), 3) +
   pow((-20 * pi3 * h3 * r16 +
        60 * pi3 * h3 * r15 * r2 -
        60 * pi3 * h3 * r14 * r22 +
        20 * pi3 * h3 * r13 * r23 +
        54 * pi2 * h2 * r14 * v -
       216 * pi2 * h2 * r13 * r2 * v +
       324 * pi2 * h2 * r12 * r22 * v -
       216 * pi2 * h2 * r1 * r23 * v +
        54 * pi2 * h2 * r24 * v), 2))), (1/3))
/
(3 * pow(2,(1/3)) * (PI * r12 - 2 * PI * r1 * r2 + PI * r22))
-
(pow(2,(1/3)) * (2 * pi2 * h2 * r14 - 
            4 * pi2 * h2 * r13 * r2 +
            2 * pi2 * h2 * r12 * r22))
/
(3 * (PI * r12 - 2 * PI * r1 * r2 + PI * r22) * 
   pow(( -20 * pi3 * h3 * r16 + 
      60 * pi3 * h3 * r15 * r2 - 
      60 * pi3 * h3 * r14 * r22 + 
      20 * pi3 * h3 * r13 * r23 + 
      54 * pi2 * h2 * r14 * v - 
     216 * pi2 * h2 * r13 * r2 * v + 
     324 * pi2 * h2 * r12 * r22 * v - 
     216 * pi2 * h2 * r1 * r23 * v + 
      54 * pi2 * h2 * r24 * v + 
     sqrt(4 * pow((2 * pi2 * h2 * r14 -
               4 * pi2 * h2 * r13 * r2 + 
               2 * pi2 * h2 * r12 * r22), 3) +
        pow((-20 * pi3 * h3 * r16 +
          60 * pi3 * h3 * r15 * r2 - 
          60 * pi3 * h3 * r14 * r22 + 
          20 * pi3 * h3 * r13 * r23 + 
          54 * pi2 * h2 * r14 * v - 
         216 * pi2 * h2 * r13 * r2 * v + 
         324 * pi2 * h2 * r12 * r22 * v - 
         216 * pi2 * h2 * r1 * r23 * v + 
          54 * pi2 * h2 * r24 * v), 2))), (1/3))) +
(2 * (PI * h * r12 - PI * h * r1 * r2))
/
(3 * (PI * r12 - 2 * PI * r1 * r2 + PI * r22))
;
// and r1 - r2!=0 and h!=0

function vtoh(v, h, r1, r2) = 
    (r1 == r2)? (0.31831 * v / (r1 * r1)) : _vtoh(v, h, r1, r2);


/* Wolfram Alpha says:
p = (-20 π^3 h^3 r1^6 + 60 π^3 h^3 r1^5 r2 - 60 π^3 h^3 r1^4 r2^2 + 20 π^3 h^3 r1^3 r2^3 + 54 π^2 h^2 r1^4 v - 216 π^2 h^2 r1^3 r2 v + 324 π^2 h^2 r1^2 r2^2 v - 216 π^2 h^2 r1 r2^3 v + 54 π^2 h^2 r2^4 v + sqrt(4 (2 π^2 h^2 r1^4 - 4 π^2 h^2 r1^3 r2 + 2 π^2 h^2 r1^2 r2^2)^3 + (-20 π^3 h^3 r1^6 + 60 π^3 h^3 r1^5 r2 - 60 π^3 h^3 r1^4 r2^2 + 20 π^3 h^3 r1^3 r2^3 + 54 π^2 h^2 r1^4 v - 216 π^2 h^2 r1^3 r2 v + 324 π^2 h^2 r1^2 r2^2 v - 216 π^2 h^2 r1 r2^3 v + 54 π^2 h^2 r2^4 v)^2))^(1/3)/(3 2^(1/3) (π r1^2 - 2 π r1 r2 + π r2^2)) - (2^(1/3) (2 π^2 h^2 r1^4 - 4 π^2 h^2 r1^3 r2 + 2 π^2 h^2 r1^2 r2^2))/(3 (π r1^2 - 2 π r1 r2 + π r2^2) (-20 π^3 h^3 r1^6 + 60 π^3 h^3 r1^5 r2 - 60 π^3 h^3 r1^4 r2^2 + 20 π^3 h^3 r1^3 r2^3 + 54 π^2 h^2 r1^4 v - 216 π^2 h^2 r1^3 r2 v + 324 π^2 h^2 r1^2 r2^2 v - 216 π^2 h^2 r1 r2^3 v + 54 π^2 h^2 r2^4 v + sqrt(4 (2 π^2 h^2 r1^4 - 4 π^2 h^2 r1^3 r2 + 2 π^2 h^2 r1^2 r2^2)^3 + (-20 π^3 h^3 r1^6 + 60 π^3 h^3 r1^5 r2 - 60 π^3 h^3 r1^4 r2^2 + 20 π^3 h^3 r1^3 r2^3 + 54 π^2 h^2 r1^4 v - 216 π^2 h^2 r1^3 r2 v + 324 π^2 h^2 r1^2 r2^2 v - 216 π^2 h^2 r1 r2^3 v + 54 π^2 h^2 r2^4 v)^2))^(1/3)) + (2 (π h r1^2 - π h r1 r2))/(3 (π r1^2 - 2 π r1 r2 + π r2^2)) and r1 - r2!=0 and h!=0
*/


// convex
function hash1poly(h2, r, a, w) =
    let (xur = r + ((a==90)?0:h2/tan(a)), yur=w+h2)
    [[xur+Hembed, yur],
     [xur+Hembed, yur-Hheight],
     [xur-.25, yur-Hheight],
     [xur-Hdepth, yur-Hlip],
     [xur-Hdepth, yur],
     [xur+Hembed, yur]];

// concave
function hash2poly(h2, r, a, w) =
    let (xur=r+((a==90)?0:h2/tan(a)), 
         xlr=r+((a==90)?0:(h2-Hheight)/tan(a)),
         yur=w+h2, adj=.1)
    [[xur-adj, yur],
     [xur+Hdepth, yur-Hdepth],
     [xlr, yur-Hheight],
     [xlr-adj, yur-Hheight],
     [xlr-adj, yur]];
     
module dosegments(aoff, index, imax, spans, space, shape)
{
    span = spans[index];
    rotate([0, 0, aoff])
    rotate_extrude(angle=span)
    polygon(shape);
    if (index < imax)
        dosegments(aoff+span+space, index+1, imax, spans, space, shape);
}

module dohash(h, r1, angle, wall, poly=0)
{
    r2 = r2(h, r1, angle);

    convert = hash_sets[HashSet][0];
    for (hash = hash_sets[HashSet][1]) {
        volume = hash[0] * convert;
        spans = hash[1];
        space = hash[2];
        prerot = hash[3];

        h2 = vtoh(volume*1000, h, r1, r2);
        if (h2 <= h) {
            shape = (poly == 0) ?
                hash1poly(h2=h2, r=r1, a=angle, w=wall):
                hash2poly(h2=h2, r=r1, a=angle, w=wall);
            rotate([0,0,prerot])
            for (q = /*[0,120, 240]*/[0, 180]) {
                dosegments(q, 0, len(spans)-1, spans, space, shape);
            }
        }
    }
}

module measure(h, r1, angle, wall)
{
    rotate_extrude()
    polygon(cupwall(h, r1, angle, wall));

    r2 = r2(h, r1, angle);
    v = volume(h, r1, r2);
    echo(str("Volume ", v, " ml, ", ml_to_oz(v), " oz ") );
}


difference() {
    union() {
        measure(h=Height, r1=Base, angle=Angle, wall=Wall);
        if (Use_Hash1)
            dohash(h=Height, r1=Base, angle=Angle, wall=Wall, poly=0);
    }
    if (Use_Hash2)
        dohash(h=Height, r1=Base, angle=Angle, wall=Wall, poly=1);
}
