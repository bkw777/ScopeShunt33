// Enclosure for ScopeShunt33

// OUTPUT
/***********************************************************/
display_assembly();
//print_bottom();
//print_top();
//shell_bottom();
//shell_top();
/***********************************************************/

// To generate this STL model of the PCB:
// KiCad -> pcbnew -> File -> Export -> Step -> ScopeShunt33_pcb.step
// FreeCAD -> File -> open *.step -> select body -> File -> Export -> STL -> ScopeShunt33_pcb.stl
pcb_model_stl = "../pcb/ScopeShunt33_pcb.stl";

corner_radius = 2.5;
wall_thickness = 1;
pcb_thickness = 1.6;
pcb_length = 35;
pcb_width = 40;
pcb_x_offset = -5.5;  // pcb model stl center
pcb_y_offset = 0;     // "   "     "   "
top_components_thickness = 0.8; // resistors 0.65
bottom_components_thickness = 2;
top_perimeter_lip = 0.8;
bottom_perimeter_lip = 1;
fitment_clearance = 0.1;
snap_length = 6;
snap_thickness = wall_thickness;
snap_clearance = 0.3;
bnc_diameter = 9.7;
bnc_clearance = 1;

cr = corner_radius;
wt = wall_thickness;
fc = fitment_clearance;
pz = pcb_thickness;
px = pcb_length;
py = pcb_width;
tpl = top_perimeter_lip;
bpl = bottom_perimeter_lip;
tcz = top_components_thickness;
bcz = bottom_components_thickness;
sl = snap_length;
st = snap_thickness;
sc = snap_clearance;

o = 0.1; // cut/join overcut/overlap
$fn = 36;

tcoz = tcz+fc+wt+o; // top cut objects z

/***********************************************************/

module print_top () {
 translate([0,0,pz+tcz+fc+wt])
  rotate([0,180,0])
   shell_top();
}

module print_bottom () {
 translate([0,0,bcz+fc+wt])
  shell_bottom();
}

module display_assembly () {
 translate([pcb_x_offset,pcb_y_offset,0]) %pcb_model();
  /* translate([0,0,-10]) */ shell_bottom();
  shell_top();
}

module pcb_model () {
  import(pcb_model_stl);
}

module shell_top() {

 difference(){

  hull(){ // diff add
   or = cr + fc + wt;
   oh = wt + fc + tcz + pz + bcz + fc + wt;
   mirror_copy([1,0,0])
    translate([px/2-cr,0,0])  
     mirror_copy([0,1,0])
      translate([0,py/2-cr,oh/2-bcz-fc-wt])
       cylinder(h=oh,r=or,center=true);
   } // diff add

  group(){ // diff cut
   // pcb
   hull(){
    mirror_copy([1,0,0])
     translate([px/2-cr,0,0])  
      mirror_copy([0,1,0])
       translate([0,py/2-cr,-o/2-wt/2-fc/2-bcz/2+pz/2+fc/2])
        cylinder(h=o+wt+fc+bcz+pz+fc,r=cr+fc,center=true);
   }
   // upper cavity / lip
   hull(){
    ir = cr - tpl;
    mirror_copy([1,0,0])
     translate([px/2-tpl-ir,0,0])  
      mirror_copy([0,1,0])
       translate([0,py/2-tpl-ir,tcz/2+fc/2+pz])
        cylinder(h=tcz+fc,r=ir,center=true);
   }
   // holes
   bnc_hole();
   terminal_hole();
  } // diff cut
 } // difference

 // snaps male
 translate([0,0,st/2-bcz-fc-wt]) {
  mirror_copy([1,0,0])
   translate([-px/2-fc,0,0])
    rotate([90,0,0])
     cylinder(h=sl,d=st,center=true);
  mirror_copy([0,1,0])
   translate([0,-py/2-fc,0])
    rotate([0,90,0])
     cylinder(h=sl,d=st,center=true);
 } // snaps male

} // shell_top()

module shell_bottom() {
 difference() {
  // add
  // outer hull
  oh = wt + fc + bcz; // height
  hull() {
   mirror_copy([1,0,0])
    translate([px/2-cr,0,0])
     mirror_copy([0,1,0])
      translate([0,py/2-cr,oh/2-bcz-fc-wt])
       cylinder(h=oh,r=cr,center=true);
  }

  // cut
  group () {
   // main cavity
   hull () {
    ir = cr - bpl;
    ix = px - bpl*2;
    iy = py - bpl*2;
    mirror_copy([1,0,0])
     translate([ix/2-ir,0,0])
      mirror_copy([0,1,0])
       translate([0,iy/2-ir,oh/2-bcz-fc])
        cylinder(h=oh,r=ir,center=true);
   }
   
   // snaps female
   sx = 1+sl+1;
   sy = o+st/2+sc;
   sz = st+sc+o;
   translate([0,0,sz/2-bcz-fc-wt-o]){
    mirror_copy([0,1,0])
     translate([0,-py/2-fc/2-o+sy/2,0])
      cube([sx,sy,sz],center=true);
    mirror_copy([1,0,0])
     translate([-px/2-fc/2-o+sy/2,0,0])
      cube([sy,sx,sz],center=true);
    }
  }

 } // difference
} // shell_bottom()

module terminal_hole() {
 translate([11.5,14,tcoz/2+pz])
  hull()
   mirror_copy([0,1,0])
    translate([0,5,0])
     mirror_copy([1,0,0]) 
      translate([5,0,0])
       cylinder(h=tcoz,r=0.4,center=true);
  // clearance for the dovetails
  translate([16.3,14.5,tcoz/2+pz])
   mirror_copy([0,1,0])
    translate([0,3.55,0])
     cylinder(h=tcoz,r=1.2,center=true);
}

module bnc_hole () {
 vw = bnc_diameter + bnc_clearance; // vertical width
 hw = fc + bnc_diameter + fc; // horizontal width
 bxo = 11.5; // bnc x offset
 cr = 0.4; //corner radius
 // hole in wall
 translate([bxo,-(o+wt+fc+tpl+o)/2-py/2+tpl+o,5.45])
  rotate([90,0,0])
   cylinder(h=o+wt+fc+tpl+o,d=vw,center=true);
 // hole in top
 translate([bxo,-13,tcoz/2+pz])
  hull(){
   cylinder(h=tcoz,d=hw,center=true);
   translate([0,cr-7.1,0])
    hull()
     mirror_copy([1,0,0])
      translate([hw/2-cr,0,0])
       cylinder(h=tcoz,r=cr,center=true);
  }
}

module mirror_copy(v) {
 children();
 mirror(v) children();
}