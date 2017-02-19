const
  style = """$beforeStyle$
ls(i)=value(sprintf("ls%i",i));lt(i)=value(sprintf("lt%i",i));pt(i)=value(sprintf("pt%i",i));lc(i)=value(sprintf("lc%i",i));
lw=2;ps=1;pi=1;axiscolor='gray30';gridcolor='gray30';clw=1;
lc1='dark-blue';lc2='dark-red';lc3='dark-green';lc4='orange';lc5='dark-pink';lc6='purple';lc7='olive';lc8='slategray';lc9='steelblue';lc10='black';
lt1=1;lt2=2;lt3=3;lt4=4;lt5=5;lt6=6;lt7=7;lt8=8;lt9=9;lt10=10;
pt1=5;pt2=7;pt3=9;pt4=11;pt5=13;pt6=15;pt7=17;pt8=19;pt9=21;pt10=23;
ls1=1;ls2=2;ls3=3;ls4=4;ls5=5;ls6=6;ls7=7;ls8=8;ls9=9;ls10=10;ls11=11;ls12=12;ls13=13;ls14=14;ls15=15;ls16=16;ls17=17;ls18=18;ls19=19;ls20=20;
$beforeStyleVar$
lw1=lw;lw2=lw;lw3=lw;lw4=lw;lw5=lw;lw6=lw;lw7=lw;lw8=lw;lw9=lw;lw10=lw;
ps1=ps;ps2=ps;ps3=ps;ps4=ps;ps5=ps;ps6=ps;ps7=ps;ps8=ps;ps9=ps;ps10=ps;
pi1=pi;pi2=pi;pi3=pi;pi4=pi;pi5=pi;pi6=pi;pi7=pi;pi8=pi;pi9=pi;pi10=pi;
$afterStyleVar$
#Line styles:
set style line 1 lc rgb lc1 lt lt1 lw lw1 ps ps1 pt pt1 pi pi1;
set style line 2 lc rgb lc2 lt lt2 lw lw2 ps ps2 pt pt2 pi pi2;
set style line 3 lc rgb lc3 lt lt3 lw lw3 ps ps3 pt pt3 pi pi3;
set style line 4 lc rgb lc4 lt lt4 lw lw4 ps ps4 pt pt4 pi pi4;
set style line 5 lc rgb lc5 lt lt5 lw lw5 ps ps5 pt pt5 pi pi5;
set style line 6 lc rgb lc6 lt lt6 lw lw6 ps ps6 pt pt6 pi pi6;
set style line 7 lc rgb lc7 lt lt7 lw lw7 ps ps7 pt pt7 pi pi7;
set style line 8 lc rgb lc8 lt lt8 lw lw8 ps ps8 pt pt8 pi pi8;
set style line 9 lc rgb lc9 lt lt9 lw lw9 ps ps9 pt pt9 pi pi9;
set style line 10 lc rgb lc10 lt lt10 lw lw10 ps ps10 pt pt10 pi pi10;
set style line 101 lc rgb axiscolor lt 1 lw 1;
set style line 102 lc rgb gridcolor lt 0 lw 1;
#End common style"""

  style2d = style & """#Define axis
set border 3 back ls 101;# remove border on top and right and set color to gray
set tics nomirror;
set grid back ls 102;
set termoption dashed;
$afterStyle$"""

  style3d = style & """set border 1+2+4+8+16+32+64+256+512 back ls 101;
set xtics border out nomirror
set ytics border out nomirror
set ztics border out nomirror
set grid x y z back ls 102;
set xyplane 0;
#Colorbox
#set format cb "%4.1f";
#set colorbox user size .03, .6;
set cbtics scale 0;
set palette negative rgb 21,22,23 #Reverse hot color palette;
$afterStyle$"""

  header = """$beforeHeader$
#Header start
#set macros;#Enable the use of macros
set terminal wxt size 480,288;#corresponding to the default size of pdf terminal 5in,3in.
set terminal wxt title "$info$";
set terminal $terminal$;
set output "$output$";
set xlabel "$xlabel$";
set ylabel "$ylabel$";
set zlabel "$zlabel$";
set xrange $xrange$;
set yrange $yrange$;
set zrange $zrange$;
info1(i)=value(sprintf("info%i",i));
info2(i,j)=value(sprintf("info%i_%i",i,j));
$infos()$
$extra$
$afterHeader$
#Header end"""

  plot2d = style2d & header & """set title "$info(1)$";
$bp$plot for [i=1:$size(1)$] '-' title info2(1,i) w lp ls ls(i);
$data(1,2d)$"""

  plot2dBar = style2d & """set style fill solid noborder;""" & header & """set title "$info(1)$";
$bp$plot for [i=2:$nColumn(1,1)$] '$data2f(1,2d)$' using i:xtic(1) title columnhead w histograms ls ls(i-1);"""

  plot3d = style3d & header & """set title "$info(1)$";
$bp$splot for [i=1:$size(1)$] "-" using 1:2:3 title info2(1,i) w l ls ls(i);
$data(1,3d)$"""

  plotDensity = style3d & """set pm3d;
set pm3d interpolate 0,0;#set pm3d interpolate -1,-1;#To turn off interpolate
set pm3d map;
set size square;
#set contour;
#set cntrparam bspline;
unset clabel;
unset surface;
unset key;
unset grid;
set xtics border in mirror;
set ytics border in mirror;
set lmargin at screen 0.1;
set rmargin at screen 0.9;
set bmargin at screen 0.2;
set tmargin at screen 0.9;
set cblabel "$zlabel$";""" & header & """set title "$info(1)$";
$bp$splot for [i=1:$size(1)$] "-" using 1:2:3 title info2(1,i) w l ls ls(i) lw clw;
$data(1,3d)$"""

  plotImage = style3d & """set xtics in mirror;
set ytics in mirror;
set cblabel "$zlabel$";""" & header & """unset key;
set view map;
set title "$info(1)$";
$bp$plot '-' using 1:2:3 with image;
$data(1,3d)$"""

  multiplot = style2d & header & """set multiplot layout $size()$,1;
set title "$info(1)$";
$bp$plot for [i=1:$size(1)$] '-' title info2(1,i) w lp ls ls(i);
$data(1,2d)$
set title "$info(2)$";
$bp$plot for [i=1:$size(2)$] '-' title info2(2,i) w lp ls ls(i);
$data(2,2d)$
set title "$info(3)$";
$bp$plot for [i=1:$size(3)$] '-' title info2(3,i) w lp ls ls(i);
$data(3,2d)$
set title "$info(4)$";
$bp$plot for [i=1:$size(4)$] '-' title info2(4,i) w lp ls ls(i);
$data(4,2d)$
set title "$info(5)$";
$bp$plot for [i=1:$size(5)$] '-' title info2(5,i) w lp ls ls(i);
$data(5,2d)$
unset multiplot;"""

#   plotx = header & """ """ # Edit to add customised plot functions
