// Enclosure for ScopeShunt33

// To generate this STL model of the PCB:
// KiCad -> pcbnew -> File -> Export -> Step -> ScopeShunt33_pcb.step
// FreeCAD -> File -> open *.step -> select body -> File -> Export -> STL -> ScopeShunt33_pcb.stl
pcb_model_stl = "../pcb/ScopeShunt33_pcb.stl";

corner_radius = 2.5;
wall_thickness = 1;
pcb_thickness = 1.6;
pcb_length = 35;
pcb_width = 40;
pcb_x_offset = 5.5;
pcb_y_offset = 0;
smd_thickness = 0.65;
tht_legs_z = 2;
top_perimeter_lip = 0.5;
bottom_perimeter_lip = 1;
fitment_clearance = 0.1;

cr = corner_radius;
wt = wall_thickness;
fc = fitment_clearance;
pz = pcb_thickness;
px = pcb_length;
py = pcb_width;
tpl = top_perimeter_lip;
bpl = bottom_perimeter_lip;

o = 0.1;
$fn = 36;

tcoz = smd_thickness+fc+wt+o; // top cut objects z

/***********************************************************/

display_assembly();
//print_top();
//print_bottom();

/***********************************************************/

module print_top () {
 translate([0,0,pz+smd_thickness+fc+wt])
  rotate([0,180,0])
   shell_top();
}

module print_bottom () {
 translate([0,0,tht_legs_z+fc+wt])
  shell_bottom();
}

module display_assembly () {
 %pcb_model();
 translate([pcb_x_offset,pcb_y_offset,0]) {
  shell_bottom();
  shell_top();
 }
}

module pcb_model () {
  import(pcb_model_stl);
}

module shell_top() {
 difference(){
  // add
  // outer shell
  hull(){
   or = cr + fc + wt;
   oh = wt + fc + smd_thickness + pz + tht_legs_z + fc + wt;
   mirror_copy([1,0,0])
    translate([px/2-cr,0,0])  
     mirror_copy([0,1,0])
      translate([0,py/2-cr,oh/2-tht_legs_z-fc-wt])
       cylinder(h=oh,r=or,center=true);
  }

  // cut
  union(){
   // pcb
   hull(){
    mirror_copy([1,0,0])
     translate([px/2-cr,0,0])  
      mirror_copy([0,1,0])
       translate([0,py/2-cr,-o/2-wt/2-fc/2-tht_legs_z/2+pz/2+fc/2])
        cylinder(h=o+wt+fc+tht_legs_z+pz+fc,r=cr+fc,center=true);
   }

   // upper cavity / lip
   hull(){
    ir = cr - tpl;
    mirror_copy([1,0,0])
     translate([px/2-tpl-ir,0,0])  
      mirror_copy([0,1,0])
       translate([0,py/2-tpl-ir,smd_thickness/2+fc/2+pz])
        cylinder(h=smd_thickness+fc,r=ir,center=true);
   }

   // holes
   bnc_hole();
   terminal_hole();
   
  } // union

 } // difference
} // shell_top()

module shell_bottom() {
 difference() {
  oh = wt + fc + tht_legs_z - fc;
  hull() {
   mirror_copy([1,0,0])
    translate([px/2-cr,0,0])
     mirror_copy([0,1,0])
      translate([0,py/2-cr,oh/2-tht_legs_z-fc-wt])
       cylinder(h=oh,r=cr+fc/2,center=true);
  }

  hull () {
   bpl = 1 ; // bottom perimeter lip
   ir = cr - bpl;
   ix = px - bpl*2;
   iy = py - bpl*2;
   mirror_copy([1,0,0])
    translate([ix/2-ir,0,0])
     mirror_copy([0,1,0])
      translate([0,iy/2-ir,oh/2-tht_legs_z-fc])
       cylinder(h=oh,r=ir,center=true);
  }

 } // difference
} // shell_bottom()

module terminal_hole() {
 translate([11.5,14.6,tcoz/2+pz])
  cube([11,11,tcoz],center=true);
}

module bnc_hole () {
 bd = 10; // bnc barrel diameter
 bxo = 11.5; // bnc x offset
 // hole in wall
 translate([bxo,-(o+wt+fc+tpl+o)/2-py/2+tpl+o,5.45])
  rotate([90,0,0])
   cylinder(h=o+wt+fc+tpl+o,d=bd,center=true);
 // hole in top
 translate([bxo,-13,tcoz/2+pz])
  hull(){
   cylinder(h=tcoz,d=bd,center=true);
   translate([0,-6.6,0]) cube([bd,1,tcoz],center=true);
  }
}

module mirror_copy(v) {
 children();
 mirror(v) children();
}