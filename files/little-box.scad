/*
 * little-box-scad
 * A configurable, printable utility box and lid
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */
 
use <MCAD/boxes.scad>

/* [Dimensions] */

Length = 80;
Width = 50;
Height = 20;
Radius = 2.5;
Thickness = 1.2;

/* [Interior] */

Rounded = false;
Group1Span = 50;    // [100]
Split = "W";        // [L:Length, W:Width]
LDiv1 = 2;
WDiv1 = 2;
LDiv2 = 1;
WDiv2 = 3;

/* [Lid] */

LidSlide = false;
// Detent+Slide changes detent
LidDetent = true;
LidSlideDepth = 0.5;
LidSlideRelief = 0.05;
LidSlideAdjust = 0.1;

LidHeight = 40;
// Rim is really RimHeight - LidThick
RimHeight = 9.5;
RimAngle = 0;
LidThick = 1.2;
LidRelief = 0.28;
// top edge radius
LidRadius = 1.1;
// Set to 0 when using slide
Notchspan = .25;

/* [Additions] */
Mounting_Holes = false;
MH_L = 3;
MH_W = 0;
MH_D = 2;
MH_ScrewSize = 4.2;

/* [Options] */
Make_Box = false;
MakeLid = false;

$fa = 0.5;
$fs = 0.5;
$fn = 60;

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
module _rail2(xadjust, rot=90)
{
    // box is centered
    lx = -Width/2 + LidThick - xadjust;
    rx = Width/2 - LidThick + xadjust;

    translate([lx, 0, 0])
    rotate([rot,0,0])
        children(0);
    translate([rx, 0, 0])
    rotate([rot,0,180])
        children(0);
}

/*
 * LDet - lid detent
 *
 * make squashed cylinder 1/3 of box length
 * centered on rim wall, use xadjust to tune
 *
 * ladjust - adjust length (make indent longer than outdent)
 * xadjust - adjust embed in rim wall
 */
module LDet(ladjust=0, xadjust=0)
{
    _rail2(xadjust,rot=90)
        scale([.5,1,1])
        cylinder(h=Length/ladjust, r=.8*LidThick-LidRelief/2, center=true);
}

module VDet(ladjust=0, xadjust=0)
{
    _rail2(xadjust, rot=0)
        scale([.5,1,1])
        cylinder(h=3, r=.8*LidThick-LidRelief/2, center=true);
}

module SlideRail(length, radius, xadjust=0, zadjust=0)
{
    translate([0,0,zadjust])
    _rail2(xadjust=xadjust,rot=90)
        //rotate([0,0,0])
        union() {
            cylinder(h=length, r=radius, center=true, $fn=7);
            translate([0,0,-length/2-1+.02])
            cylinder(h=2, r1=0, r2=radius, center=true,$fn=7);
            translate([0,0,length/2+1-.02])
            cylinder(h=2, r1=radius, r2=0, center=true,$fn=7);
        }
}

module render_box()
{
    workingWidth = Width - Thickness - 2*LidThick;
    workingLength = Length - Thickness - 2*LidThick;
    
    width1 = Split == "L"? (Group1Span * workingWidth * 0.01) : workingWidth;
    length1 = Split == "L"? workingLength : (Group1Span * workingLength * 0.01);
    wdivsize1 = width1 / WDiv1;
    ldivsize1 = length1 / LDiv1;

    w2off = (Split == "L"? width1 : 0);
    width2 = Split == "L"? (workingWidth - width1) : workingWidth;
    l2off = (Split == "L"? 0 : length1);
    length2 = Split == "L"? workingLength : (workingLength - length1);

    wdivsize2 = width2 / WDiv2;
    ldivsize2 = length2 / LDiv2;
    
    echo(str("box 1 is ",ldivsize1-Thickness,"x",wdivsize1-Thickness));
    if (Group1Span < 100)
      echo(str("box 2 is ",ldivsize2-Thickness,"x",wdivsize2-Thickness));

