/*
 * boxlib.scad
 * A configurable, printable utility box and lid
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */
 
use <MCAD/boxes.scad>
use <../../lib/shapes.scad>

/*
 * _coin - make a disc with rounded rim
 *
 * radius - radius of disc
 * radius2 - radius of edge relief
 */
module _coin(radius, radius2)
{
    cylinder(h=2*radius2, r=radius-radius2, center=true);
    rotate_extrude(angle=360)
    translate([radius-radius2, 0, 0])
        circle(r=radius2);
}

/*
 * RoundedBox2 - box with different relief radii on vertical and horizontal edge
 * 
 * size - [x,y,z]
 * radius - relief on vertical edges
 * radius2 - relief on horizontal edges
 * top - (true) round top edges
 * bottom - (true) round bottom edges
 * 
 * TODO: ignores top/bottom flags
 */
module RoundedBox2(size, radius, radius2, top=true, bottom=true)
{
    rot = [ [0,0,0], [90,0,90], [90,90,0] ];

    cube([size[0], size[1]-radius*2+.02, size[2]-radius2*2+.02], center=true);
    cube([size[0]-radius*2+.02, size[1], size[2]-radius2*2+.02], center=true);
    
    cube([size[0]-radius*2+.02, size[1]-radius2*2+.02, size[2]], center=true);
    cube([size[0]-radius2*2+.02, size[1]-radius*2+.02, size[2]], center=true);

    // Vertical edges
    for (x = [radius-size[0]/2, -radius+size[0]/2],
         y = [radius-size[1]/2, -radius+size[1]/2]) {
        rotate(rot[0])
        translate([x,y,0])
            cylinder(h=size[2]-2*radius2+.02, r=radius, center=true);
    }

    // Top edges
    for (axis = [1,2]) {
        for (x = [radius2-size[axis]/2, -radius2+size[axis]/2],
             y = [radius2-size[(axis+1)%3]/2, -radius2+size[(axis+1)%3]/2]) {
            rotate(rot[axis])
            translate([x, y, 0])
                cylinder(h=size[(axis+2)%3]-2*radius+.02, r=radius2, center=true);
        }
    }

    // Corners
    // if the corner is already squared, this is inside its radius and invisible
    for (x = [radius-size[0]/2, -radius+size[0]/2],
           y = [radius-size[1]/2, -radius+size[1]/2],
           z = [radius2-size[2]/2, -radius2+size[2]/2]) {
        translate([x,y,z]) _coin(radius=radius, radius2=radius2);
    }
}

module RoundedBox(size, radius, sidesonly=false, center=false)
{
    if (center) {
        roundedBox(size, radius, sidesonly);
    } else {
        translate([size[0]/2, size[1]/2, size[2]/2])
            roundedBox(size, radius, sidesonly);
    }
}

//
// Base implementation of RoundedShell
// This is always centered because of roundedBox
//
module _RoundedShell(size, radius, thickness)
{
    difference() {
        roundedBox(size, radius, sidesonly=true);
        roundedBox([size[0] - 2*thickness,
                    size[1] - 2*thickness,
                    size[2] + .1],
                    max(0, radius - thickness),
                    sidesonly=true);
    }
}

module RoundedShell(size, radius, thickness, center=false)
{
    if (center) {
            _RoundedShell(size, radius, thickness);
    } else {
        translate([size[0]/2, size[1]/2, size[2]/2])
            _RoundedShell(size, radius, thickness);
    }
}

/*
 * _rail2 - orient a shape to rim wall
 *
 * xadjust - tune overlap
 * rot - X rotation of object, default 90
 *
 * Puts object on left and right edges
 */
module _rail2(xleft, xright, rot=90)
{
    translate([xleft, 0, 0])
    rotate([rot, 0, 0])
        children(0);
    translate([xright, 0, 0])
    rotate([rot, 0, 180])
        children(0);
}
