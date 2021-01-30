/*
 * plug.scad
 *
 * Top for shaker
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */

use <../../lib/shapes.scad>

// first, a parabola

/* [Body] */
Height = 45;
Radius = 42.5;
Taper = 2.2;
Wall = 10;
KnobMult = .25;
/* [Rim] */
RimR1Num = 31;
RimR1Den = 32;
RimR2Num = 1;
RimR2Den = 13;

$fa=.55;
$fn = 0;

Make_Plug = false;
Show_Domes = false;

module _dummy() {}

//function Func(x, f1, f2) = (x + f1) * (x + f2);
function Func2(x, a, b, c) = a*x*x + b*x + c;


//function FPts(f1, f2) = [
//    for (xv = [f1 : 0.2 : f2])
//        [xv, Func(xv, f2, f2)]
//];

function FPts2(x1, x2, a, b, c) = [
    for (xv = [x1 : 0.2 : x2+.199999])
        [xv, Func2(xv, a, b, c)],
    [0,0]
];
    
module donut(r1, r2)
{
    rotate_extrude()
    translate([r1, 0, 0])
    circle(r=r2, $fn=40);
}

module _dome(h, r)
{
    A = -(h+.01)/(r*r);
    B = 0;
    C = h-.01;

    pts = FPts2(0, r, A, B, C);
    //echo(pts);

    polygon(pts);
}
module dome(h, r)
{
    A = -(h+.01)/(r*r);
    B = 0;
    C = h-.01;

    pts = FPts2(0, r, A, B, C);
    //echo(pts);

    rotate_extrude()
        _dome(h, r);
}
    
module render_plug()
{
    difference() {
        union() {
            render()
            cylinder(h=Height/2+.2, r1=Radius-Taper, r2=Radius);
            render()
            translate([0, 0, Height/2])
                donut(r1=Radius*RimR1Num/RimR1Den,
                      r2=Height*RimR2Num/RimR2Den);
            render()
            translate([0, 0, Height/2])
                dome(h=Height/2, r=Radius*1.03125);
            render()
            translate([0,0,Height])
                sphere(r=Radius*KnobMult);
        }
        render()
        translate([0,0,-0.01])
            dome(h=Height*.75, r=Radius-Wall);
        render()
        translate([0, 0, Height*.55])
            cylinder(h=Height*.45,r1=Height*.4,r2=0);
    }
}

if (Make_Plug)
    render_plug();

if (Show_Domes) {
    translate([0, Height/2, 0])
        _dome(h=Height/2, r=Radius*1.03125);
 //   translate([0,0,-0.01])
        #_dome(h=Height*.75, r=Radius-Wall);
}