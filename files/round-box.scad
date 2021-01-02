/*
 * round-box.scad
 * A configurable, printable utility box and lid
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */

use <../../lib/gems.scad> 
use <../../lib/shapes.scad> 
use <MCAD/boxes.scad>

/* [Dimensions] */

Height = 20;
Radius1 = 80;
Radius2 = 30;
Wall = 1.2;
Sections = 5;

/* [Lid] */

LidHeight = 40;
RimHeight = 8.5;
LidRadius = 1.5;
LidGap = 0.25;
LidStyle = 3;

/* [Decoration (style 2)] */

BurstSides = 8;
BurstDiv = [12,15];
BurstRadius = 2;
BurstOffset = 12;
BurstRays = 7;

GemSides = 8;
GemDiv = [1, 3];
GemRadius = 3;

GemScale = .5;

/* [Weave (style 3)] */

WeaveHeight = 1.1;
WeaveInterval = 12;
WeaveThick = 1.5;
WeaveGap = 1.1;

/* [Monostring (style 4)] */

Monogram = "Hi!";
MonoScale = 0.33;
MonoHeight = 1.75;
MonoRotate = 0;

/* [Mono3 (style 5)] */
MonoScale2 = 0.44;
MonoXAdj = [-5.5, 0.1, 5.5];

/* [Options] */
Make_Box = false;
Make_Rim = false;
Make_Lid = false;
Make_Gem = false;
Make_Wavy = false;

$fa = 0.5;
$fs = 0.5;
$fn = 0;

module mirrorself(v=[0,0,1], overlap=.02)
{
    translate([0, 0, -overlap])
        children(0);
    translate([0, 0, overlap])
        mirror(v)
        children(0);
}

module radial(radius, height, wall)
{
    translate([-wall/2,0,0])
    cube([wall, radius, height], center=false);
}

module _rim(radius, height, rtop, wbot)
{
    H = height - rtop;
    W = wbot / 2;
    Rw2 = H*H + W*W;
    //Rw = sqrt(Rw2);
    Tw2 = Rw2 - rtop*rtop;
    Tw = sqrt(Tw2);
    
    sina = (W - rtop) / Tw;
    a = asin(sina);
    yoff = rtop * sina;
    xoff = rtop * cos(a);
    
    pts = [
        [-W, 0],
        [-xoff, height - rtop + yoff ],
        [xoff, height - rtop + yoff],
        [W, 0]
    ];
    
    /* rotate to match body when fs is large */
    rotate([0,0,180])
    rotate_extrude() {
        translate([radius, 0, 0]) {
            polygon(points=pts);
            translate([0, height-rtop, 0])
                circle(r=rtop, $fn=30);
        }
    }
}

module Rim()
{
    translate([0, 0, Height])
    mirrorself(overlap=.01)
    _rim(radius=Radius1-1.5*Wall,
        height=RimHeight+.01,
        rtop=.2*Wall,
        wbot=1.5*Wall);
}

module LidGroove()
{
    gap = LidGap;
    translate([0, 0, -0.01])
    _rim(radius=Radius1-1.5*Wall,
         height=RimHeight+gap+.01,
         rtop=.2*Wall+gap,
         wbot=1.5*Wall+2*gap);
}

module render_box()
{
    as = 360/Sections;
    
    difference() {
        // Main body
        linear_extrude(height=Height)
        circle(r=Radius1);

        // reserve floor
        translate([0,0,Wall]) {
            // center compartment
            linear_extrude(height=Height+2)
                circle(r=Radius2);

            // negative space of outer compartments
            difference() {
                // radius of internal wall
                linear_extrude(height=Height+1)
                    circle(r=Radius1-2*Wall);
                
                // remove the inner circle and radials,
                translate([0,0,-1]) {
                    // radius to outside wall of inner circle
                    // (interior wall of outer compartments)
                    if (Radius2 > 0) {
                        linear_extrude(height=Height+2)
                            circle(r=Radius2+Wall);
                    }

                    // radials
                    if (Sections > 0) {
                        for (angle = [0 : as: 359]) {
                            rotate([0, 0, angle])
                            radial(radius=Radius1, height=Height+2, wall=Wall);
                        }
                    }
                }
            }
        }
    }
    // add rim last
    Rim();
}

