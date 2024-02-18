/*
 * snap-bracket.scad
 * A configurable snap mount bracket
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 */


use <../../lib/grommet.scad>


BaseThick = 4.5;
BaseInner = 30.2;
RiserThick = 3.5;
RiserInner = 19.5;
LatchHeight = 6;
LatchLip = 2.5;
BodyLength = 25;
CounterSink = 1.5;
ScrewSize = 4.2;
// #6 == 3.5, #8 == 4.2

$fn=60;

shape = [
    [0, 0],
    [2 * RiserThick + BaseInner, 0],
    [2 * RiserThick + BaseInner, BaseThick + RiserInner + LatchHeight],
    [1.4* RiserThick + BaseInner, BaseThick + RiserInner + LatchHeight],
    [    RiserThick + BaseInner - LatchLip, BaseThick + RiserInner],
    [    RiserThick + BaseInner, BaseThick + RiserInner],
    [    RiserThick + BaseInner, BaseThick],
    [RiserThick, BaseThick],
    [RiserThick, BaseThick + RiserInner],
    [RiserThick + LatchLip, BaseThick + RiserInner],
    [.6*RiserThick, BaseThick + RiserInner + LatchHeight],
    [0, BaseThick + RiserInner + LatchHeight],
    [0, 0]
];

ScrewHead = 2*ScrewSize;
x1 = RiserThick+BaseInner/4;
x2 = RiserThick+3*BaseInner/4;

grommet(h=CounterSink,
        r=ScrewHead/2,
        thickness=1.4, 
        offset=[x1, BaseThick-CounterSink/2, BodyLength/2],
        rotate=[90,0,0])
grommet(h=CounterSink,
        r=ScrewHead/2,
        thickness=1.4, 
        offset=[x2, BaseThick-CounterSink/2, BodyLength/2],
        rotate=[90,0,0])

grommet(h=BaseThick,
        r=ScrewSize/2,
        thickness=1.4, 
        offset=[x1, BaseThick/2, BodyLength/2],
        rotate=[90,0,0])
grommet(h=BaseThick,
        r=ScrewSize/2,
        thickness=1.4, 
        offset=[x2, BaseThick/2, BodyLength/2],
        rotate=[90,0,0])
linear_extrude(BodyLength)
polygon(shape);
