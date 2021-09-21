/*
 * little-box.scad
 * A configurable, printable utility box and lid
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
 */
 
use <MCAD/boxes.scad>
use <../../lib/shapes.scad>
use <boxlib.scad>


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
Grade1 = 5;

LDiv2 = 1;
WDiv2 = 3;
Grade2 = 5;

Vents = 0;
VentWidth = 2;

/* [Lid] */
LidHeight = 40;
// Rim is really RimHeight - LidThick
RimHeight = 9.5;
LidThick = 1.2;

LidRadius = 1.1;

LidDetent = true;

// Detent+Slide changes detent
LidSlide = false;
LidSlideDepth = 0.5;
LidSlideRelief = 0.05;
LidSlideAdjust = 0.1;

RimCut = false;
RimCutAdjust = 0;
RimAngle = 0;

// Ignored when using slide
Notchspan = .25;
NotchHeight = .25;

LidRelief = 0.28;
// top edge radius

/* [Additions] */
Mounting_Holes = false;
MH_L = 3;
MH_W = 0;
MH_D = 2;
MH_ScrewSize = 4.2;

/* [Monogram] */
MonoFont = "Script MT Bold:style=Italic";
Monogram = "RC";
MonoScale = .2;
MonoScale2 = .2;
MonoHeight = 1.75;
MonoXAdj = [-20, .4, 12, 20, 30];

/* [Options] */
Make_Box = false;
MakeLid = false;
MakeMono = false;

$fa = 0.5;
$fs = 0.5;
$fn = 60;

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
    // box is centered
    lx = -Width/2 + LidThick - xadjust;
    rx = Width/2 - LidThick + xadjust;
    
    _rail2(xleft=lx, xright=rx, rot=90)
        scale([.5,1,1])
        cylinder(h=Length+ladjust, r=.8*LidThick-LidRelief/2, center=true);
}

module VDet(height, xadjust=0)
{
    // box is centered
    lx = -Width/2 + LidThick - xadjust;
    rx = Width/2 - LidThick + xadjust;
    
    _rail2(xleft=lx, xright=rx, rot=0)
        scale([.55,1,1])
        cylinder(h=height, r=.8*LidThick-LidRelief/2, center=true);
}

module SlideRail(length, radius, xadjust=0, zadjust=0)
{
    // box is centered
    lx = -Width/2 + LidThick - xadjust;
    rx = Width/2 - LidThick + xadjust;
    
    translate([0,0,zadjust])
    _rail2(xleft=lx, xright=rx, rot=90)
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
    function startspan(nom, div, grade) = (div == 1)? nom : nom - (div-1)*grade/2;
    function nsum(n) = (n * (n-1))/2;

    workingWidth = Width - Thickness - 2*LidThick;
    workingLength = Length - Thickness - 2*LidThick;
    
    width1 = Split == "L"? (Group1Span * workingWidth * 0.01) : workingWidth;
    length1 = Split == "L"? workingLength : (Group1Span * workingLength * 0.01);
    wdivsize1 = width1 / WDiv1;
    ldivsize1 = length1 / LDiv1;

    echo(str("wdivsize1 = ", wdivsize1));
    wgrade1 = Split != "L"? Grade1 : 0;
    echo(str("wgrade1 = ", wgrade1));
    wstart1 = startspan(wdivsize1, WDiv1, wgrade1);
    echo(str("wstart1 = ", wstart1));

    echo(str("ldivsize1 = ", ldivsize1));
    lgrade1 = Split == "L"? Grade1 : 0;
    echo(str("lgrade1 = ", lgrade1));
    lstart1 = startspan(ldivsize1, LDiv1, lgrade1);
    echo(str("lstart1 = ", lstart1));

    w2off = (Split == "L"? width1 : 0);
    width2 = Split == "L"? (workingWidth - width1) : workingWidth;
    l2off = (Split == "L"? 0 : length1);
    length2 = Split == "L"? workingLength : (workingLength - length1);

    wdivsize2 = width2 / WDiv2;
    ldivsize2 = length2 / LDiv2;

    echo(str("wdivsize2 = ", wdivsize2));
    wgrade2 = Split != "L"? Grade2 : 0;
    echo(str("wgrade2 = ", wgrade2));
    wstart2 = startspan(wdivsize2, WDiv2, wgrade2);
    echo(str("wstart2 = ", wstart2));

    echo(str("ldivsize2 = ", ldivsize2));
    lgrade2 = Split == "L"? Grade2 : 0;
    echo(str("lgrade2 = ", lgrade2));
    lstart2 = startspan(ldivsize2, LDiv2, lgrade2);
    echo(str("lstart2 = ", lstart2));
    
    echo(str("box 1 is ",ldivsize1-Thickness,"x",wdivsize1-Thickness));
    echo(str("interior is ",wdivsize1-Thickness,"W x ",
             ldivsize1-Thickness, "L x ", Height+Radius, "H"));

    if (Group1Span < 100) {
        echo(str("box 2 is ",ldivsize2-Thickness," x ",wdivsize2-Thickness));
        echo(str("interior is ",wdivsize2-Thickness,"W x ",
                 ldivsize2-Thickness, "L x ", Height+Radius, "H"));
    }