    difference() {
        RoundedBox(size=[Width, Length, Height], radius=Radius, sidesonly=true);

        // subtract the internal boxes
        for (woff = [Thickness + LidThick : wdivsize1 : width1],
             loff = [Thickness + LidThick : ldivsize1 : length1]) {
            translate([woff,loff,Thickness])
                RoundedBox(size=[wdivsize1-Thickness,
                                 ldivsize1-Thickness,
                                 Height+Radius],
                           radius=Radius-Thickness,
                           sidesonly=!Rounded);
        }
        // Group 2
        if (Group1Span < 100) {
            for (woff = [Thickness : wdivsize2 : width2],
                 loff = [Thickness : ldivsize2 : length2]) {
                translate([w2off + woff + Thickness, l2off + loff + Thickness, Thickness])
                    RoundedBox(size=[wdivsize2-Thickness,
                                    ldivsize2-Thickness,
                                    Height+Radius],
                               radius=Radius - Thickness,
                               sidesonly=!Rounded);
            }
        }
        // subtract the rim for the lid
        translate([-1, -1, Height - RimHeight + LidThick])
        difference() {
            RoundedShell(size=[Width + 2, Length + 2, LidHeight + 1],
                         radius=Radius + 1, thickness=LidThick + 1);
            if (LidSlide) {
                translate([LidThick+1, -1+Thickness, 0])
                cube(size=[Width-2*LidThick, Radius + 2, LidHeight + 1]);
            }
        }
        
        // cut away interior of rim - goes with slide lid
        if (RimAngle) {
            translate([(Width+2)/2,
                       (Length+2)/2+Thickness+LidThick,
                       Height+LidHeight/2 - (Length/2)*sin(RimAngle)])
            rotate([-RimAngle, 0, 0])
            cube(size=[Width+2, Length+LidHeight, LidHeight], center=true);
        }

        if (!LidSlide && LidDetent) {
            translate([Width/2, Length/2, Height-(RimHeight-LidThick)/2])
                LDet();
        }

        // Make a slide rail, subtract it from interior rim
        if (LidSlide) {
            translate([Width/2, Length/2+Radius, Height-(RimHeight-LidThick)/2])
            SlideRail(length=Length,
                      radius=LidSlideDepth,
                      xadjust=0,
                      zadjust=LidSlideAdjust);
        }

        // With slide, detent is perpendicular and at back of rail
        if (LidSlide && LidDetent) {
            translate([Width/2,
                       .9*Length,
                       Height-(RimHeight-LidThick)/2+LidSlideAdjust])
                VDet();
        }

        // Side mounting holes
        // Length wall
        if (Mounting_Holes) {
            for (i = [1 : MH_L], j = [1 : MH_D]) {
                translate([Width/2-.5, i*Length/(MH_L+1), j*Height/(MH_D+1)])
                rotate([0,90,0])
                    cylinder(h=Width+1, r=MH_ScrewSize/2, center=true);

                translate([Width/2-Thickness-.5, i*Length/(MH_L+1), j*Height/(MH_D+1)])
                rotate([0,90,0])
                    cylinder(h=Width, r=1.25*MH_ScrewSize, center=true);
            }
        }
    }
}

module render_lid()
{
    difference() {
        if (LidRadius == 0) {
            RoundedBox(size=[Width, Length, LidHeight],
                       radius=Radius, sidesonly=true, center=true);
        } else {
            translate([0, 0, LidHeight/2])
            difference() {
                RoundedBox2(size=[Width, Length, 2*LidHeight],
                        radius=Radius, radius2=LidRadius);
                translate([0, 0, LidHeight/2+1])
                    cube(size=[Width+1, Length+1, LidHeight+1], center=true);
            }
        }

        // subtract interior
        translate([0, 0, LidThick])
            RoundedBox(size=[Width - 2*LidThick - 2*Thickness,
                            Length - 2*LidThick - 2*Thickness,
                            LidHeight],
                       radius=max(0, Radius-LidThick-Thickness),
                       sidesonly=true, center=true);

        // subtract interior of rim
        // for slide, lengthen the removed piece to take the whole end away
        radjust = LidSlide? 2 * LidThick + Radius : 0;
        translate([0, radjust/2, LidThick + (LidHeight - RimHeight)/2])
            RoundedBox(size=[Width - 2*LidThick + LidRelief,
                            Length - 2*LidThick + LidRelief + radjust,
                            RimHeight],
                       radius=max(0, Radius-LidThick)+LidRelief,
                       sidesonly=true, center=true);
        // Thumb notch
        translate([0,0,LidHeight/2+LidThick])
        rotate([90,0,0])
            scale([(Notchspan/2) * Width/RimHeight, .5, 1])
            cylinder(h=Length + 1, r=RimHeight, center=true);
    }

    if (LidDetent) {
        translate([0, 0, LidHeight/2-(RimHeight-LidThick)/2])
            LDet(ladjust=-.5, xadjust=LidRelief);
    }

    if (LidSlide) {
        translate([0, 0, LidHeight/2-(RimHeight-LidThick)/2+LidSlideRelief])
            SlideRail(length=.9*Length-2*Radius,
                      radius=LidSlideDepth-.05,
                      xadjust=LidRelief,
                      zadjust=-LidSlideAdjust);
    }
    if (LidSlide && LidDetent) {
        translate([0,
                  -.8*Length/2,
                  LidHeight/2-(RimHeight-LidThick)/2-LidSlideAdjust])
            VDet(ladjust=-.5, xadjust=LidRelief);
    }
}


if (MakeLid) {
    translate([-Width/2 - 5, Length / 2, LidHeight / 2])
        render_lid();
}

if (Make_Box) {
    translate([5, 0, 0])
        render_box();
}
