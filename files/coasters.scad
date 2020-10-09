/*
 * coasters.scad
 * 
 * Protect your furniture!
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */

use <../../lib/shapes.scad> 

Radius = 50;
Height = 5;
Margin = 1.1;
EdgeRadius = 2.5;
Wall = 3;

WeaveHeight = 1.1;
WeaveThick = 1.4;
WeaveInterval = 15;
WeaveGap = 2.2;

$fn=120;

/*
 * stack child n times
 */
module stack(n, zoffset)
{
    for (i = [0 : n-1]) {
        translate([0,0,i*zoffset])
        children(0);
    }
}

module coaster()
{
    yscale = WeaveHeight;
    period = WeaveInterval;
    gap = WeaveGap;

    difference() {
        union() {
            cyl_shell(h=Height,
                      r=Radius,
                      wall=Wall,
                      center=false);
            cylinder(h=Height-Margin-yscale-WeaveThick/2,
                     r=Radius,
                     center=false);
            translate([0,0,Height-Margin-yscale-WeaveThick/2])
                stack(2, -(WeaveThick - .03))
                disc_weave(h=Height,
                          r=Radius,
                          yscale=yscale,
                          gap=gap,
                          period=period,
                          wall=WeaveThick);
        }
        translate([0,0,-(yscale+WeaveThick)])
        cube([2*Radius, 2*Radius, 2*(yscale+WeaveThick)], center=true);
    }
}

coaster();