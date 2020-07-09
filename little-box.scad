/*
 * (C)Copyright 2020 Kent Forschmiedt
 *
 * Released under Creative Commons
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

LidHeight = 4;
LidThick = 1.2;

/* [Options] */
MakeBox = true;
MakeLid = true;

$fa = 0.5;
$fs = 0.5;

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
                    radius,
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

module render_box()
{
    workingWidth = Width - Thickness - 2*LidThick;
    workingLength = Length - Thickness - 2*LidThick;
    
    width1 = Split == "L"? (Group1Span * workingWidth * 0.01) : workingWidth;
    length1 = Split == "L"? workingLength : (Group1Span * workingLength * 0.01);
    wdivsize1 = width1 / WDiv1;
    ldivsize1 = length1 / LDiv1;

    w2off = (Split == "L"? width1 : 0) + Thickness;
    width2 = Split == "L"? ((100 - Group1Span) * workingWidth * 0.01) : workingWidth;
    l2off = (Split == "L"? 0 : length1) + Thickness;
    length2 = Split == "L"? workingLength : ((100 - Group1Span) * workingLength * 0.01);
    wdivsize2 = width2 / WDiv2;
    ldivsize2 = length2 / LDiv2;

    difference() {
        RoundedBox(size=[Width, Length, Height], radius=Radius, sidesonly=true);

        // subtract the internal boxes
        for (woff = [Thickness + LidThick :
                     wdivsize1 :
                     width1])
        for (loff = [Thickness + LidThick :
                     ldivsize1 :
                     length1]) {
            translate([woff,loff,Thickness])
                RoundedBox(size=[wdivsize1-Thickness,
                                 ldivsize1-Thickness,
                                 Height+Radius],
                           radius=Radius - Thickness,
                           sidesonly=!Rounded);
        }
        // Group 2
        if (Group1Span < 100) {
            for (woff = [Thickness :
                         wdivsize2 :
                         width2])
            for (loff = [Thickness :
                         ldivsize2 :
                         length2]) {
                translate([w2off + woff, l2off + loff, Thickness])
                    RoundedBox(size=[wdivsize2-Thickness,
                                    ldivsize2-Thickness,
                                    Height+Radius],
                               radius=Radius - Thickness,
                               sidesonly=!Rounded);
            }
        
        }

        // subtract the rim for the lid
        translate([-1, -1, Height - LidHeight + LidThick])
            RoundedShell(size=[Width + 2, Length + 2, LidHeight + 1],
                         radius=Radius, thickness=LidThick + 1);
    }
}

module render_lid()
{

    difference() {
        RoundedBox(size=[Width, Length, LidHeight],
                   radius=Radius, sidesonly=true);
        translate([LidThick, LidThick, LidThick])
            // Reduce interior radius slightly to relax fit with box
            RoundedBox(size=[Width - 2*LidThick,
                            Length - 2*LidThick,
                            LidHeight],
                       radius=Radius-.5, sidesonly=true);
    }
}

module render_mono()
{
    polytext("ABC", 120, "fixed");

}


if (MakeLid)
    translate([-Width - 5, 0, 0])
        render_lid();

if (MakeBox)
    translate([5, 0, 0])
        render_box();