module _burst(count=5, offset=0)
{
    adiv = 360/count;
    for (a = [0 : adiv : 359]) {
        rotate([0, 0, a])
        translate([offset, 0, 0])
            children(0);
    }
}

module lidgems(sides, ldiv, r, count=3, offset=0, zscale=1)
{
    _burst(count=count, offset=offset)
    rotate([0, 90, 0])
        gem(sides=sides, ldiv=ldiv, r=r, zscale=zscale);
}

module _roundedLid()
{
    difference() {
        cyl_rounded(height=LidHeight,
                    radius=Radius1,
                    redge=LidRadius,
                    rfn=0);
        LidGroove();
    }
}

module lid1()
{
    difference() {
        linear_extrude(height=LidHeight)
            circle(r=Radius1);
        LidGroove();
    }
}

module lid2()
{
    _roundedLid();

    if (BurstSides > 0) {
        translate([0, 0, LidHeight]) {
            scale([1, 1, GemScale])
            lidgems(sides=BurstSides,
                    ldiv=BurstDiv,
                    r=BurstRadius,
                    offset=BurstOffset,
                    count=BurstRays);
            gem(sides=GemSides, ldiv=GemDiv, r=GemRadius);
        }
    }
}

module lid3()
{
    yscale = WeaveHeight;
    period = WeaveInterval;
    gap = WeaveGap;
    wall = WeaveThick;
    
    difference() {
        union() {
            cylinder(h=LidHeight-LidRadius+.05, r=Radius1, center=false);
            
            intersection() {
                cyl_rounded(height=LidHeight,
                            radius=Radius1,
                            redge=LidRadius);
                translate([0,0,LidHeight-wall-yscale/2]) {
                    cyl_shell(h=2*yscale+wall,
                          r=Radius1,
                          wall=wall,
                          center=true);
                    cyl_weave(h=LidHeight,
                          r=Radius1,
                          wscale=yscale,
                          wgap=gap,
                          wcycles=LidRadius/period
                          );
                }
            }
        }
        LidGroove();
    }
}

module lid4()
{
    size = MonoScale * Radius1;

    if (MonoHeight >= 0) {
        _roundedLid();
    
        rotate([0, 0, MonoRotate])
        translate([0, -size/2, LidHeight+MonoHeight/2-.005])
            linear_extrude(MonoHeight+.01, center=true)
            text(text=Monogram,
                 size=size,
                 halign="center",
                 font="Script MT Bold:style=Italic",
                 $fn=0);
    } else {
        difference() {
            _roundedLid();
    
            translate([0, -size/2, LidHeight+MonoHeight/2])
            linear_extrude(-MonoHeight+.1, center=true)
            text(text=Monogram,
                 size=size,
                 halign="center",
                 font="Script MT Bold:style=Italic",
                 $fn=0);
        }
    }
}

module mono(str, idx)
{
    if (idx < 3) {
        size = (idx == 1? MonoScale2 : MonoScale) * Radius1;
        base = (idx == 1? (MonoScale - MonoScale2)/2 * Radius1 : 0);
        translate([MonoXAdj[idx], base, 0])
        text(text=str[idx],
            size=size, 
            halign="center",
            font="Script MT Bold:style=Italic",
            $fn=0);
        mono(str, idx+1);
    }
}
 
module lid5()
{
    assert(MonoHeight > 0);

    size = MonoScale * Radius1;

    _roundedLid();

    rotate([0, 0, MonoRotate])
    translate([0, -size/2, LidHeight+MonoHeight/2-.05])
        linear_extrude(MonoHeight+.05, center=true)
    mono(str=Monogram, idx=0);    
}


if (Make_Box) {
    render_box();
}

if (Make_Lid) {
    if (LidStyle == 1)
        lid1();
    else if (LidStyle == 2)
        lid2();
    else if (LidStyle == 3)
        lid3();
    else if (LidStyle == 4)
        lid4();
    else if (LidStyle == 5)
        lid5();
}

if (Make_Rim) {
    Rim();
    //rim(radius=Radius1-Wall, height=RimHeight, rtop=.2*Wall , wbot=Wall);
}

if (Make_Gem) {
    lidgems(sides=7, ldiv=[12, 15], r=2, offset=6, count=5);
}

if (Make_Wavy)
    weave();