    difference() {
        RoundedBox(size=[Width, Length, Height], radius=Radius, sidesonly=true);

        // subtract the internal boxes
        echo("GROUP 1");
        for (widx = [0 : 1 : WDiv1-1],
             lidx = [0 : 1 : LDiv1-1]) {
 
            woff = Thickness + LidThick + widx * wstart1 + wgrade1 * nsum(widx);
            wsize = wstart1 + wgrade1 * widx - Thickness;

            loff = Thickness + LidThick + lidx * lstart1 + lgrade1 * nsum(lidx);
            lsize = lstart1 + lgrade1 * lidx - Thickness;

            echo(str("lidx: ", lidx, " loff: ",loff, " lsize: ", lsize));
            echo(str("widx: ", widx, " woff: ",woff, " wsize: ", wsize));

            translate([woff,loff,Thickness])
                RoundedBox(size=[wsize, lsize, Height+Radius],
                           radius=Radius-Thickness,
                           sidesonly=!Rounded);
        }
        // Group 2
        if (Group1Span < 100) {
            echo("GROUP 2");
            for (widx = [0 : 1 : WDiv2-1],
                 lidx = [0 : 1 : LDiv2-1]) {

                woff = Thickness + widx * wstart2 + wgrade2 * nsum(widx);
                wsize = wstart2 + wgrade2 * widx - Thickness;

                loff = Thickness + lidx * lstart2 + lgrade2 * nsum(lidx);
                lsize = lstart2 + lgrade2 * lidx - Thickness;

                echo(str("lidx: ", lidx, " loff: ",loff, " lsize: ", lsize));
                echo(str("widx: ", widx, " woff: ",woff, " wsize: ", wsize));

                translate([w2off + woff + LidThick,
                           l2off + loff + LidThick,
                           Thickness])
                    RoundedBox(size=[wsize, lsize, Height+Radius],
                               radius=Radius - Thickness,
                               sidesonly=!Rounded);
            }
            if (Vents > 0) {
                xsize = (Split == "L")? Thickness + .1:
                                        Width - 4*Thickness - 2*LidThick;
                ysize = (Split == "W")? Thickness + .1:
                                        Length - 4*Thickness - 2*LidThick;
                xoff = (Split == "L")? LidThick + width1 - .05 :
                                       2*Thickness + LidThick;
                yoff = (Split == "W")? LidThick + length1 - .05 :
                                       2*Thickness + LidThick;
                
                ztop = Height - Thickness - RimHeight + LidThick;
                zvent = (ztop - Thickness) / Vents;
                for (zoff = [Thickness+.75*zvent : zvent : ztop]) {
                    translate([xoff, yoff, zoff])
                        cube([xsize, ysize, VentWidth]);
                }
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

        // cut away top of interior inside of rim
        if (RimCut) {
            if (LidSlide) {
                translate([Width/2+1,
                           Length/2+Thickness/2+LidThick/2,
                           Height+LidHeight/2+RimCutAdjust])
                rotate([90, 0, -90])
                    paracube(size=[Length-Thickness-LidThick, 2*LidHeight, Width+2],
                            angle=RimAngle,
                            center=true);
            } else {
                translate([Width/2,
                           Length/2,
                           Height+LidHeight+RimCutAdjust])
                rotate([90, 0, -90])
                    paracube(size=[Length+.02, 2*LidHeight, Width+2],
                            angle=RimAngle,
                            center=true);
            }
        }

        // Make a slide rail, subtract it from interior rim
        if (LidSlide) {
            translate([Width/2, Length/2+Radius, Height-(RimHeight-LidThick)/2])
            SlideRail(length=Length,
                      radius=LidSlideDepth,
                      xadjust=0,
                      zadjust=LidSlideAdjust);

            // With slide, detent is perpendicular and at back of rail
        }
        if (LidDetent) {
            if (LidSlide) {
                translate([Width/2,
                           .9*Length,
                           Height-(RimHeight-LidThick)/2+LidSlideAdjust])
                    VDet(height=4*LidSlideDepth);
            } else {
                translate([Width/2, Length/2, Height-(RimHeight-LidThick)/2])
                    LDet(ladjust=-Length/2);
            }
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
        if (Notchspan > 0) {
            translate([0,0,LidHeight/2+LidThick])
            rotate([90,0,0])
                scale([(Notchspan/2) * Width/RimHeight, NotchHeight, 1])
                cylinder(h=Length + 1, r=RimHeight, center=true);
        }
    }

    if (!LidSlide && LidDetent) {
        translate([0, 0, LidHeight/2-(RimHeight-LidThick)/2])
            LDet(ladjust=-Length/2-Radius, xadjust=LidRelief);
    }

    if (LidSlide) {
        translate([0, 0, LidHeight/2-(RimHeight-LidThick)/2+LidSlideRelief])
            SlideRail(length=.9*Length-2*Radius,
                      radius=LidSlideDepth-.05,
                      xadjust=LidRelief,
                      zadjust=-LidSlideAdjust);
        if (LidDetent) {
            translate([0,
                       -.8*Length/2,
                       LidHeight/2-(RimHeight-LidThick)/2-LidSlideAdjust])
                VDet(height=.9*4*LidSlideDepth, xadjust=LidRelief);
        }
    }
}

module mono(str, idx)
{
    if (idx < len(str)) {
        size = (idx == 1? MonoScale2 : MonoScale) * Height;
        base = (idx == 1? (MonoScale - MonoScale2)/2 * Height : 0);
        translate([MonoXAdj[idx], base, 0])
        text(text=str[idx],
            size=size, 
            halign="center",
            font=MonoFont,
            $fn=0);
        mono(str, idx+1);
    }
} 

module mono_face()
{
    translate([Width/2, Length,(Height-RimHeight)/2])
    rotate([90, 0, 180])
        linear_extrude(MonoHeight+.05, center=true)
    mono(str=Monogram, idx=0);    
}

if (MakeLid) {
    translate([-Width/2 - 5, Length / 2, LidHeight / 2])
    rotate([0,0,180])
        render_lid();
}

if (Make_Box) {
    translate([5, 0, 0])
        render_box();
}

if (MakeMono) {
    mono_face();
}
