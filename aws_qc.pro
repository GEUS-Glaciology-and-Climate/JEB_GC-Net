pro qc						; 	Jason Box, 1995-2002
; -----------------------------------------------------------------------------
; IDL program to filter/interpolate spurious and missing AWS data.
; Numerous idl procedures are 'called' as QC tools in the program's Main Body.
; -----------------------------------------------------------------------------
; This version processes the "<station number>_<year>a.dat" data and outputs
; annual chunks of "<station #>_<year>c.dat" data to the spec. path called 'path'.
; Ancillary data are I/O to a sub-directory containing ancillary data.
; -----------------------------------------------------------------------------
; Important Notes:
; * temperature QC should be run before surface height QC
; * snow and instrument height sub-routines must run before wind_constant_z
; * T_COR_W_RH procedure must come after RH cleaning procedures
; * rh_ice procedure must come after T_COR_W_RH procedure
; * snow height processing must come before wind cleaning
; snow temps at fixed depths are discontoinued in hourly data, try daily means.
; if your really want these data, uncomment the write to unit 4 in write_out routine
; -------------------- search items
; RH CS Wind  thresh=slopex dudz attery regression, t_cor_w_rh -E
; correct_overheat snowtem write_out aws_plot snowtem reverse wind thresh=
; Net Radiation  tower_wake_filter ressure read init_in end_of_year frozen rh_ice
; calc_snow_t_z sound loadct
; -----------------------------------------------------------------------------
; =========================== USER Defined Variables =================
beginchoice=09	; i.e. station number, 4, 7
endchoice=09
yrchoice=2004
plot_prompt='n'	; select 'y' if user wants prompts between plots.
ppp='y'  ; set ppp to 'y' if you want to see plots of the QC in action
final_plot_prompt='y'	; do 'y' if want prompts from aws_plot in batch processing mode.
; --------------------------
close,/all
set_plot,'x'
device, true=1,DECOMPOSED=0
nyears=11 & years=findgen(nyears)+1995.
nstations=26	; number of stations in GC-NET
layot='x' 	; 'l' for postscript eps file to print, 'x' for x-window
path='/data2/aws/gdf/' & path2='/data2/aws/ancillary/' & path3='/data2/aws/ancillary/qc/'
; -------------------------------------------- begin loop over stations
cs=1.5  		; character size
ncols=40
stnum=strarr(nstations) & openr,1,path2+'stnums.dat' & readf,1,stnum & close,1

for jx=beginchoice-1,endchoice-1 do begin ; begin loop over stations
  for kkk=yrchoice-1995,yrchoice-1995 do begin
  ;for kkk=5,nyears-1 do begin
;lfor kkk=0,9 do begin


ly=''

;loadct,0
;loadct,13

year=years(kkk)

if year eq 1994. then yr='1994' & if year eq 1995. then yr='1995'
if year eq 1996. then yr='1996' & if year eq 1997. then yr='1997'
if year eq 1998. then yr='1998' & if year eq 1999. then yr='1999'
if year eq 2000. then yr='2000' & if year eq 2001. then yr='2001'
if year eq 2002. then yr='2002' & if year eq 2003. then yr='2003'
if year eq 2004. then yr='2004' & if year eq 2005. then yr='2005'

if year eq 1994. then ly='1993' & if year eq 1995. then ly='1994'
if year eq 1996. then ly='1995' & if year eq 1997. then ly='1996'
if year eq 1998. then ly='1997' & if year eq 1999. then ly='1998'
if year eq 2000. then ly='1999' & if year eq 2001. then ly='2000'
if year eq 2002. then ly='2001' & if year eq 2003. then ly='2002'
if year eq 2004. then ly='2003' & if year eq 2005. then ly='2004'

if year eq 1995. then toread=[1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
if year eq 1996. then toread=[1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
if year eq 1997. then toread=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0]
if year eq 1998. then toread=[1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0]
if year eq 1999. then toread=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0]
if year eq 2000. then toread=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0]
if year eq 2001. then toread=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0]
if year eq 2002. then toread=[1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,1,0,1,0,1,1,1,1,0,1]
if year eq 2003. then toread=[1,1,0,0,1,1,1,1,1,1,1,0,0,1,1,0,1,0,1,0,0,0,0,1,0,1]
if year eq 2004. then toread=[1,1,0,0,0,1,0,1,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,0,0]
if year eq 2005. then toread=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0]
;if year eq 2002. then toread=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]


if toread(jx) eq 1 then begin

colo=255
bg=0

;openw,6,path+stnum(jx)+'_'+yr+'c.inf'

; ---------------------------------------------------------------------------
; --------------------------------------------- main program, procedure calls
; ---------------------------------------------------------------------------

;printf,6,''
;printf,6,'------------------------------------------------ Begin AWS_CLEAN.PRO'
print,'-------------------------------------------------- Begin AWS_CLEAN.PRO'
print,''
print,'Cleaning of station ',stnum(jx),' data.'
print,''


print,'------------------------------------------------------ Read AWS Input.'
read_input,jx,nstations,nlines,lat,lon,length,outputfile,stnum,path,ncols,e,d,yr,stnames,mod_count


print,'------------------------------------------------------ Calibration coefficients'
aws_mult,d,stnum,jx,path,nlines,year,nstations,yr

print,''
print,'------------------------------------------------------- Time cleaning.'
Fill_Time_Gaps,nlines,ncols,d,d2

; ------------------------- initialize misc data if any, as in case of dye-2 and swiss camp
;				the misc data also includes instrument overheating estimates
  misc=fltarr(12,nlines)
  for i=0,9 do misc(i,*)=d2(30+i,*)
  for i=0,9 do d2(30+i,*)=999.
  misc(10,*)=999. & misc(11,*)=999.


print,'------------------------------------------------------- Initialize Quality Identifiers'
qi_init,nlines,d2,ncols,modvar










;plot_prompt='n'	; select 'y' if user wants prompts between plots.

; ============================================================== begin variable
print,''
print,'------------------------------------------------ Snow Height cleaning.'
varname='Snow Height'
icol=17
fcol=18

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
speed_of_sound_cor,nlines,d2,ppp
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; -------------------------------------------------------- Begin ADJUST Z

if (stnum(jx) eq '01') then begin
  for i=0,nlines-1 do begin
    if ((year eq 1997) and (d2(2,i) ge 141.9583))then begin
      temp=0.
	temp=d2(18,i)
	d2(18,i)=d2(17,i)
	d2(17,i)=temp
    endif
  endfor
    adjust_z,d2,nlines,18,18,2001,1,2.372
    adjust_z,d2,nlines,17,17,2001,1,1.172

   plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

if (stnum(jx) eq '02') then begin

  if year eq '1997' then begin
    for i=0,nlines-1 do begin
      if i ge 7378 then begin
        if d2(17,i) ne 999. then d2(17,i)=d2(17,7378)-d2(17,i)+1.7
        if d2(18,i) ne 999. then d2(18,i)=d2(18,7378)-d2(18,i)+2.7
      endif
    endfor
  adjust_z,d2,nlines,icol,icol,1997,309.2917,-0.85
  endif ; 1997

    adjust_z,d2,nlines,17,18,1997,133.375,1.9
    adjust_z,d2,nlines,17,17,1998,151.7083,-2.3
    adjust_z,d2,nlines,17,17,1999,1,-1.6
    adjust_z,d2,nlines,17,18,1999,1,4.8
    adjust_z,d2,nlines,17,17,2000,1,0.7539
    adjust_z,d2,nlines,18,18,2000,1,1.546
    adjust_z,d2,nlines,17,18,2001,148.,2.2

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

endif

if (stnum(jx) eq '03') then begin
  adjust_z,d2,nlines,17,17,1997,139.8333,-0.5
  adjust_z,d2,nlines,18,18,1997,139.8333,0.25
  adjust_z,d2,nlines,17,17,1998,1.,-0.5
  adjust_z,d2,nlines,18,18,1998,1.,0.25
  adjust_z,d2,nlines,17,17,1999,133.6667,2.8
  adjust_z,d2,nlines,18,18,1999,133.6667,2.67
  adjust_z,d2,nlines,18,18,1999,1.,0.48
  adjust_z,d2,nlines,17,17,2000,1.,2.29
  adjust_z,d2,nlines,18,18,2000,1.,2.8774
endif

if (stnum(jx) eq '04') then begin
  adjust_z,d2,nlines,17,17,1997,137.4583,2.
  adjust_z,d2,nlines,18,18,1997,137.4583,2.5
  adjust_z,d2,nlines,17,17,1999,1,6.45
  adjust_z,d2,nlines,18,18,1999,1,7.25
  adjust_z,d2,nlines,17,17,2000,1,0.6721
  adjust_z,d2,nlines,18,18,2000,1,1.5192
endif

if (stnum(jx) eq '06') then begin
  adjust_z,d2,nlines,17,17,1998,136.5417,+0.37
  adjust_z,d2,nlines,18,18,1998,136.5417,-0.4
  adjust_z,d2,nlines,17,17,1999,130.625,1.22
  adjust_z,d2,nlines,17,17,1999,1,0.55
  adjust_z,d2,nlines,18,18,1999,130.625,2.38
  adjust_z,d2,nlines,17,18,2001,161.666,2.26
endif

if (stnum(jx) eq '07') then begin
  adjust_z,d2,nlines,17,18,1998,139.0000,0.3
  adjust_z,d2,nlines,17,17,1999,1,0.359
  adjust_z,d2,nlines,18,18,1999,1,0.4719
  adjust_z,d2,nlines,17,18,2000,1,0.27
  adjust_z,d2,nlines,17,18,2001,1,0.26
  adjust_z,d2,nlines,17,17,2001,159.7917,2.15
  adjust_z,d2,nlines,18,18,2001,159.7917,2.45
endif

if (stnum(jx) eq '08') then begin
  adjust_z,d2,nlines,17,17,1998,118.8750,0.95
  adjust_z,d2,nlines,18,18,1998,118.8750,2.25
  adjust_z,d2,nlines,17,17,1999,1.,0.95
  adjust_z,d2,nlines,18,18,1999,1.,2.25
  adjust_z,d2,nlines,17,17,2000,1.,1.022
  adjust_z,d2,nlines,18,18,2000,1.,2.1993
  adjust_z,d2,nlines,icol,fcol,2000,134.,2.4
  adjust_z,d2,nlines,icol,fcol,2003,129.8333,2.3
endif

if (stnum(jx) eq '09') then begin
  adjust_z,d2,nlines,17,17,1998,146.5833,-.85
  adjust_z,d2,nlines,17,17,1999,151.9167,-1.77
  adjust_z,d2,nlines,17,17,1999,1,-.85
  adjust_z,d2,nlines,18,18,1999,151.9167,-2.58
  adjust_z,d2,nlines,17,17,2000,1,2.55
  adjust_z,d2,nlines,18,18,2000,1,2.75
  adjust_z,d2,nlines,17,17,2002,130.9167,-1.63
  adjust_z,d2,nlines,18,18,2002,130.9167,-1.708
endif

if (stnum(jx) eq '10') then begin
  adjust_z,d2,nlines,17,17,1998,107.5833,0.45
  adjust_z,d2,nlines,17,17,1999,1,0.45
  adjust_z,d2,nlines,17,17,1999,105.667,2.15
  adjust_z,d2,nlines,18,18,1999,105.667,2.85
  adjust_z,d2,nlines,17,17,2000,1,2.55
  adjust_z,d2,nlines,18,18,2000,1,2.75
 ; adjust_z,d2,nlines,17,17,2001,1,2.4134
 ; adjust_z,d2,nlines,18,18,2001,1,2.7481
  adjust_z,d2,nlines,17,18,2001,156.625,2.35
 ; adjust_z,d2,nlines,17,17,2003,125,1.


endif

if (stnum(jx) eq '11') then begin
  adjust_z,d2,nlines,17,17,1998,108.,2.45
  adjust_z,d2,nlines,18,18,1998,108.,2.45
  adjust_z,d2,nlines,17,18,1999,1.,2.446
  adjust_z,d2,nlines,17,17,1999,112.9167,1.6
  adjust_z,d2,nlines,18,18,1999,112.9167,2.6
  adjust_z,d2,nlines,17,18,2001,158.4167,2.9
endif

if (stnum(jx) eq '13') then begin
  adjust_z,d2,nlines,17,18,1998,152.,1.12
  ;adjust_z,d2,nlines,18,18,1998,152.,1.12
  adjust_z,d2,nlines,17,17,1999,1.,0.84
  adjust_z,d2,nlines,18,18,1999,1.,1.147
  adjust_z,d2,nlines,17,17,1999,160.25,1.15
  adjust_z,d2,nlines,17,17,1999,148.,0.8
  adjust_z,d2,nlines,18,18,1999,148.,2.
  adjust_z,d2,nlines,17,17,2000,155.75,2.464
  adjust_z,d2,nlines,18,18,2000,155.75,1.7
  adjust_z,d2,nlines,18,18,2000,155.75,1.7
endif

if (stnum(jx) eq '14') then begin
  adjust_z,d2,nlines,17,17,1999,170.5,.30
  adjust_z,d2,nlines,17,17,2000,167.8,2.7
  adjust_z,d2,nlines,18,18,2000,167.8,2.7

endif

if (stnum(jx) eq '15') then begin
  adjust_z,d2,nlines,17,17,1999,111.875,1.58
  adjust_z,d2,nlines,17,17,2000,1.,1.62
  adjust_z,d2,nlines,17,18,2000,137.7083,3.012
  adjust_z,d2,nlines,17,17,2003,130.7083,2.86
  adjust_z,d2,nlines,18,18,2003,130.7083,2.92
endif

if (stnum(jx) eq '17') then begin
  adjust_z,d2,nlines,17,17,2000,148.0417,-2.1
  adjust_z,d2,nlines,17,17,2001,142.0833,-2.31
  adjust_z,d2,nlines,17,17,2002,127.6667,-2.84
  adjust_z,d2,nlines,17,17,2003,121.75,-2.79
endif

if (stnum(jx) eq '19') then begin
  adjust_z,d2,nlines,17,17,2001,140.1667,-2.817
  adjust_z,d2,nlines,17,17,2002,126.25,-2.43

endif

if (stnum(jx) eq '20') then begin
  adjust_z,d2,nlines,17,17,2000,148.0417,0.52
endif
if (stnum(jx) eq '26') then begin
  adjust_z,d2,nlines,17,18,2003,126.7083,-1.05
endif

  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; -------------------------------------------------------- END ADJUST Z

; -------------------------------------------------------- Begin Small Limits Filters

if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.29,1.6,140.7083,145.5,year,1998.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.95,2.5,95.0833,112.375,year,1999.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.,2.5,95.0833,112.375,year,1999.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,2.2,3.5,212.375,365.9583,year,1999.

  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,1.9,8,1,42,year,2000.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.7,8,1,365.9583,year,2000.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,1.9,8,1,365.9583,year,2000.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.6,8,210,310.,year,2000.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.3,8,250,350.,year,2000.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,199.,366,year,2000.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,0.9,1.35,1,137.625,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,137.625,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,0.65,3,125,188,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.3,3,188,233,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.3,3,290,300,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.5,3,215,233,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.6,3,233,270,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,0.9,3,270,367,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,0.8,1.2,350,367,year,2001.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.8,3.4,1,367,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.9,3.4,190,367,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.5,3.4,180,190,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.3,3.4,170,180,year,2002.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,366,year,2003.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,4,6,200,366,year,2003.

endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.7,4.,255.875,268.375,year,1995.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.6,4.,268.4167,301.7083,year,1995.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.5,4.,301.75,318.375,year,1995.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.25,4.,310.0417,360.5,year,1995.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.15,4.,360.5,367,year,1995.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.95,4.,360.5,367,year,1995.

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.3,6.,1.0,167.708,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.49,6.,1.0,84.292,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.85,6.,1.0,63.458,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.15,6.,1.0,105.125,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.7,6.,1.0,42.625,year,1996.

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,2,1.0,42.625,year,1997.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-1.5,-0.5,307.2500,360.,year,1997.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-0.3,0.5,307.2500,360.,year,1997.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.15,1,147.625,148.75,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.4,1,147.625,148.75,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.2,1,147.625,305.6667,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.,1,147.625,305.6667,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.9,6,1,310,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.,6,1,310,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.5,6,1,25,year,2000.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.4,2,1,17,year,2001.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.29,4,1,17,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-0.2,2,1,367,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,1.8,4,1,367,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,.5,4,209,269,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.5,4,100,259,year,2001.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.85,5,1,128,year,2002.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.8,5,1,128,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.7,5,128,366,year,2002.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.5,5,128,366,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,271,366,year,2002.
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2002

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,109,year,2003.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.55,4,109,366,year,2003.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,366,year,2003.
  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2003

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.6,4,1,366,year,2004.
endif

if (stnum(jx) eq '03') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.7,3.1,317.6667,365.9583,year,1995.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.1,4.,317.6667,365.9583,year,1995.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,3.,75.9583,84.2917,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.45,3,1.,63.4583,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.1,4.,1.,9.2917,year,1996.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.3,3.55,139.8333,148.,year,1997.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.8,4.2,139.8333,148.,year,1997.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.5,4.,139.8333,365.9583,year,1997.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.,4.,139.8333,365.9583,year,1997.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2,2.9,1,365.9583,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.4,3.6,1,365.9583,year,1998.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.5,2,120,134.375,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.4,1.8,1,63,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.2,1.8,63,120,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,3,1,63,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.9,3,133,200,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,3,133,200,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0,1,167,250,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,.1,3,207,366,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,.8,3,207,366,year,1999.

  adjust_z,d2,nlines,17,17,1999,1.,-0.50
  adjust_z,d2,nlines,18,18,1999,1.,-0.26

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,4,1,42,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,4,126,142,year,2000.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,0.5,4,1,256,year,2000.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.3,4,250,366,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.5,3,250,366,year,2001.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.25,4,1,20,year,2002
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2,3,1,366,year,2002

endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.6,3.2,283.5,365.9583,year,1995.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.75,3.2,304.3333,321.,year,1995.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.8,3.2,312.6667,321.,year,1995.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,3,1,130.7917,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.55,3,1,42.625,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.3,3,1,137.7917,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.4,2,337.7917,366.4583,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.2,1.6,2.5,42.2917,year,1997
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.35,2,2.5,42.2917,year,1997

  sm_lim_filter,nlines,d2,17,18,varname,mod_count,0.5,1,137,140,year,1997

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.2,-1.6,121,135,year,1999
  sm_lim_filter,nlines,d2,17,18,varname,mod_count,-2.4,-1.6,121,293,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.8,-2.3,292,367,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-3,-2,292,367,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.7,5,1,155,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3,6,1,110,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,3.5,166,366,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.5,5,250,366,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,3,200,366,year,2000

  sm_lim_filter,nlines,d2,17,18,varname,mod_count,2.,4,1,366,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.,3,1,110,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,4.,6,1,110,year,2001

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.5,6,1,293,year,2002
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,4.4,6,1,293,year,2002

  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2000
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2001

endif

if (stnum(jx) eq '05') then begin
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.4,4,173.083,365.958,year,1995.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.9,3.2,42,63,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.8,3.1,32,147,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.4,3.6,1,84,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.4,3.52,32,100,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.4,3.5,100,147,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.8,3.7,1,365.958,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,3.4,1,365.958,year,1996.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,1.7,46.875,55,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,2.1,46.875,55,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.1,1.7,1,55,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.4,1.7,1,55,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.3,1.7,1,180,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1,1.7,1,180,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.2,1.7,1,34.5,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,1.2,138.75,143,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.6,2,360,367,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.9,2,360,367,year,2000.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.65,0.7,1,90,year,2001.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.95,2.7,1,90,year,2001.
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2001

  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,86,year,2002.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,0.1,0.6,1,367,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,0.3,0.45,90,367,year,2002.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,200,367,year,2002.

  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,2.2,4,1,367,year,2003

  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2002
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2003

endif


if (stnum(jx) eq '06') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.,3,134.5,366,year,1996.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.4,4,134.5,366,year,1996.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.,2.5,1.0417,84.,year,1997.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.3,3.,1.0417,84.,year,1997.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.6,2.,292.,365.,year,1997.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.3,1.6,130.,140.,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,2.,130.,140.,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.6,2.,1.,22.,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,1.5,289.875,365.9583,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,1.7,289.875,365.9583,year,1998.

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-999.,-99.,1.,89.7083,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999.,-99.,1.,90.9583,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.0,1.2,80.,110.,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.5,5,300,366,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.,5,300,366,year,1999.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-0.2,0,360,366,year,1999.
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,3,300,367,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.,3,300,367,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.5,2,1,174,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.1,2,334,366,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.5,2.7,1,46,year,2000.
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,2,1,60,year,2001.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.5,2,170,240,year,2001.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,2,240,366,year,2001.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.9,3,1,60,year,2001.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.7,3,170,240,year,2001.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.4,3,240,366,year,2001.
  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2001

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.4,3,1,120,year,2002.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.4,5,1,120,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.,3,120,366,year,2002.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.,5,120,366,year,2002.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2,3,1,120,year,2003.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3,5,1,120,year,2003.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.5,2.85,250,388,year,2003.
endif

if (stnum(jx) eq '07') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.5,2.,1.0,84.2917,year,1997.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.7,1.5,1.,355.,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.4,2,1.,355.,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.75,2.1,42.625,80.125,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.15,1.3,42.625,80.125,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.5,2.15,63.5,121.75,year,1998.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,.7,2.,1.,63.,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.1,2.2,1.,63.,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.05,2.2,63.,96.,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.25,0.7,292,367,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.75,2,292,367,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,80.625,year,2000
  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.8,2,1,80,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.25,2,1,113,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.2,2,113,130,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.5,2,1,80,year,2001

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.7,3,1,367,year,2002

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.85,3,1,120,year,2003
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-999,-99,1,120,year,2003

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.2,2.7,120,367,year,2003
endif

if (stnum(jx) eq '08') then begin
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.4,2.7,333.2917,366.9583,year,1996.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1,1.3,34,60,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.8,1.2,105,128,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.,1.6,105,128,year,1998

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.5,1.6,197,238.5,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.122,1,1,13,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.9,1,1,275,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-1.3,1,275,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-0.2,1,1,256,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-0.9,1,256,367,year,2000

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.6,5,1,157,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.1,5,1,157,year,2001

  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,140.7083,367,year,2002
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.43,2.7,1,140.7083,year,2002
  last_val,nlines,d2,icol,fcol,varname,mod_count,modvar

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1,5,1,360,year,2003

endif

if (stnum(jx) eq '09') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.6,3.,172,202,year,1996.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.7,3.,200.375,208.9583,year,1996.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.4,2.8,142.625,149.25,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.55,2.65,142.625,149.25,year,1998.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.,3.8,175.,180.,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.2,3.8,146.,155.25,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.5,4,146.,155.25,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,4.,5.,30.,84.,year,1999.

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-1.5,5.,1.,367.,year,2000.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-1,-0.7,26.,51.,year,2000.
  ;sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-0.6,1.,26.,51.,year,2000.


  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,1.45,3.3,139.,225.,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.85,3.3,205.,307.,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,3,3.3,225.,307.,year,2001.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.5,3.3,195.,366.,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.2,4.3,215.,307.,year,2001.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.7,4.3,306.,366,year,2001.


  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,3.4,7,184,366,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,4,7,200,366,year,2002.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,4.8,7,230,366,year,2002.

  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,150.875,year,2004.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.3,7,200,366,year,2004.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,2.65,7,200,366,year,2004.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.9,7,200,280,year,2004.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.2,7,200,280,year,2004.
endif

if (stnum(jx) eq '10') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.1,1.5,319,365.9583,year,1997

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.1,1.3,1.,40.5417,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.85,1.3,67.6250,84.2917,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,.5,292.625,365.9583,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.35,2.,292.625,365.9583,year,1998

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.15,.25,1.,10.,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.15,.25,10.,63.5,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.4,2.,1.,42.625,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-1,2,84,366,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1,2,88,146,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.8,-0.6,1,14,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.0,1,1,366.9583,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-0.8,1,1,366.9583,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.0,-1.9,328.,367,year,2000

;  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.08,-1.84,1,157.,year,2001
;  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.05,-1.9,50,60.,year,2001
;  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.03,-1.9,67,90.,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,157.,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.75,1,157,366.,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.5,2.5,157,366.,year,2001

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,129.,year,2003
  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2003

endif

if (stnum(jx) eq '11') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.9,1.2,342.7917,365.9583,year,1997
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.05,2.5,342.7917,365.9583,year,1997
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,2.,321.9583,338.625,year,1997

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.,1.,105.125,190.7083,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,105.125,110.375,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.05,0.3,110.375,114.5,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,0.4,94.5,105.125,year,1998.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.7,0.,300,365.9583,year,1998.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.4,1.,300,365.9583,year,1998.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-1.,1.8,1.,30.,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.2,3.1,1.,30.,year,1999.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-1.3,2,100.,117,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-0.1,3,100.,117,year,1999.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-0.05,0.3,134.,142.5,year,1999.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.0,1.7,208.,251,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.8,2,251,292,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.,5,1,259,year,2000.
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.55,5,1,367,year,2000.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.6,2,1,367,year,2000.

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,156.7917,year,2001.
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.2,4,158.5,367,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.55,4,150,270,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2,4,110,160,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.35,3,1.,367.,year,2001

endif

if (stnum(jx) eq '12') then begin
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.2,3.5,332.,365.,year,1997

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.5,1.8,1.0417,76.,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.2,3.5,1.0417,76.,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.1,1.45,336.5,352.25,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.,1.4,342.5,365.2083,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.7,3.,342.5,365.2083,year,1998

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.8,1.5,1.,100.,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.8,3.1,1,13.5,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.6,3.2,55.,100.,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.48,0.6,309.,320.,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.45,0.5,320.,369.,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.2,4,309.,367.,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.2,2.95,42.,55.,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.3,0.6,1.,367.,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.9,2.5,1.,367.,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.1,3.,1.,96.,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1.,98.91,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.5,2,296.,367.,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.9,2.06,334.,367.,year,2000

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.75,2.5,1.,367.,year,2001
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.8,2.,1.,105.,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1.,159.5,year,2001


  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2000

endif

if (stnum(jx) eq '13') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.0,1.2,310.0417,315.8333,year,1997

  sm_lim_filter,nlines,d2,18,18,varname,mod_count,.35,.55,142,148.625,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,.37,.45,140,152,year,1998

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-.5,-.3,113,147,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-.85,-.5,113,147,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,-.85,-.3,1,20,year,1999
endif

if (stnum(jx) eq '14') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.5,2.67,326,353,year,1997
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,3.3,3.41,326,353,year,1997

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.5,2.8,1,76,year,1998
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.9,2.13,313.,365.7917,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.8,2.94,313.,365.7917,year,1998

;  sm_lim_filter,nlines,d2,17,18,varname,mod_count,-999,-99,1.0417,90.4583,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.8,2.5,1.0417,90.4583,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.45,3.3,1.0417,90.4583,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.5,2,313,367,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.5,1.8,210,240,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.8,3,1,100,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.7,3,188,209,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.4,2.5,200,367,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.55,2.5,250,265,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.2,2.45,20,93,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2,3,93,120,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.7,2.5,200,300,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.9,2,300,367,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.15,3,188,209,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,4,5,1,31,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.8,5,105,160,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.6,5,160,366,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,4,4.8,1,366,year,2001

  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.9,5,1,366,year,2002

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,3,5,1,80,year,2003
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.6,5,1,366,year,2003
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.6,2.85,340,366,year,2003
   sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,3.1,5,1,366,year,2003

  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,1999

  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2001

endif

if (stnum(jx) eq '15') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.7,3,260.,318.,year,1998
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,4,5,313.,366,year,1998

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.3,4,300.,366,year,1999
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.4,4,300.,366,year,1999

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.4,-0.1,1,20,year,2000
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-2.1,0,300,360,year,2000
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.6,3,270,360,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-0.7,0,38,50,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.35,5,200,366,year,2002

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.,5,1,366,year,2003
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.2,5,1,50,year,2003
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.5,5,146,300,year,2003
  sm_lim_filter,nlines,d2,18,18,varname,mod_count,1.25,5,1,366,year,2003

  first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,2000
endif

if (stnum(jx) eq '16') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.9,6,1.,366,year,1999
  sm_lim_filter,nlines,d2,17,18,varname,mod_count,3.9,6,1.,25,year,2000
  sm_lim_filter,nlines,d2,17,18,varname,mod_count,2.5,6,1.,46,year,2001

  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,2.5,6,1.,46,year,2003
endif

if (stnum(jx) eq '17') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.2,4,237.375,266,year,1999
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,2.8,8,130,170,year,2001
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,6,8,230,360,year,2001

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.8,8,1,360,year,2003
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,4.8,8,180,360,year,2003
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,5.8,8,200,240,year,2003
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,6.8,8,240,360,year,2003

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,148.0833,year,2004    
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,4.5,8,210,367,year,2004
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,5,8,225,367,year,2004
  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2004
endif

if (stnum(jx) eq '19') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,3.8,5,254,366,year,2000
endif
; Russ, I added the following if shell to eliminate surface height errors.
; uncomment it and see it work
if (stnum(jx) eq '26') then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.,2.7,151,300,year,2002
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; -------------------------------------------------------- End Small Limits Filters

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
grad_thresh,nlines,d2,icol,fcol,.3,mod_count,varname
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
grad_thresh,nlines,d2,icol,fcol,.3,mod_count,varname
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
snow_height_invert,nlines,d2,stnum,jx,nstations,17,18
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr



if stnum(jx) eq '02' then begin
  if year eq '1998' then begin
    snow_height_invert,nlines,d2,stnum,jx,nstations,17,18
    plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
    for i=3577,nlines-1 do begin
      d2(17,i)=(d(17,3576)-d2(17,i))+3.8+2.35
      d2(18,i)=(d(18,3576)-d2(18,i))+3.8+0.55
    endfor
    plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
  endif
    adjust_z,d2,nlines,17,17,1999,1,2.4452
    adjust_z,d2,nlines,18,18,1999,1,3.2533
    plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

if stnum(jx) eq '06' then begin
    adjust_z,d2,nlines,17,17,1999,1,1.9254
    adjust_z,d2,nlines,18,18,1999,1,1.8717
    plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

grad_thresh,nlines,d2,icol,fcol,.25,mod_count,varname
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; before running S_V_Filter, snow height data are sent to misc 8 and 9
misc(7,*)=d2(17,*)
misc(8,*)=d2(18,*)

S_V_Filter,nlines,d2,17,18,2.5,80,.05,varname
last_val,nlines,d2,icol,fcol,varname,mod_count,modvar



plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr




; ------------- specific treatment of DYE-2, and others something in way of snow height
; 						   mesurements some of the time.

if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,1.54,1.8,39.6667,45.7083,year,1998.
  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
  last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
endif

; ---------------- specific treatment of Saddle
if stnum(jx) eq '10' then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.6,.83,1.0833,26.0417,year,1998.
endif

; ---------------- specific treatment of SDOME
if stnum(jx) eq '11' then begin
  for i=0,nlines-1 do begin
    if ((year eq 1998) and (d2(2,i) lt 7.))then begin
	d2(17,i)=1.067
	d2(18,i)=1.102
    endif
  endfor
endif

; ---------------- specific treatment of CP 1
if ((stnum(jx) ne '02' )and(year ne 1996))then begin
  S_V_Filter,nlines,d2,18,18,2.5,200,.03,varname
  last_val,nlines,d2,18,18,varname,mod_count,modvar
  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

; ----------------------------------------------------------------------- end specifics

  S_V_Filter,nlines,d2,17,17,2.5,100,.03,varname
  last_val,nlines,d2,17,18,varname,mod_count,modvar
  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr


if stnum(jx) eq '02' then begin
  for i=0,nlines-1 do begin
    if ((d2(1,i) eq 1997.) and (d2(2,i) ge 101.3750) and (d2(2,i) le 133.8333)) then d2(17,i)=d2(18,i)
  endfor
;sm_lim_filter,nlines,d2,18,18,varname,mod_count,2.2,2.6,12.,46.,year,1997
endif


if stnum(jx) eq '14' then begin
sm_lim_filter,nlines,d2,17,17,varname,mod_count,0.15,0.25,34.3333,64.75,year,1998
sm_lim_filter,nlines,d2,18,18,varname,mod_count,0.2,0.35,34.3333,64.75,year,1998

  last_val,nlines,d2,17,18,varname,mod_count,modvar

endif
; --------------------------------------- end more specifics

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

S_V_Filter,nlines,d2,17,18,2.5,100,.03,varname
last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

!p.multi=0
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,990
if ppp eq 'y' then oplot,d2(18,*),max_value=990,line=1,color=180
if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s

; -----------------------------------	begin final low pass filtering.

S_V_Filter,nlines,d2,17,18,2.5,100,.03,varname
last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; XXXXXX
;S_V_Filter,nlines,d2,icol,fcol,2.5,60,.02,varname
;last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
;plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

;S_V_Filter,nlines,d2,icol,fcol,2.5,30,.02,varname
;last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
;plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr


if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,200,366,year,2000.
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,17,18,varname,mod_count,-999,-99,42.5,137.5,year,1997
endif



if stnum(jx) eq '12' then begin
  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,269,367.,year,2000

  sm_lim_filter,nlines,d2,17,17,varname,mod_count,-999,-99,1,157.,year,2001
;  first_val,nlines,d2,icol,icol,varname,mod_count,modvar,year,2001
endif

read_in_end_of_last_year_snow_heights,jx,stnum,path2,d2,yr,nlines,ly,nstations,ivals

if stnum(jx) eq '01' and year eq 2001 then begin
  for i=0,nlines-1 do if d2(18,i) ne 999. then d2(18,i)=d2(18,i)+(-2.1)
endif

if stnum(jx) eq '09' and year eq 2001 then begin
  for i=0,nlines-1 do begin
    if d2(17,i) ne 999. then d2(17,i)=d2(17,i)+(-2.657)
    if d2(18,i) ne 999. then d2(18,i)=d2(18,i)+(-2.774)
  endfor
endif

if stnum(jx) eq '10' and year eq 2001 then begin
  for i=0,nlines-1 do begin
    if d2(17,i) ne 999. then d2(17,i)=d2(17,i)+2.55
  endfor
endif


limits_filter,nlines,d2,icol,fcol,varname,mod_count,-20.,21.
init_instr_z,stnum,nlines,d2,jx,stnams,nstations,yr,ly,path2

if stnum(jx) eq '09' and year eq 2001 then begin
  for i=0,nlines-1 do begin
    if d2(32,i) ne 999. then d2(32,i)=d2(32,i)+(-1.37)
    if d2(33,i) ne 999. then d2(33,i)=d2(33,i)+(-1.37)
  endfor
endif

if stnum(jx) eq '11' and year eq 2001 then begin
  for i=0,nlines-1 do if d2(2,i) ge 158.45 then d2(17,i)=d2(17,i)+5.429
endif

write_out_end_of_year_snow_n_instr_z,jx,stnum,path2,d2,yr,nlines

; ======================================================================== end variable














; ====================================================================== begin variable
;printf,6,''
;printf,6,'----------------------------------------- Type-E temperature cleaning.'
print,''
print,'----------------------------------------- Type-E temperature cleaning.'
varname='Type E Air temperature'
icol=6
fcol=7
search_size=10

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,213.333,367,year,1998
endif

if stnum(jx) eq '07' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-80.,-40.,338,340,year,1999
endif

if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-35.,-6.,149.9583,158.2917,year,1996
endif



limits_filter,nlines,d2,icol,fcol,varname,mod_count,-80.,10.
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
grad_thresh,nlines,d2,icol,fcol,12.,mod_count,varname
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,24,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
grad_thresh,nlines,d2,icol,fcol,8.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,10,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
; ----------------------------------- special case Summit data gap

if stnum(jx) eq '06' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,36.,94.9583,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,95.,134.6667,year,1998.
endif

if stnum(jx) eq '07' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-20.,0.,174.2083,195.0833,year,1998
endif

if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,111.7917,155.4583,year,1997
endif

if stnum(jx) eq '09' then begin
  sm_lim_filter,nlines,d2,6,6,varname,mod_count,-999.,-99.,147.,365.9583,year,1998
  sm_lim_filter,nlines,d2,6,6,varname,mod_count,-999.,-99.,1.0,151.5417,year,1999
endif

if stnum(jx) eq '10' then begin
  instrument_reverse,nlines,d2,varname,modvar,year,1999,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2000,1,155,icol,fcol
endif

if stnum(jx) eq '13' then begin
  instrument_reverse,nlines,d2,varname,modvar,year,1999,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2000,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2001,1,366,icol,fcol
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; ======================================================================== end variable













; ====================================================================== begin variable
;printf,6,''
;printf,6,'----------------------------------------------- CS500 Temp cleaning.'
print,''
print,'------------------------------------------------- CS500 Temp cleaning.'
varname='CS-500 Air Temperature'
icol=8
fcol=9
search_size=12



if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-35,20,154.125,162.4583,year,1996
endif
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s

limits_filter,nlines,d2,icol,fcol,varname,mod_count,-41,10.
grad_thresh,nlines,d2,icol,fcol,12.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
grad_thresh,nlines,d2,icol,fcol,8.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,188.583,367,year,1996
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,187.792,367,year,1996
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,133.833,year,1997
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,131.6250,132.7083,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,131.6250,365.9583,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,134.4583,367,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2002
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,205,367,year,2002
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
endif

if stnum(jx) eq '05' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,63.417,130.625,year,1996
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,248.0000,367,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,1998
  sm_lim_filter,nlines,d2,8,9,varname,mod_count,-999,-99,1.0417,124.7083,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,29.125,367,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,367,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,167,367,year,2003
endif

if stnum(jx) eq '06' then begin
   sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,1,244.625,year,1997.
   sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,335.875,367,year,1998.
   sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,304.5417,366,year,1996.
endif

if stnum(jx) eq '07' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,91.9167,365.9583,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,292.625,365.9583,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.0,138.9583,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,367,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,140.875,367,year,1999
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,160,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,160,367,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2002
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,150.7083,year,2003

  instrument_reverse,nlines,d2,varname,modvar,year,1996,1,366,icol,fcol
endif

if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,258.2917,297.125,year,1996
endif

if stnum(jx) eq '09' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,367,year,2004
endif

if stnum(jx) eq '11' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,167.8333,365.9167,year,1997
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,112.8333,year,1999
endif

if stnum(jx) eq '12' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,346.6667,367,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,365.9583,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,140.7083,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,140.7083,367.,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367.,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,159.5,year,2001
endif

if stnum(jx) eq '13' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.0,366,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.0,155.7917,year,2000

  instrument_reverse,nlines,d2,varname,modvar,year,1997,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1998,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1999,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2000,1,156,icol,fcol
endif

if stnum(jx) eq '14' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.0,160.875,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,367,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,367,year,2001
endif

if stnum(jx) eq '17' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,115,126.6777,year,2002
endif

if stnum(jx) eq '19' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,20,1,366,year,2002
endif

if stnum(jx) eq '20' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-15,6,1.,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-15,6,1.,367,year,2001
endif


plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s

varname='dt TC CS'
dtdz_filter,nlines,d2,varname,mod_count,year,6,7,ppp,plot_prompt

; ======================================================================== end variable











; ======================================================================== Begin variable
correct_overheat,d2,nlines,modvar,stnum,jx,yr,path2,misc
; ======================================================================== end variable



; ====================================================================== begin variable
;printf,6,''
;printf,6,'------------------------------------------------- pressure cleaning.'
print,''
print,'--------------------------------------------------- pressure cleaning.'
varname='pressure'
icol=16
fcol=16
search_size=48




plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
limits_filter,nlines,d2,icol,fcol,varname,mod_count,500,1100


if stnum(jx) eq '01' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,800,998
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999.,-99.,132.875,133.9167,year,1997.
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,0.,1.,126.750,131.5,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,213.333,367,year,1998
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,156,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,1,366,year,2001
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,1,128.4583,year,2002
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,785,825.,128.4583,366,year,2002
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,775,900,1,366,year,2003
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,790,900,1,366,year,2004
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,1,366,year,2002
endif

if stnum(jx) eq '04' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,42.5,137.4167,year,1997
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,785.,800.,123.,130.750,year,1996.
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,0.,1.,126.750,131.5,year,1996.
endif

if stnum(jx) eq '05' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,237.167,237.167,year,1996.
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,770,900,120,250,year,2003.
endif

if stnum(jx) eq '06' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,600,700,1,366,year,1996.
endif

if stnum(jx) eq '07' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,700,820
endif

if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,750.,780.,149.9583,154.1250,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,760.,800.,175.,183,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,720.,810.,1.,367,year,2000.
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,1,367,year,2002
endif

if stnum(jx) eq '09' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,850.,998.,1.,367,year,2000.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,860.,998.,1.,367,year,2004.
endif

if stnum(jx) eq '10' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,110.875,365.9583,year,1997
   sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,1.,107.5,year,1998
endif

if stnum(jx) eq '11' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,113.6667,365.9167,year,1997
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,-999,-99,1.,108.8333,year,1998
endif

if stnum(jx) eq '13' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,710,990,1.,366,year,1999
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,710,990,1.,366,year,2000
endif

if stnum(jx) eq '15' then begin
  sm_lim_filter,nlines,d2,16,16,varname,mod_count,710,990,113.,120,year,1998
endif

if stnum(jx) eq '17' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,700,998
endif

grad_thresh,nlines,d2,icol,fcol,3.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
S_V_Filter,nlines,d2,icol,fcol,2.,200,5.,varname
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
grad_thresh,nlines,d2,icol,fcol,5.,mod_count,varname
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,1200
;clean_frozen,nlines,d2,icol,icol,0.1,modvar

; ======================================================================== end variable













; ====================================================================== begin variable
;printf,6,''
;printf,6,'------------------------------------------------------- RH cleaning.'
print,''
print,'--------------------------------------------------------- RH cleaning.'
varname='Relative Humidity'
icol=10
fcol=11
search_size=10

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
limits_filter,nlines,d2,icol,fcol,varname,mod_count,50.,120.
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
grad_thresh,nlines,d2,icol,fcol,15.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar


if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,265.1250,366,year,2003
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,60.,103.,1,367,year,1997
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,147.625,366.,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,156.0417,year,2000
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2002
endif

if stnum(jx) eq '04' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,41.875,43,year,1997
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,134.4583,367,year,1999
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
endif

if stnum(jx) eq '05' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,63.417,130.625,year,1996
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,29.125,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,118.8333,year,2002
endif

if stnum(jx) eq '06' then begin
sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,143.8333,year,1997
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,243.7083,244.75,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,105,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,191.583,191.875,year,1998.
;obsolete  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,191.708,191.692,year,1998.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,335.250,367,year,1998.
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,335.875,336.834,year,1998.
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1,366,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,20,100.1,1,366,year,1999
  
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1,168.75,year,2000
endif


if stnum(jx) eq '07' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,43,367,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.0,138.9583,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,50,100,276.,365.9583,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,292.0417,year,1999
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,160,367,year,2001
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,367,year,2002
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,150.7083,year,2003
  ;instrument_reverse,nlines,d2,varname,modvar,year,1996,1,366,icol,fcol
endif

if stnum(jx) eq '09' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1,367,year,2004
endif

if stnum(jx) eq '11' then begin
;  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,137.2917,365.9167,year,1997
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,167.8333,365.9167,year,1997
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,365.9583,year,1998
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1.,112.9167,year,1999
endif

if stnum(jx) eq '12' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,346.6667,367,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,365.9583,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,367,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,367,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,1.,159.5,year,2001
endif

if stnum(jx) eq '13' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,50.0833,147.9167,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,48,366,year,1999
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999,-99,1,155.7917,year,2000
  instrument_reverse,nlines,d2,varname,modvar,year,1997,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1998,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1999,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2000,1,156,icol,fcol
endif

if stnum(jx) eq '14' then begin
;  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,50,150,1,367,year,1997
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,46.7083,160.875,year,1998
endif

if stnum(jx) eq '17' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,115,126.6777,year,2002
endif

layot='x'
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s
layot='x'

; ======================================================================== end variable






; ------------------------------------------------  Measure temperatures with RH sensor
; --------- synthesize T using RH, T_COR_W_RH must come before RH_ICE sub routine and after RH cleaning
;
  if year le 2000 then t_cor_w_rh,nlines,d2,modvar,jx,stnum,path3,yr,nstations,ppp
; -----------------------------------------------------






; ====================================================================== begin variable'
print,''
print,'-------- Type-E temperature cleaning, removal of bad data after T synthesis with RH data.'
varname='Type E Air temperature'
icol=6
fcol=7

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,201.625,201.958,year,2002. ; BAD TC
endif

if stnum(jx) eq '06' then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,142.625,367,year,1997. ; BAD TC dT
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,1,94.9583,year,1998. ; BAD TC dT
endif


if stnum(jx) eq '09' then begin
  sm_lim_filter,nlines,d2,6,6,varname,mod_count,-999.,-99.,147.,365.9583,year,1998 ; BAD TC dT
  sm_lim_filter,nlines,d2,6,6,varname,mod_count,-999.,-99.,1.0,151.5417,year,1999 ; BAD TC dT
endif

if stnum(jx) eq '10' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,367,year,1997. ; BAD TC dT
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,107.5833,year,1998. ; BAD TC dT
endif

if stnum(jx) eq '11' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,367,year,1997. ; BAD TC dT
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,107.7083,year,1998. ; BAD TC dT
endif

if stnum(jx) eq '13' then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,367,year,1997. ; BAD TC dT
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,367,year,1998. ; BAD TC dT
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,1.,148,year,1999. ; BAD TC dT

endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; ======================================================================== end variable



; ======================================================================== Begin variable
; this procedure  must come after t_cor_w_ rh procedure !
varname='RH Ice'
icol=10
fcol=11
search_size=10
pptile=0.96
rh_col=[10,11]
t_col=[8,9]

if (stnum(jx) eq '06' )then pptile=0.9
if (stnum(jx) eq '14' )then pptile=0.92
if (stnum(jx) eq '15' )then pptile=0.92


rh_ice,nlines,d2,stnum,jx,yr,path3,nstations,stnames,pptile,t_col,rh_col,ppp

limits_filter,nlines,d2,icol,fcol,varname,mod_count,40.,100.001
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s

; - CS-500 filter after rhice to allow the use of -40 limit when no TYPE-E TC data avbailable
limits_filter,nlines,d2,8,9,varname,mod_count,-70,10.

; ======================================================================== end variable










; ------------------------------------------- convert RH into specific humidity
;varname='Specific Humidity (q)'
;icol=10
;fcol=11
;specific_humidity,d2,nlines,path2,nstations,jx
;plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr











; ====================================================================== begin variable
print,''
print,'-------------------------------------------- snow temperature cleaning.'
varname='Snow temperature'
icol=19
fcol=28
if ((stnum(jx) eq '03')and(year lt 1998)) then icol=28
if ((stnum(jx) eq '03')and(year ge 1998)) then icol=19
search_size=2000

plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
limits_filter,nlines,d2,icol,fcol,varname,mod_count,-55,10.

if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-20,-7,90,100,year,1999
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-17,1,1,367,year,2001
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,213.,367,year,1998
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,-12.,282.,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,0.05,1.,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-22,-14,25.,40,year,2001
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-22,-14,1.,367,year,2001
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-21,-13,1.,367,year,2002
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-18.5,-13,1.,367,year,2003
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-18,-14,100.,367,year,2004
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-32,-9,134,367,year,1999.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-35,-10,1.,367,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-30,-21,1.,148,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-30,-21,1.,148,year,2001
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-30,-17.5,148.,366,year,2001
; the logger data should eliminate this problem and this line of code.
  if year eq 2000 then interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-30,-20,1.,366,year,2002
endif

if (stnum(jx) eq '04') then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,-31,0.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-37,-22,1.,138,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-37,-13,1.,366,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-28,-17,1.,366,year,2001
endif

if (stnum(jx) eq '05') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-45,-10,310,367,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-32,-9,1,367,year,1997.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-42,-12,1,167,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-31,-10,230,367,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-35,-18,1,367,year,2000.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-35,-16,1,367,year,2001.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-35,-16,1,367,year,2003
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-31,-8,1,367,year,1999.
endif

if (stnum(jx) eq '05') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-45,-25,1.0417,84,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-38,-13,1.0417,214.625,year,1999.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-15.5,209.,251.,year,1999.
  plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
; the following line needed because the transmitted data had very few data points
; the logger data should eliminate this problem and this line of code.
  if year eq 2000 then interp,nlines,d2,icol,fcol,ncols,varname,mod_count,400,modvar
endif

if (stnum(jx) eq '07') then begin
; obsolete  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-12,167.75,209.4167,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-15,1,367,year,1999.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-22,1,142,year,2000.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-38,-19,1,366,year,2001.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-38,-19,1,142,year,2002.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-35,-19,1,367,year,2003.
endif

if (stnum(jx) eq '08') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-18,-12,145.8333,154.1250,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-19,0,253,355,year,1999.
endif

if (stnum(jx) eq '09') then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,-50,10.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-13,10,204.,230.,year,1996.
endif

if (stnum(jx) eq '11') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-10,300.,360.,year,2001.
endif

if (stnum(jx) eq '14') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,-19,1.,367,year,1999.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,-19,1.,367,year,2000.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,-30,1.,159,year,2000.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-23,1.,367,year,2001.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-40,-23,1.,367,year,2002.
endif

grad_thresh,nlines,d2,icol,fcol,2.,mod_count,varname

plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg

S_V_Filter,nlines,d2,icol,fcol,2.,400,1.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
S_V_Filter,nlines,d2,icol,fcol,2.,60,1.,varname
plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
S_V_Filter,nlines,d2,icol,fcol,2.,120,1.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
S_V_Filter,nlines,d2,icol,fcol,2.,30,1.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar


; -----------------------------------
if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol-1,varname,mod_count,-999.,-99.,1,168.625,year,1996.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,154.5417,365.9583,year,1998.
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,309.2917,365.9583,year,1997.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,1.,149.9167,year,1998.
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,19,27,varname,mod_count,-999.,-99.,1,132.625,year,1998.
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-50,-7,126.6667,292.7083,year,1999
plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
endif



; ----------------------------------- special case Summit data gap
if stnum(jx) eq '06' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,36.,91.625,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,95.,134.6667,year,1998.
endif
; ----------------------------------- special case dye-2 data gap
if stnum(jx) eq '08' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,111.7917,155.4583,year,1997.
endif

if stnum(jx) eq '05' then begin	; --------------- to deal with noisy transmissions
  sm_lim_filter,nlines,d2,icol,fcol-1,varname,mod_count,-999.,-99.,1,130.583,year,1996.
  S_V_Filter,nlines,d2,icol,fcol,2.5,240,2.,varname
  interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,285.500,300.0833,year,1997.
endif

if (stnum(jx) eq '09') then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,-49.75,10.
endif


plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg

calc_snow_t_z,nlines,d2,stnum,jx,path2,z,nstations,path,yr
;calc_T_snow_fixed_intervals,nlines,d2,z,tt,zz,jx,path2,nstations

if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s
; -------------------------------------------------- end Snow temperature
; ======================================================================== end variable











; ====================================================================== begin variable
;printf,6,''
;printf,6,'---------------------------------------------- sw Radiation cleaning.'
print,''
print,'------------------------------------------------ sw Radiation cleaning.'
varname='Shortwave Radiation'
icol=3
fcol=4

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s

if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,265.1250,366,year,2003
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,249.,366,year,2004
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,213.333,367,year,1998
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,229.,367,year,2004
endif

if stnum(jx) eq '05' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,1,160,year,2003
endif

if stnum(jx) eq '06' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,36.,91.625,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,95.,134.6667,year,1998.
endif

if (stnum(jx) eq '07') then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,65,93,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,80,95,year,2001
endif

if (stnum(jx) eq '10') then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,53,65,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,290,320,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,69,79,year,2001
endif

if (stnum(jx) eq '12') then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,70,125,year,1998
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,70,115,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,270,300,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,60,105,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,60,119,year,2001
endif

if (stnum(jx) eq '14') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,81,95,year,1998
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,75,94,year,1999
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,55,104,year,2000
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-99.,82,94,year,2001
endif


if (stnum(jx) eq '20') then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,1,367,year,2000
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,-999.,-99.,1,367,year,2001
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s
sw_clean,d2,lat,lon,nlines,solar_zenith,mod_count,modvar,misc,path2
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s
grad_thresh,nlines,d2,icol,fcol,200.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,4,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
;read,s

; ======================================================================== end variable









; ====================================================================== begin variable
;printf,6,''
;printf,6,'-------------------------------------------- Net Radiation cleaning.'
print,''
print,'---------------------------------------------- Net Radiation cleaning.'
varname='Net Radiation'
icol=5
fcol=5
search_size=5
plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,990
;read,s
if stnum(jx) eq '04' then limits_filter,nlines,d2,icol,fcol,varname,mod_count,-200.,100.
if stnum(jx) ne '04' then limits_filter,nlines,d2,icol,fcol,varname,mod_count,-200.,600.

if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-100,150.,1.,367,year,1997
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,141.4167,164,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,265.1250,366,year,2003
endif

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,213.333,367,year,1998.
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99.,229.,367,year,2004.
endif

if stnum(jx) eq '05' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,70,97,year,1998
endif

if stnum(jx) eq '07' then begin
 sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999.,-599.,72,76,year,2001
endif

if stnum(jx) eq '12' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-60,150.,1.,130,year,1999
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,58.,105,year,2000
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,48.,118,year,2001
endif

if stnum(jx) eq '12' then limits_filter,nlines,d2,icol,fcol,varname,mod_count,-200.,150.

if (stnum(jx) eq '14') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-599.,81,95,year,1998
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-599.,40,100,year,1999
endif

if (stnum(jx) eq '15') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-150,100,1,150,year,2002
endif


grad_thresh,nlines,d2,icol,fcol,120.,mod_count,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
; ----------------------------------- special case Summit data gap
if stnum(jx) eq '06' then begin
sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-200.,75.,1.,126.,year,1998.
sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,36.,91.625,year,1998.
sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999.,-99.,95.,134.6667,year,1998.

endif

plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,990
;read,s

; ======================================================================== end variable








; ====================================================================== begin variable
; must come before wind cleaning
varname='Synthetic Wind Speeds'
icol=30
fcol=31

wind_constant_z,stnum,nlines,d2,jx,stnames,nstations,modvar,0.97,ppp

interp,nlines,d2,30,31,2,'synthetic wind speed',mod_count,4,modvar
clean_frozen,nlines,d2,30,31,0.1,modvar
interp,nlines,d2,30,31,2,'synthetic wind speed',mod_count,4,modvar

scattergram,ppp,nlines,stnames,layot,plot_prompt,d2,12,30,jx,yr,xvarname,yvarname
scattergram,ppp,nlines,stnames,layot,plot_prompt,d2,13,31,jx,yr,xvarname,yvarname

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,12,13,jx,yr
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; ======================================================================== end variable

;			keep instr height following wind_constant z

; ====================================================================== begin variable
; --------------------------------------------------------------- plot instrument heights
varname='Profile Instrument Heights'
icol=32
fcol=33

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

; ======================================================================== end variable





; ====================================================================== begin variable
;printf,6,''
;printf,6,'------------------------------------------- Wind Direction cleaning.'
print,''
print,'--------------------------------------------- Wind Direction cleaning.'
varname='Wind Direction'
icol=14
fcol=15
search_size=4

if stnum(jx) eq '01' then begin		; correct wind sensor pointing 180 degrees in wrong dir
  if year eq '1998' then begin
    for i=0,nlines-1 do begin
      if d2(2,i) gt 154.5 then begin
	for jjj=icol,fcol do begin
	  d2(jjj,i)=d2(jjj,i)-117.
	  if d2(jjj,i) lt 0 then d2(jjj,i)=d2(jjj,i)+360.
	endfor
      endif
    endfor
  endif
  if year eq '1999' then begin
    for i=0,nlines-1 do begin
      if d2(2,i) lt 146.833 then begin
	for jjj=icol,fcol do begin
	  d2(jjj,i)=d2(jjj,i)-117.
	  if d2(jjj,i) lt 0 then d2(jjj,i)=d2(jjj,i)+360.
	endfor
      endif
    endfor
  endif
endif

if stnum(jx) eq '02' then begin		; correct wind sensor pointing 180 degrees in wrong dir
  if year ge 1997 then for i=0,nlines-1 do if d2(14,i) ne 999. then d2(14,i)=abs(d2(14,i)-360.)
  if year eq '1996' then begin
    for i=0,nlines-1 do begin
      if d2(2,i) gt 141.708 then begin
        if d2(14,i) ne 999. then d2(14,i)=abs(d2(14,i)-360.)
      endif
    endfor
  endif
endif

shift_wind_dir,nlines,d2,jx,stnum,fcol,127.6667,'17',140,2002,year
shift_wind_dir,nlines,d2,jx,stnum,icol,118,'17',90,2003,year
shift_wind_dir,nlines,d2,jx,stnum,fcol,118,'17',-150,2003,year

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
endif

if (stnum(jx) eq '07') then begin
  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,231.375,256,year,2000
endif

if (stnum(jx) eq '11') then begin
  sm_lim_filter,nlines,d2,fcol,fcol,varname,mod_count,0.,330.,146,367,year,2001
endif

limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.,360.1
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
clean_frozen,nlines,d2,icol,fcol,0.5,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
S_V_Filter,nlines,d2,icol,fcol,3.,20,50.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

xvarname='wind dir 1'
yvarname='wind dir 2'
scattergram,ppp,nlines,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,xvarname,yvarname
; ======================================================================== end variable








; ====================================================================== begin variable
;printf,6,''
;printf,6,'----------------------------------------------------- Wind cleaning.'
print,''
print,'------------------------------------------------------- Wind cleaning.'
varname='Wind'
icol=12
fcol=13
search_size=10

limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.,35.


plot_tower_wake_effects,nlines,d2,icol,fcol,14,32,ppp
;read,s

if stnum(jx) eq '01' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-599.,265.1250,366,year,2003
endif

;if (stnum(jx) eq '07') then begin
;  sm_lim_filter,nlines,d2,icol,icol,varname,mod_count,-999,-99,231.375,256,year,2000
;endif

if stnum(jx) eq '01' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,200.,240.,year,2000,1,366,ppp
endif

if stnum(jx) eq '02' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,235.,245.,year,1996,1,366,ppp;,'02'
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,245.,260.,year,1997,1,366,ppp;,stnum(jx)
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,195.,240.,year,1999,1,366,ppp
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,200.,250.,year,2000,1,366,ppp
endif

if stnum(jx) eq '03' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,230.,290.,year,2000,1,366,ppp
endif


if stnum(jx) eq '05' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,220.,310.,year,2000,1,366,ppp
endif

if stnum(jx) eq '06' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,90.,120.,year,2000,1,366,ppp
endif

if stnum(jx) eq '07' then begin
  tower_wake_filter,nlines,d2,icol,icol,14,32,modvar,stnum,yr,jx,path2,200.,210.,year,2000,1,366,ppp
endif

if stnum(jx) eq '09' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,220.,285.,year,1997,1,366,ppp
endif

if stnum(jx) eq '10' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,60.,95.,year,1997,1,366,ppp
endif

if stnum(jx) eq '14' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,80.,130.,year,1999,1,366,ppp
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,110.,145.,year,2000,1,168,ppp
endif

if stnum(jx) eq '17' then begin
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,125.,175.,year,1999,1,366,ppp
  tower_wake_filter,nlines,d2,icol,fcol,14,32,modvar,stnum,yr,jx,path2,125.,175.,year,2000,1,152,ppp
endif

grad_thresh,nlines,d2,icol,fcol,10.,mod_count,varname
clean_frozen,nlines,d2,icol,fcol,0.1,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
S_V_Filter,nlines,d2,icol,fcol,3.5,200,2.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr

if stnum(jx) eq '02' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-1,10.69,143.417,365.958,year,1995
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-1,10.69,1.0000,141.5,year,1996.
  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

if stnum(jx) eq '03' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-1,10.69,151.0417,365.9583,year,1995
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-1,10.69,1.,211.4583,year,1996
  plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
endif

if (stnum(jx) eq '04') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,42.5,137.4167,year,1997
endif



if (stnum(jx) eq '14') then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,-999,-99,1.0417,92,year,1999
endif

if (stnum(jx) eq '13') then begin
  instrument_reverse,nlines,d2,varname,modvar,year,1997,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1998,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,1999,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2000,1,366,icol,fcol
  instrument_reverse,nlines,d2,varname,modvar,year,2001,1,366,icol,fcol
endif

plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
dircol=14
if stnum(jx) eq '04' then dircol=15
;if (stnum(jx) eq '04') and (year eq '1997')then dircol=15

fix_neg_wind_gradients,nlines,d2,icol,fcol,dircol,32,modvar,stnum,yr,jx,path2 ;hi




plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
plot_tower_wake_effects,nlines,d2,icol,fcol,14,32,ppp
;read,s

; ======================================================================== end variable























; ====================================================================== begin variable
varname='albedo'
icol=34
fcol=34
search=20

if stnum(jx) eq '06' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.75,.98
endif

if stnum(jx) eq '07' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.8,.98
endif

if stnum(jx) eq '11' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.7,.98
endif

if stnum(jx) eq '12' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.84,.98
endif

if stnum(jx) eq '14' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.75,.92
endif

limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.05,.98
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar

if stnum(jx) eq '06' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.75,.98
endif

if stnum(jx) eq '07' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.8,.98
endif

if stnum(jx) eq '11' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.7,.98
endif

if stnum(jx) eq '12' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.84,.98
endif

if stnum(jx) eq '14' then begin
  limits_filter,nlines,d2,icol,fcol,varname,mod_count,0.75,.92
endif

if stnum(jx) eq '17' then begin
  sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,0.6,1.,1,120,year,2002
endif

plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,990
; ======================================================================== end variable



;for i=0,nlines-1 do begin
;      if d2(2,i) ge 144.95 then begin
;	print,d2(2,i),d2(3,i),d2(4,i),d2(34,i)
;	read,s
;      endif
;endfor









; ====================================================================== begin variable
;printf,6,''
;printf,6,'---------------------------------------------- Battery Data cleaning.'
print,''
print,'------------------------------------------------ Battery Data cleaning.'
varname='Battery'
icol=29
fcol=29
grad_thresh,nlines,d2,icol,fcol,6.,mod_count,varname
S_V_Filter,nlines,d2,icol,fcol,2.,600,2.,varname
interp,nlines,d2,icol,fcol,ncols,varname,mod_count,50,modvar

plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,990
; ======================================================================== end variable









;printf,6,''
;printf,6,'------------------------------------------------ Plot miscelaneous data.'
print,''
print,'-------------------------------------------------- Plot miscelaneous data.'
varname='miscelaneous'

for k=0,9 do begin
  for i=0,nlines-1 do begin
    if (abs(misc(k,i)) gt 998) then misc(k,i)=999.
  endfor
;  plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,misc,i,jx,yr,990
endfor


;printf,6,''
;printf,6,'------------------------------------------------ Plot cleaned data.'
print,''
print,'-------------------------------------------------- Plot cleaned data.'
if final_plot_prompt eq 'y' then begin
  aws_plot,d2,layot,nlines,cs,lim,jx,final_plot_prompt,misc,colo,bg
endif

;printf,6,''
;printf,6,'------------------------------------- Write out cleaning statistics.'
print,''
print,'--------------------------------------- Write out cleaning statistics.'
clean_stat,d2,nlines,ncols,stnum,jx,path,mod_count,yr

;printf,6,''
;printf,6,'---------------------------------------------------- Write out data.'
print,''
print,'------------------------------------------------------ Write out data.'
qi_init_final,nlines,d2,ncols,modvar
write_out,nlines,path,outputfile,d2,length,jx,nstations,modvar,misc,stnum,yr,tt,zz

print,''
print,'----------------------------------------------------- closing inf file'
;printf,6,''
;printf,6,'------------------------------------------------ Done AWS_CLEAN.PRO'
close,6 ; information file

endif; toread
  endfor ; kkk
endfor ; jx



print,''
print,'-------------------------------------------------- Done AWS_CLEAN.PRO'

end
; ------------------------------------------------------- end main program
; ----------------------- following are sub-routines
;
;
;
;
;
;




;-------------- sub routine --------------  SD height readjust

pro adjust_z,d2,nlines,icol,fcol,year,chg_time,dz

; ------------------------------------- loop through data
;printf,6,''
;printf,6,'Begin height re-adjust.'
print,''
print,'Begin height re-adjust.'

for k=icol,fcol do begin
  c=0
  for i=1,nlines-1 do begin
    if((d2(2,i) ge chg_time)and(d2(1,i) eq year)and(d2(k,i) lt 990.)) then begin
      d2(k,i)=d2(k,i)-dz
      c=c+1
    endif
  endfor
  print,'  Number of data points modified : ',c
endfor

;printf,6,'End loop of height re-adjust.'
;printf,6,''
print,'End loop of height re-adjust.'
print,''
end ; ---------------------------------------------------------000






;-------------- sub routine --------------  Solar Zenith sub-routine

function solar_zenith,jday,lat,lon
;-----------------------------------------------------------------------
;  This function returns the solar zenith angle.
;
;  INPUT:
;       JDAY     DECIMAL JULIAN DAY (JAN. 1 AT NOON IS DAY 1.5),
;                GREENWICH MEAN TIME
;       LON      DEGREE LONGITUDE OF GRID POINT,
;                COUNTED POSITIVE WEST OF GREENWICH
;       LAT      DEGREE LATITUDE  OF GRID POINT,
;                COUNTED POSITIVE NORTHERN HEMISPHERE
;
;  OUTPUT:
;       ZENANG   ZENITH ANGLE IN DEGREES
;
;-----------------------------------------------------------------------
;       D A T A               V A R I A B L E S:
;-----------------------------------------------------------------------
;       EPSILN   ECCENTRICITY OF EARTH ORBIT
;       SINOB    SINE OF OBLIQUITY OF ECLIPTIC
;       DPY      DAYS PER YEAR (365.242)
;       DPH      DEGREES PER HOUR (360./24)
;-----------------------------------------------------------------------
;       I N T E R N A L       V A R I A B L E S:
;-----------------------------------------------------------------------
;       DPR      DEGREE/RADIAN (*57.29578)
;       RPD      RADIAN/DEGREE (*.01745329)
;       DANG     ANGLE MEASURED FROM PERIHELION, IN RADIANS
;                WHICH IS TAKEN AS MIDNIGHT JAN. 1
;       HOMP     HOURS OF MERIDIAN PASSAGE OR TRUE SOLAR NOON
;                ( Reference -- eq  1.6 )
;       HANG     HOUR ANGLE, A MEASURE OF THE LONGITUDINAL DISTANCE
;                TO THE SUN FROM THE POINT CALCULATED  ( eq  1.5 )
;       SINDLT   SINE OF DECLINATION ANGLE  ( eq  1.2 )
;       COSDLT   COSINE OF DECLINATION ANGLE
;       SIGMA    Reference -- eq  1.3A
;       ANG      Reference -- eq  1.3B
;
;       REFERENCE:    Woolf, H.M., NASA TM X-1646.
;                     ON THE COMPUTATION OF SOLAR ELEVATION
;                     ANGLES AND THE DETERMINATION OF SUNRISE
;                     AND SUNSET TIMES.
;-----------------------------------------------------------------------
      raddeg = 180./3.1415927
      HOUR = (JDAY - FIX(JDAY))*24.

      EPSILN = .016733
      SINOB = .3978
      DPY = 365.242
      DPH = 15.0
      PI = 3.1415927
      RPD = PI/180.0
      DPR = 1.0/RPD
      DANG = 2.0*PI* (JDAY-1.0)/DPY
      HOMP = 12.0 + 0.123570*SIN(DANG) - 0.004289*COS(DANG) + $
             0.153809*SIN(2.0*DANG) + 0.060783*COS(2.0*DANG)
      HANG = DPH* (HOUR-HOMP) - LON
      ANG = 279.9348*RPD + DANG
      SIGMA = (ANG*DPR+0.4087*SIN(ANG)+1.8724*COS(ANG)- $
              0.0182*SIN(2.0*ANG)+0.0083*COS(2.0*ANG))*RPD
      SINDLT = SINOB*SIN(SIGMA)
      COSDLT = SQRT(1.0-SINDLT^2)
      temp = SINDLT*SIN(RPD*LAT) + COSDLT*COS(RPD*LAT)*COS(RPD*HANG)
      zenang = acos(temp)*raddeg

      return,zenang
      END





pro sw_clean,d,lat,lon,nlines,solar_zenith,mod_count,modvar,misc,ancpath
; --------------------------------------------------------------------
; 	idl sub-routine to reject data beyond user defined limits
; it is more general than the small limits filter, used to reject impossible
; data using absolute limits.
; --------------------------------------------------------------------

print,'Begin sw cleaning loop.'
zen=0.


for i=1,nlines-1-1 do begin

  albedo=999.
  flag=0
; ----------------------------------- calculate solar zenith angle
  zen=solar_zenith(d(2,i),lat,lon)
  misc(9,i)=zen
; ---------------------------------- Clean Radiation data
; correct for LI-COR spectral bias in reflected radiation
  ;coef=0.934
  coef=1.
  coef2=1.
  ;if d(0,i) eq 0. then coef=0.96
  ; summit bias stats:
  ; SW down bias 0.984303
  ; sw in bias 1.07505
  if d(0,i) eq 6. then begin
    coef=0.92495
   ; coef2=0.984303
  endif
  ; Tunu-N special correction after box et al, submitted to J. appl met.

  ;if d(0,i) eq 6. then coef=0.91
  ;if d(0,i) eq 6. then coef=0.82
  ;if d(0,i) eq 6. and d(3,i) ne 999. then d(3,i)=d(3,i)*0.96

  ;if d(0,i) eq 14. then coef=1.03
  if d(4,i) ne 999. then d(4,i)=d(4,i)*coef
  if d(3,i) ne 999. then d(3,i)=d(3,i)*coef2
  if d(3,i) ne 999. and d(4,i) ne 999. and d(3,i) ne d(4,i) and d(3,i) gt 1. and d(3,i) gt d(4,i) and zen lt 75 then begin
  albedo=(d(4,i)/d(3,i))
  flag=1
  endif

  ;if d(4,i) ne 999. and d(3,i) eq 999. and zen lt 90. then begin
  ;  d(3,i)=d(4,i)/albedo
  ;  modvar(3,i)=5
  ;    mod_count(3)=mod_count(3)+1.
  ;  print,'Synthetic SW data (a)',d(2,i),d(3,i),d(4,i),albedo
  ;endif

  ;if d(4,i) gt d(3,i) and d(3,i) ne 999. and d(4,i) ne 999. and zen gt 65 then begin
  ;  d(4,i)=d(3,i)*albedo
  ;    mod_count(4)=mod_count(4)+1.
  ;  modvar(4,i)=5
  ;  print,'Synthetic SW data (b) ',d(2,i),d(3,i),d(4,i),albedo
  ;endif

  ;if d(4,i) gt d(3,i) and d(3,i) ne 999. and d(4,i) ne 999. and zen lt 65 then begin
  ;  d(3,i)=d(4,i)/albedo
  ;    mod_count(3)=mod_count(4)+1.
  ;  modvar(3,i)=5
  ;  print,'Synthetic SW data (b) ',d(2,i),d(3,i),d(4,i),albedo
  ;endif

if zen gt 85. or flag eq 0 then albedo=999.

  if albedo ne 999. then begin
    d(34,i)=albedo
  endif else begin
    d(34,i)=999.
  endelse

  for k=3,4 do begin

; --------- flag sw data that are lt 5 w m^-2 when solar zenith angle is lt 85
    if d(k,i) gt 6. and zen gt 90. then begin
      d(k,i)=0.
      mod_count(k)=mod_count(k)+1.
    endif
    if(d(k,i) lt 0.) then d(k,i)=0.
  endfor

endfor

print,'  Fraction of Incoming sw values modified : ',mod_count(3)/nlines
print,'  Fraction of Reflected sw values modified : ',mod_count(4)/nlines

print,'End sw radiation cleaning loop.'
print,''

end ; ---------------------------------------------------------000















pro limits_filter,nlines,d2,icol,fcol,varname,mod_count,lo,hi
; --------------------------------------------------------------------
; 	idl sub-routine to reject data beyond user defined limits
; it is more general than the small limits filter, used to reject impossible
; data using absolute limits.
; --------------------------------------------------------------------

;printf,6,'Begin limits filter subroutine.'
print,'Begin limits filter subroutine.'

for k=icol,fcol do begin
  cc=0
  c=0
  for i=1,nlines-1 do if d2(k,i) ne 999. then c=c+1
  if c gt 10 then begin
    for i=1,nlines-1 do begin
      if ((d2(k,i) gt hi) or (d2(k,i) lt lo)) then begin
        d2(k,i)=999.
        cc=cc+1
      endif
    endfor
  endif
endfor

;printf,6,'  Number of data set to 999. : ',cc
print,'  Number of data set to 999. : ',cc

;printf,6,'End limits filter routine.'
;printf,6,''

print,'End limits filter routine.'
print,''
end



pro sm_lim_filter,nlines,d2,icol,fcol,varname,mod_count,lo,hi,day_0,day_f,year,yearx
; --------------------------------------------------------------------
; 	idl sub-routine to reject data beyond user defined limits in time
; and in the y dimension.  This filter is used to reject data that are not
; caught by the other filters.  For example if an instrument is mal-
; functioning, reading -40 all the time, this filter can reject all data
; by setting lo and hi to -999 and -99 respectively, or if a bad point
; is contaminating good data, a limit is set of data to keep.
; --------------------------------------------------------------------


flagx=0
modflag=0

if yearx ne year then begin
  flagx=1
endif



if flagx eq 0 then begin

print,'Begin small limits filter subroutine.',day_0,day_f,year

print,'  Minimum data timeframe acceptable ; ',lo,day_0
print,'  Maximum data timeframe acceptable ; ',hi,day_f

i_0=0
i_f=0

  ; ----------------- find min and max array indexes
  for i=nlines-1,0,-1 do if  ((d2(2,i) ge day_0) and( d2(2,i) ne 999.))then i_0=i
  for i=0,nlines-1 do if (d2(2,i) le day_f) then i_f=i

print,'  Begin time : ',day_0
print,'  Begin array index : ',i_0
print,'  End time : ',day_f
print,'  End array index : ',i_f
print,''

  cc=0

for k=icol,fcol do begin
  cc=0
    for i=i_0,i_f do begin
      if ((d2(k,i) gt hi) or (d2(k,i) lt lo)) then begin
    ;    print,i,d2(k,i)
	d2(k,i)=999.
modflag=1
        cc=cc+1
      endif
    endfor

;printf,6,'  Number of data set to 999. : ',cc
print,'  Number of data set to 999. : ',cc

endfor

if modflag eq 0 then begin
  print, 'This filter did nothing, do you want to modify it or remove this procedure call?'
  ;read,s
endif
; if ghd						; Jason 1020
;
;printf,6,'End small limits filter routine.'
;printf,6,''
print,'End small limits filter routine.'
print,''

endif ; flagx

end












pro interp,nlines,d2,icol,fcol,ncols,varname,mod_count,search_size,modvar
; --------------------------------------------------------------------
; 	idl sub-routine to linearly interpolate when a value is 999. and data
; are available within a given search size.
; --------------------------------------------------------------------

;printf,6,'Begin interpolation procedure : ',varname
;printf,6,'  search radius : ',search_size
print,'Begin interpolation procedure : ',varname
print,'  search radius : ',search_size

  print,''
  print,'Begin find_limits routine to search for range of good values.'
  print,''

  xmin=fltarr((fcol-icol)+1)
  xmax=fltarr((fcol-icol)+1)
  xmin(*)=nlines-1
  xmax(*)=8

  for kki=icol,fcol do begin
    for i=0,nlines-1 do begin
      if ((d2(kki,i) ne 999.) and(i lt xmin(kki-icol)))then xmin(kki-icol)=i
      if ((d2(kki,i) ne 999.) and(i gt xmax(kki-icol)))then xmax(kki-icol)=i
    endfor

    print,'  Minimum good location :',xmin(kki-icol)
    print,'  Maximum good location :',xmax(kki-icol)
  endfor

m=0.
b=0.


for k=icol,fcol do begin
  if xmin(k-icol) eq 0 then xmin(k-icol)=1

  c=0
  cc=0

  for i=0,nlines-1 do if d2(k,i) ne 999. then c=c+1

  if c le search_size then print,'  Not enough data for interpolation.'

  if c gt search_size then begin
    ct=0

    for i=xmin(k-icol),xmax(k-icol)-1 do begin

      if((d2(k,i-1) ne 999.) and (d2(k,i+1) ne 999.) and (d2(k,i) eq 999.)) then begin
        d2(k,i)=(d2(k,i-1)+d2(k,i+1))/2
        if(modvar(k,i)eq 1)then mod_count(k)=mod_count(k)+1
        modvar(k,i)=2
      endif

      if d2(k,i)eq 999. then begin
        x1=0.
        x2=0.
        y1=0.
        y2=0.
        flag1=0
        flag1b=0
        c=0
        while flag1 ne 1 do begin
          if (c gt search_size) then flag1=1
          if (i-c ge 0) then begin
            if d2(k,i-c) ne 999. then begin
              x1=d2(2,i-c)
	      y1=d2(k,i-c)
              flag1=1
	      flag1b=1
	    endif
          endif
          c=c+1
        endwhile
        flag2=0
        flag2b=0
        c=0
        while flag2 ne 1 do begin
          if (c gt search_size) then flag2=1
          if (i+c lt nlines-1) then begin
            if d2(k,i+c) ne 999. then begin
              x2=d2(2,i+c)
	      y2=d2(k,i+c)
              flag2=1
	      flag2b=1
	    endif
          endif
          c=c+1
        endwhile
	if flag1 eq 0 then begin
	  ;printf,6,'flag1 = 0'
	  print,'flag1 = 0'
	endif
	if flag2 eq 0 then begin
	  ;printf,6,'flag2 = 0'
	  print,'flag2 = 0'
	endif
	if ((flag1b ne 0 ) and (flag2b ne 0))then begin
          m=(y2-y1)/(x2-x1)
          b=y1-(m*x1)
          d2(k,i)=(m*d2(2,i))+b
          cc=cc+1
	  if(modvar(k,i)eq 1)then mod_count(k)=mod_count(k)+1
          modvar(k,i)=2
          ct=ct+1
        endif
    endif
  endfor
endif

print,'  ',varname,' ',(k-icol)+1,' :',' Number of interpolations : ',cc

endfor ; k

for k=icol,fcol do begin
  ;printf,6,'  Cumulative fraction of modifications : ',mod_count(k)/nlines,' ',varname
  print,'  Cumulative fraction of modifications : ',mod_count(k)/nlines,' ',varname
endfor

print,'End interpolation filter : ',varname
print,''

end







pro S_V_Filter,nlines,d2,icol,fcol,ndvs,boxsize,gradthresh,varname
; --------------------------------------------------------------------
; 'Spectral Variance Filter'
;
; 	idl sub-routine to reject data beyond some number of standard
; deviations within a given time search window (in hours)
;
; spectral because different window sizes are often employed for a given parameter
;
; Jason Box
; --------------------------------------------------------------------

;printf,6,'Begin S_V_Filter subroutine.'
print,'Begin S_V_Filter subroutine.'

nboxes=fix((nlines/boxsize))

;printf,6,'  N boxes :',nboxes
print,'  N boxes :',nboxes

for k=icol,fcol do begin

ct=0 ; count of values beyond threshold

for i=0,nlines-1-1-boxsize,boxsize do begin
  var=fltarr(boxsize)
; ---------------------- initialize moving smaller cell
  cc=0
  for j=0,boxsize-1 do begin
    if (d2(k,i+j) ne 999.) then begin
      var(cc)=d2(k,i+j)
      cc=cc+1
    endif
  endfor ; j

  std=0.
  m1=0.
  grad=0.

  std=stdev(var,m1)
  if cc gt 3 then begin
    for j=0,boxsize-1 do begin
      grad=0.
      if d2(k,i+j) ne 999. then grad=(abs(d2(k,i+j)-m1))
      if ((grad gt (ndvs*std)) and (grad gt gradthresh)) then begin
      ;  ;printf,6,d2(2,i+j),i,i+j,d2(k,i+j),m1,std
      ;  print,d2(2,i+j),i,i+j,d2(k,i+j),m1,std
        d2(k,i+j)=999.
        ct=ct+1
      endif
    endfor
  endif
endfor ; i

;printf,6,'  ',varname,' ',k-icol,' Number of inhomogenous values : ',ct
print,'  ',varname,' ',k-icol,' Number of inhomogenous values : ',ct


endfor ; k

;printf,6,'End S_V_Filter filter.'
;printf,6,''
print,'End S_V_Filter filter.'
print,''

end












;-------------- sub routine --------------  use last value when 999.
; note: used as a last filter for snow depth data with large flagged gaps.

pro last_val,nlines,d2,icol,fcol,varname,mod_count,modvar
; --------------------------------------------------------------------
; 	idl sub-routine to insert the last available good value in the
; absence of snow height data.  Assumption: no change in surface height
; works more realistically than a linear interpolation for snow height
; data.
; --------------------------------------------------------------------
;printf,6,'Begin last_fill subroutine.'
print,'Begin last_fill subroutine.'

search_size=10
cc=0
c=0

for k=icol,fcol do begin
  c=0
  for i=1,nlines-1 do if d2(k,i) ne 999. then c=c+1
  if c gt search_size then begin
    for i=1,nlines-1 do begin
      if ((d2(k,i) gt 990.) and (d2(k,i-1) ne 999.))then begin
        d2(k,i)=d2(k,i-1)
        if(modvar(k,i)ne 1)then mod_count(k)=mod_count(k)+1
        modvar(k,i)=2
        cc=cc+1
      endif
    endfor
  endif
endfor

print,'  Number of last_fill modifications : ',cc
;printf,6,'  Number of last_fill modifications : ',cc

for k=icol,fcol do begin
  ;printf,6,'  Cumulative fraction of modifications : ',mod_count(k)/nlines,' ',varname
  print,'  Cumulative fraction of modifications : ',mod_count(k)/nlines,' ',varname
endfor

;printf,6,'End last fill sub-routine.'
;printf,6,''
print,'End last fill sub-routine.'
print,''

end


;-------------- sub routine --------------  use last value when 999.
; note: used as a last filter for snow depth data with large flagged gaps.

pro first_val,nlines,d2,icol,fcol,varname,mod_count,modvar,year,yearx
; --------------------------------------------------------------------
; 	idl sub-routine to insert the last available good value in the
; absence of snow height data.  Assumption: no change in surface height
; works more realistically than a linear interpolation for snow height
; data.
; this one works in the opposite direction as last_val
; --------------------------------------------------------------------

if year eq yearx then begin

print,'Begin first_val subroutine.'

search_size=10
cc=0
c=0

for k=icol,fcol do begin
  c=0
  for i=nlines-2,0,-1 do if d2(k,i) ne 999. then c=c+1
  if c gt search_size then begin
    for i=nlines-2,0,-1 do begin
      if ((d2(k,i) gt 990.) and (d2(k,i+1) ne 999.))then begin
        d2(k,i)=d2(k,i+1)
        if(modvar(k,i)ne 1)then mod_count(k)=mod_count(k)+1
        modvar(k,i)=2
        cc=cc+1
      endif
    endfor
  endif
endfor

print,'  Number of last_fill modifications : ',cc

for k=icol,fcol do begin
  print,'  Cumulative fraction of modifications : ',mod_count(k)/nlines,' ',varname
endfor

print,'End first_val sub-routine.'
print,''

endif ; year eq yearx
end




pro snow_height_invert,nlines,d2,stnum,jx,nstations,icol,fcol
; --------------------------------------------------------------------
; 	idl sub-routine to invert decreasing ADG height, into
; positive accumulation
; --------------------------------------------------------------------
;printf,6,'Begin snow_height_invert'
print,'Begin snow_height_invert'

; ------------------------------------------------- get initial value

infile='/data2/aws/ancillary/aws_initial_snow_heights.dat'

;printf,6,'Reading : ',infile
;printf,6,''
print,'Reading : ',infile
print,''

openr,1,infile
iv=fltarr(3,nstations)
readf,1,iv
close,1

for k=icol,fcol do begin ; -----------------

  ;printf,6,'Column ',k+1
  print,'Column ',k+1

  ival=0.

  ival=iv(k-16,jx)

  ;printf,6,'Initial Snow Height Value',ival
  ;printf,6,''
  print,'Initial Snow Height Value',ival
  print,''

  for i=0,nlines-1 do if d2(k,i) ne 999.then d2(k,i)=(ival-d2(k,i))


endfor ; k ----------------------------------

;printf,6,'End Snow Height invert loop.'
;printf,6,''
print,'End Snow Height invert loop.'
print,''

end










pro grad_thresh,nlines,d,icol,fcol,thresh,mod_count,varname
;---------------------------------------------------------------------
;	idl procedure to apply gradient threshold to data in effort to
; remove outliers.  The user selects the threshold, thresh
;
; Jason Box
;---------------------------------------------------------------------

;printf,6,'Begin gradient threshold cleaning.'
print,'Begin gradient threshold cleaning.'

med=0.
badval=0
upflag=1
dnflag=1

for k=icol,fcol do begin

  cc=0
  for i=0,nlines-1-1 do begin
    if ((d(k,i+1) ne 999.) and (d(k,i) ne 999.))then begin
      grad=abs(d(k,i+1)-d(k,i))
      if grad gt thresh then begin
;     ;printf,6,i,k,grad,thresh,d(k,i+1),d(k,i)
;     print,i,k,grad,thresh,d(k,i+1),d(k,i)
        d(k,i+1)=999.
        cc=cc+1
        i=i+1
      endif
    endif
  endfor ; i

print,'  ',varname,' column ',k+1-icol,'  Number of data set to 999. : ',cc
;printf,6,'  ',varname,' column ',k+1-icol,'  Number of data set to 999. : ',cc

endfor ; k

;printf,6,'End gradient threshold cleaning.'
;printf,6,''
print,'End gradient threshold cleaning.'
print,''

end










pro Fill_Time_Gaps,nlines,ncols,d,d2
;---------------------------------------------------------------------
;	idl procedure to insert data into missing time slots, reads in
; array d and outputs array d2, also redefines nlines to reflect
; added lines.
;---------------------------------------------------------------------

;printf,6,'Begin time cleaning loop.'
print,'Begin time cleaning loop.'

dt=0.
dtx=0
; ----------------------------------- loop through dataset insert missing time
c=0


dt=0.
dtx=0
c=0

for i=0,nlines-1-1 do begin
  dt=d(2,i+1)-d(2,i)
  if dt gt 0.044 then begin
    dtx=fix((dt*24)+.1)
    ;printf,6,i,dt,(dt*24)+.1,dtx-1,d(2,i+1),d(2,i)
    print,i,dt,(dt*24)+.1,dtx-1,d(2,i+1),d(2,i)
    for j=1,dtx-1 do c=c+1
  endif
endfor

;printf,6,'  Number of missing hours : ',c
print,'  Number of missing hours : ',c

; ----------------------------------- loop through dataset insert missing time
;printf,6,'  Begin loop to clean time data.'
print,'  Begin loop to clean time data.'

d2=fltarr(ncols,nlines+c)
dt=fltarr(nlines)
ct=0

for i=0,nlines-1-1 do begin
  dt(i)=d(2,i+1)-d(2,i)
  for k=0,ncols-1 do d2(k,ct)=d(k,i)
; ---------------------------------- insert data if missing hours
    if dt(i) gt 0.044 then begin
      dtx=fix((dt(i)*24)+.1)
      for j=1,dtx-1 do begin
        for k=3,ncols-1 do d2(k,ct+1)=999.
	d2(0,ct+1)=d(0,i)
	d2(1,ct+1)=d(1,i)
        d2(2,ct+1)=(d(2,i)+((j)*0.0416666667))
        ct=ct+1
      endfor
    endif

  ct=ct+1

endfor

for k=0,ncols-1 do d2(k,ct)=d(k,nlines-1)

nlines=nlines+c

;printf,6,'New number of lines (including missing data) : ',nlines
;printf,6,''
print,'New number of lines (including missing data) : ',nlines
print,''

;printf,6,'End time cleaning loop.'
;printf,6,''
print,'End time cleaning loop.'
print,''

end














pro clean_stat,d,nlines,ncols,stnum,jx,path,mod_count,yr
;---------------------------------------------------------------------
;	idl procedure to output statistics of the amount of modified
; and missing data output from this qc program
;---------------------------------------------------------------------
varnam=strarr(ncols)
openr,1,'/data2/aws/ancillary/varnames_abreviated.dat'
readf,1,varnam
close,1

;printf,6,'Begin calculating cleaning statistics.'
print,'Begin calculating cleaning statistics.'

openw,2,path+stnum(jx)+'_'+yr+'.st2'
;--------------------- data limits filter set invalid to 999.
c=fltarr(ncols)

for i=0,nlines-2 do begin
  for k=0,ncols-1 do begin
    if d(k,i) eq 999. then c(k)=c(k)+1
  endfor ; k
endfor ; i

;printf,6,'Begin writting cleaning statistics to ',path+stnum(jx)+'stat2.dat'
print,'Begin writting cleaning statistics to ',path+stnum(jx)+'stat2.dat'

  for k=0,ncols-1 do begin
    printf,2,'AWS',stnum(jx),varnam(k),(c(k)/(nlines-2))*100,'% missing data out of',fix(nlines),$
    	  'lines,modified count',fix(mod_count(k)),(mod_count(k)/(nlines-1))*100,'% modified data',$
	      format='(a3,1x,a2,1x,a3,1x,f8.4,1x,a21,1x,i6,1x,a21,1x,i6,1x,f8.4,1x,a16)'
  endfor ; k
  close,2 ; statfile

;printf,6,'End cleaning statistics.'
;printf,6,''
print,'End cleaning statistics.'
print,''

end

















pro clean_frozen,nlines,d2,icol,fcol,frozenthresh,modvar
;---------------------------------------------------------------------
;	idl procedure to throw out data that are frozen for 4 hours
; with no change above a threshold.
;---------------------------------------------------------------------
boxsize=4
temp=fltarr(boxsize)
tex=0.

for k=icol,fcol do begin
  c=0.
  for i=0,nlines-1-boxsize,boxsize do begin
    for j=0,boxsize-1 do temp(j)=d2(k,i+j)
    tex=(temp(0)+temp(1)+temp(2)+temp(3))/4.
    if ((abs(d2(k,i) - tex) lt frozenthresh) and(tex ne 999.) and (d2(k,i) ne 999.))then begin
      for j=0,boxsize-1 do d2(k,i+j)=999.
      c=c+4.
      modvar(k,i)=3
    endif
  endfor
  print,''
  print,'  The number of frozen values set to 999. : ',c
endfor

print,''
print,'End clean frozen.'

end














pro aws_plot,d2,layot,nlines,cs,lim,jx,final_plot_prompt,misc,colo,bg
;---------------------------------------------------------------------
;	idl procedure to plot output data from this qc program
;---------------------------------------------------------------------


!p.multi=0.
; ------------------------------------------------------- Albedo
print,'Plot Albedo'


plot,d2(34,*),$
  /xstyle,/ystyle,$
  yrange=[0.0,1.1],$
  line=0,$
  charsize=cs,$
  ytitle='dimensionless',$
  xtitle='hour',$
  title='Albedo',$
  psym=4,$
  symsize=0.4,$
  max_value=990.,$
  color=colo,background=bg

; -----------------------------------------------------
if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

!p.multi=[0,1,2,0,0]

if layot ne 'l' then window,0,xsize=700,ysize=500

; ------------------------------------------------------- Incomming sw
print,'Plot sw Radiation'
plot,d2(3,*),$
  /xstyle,/ystyle,$
  ;yrange=[-1,1200],$
  line=0,$
  charsize=cs,$
  ytitle='W m!E-2!N',$
  xtitle='hour',$
  title='Solar Radiation',$
  color=colo,background=bg,$
	max_value=990

; ------------------------------------------------------- Reflected sw

plot,d2(4,*),$
  /xstyle,/ystyle,$
  ;yrange=[-1,1200],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='W m!E-2!N',$
  title='Solar Radiation',$
  color=colo,background=bg,$
	max_value=990

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s
; ------------------------------------------------------- Net Radiation
print,'Plot Net Radiation'
if layot ne 'l' then window,0,xsize=700,ysize=500
!p.multi=0

plot,d2(5,*),$
  /xstyle,/ystyle,$
  yrange=[-500,500],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='W m!E-2!N',$
  title='Net Radiation',$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s
; ------------------------------------------------------- pressure
print,'Plot pressure'
if layot ne 'l' then window,0,xsize=700,ysize=500
plot,d2(16,*),$
  /xstyle,/ystyle,$
  ;yrange=[lim(1,jx),lim(2,jx)],$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[mb]',$
  title='Barometric pressure',$
	max_value=1200,$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

; ------------------------------------------------------- TC Air 1
print,'Plot Type - E Air temperature'
if layot ne 'l' then window,0,xsize=700,ysize=500
!p.multi=[0,2,2,0,0]

plot,d2(6,*),$
  /xstyle,/ystyle,$
  yrange=[-70,5],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[C]',$
  title='temperature, TC Air 1',$
  color=colo,background=bg

oplot,[1995,2000],[0,0],line=2


; ------------------------------------------------------- TC Air 2
plot,d2(7,*),$
  /xstyle,/ystyle,$
  yrange=[-70,5],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[C]',$
  title='temperature, TC Air 2',$
  color=colo,background=bg

oplot,[1995,2000],[0,0],line=2

; ------------------------------------------------------- T CS500 1
print,'Plot CS-500 temperature'
plot,d2(8,*),$
  /xstyle,/ystyle,$
  yrange=[-70,5],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[C]',$
  title='temperature, CS500 1',$
  color=colo,background=bg

oplot,[1995,2000],[0,0],line=2

; ------------------------------------------------------- T CS500 2

plot,d2(9,*),$
  /xstyle,/ystyle,$
  yrange=[-70,5],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[C]',$
  title='temperature, CS500 2',$
  color=colo,background=bg

oplot,[1995,2000],[0,0],line=2

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

;------------------------------------------------------- RH 1
print,'Plot Relative humidity'
if layot ne 'l' then window,0,xsize=700,ysize=500

plot,d2(10,*),$
  /xstyle,/ystyle,$
  yrange=[20,110],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[%]',$
  title='humidity 1',$
  color=colo,background=bg

oplot,[1995,2000],[100,100],line=2

; ------------------------------------------------------- RH 2

plot,d2(11,*),$
  /xstyle,/ystyle,$
  yrange=[20,110],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[%]',$
  title='humidity 2',$
  color=colo,background=bg

oplot,[1995,2000],[100,100],line=2

;------------------------------------------------------- RH 1
;print,'Plot Specific humidity'
;if layot ne 'l' then window,0,xsize=700,ysize=500

;plot,d2(10,*),$
;  /xstyle,/ystyle,$
;  yrange=[-1,12],$
;  line=0,$
;  charsize=cs,$
;  xtitle='hour',$
;  ytitle='[g kg!e-1!n]',$
;  title='humidity 1',$
;  color=colo,background=bg

;oplot,[1995,2000],[100,100],line=2

; ------------------------------------------------------- RH 2

;plot,d2(11,*),$
;  /xstyle,/ystyle,$
;  yrange=[-1,12],$
;  line=0,$
;  charsize=cs,$
;  xtitle='hour',$
;  ytitle='[g kg!e-1!n]',$
;  title='humidity 2',$
;  color=colo,background=bg

;oplot,[1995,2000],[100,100],line=2

; ------------------------------------------------------- Wind Speed 1
print,'Plot Wind Speed'

plot,d2(12,*),$
  /xstyle,/ystyle,$
  yrange=[-5,30],$
  charsize=cs,$
  ytitle='[m s!E-1!N]',$
  xtitle='hour',$
  title='Wind Speed 1',$
  color=colo,background=bg

; ------------------------------------------------------- Wind Speed 2

plot,d2(13,*),$
  /xstyle,/ystyle,$
  yrange=[-5,30],$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[m s!E-1!N]',$
  title='Wind Speed 2',$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

; ------------------------------------------------------- Synthetic 2 m Wind Speed
!p.multi=[0,1,2,0,0]
print,'Plot Synthetic Wind Speed'

plot,d2(30,*),$
  /xstyle,/ystyle,$
  yrange=[-5,50],$
  charsize=cs,$
  ytitle='[m s!E-1!N]',$
  xtitle='hour',$
  title='2 m Wind Speed',$
  color=colo,background=bg

; ------------------------------------------------------- Synthetic 10 m Wind Speed

plot,d2(31,*),$
  /xstyle,/ystyle,$
  yrange=[-5,50],$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[m s!E-1!N]',$
  title='10 m Wind Speed',$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

; ------------------------------------------------------- Instrument Heights
print,'Plot Profile Instrument Heights'
!p.multi=[0,1,2,0,0]

plot,d2(32,*),$
  /xstyle,/ystyle,$
  ;yrange=[-1,5],$
  charsize=cs,$
  ytitle='[m]',$
  xtitle='hour',$
  title='Instrument 1 Heights',$
	max_value=990,$
  color=colo,background=bg

plot,d2(33,*),$
  /xstyle,/ystyle,$
  ;yrange=[-1,11],$
  charsize=cs,$
  ytitle='[m]',$
  xtitle='hour',$
  title='Instrument 2 Heights',$
	max_value=990,$
  color=colo,background=bg


if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

;------------------------------------------------------- Wind Direction 1
print,'Plot Wind Direction'
if layot ne 'l' then window,0,xsize=700,ysize=500
!p.multi=[0,1,2,0,0]

plot,d2(14,*),$
  /xstyle,/ystyle,$
  yrange=[0,360],$
  charsize=cs,$
  ytitle='[degrees]',$
  xtitle='hour',$
  title='Wind Direction 1',$
  max_value=360,$
  psym=3,$
  color=colo,background=bg

; ------------------------------------------------------- Wind Direction 2

plot,d2(15,*),$
  /xstyle,/ystyle,$
  yrange=[0,380],$
  charsize=cs,$
  ytitle='[degrees]',$
  xtitle='hour',$
  title='Wind Direction 2',$
  max_value=360,$
  psym=3,$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s
; ------------------------------------------------------- Snow Height 1
print,'Plot Snow Height'

if layot ne 'l' then window,0,xsize=700,ysize=500

plot,d2(17,*),$
  /xstyle,/ystyle,$
;  yrange=[lim(3,jx),lim(4,jx)],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[m]',$
  title='Snow Surface Height 1',$
  max_value=990.,$
  color=colo,background=bg

oplot,[-2000,200000],[0,0],line=1

; ------------------------------------------------------- Snow Height 2


plot,d2(18,*),$
  /xstyle,/ystyle,$
;  yrange=[lim(3,jx),lim(4,jx)],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[m]',$
  title='Snow Surface Height 2',$
  max_value=990.,$
  color=colo,background=bg

oplot,[-2000,200000],[0,0],line=1

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s
; ------------------------------------------------------- Snow temperature
print,'Plot Snow temperature'
if layot ne 'l' then window,0,xsize=y00,ysize=500
!p.multi=0
cols=[255,235,225,205,180,160,120,100,80,60]

plot,d2(28,*),$
  /xstyle,/ystyle,$
  yrange=[-55,10],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[C]',$
  title='Snow temperature Profile',$
  color=colo,background=bg

oplot,[-2000,200000],[0,0],line=1

for j=0,8 do begin
  oplot,d2(19+j,*),color=cols(j)
endfor

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

; ------------------------------------------------------- Battery
print,'Plot Battery'
if layot ne 'l' then window,0,xsize=700,ysize=500
!p.multi=0

plot,d2(29,*),$
  /xstyle,/ystyle,$
  yrange=[9,16],$
  line=0,$
  charsize=cs,$
  xtitle='hour',$
  ytitle='[VDC]',$
  title='Battery',$
  color=colo,background=bg

if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s


; ------------------------------------------------------- SZA
;print,'Plot zenith angle'
;if layot ne 'l' then window,0,xsize=700,ysize=500
;!p.multi=0

;plot,misc(9,*),$
;  /xstyle,/ystyle,$
;  line=0,$
;  charsize=cs,$
;  xtitle='hour',$
;  ytitle='degrees',$
;  title='Solar Zenith Angle',$
;	max_value=990.

;oplot,[0,nlines],[90,90],thick=3

;if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s


; ------------------------------------------------------- resid noise 1 and 2
;print,'Plot residual snow heihgt noise'
;if layot ne 'l' then window,0,xsize=700,ysize=500
;!p.multi=[0,1,2,0,1]

;for k=0,1 do begin
;plot,misc(7+k,*)-d2(17+k,*),$
;  /xstyle,/ystyle,$
  ;yrange=[0,20],$
;  line=0,$
;  charsize=cs,$
;  xtitle='hour',$
;  ytitle='m',$
;  title='Residual Snow Height noise',$
;	max_value=1,$
;	min_value=-1
;endfor

;if ((layot eq 'x' ) and (final_plot_prompt eq 'y'))then read,s

if((layot eq 'p') or (layot eq 'P') or (layot eq 'l')) then device,/close

end












pro write_out,nlines,path,outputfile,d2,length,jx,nstations,modvar,m,stnum,yr,tt,zz
;---------------------------------------------------------------------
;	idl procedure to write out data from this qc program
;---------------------------------------------------------------------
;printf,6,'Begin writting output files : ',path+outputfile
print,'Begin writting output files : '
print,'  '+path+outputfile
print,'  '+path+stnum(jx)+'_'+yr+'m.dat'
print,'  '+path+stnum(jx)+'_'+yr+'q.dat'

  openw,1,path+outputfile
  openw,2,path+stnum(jx)+'_'+yr+'m.dat'
  openw,3,path+stnum(jx)+'_'+yr+'q.dat'
  ;openw,4,path+stnum(jx)+'_'+yr+'_snow_T_fixed_z.dat'

  for i=0,nlines-1 do begin

mv=double(0)
mv=   (modvar(10,i)*10000000)
mv=mv+(modvar(9,i)*1000000)
mv=mv+(modvar(8,i)*100000)
mv=mv+(modvar(7,i)*10000)
mv=mv+(modvar(6,i)*1000)
mv=mv+(modvar(5,i)*100)
mv=mv+(modvar(4,i)*10)
mv=mv+modvar(3,i)
mv1=mv

mv=double(0)
mv=   (modvar(18,i)*10000000)
mv=mv+(modvar(17,i)*1000000)
mv=mv+(modvar(16,i)*100000)
mv=mv+(modvar(15,i)*10000)
mv=mv+(modvar(14,i)*1000)
mv=mv+(modvar(13,i)*100)
mv=mv+(modvar(12,i)*10)
mv=mv+modvar(11,i)
mv2=mv
mv=double(0)
mv=   (modvar(26,i)*10000000)
mv=mv+(modvar(25,i)*1000000)
mv=mv+(modvar(24,i)*100000)
mv=mv+(modvar(23,i)*10000)
mv=mv+(modvar(22,i)*1000)
mv=mv+(modvar(21,i)*100)
mv=mv+(modvar(20,i)*10)
mv=mv+modvar(19,i)
mv3=mv
mv=double(0)

mv=mv+(modvar(29,i)*100)
mv=mv+(modvar(28,i)*10)
mv=mv+modvar(27,i)
mv4=mv

printf,1,fix(d2(0,i)),fix(d2(1,i)),d2(2,i),d2(3,i),d2(4,i),d2(5,i),d2(6,i),d2(7,i),d2(8,i),d2(9,i),$
	d2(10,i),d2(11,i),d2(12,i),d2(13,i),d2(14,i),d2(15,i),d2(16,i),d2(17,i),d2(18,i),d2(19,i),$
	d2(20,i),d2(21,i),d2(22,i),d2(23,i),d2(24,i),d2(25,i),d2(26,i),d2(27,i),d2(28,i),d2(29,i),$
	d2(30,i),d2(31,i),d2(32,i),d2(33,i),d2(34,i),d2(35,i),mv1,mv2,mv3,mv4,$
	format='(i2,1x,i4,1x,f8.4,1x,2(f7.2,1x),1x,9f7.2,2f6.1,f7.1,2f9.4,10f7.2,f7.2,1x,2(f6.2,1x),3(f9.3,1x),f6.2,1x,3(i8,1x),i3)'


printf,2,fix(d2(0,i)),fix(d2(1,i)),d2(2,i),m(0,i),m(1,i),m(2,i),m(3,i),m(4,i),$
	m(5,i),m(6,i),m(7,i),m(8,i),m(9,i),m(10,i),m(11,i),$
	format='(i2,1x,i4,1x,f8.4,1x,12f8.3)'

printf,3,fix(d2(0,i)),fix(d2(1,i)),d2(2,i),modvar(3,i),modvar(4,i),modvar(5,i),modvar(6,i),modvar(7,i),$
	modvar(8,i),modvar(9,i),modvar(10,i),modvar(11,i),modvar(12,i),modvar(13,i),modvar(14,i),modvar(15,i),$
	modvar(16,i),modvar(17,i),modvar(18,i),modvar(19,i),modvar(20,i),modvar(21,i),modvar(22,i),$
	modvar(23,i),modvar(24,i),modvar(25,i),modvar(26,i),modvar(27,i),modvar(28,i),$
	format='(i2,1x,i4,1x,f8.4,26(1x,i1))'

;printf,4,fix(d2(0,i)),fix(d2(1,i)),d2(2,i),$
;	tt(*,i),$
	;format='(i2,1x,i4,1x,f8.4,14f7.2)'

  endfor ; i
  close,1,2,3,4

;printf,6,'Converting to universal format.'
print,'Converting to universal format.'

  spawn,'unix2dos '+path+outputfile+' '+path+outputfile

;printf,6,'Done converting.'
;printf,6,''
print,'Done converting.'
print,'

end







pro read_input,jx,nstations,nlines,lat,lon,length,outputfile,stnum,path,ncols,e,d,yr,stnames,mod_count
;---------------------------------------------------------------------
;	idl procedure to read input data for qc program
;---------------------------------------------------------------------


;printf,6,'Begin reading input.'
print,'Begin reading input.'
path2='/data2/aws/ancillary/'

  inputfile=stnum(jx)+'_'+yr+'a.dat'
  outputfile=stnum(jx)+'_'+yr+'c.dat'

  pos=fltarr(3,nstations)
  openr,1,path2+'aws_positions.dat'
  readf,1,pos
  close,1
  ;printf,6,'  Done reading AWS position file.'
  ;printf,6,''
  print,'  Done reading AWS position file.'
  print,''

  lat=pos(1,jx)
  lon=pos(2,jx)

  Print,'  AWS Latitude : ',lat
  Print,'  AWS Longitude : ',lon
  print,''

  ;length=intarr(2,nstations)
  ;openr,1,path2+'n'+yr+'.dat'
  ;readf,1,length
  ;close,1
  c=0
  garb=''
  openr,1,path+inputfile
  while not eof(1) do begin
    readf,1,garb
    c=c+1
  endwhile
  close,1

  nlines=c

  print,'  Done reading data size file.'
  print,''
  ;nlines=length(1,jx)

  stnames=strarr(nstations)
  openr,1,path2+'aws_names.dat'
  readf,1,stnames
  close,1

  print,'  Done reading aws names file.'
  print,''


  print,'  Array to read is ',ncols,' by ',nlines,' elements.'
  print,'  Begin reading : ',inputfile

  e=fltarr(ncols,nlines)
  openr,1,path+inputfile
  readf,1,e
  close,1

; ------------------  create e array for camparison with modified data
  d=e

  mod_count=fltarr(ncols)

  print,'Done reading input.'
  print,''
end











pro plotpair,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr
; --------------------------------------------------------------------
; 	idl sub-routine to plot 2 parameters with 2 plots on 1 window
; --------------------------------------------------------------------
  if ppp eq 'y' then begin
  device,true=1,decomposed=0,retain=2
  !p.multi=[0,1,2,0,0]
  ;window,0,xsize=600,ysize=500


;  psname='/data2/aws/temp/rh_uncor.ps'

;  if (layot eq 'p') then begin
;   set_plot,'ps'
;   device,/portrait,file=psname,xsize=20,ysize=25, $
;   xoffset=1,yoffset=1
;  endif

;  if (layot eq 'x') then set_plot,'x'

set_plot,'x'
device, true=1

  loadct,0

  plot,d2(icol,*),max_value=990,$
	title=stnames(jx)+' '+varname+' 1 '+yr,/xstyle,xrange=[-20,nlines],$
	xtitle='data coordinate',/ystyle;color=100,background=60

  oplot,d2(icol,*),psym=3;,color=180

  plot,d2(fcol,*),max_value=990,$
	title=stnames(jx)+' '+varname+' 2 '+yr,/xstyle,xrange=[-20,nlines],$
	xtitle='Data Coordinate',/ystyle;color=100,background=60

  oplot,d2(fcol,*),psym=3;,color=180

  print,'enter a number to continue, or enter a character to break.'
  if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s

  if((layot eq 'p') or (layot eq 'P') or (layot eq 'l')) then device,/close
  endif ; ppp
end


pro plotsingle,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,jx,yr,mv
; --------------------------------------------------------------------
; 	idl sub-routine to plot a single parameter
; --------------------------------------------------------------------
  if ppp eq 'y' then begin
  !p.multi=0
  loadct,0
  plot,d2(icol,*),$
	max_value=mv,/xstyle,$
	title=stnames(jx)+' '+varname+' '+yr,$
	xrange=[-10,nlines],$
	xtitle='Data Coordinate',$
	/ystyle;,color=140,background=60

  if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s
  endif ; ppp
end



pro plotsnowtemps,ppp,nlines,varname,stnames,layot,plot_prompt,d2,icol,fcol,jx,yr,bg
; --------------------------------------------------------------------
; 	idl sub-routine to plot the GC-Net 10 instrument snow temperature
; profile
; --------------------------------------------------------------------
cols=[255,215,185,165,140,120,100,80,70,60]
device, DECOMPOSED=0

  if ppp eq 'y' then begin
  !p.multi=0
  plot,d2(fcol,*),max_value=990,$
	/ystyle,yrange=[-45,5],$
	/xstyle,xrange=[0,nlines],$
	title=stnames(jx)+' '+varname+' '+yr,$
	xtitle='Data Coordinate',$
	/nodata,background=bg

  oplot,d2(fcol,*),psym=3,color=cols(9)

  for h=icol,fcol-1 do begin
    oplot,d2(h,*),max_value=990,color=cols(h-icol)
    oplot,d2(h,*),psym=3,color=cols(h-icol)
  endfor

  if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s
  endif ; ppp
end















pro init_instr_z,stnum,nlines,d,jx,stnams,nstations,yr,ly,path2
;---------------------------------------------------------------------
; 	IDL Code to calculate wind speed at a fixed heights of 2 and 10 m
;	time of instrument change must be given exactly as in *a.dat, i.e. in
;	/data2/aws/ancillary/*_instr_z.dat
;
;					Jason Box.
;					Oct, 1997
;					revised Aug 1998
;					revised Sept 1999
;---------------------------------------------------------------------
print,''
print,'Begin calculating instrument heights.'

; ------------------------------------------- read input
inputfile='/data2/aws/gdf/'+stnum(jx)+'_'+ly+'c.dat'
  c=0
  garb=''
  
  valid=0
  ON_IOERROR, no_file
  openr,1,inputfile
  valid=1
  while not eof(1) do begin
    readf,1,garb
    c=c+1
  endwhile
  close,1

  no_file: IF NOT valid THEN c=0
  message_x=1
  if c eq 0 then message_x=0
  i_zz=fltarr(2)

if c gt 0 then begin
  print,'initialize from end of year heights'
  openr,1,inputfile
  xs=fltarr(40,c)
  readf,1,xs
  close,1

  i_zz(0)=xs(32,c-1)
  i_zz(1)=xs(33,c-1)

endif

  inputfile='/data2/aws/ancillary/'+stnum(jx)+'_instr_z.dat'
  c=0
  garb=''
  openr,1,inputfile
  while not eof(1) do begin
    readf,1,garb
    c=c+1
  endwhile
  close,1
  nchanges=c

  print,'Number of instrument profile height changes : ',nchanges
  print,''

levels=fltarr(4,nchanges)
openr,1,inputfile
readf,1,levels
close,1
print,levels
print,'Done reading /data2/aws/ancillary/'+stnum(jx)+'_instr_z.dat'




print,''
print,'Done reading input.'

; ------------------------------------ initialize computational variables
print,''
print,'  Begin processing.'

zu1=0.
zu2=0.
h=0.
dz=0.
cx=0.

; ---------------------------------------------------------------

dzx=fltarr(nlines)
hx=fltarr(nlines)

for i=0,nlines-1 do begin
  if d(17,i) ne 999. then hx(i)=d(17,i)
  if ((d(17,i) ne 999.) and (d(18,i) ne 999.))then hx(i)=(d(17,i)+d(18,i))/2.
endfor


for i=0,nlines-2 do begin
  if ((hx(i) ne 999.) and (hx(i+1) ne 999.))then dzx(i)=hx(i+1)-hx(i)
endfor

flagg=0

cum=0.

for i=0,nlines-1 do begin

  u2m=999.
  U10m=999.
  h=0.
  h2=0.
    if i eq 0 then begin
	zu1=i_zz(0)
	zu2=i_zz(1)
      cum=0.
	print,'Instrument height initialized for beginning of year ',zu1,zu2
        flagg=1
    endif

  for j=0,nchanges-1 do begin


    if ((d(1,i) eq levels(0,j)) and (d(2,i) eq levels(1,j))) then begin
      zu1=levels(2,j)
      zu2=levels(3,j)
      cum=0.
      flagg=1
      print,'Value identified',d(1,i),d(2,i)
      print,'Instrument level 1 ',zu1
      print,'Instrument level 2 ',zu2
    endif
  endfor



if i ne nlines-1 then begin

  fag1=0

  if ((d(17,i) ne 999.) and (d(18,i) ne 999.)) then begin
    h=(d(17,i)+d(18,i))/2.
    fag1=1
  endif
  if d(17,i) ne 999. and fag1 eq 0 then begin
    h=d(17,i)
    fag1=1
  endif
  if d(18,i) ne 999. and fag1 eq 0 then begin
    h=d(18,i)
    fag1=1
  endif


  fag2=0

  if ((d(17,i+1) ne 999.)and (d(18,i+1) ne 999.)) then begin
    h2=(d(17,i+1)+d(18,i+1))/2.
    fag2=1
  endif

  if d(17,i+1) ne 999. and fag2 eq 0 then begin
    h2=d(17,i+1)
    fag2=1
  endif

  if d(18,i+1) ne 999. and fag2 eq 0 then begin
    h2=d(18,i+1)
    fag2=1
  endif
  ;print,h,h2,d(17,i),d(17,i+1),d(18,i),d(18,i+1)
endif

  if ((fag1 eq 1) and (fag2 eq 1)) then begin
    cum=h2-h
    if abs(cum) ge 2. then begin
      print,d(2,i),cum,zu1,zu2,cum,d(17,i+1),d(18,i+1),d(17,i),d(18,i)
      cum=0.
      print,'Sorry, cumulative change is too large!'
      read,s
    endif
  endif

  if flagg eq 0 then begin
    print, 'No instrument heights available!'
   ; read,s
  endif

  dz=zu2-zu1

  zu1=zu1-cum
  zu2=zu2-cum
  d(32,i)=zu1
  d(33,i)=zu2
endfor ; i

if flagg eq 0 then begin
  print,'Instrument Height value not set. Time value must be discrete, e.g. 134.6250.'
  print,'Match date exactly between *instr_z.dat with *a.dat.'
  print,'input a number to proceed, but beware, if you made an extension, make sure you edit *_instr_z.dat. As of now, the POTENTIAL problem is not fixed!'
  read,s
  print,'Are you sure you want to continue? .... alright, fine.'
  read,s
endif

if message_x eq 0 then begin
  print,'Previous year information missing.'
  ;read,s
endif

end









pro wind_constant_z,stnum,nlines,d,jx,stnams,nstations,modvar,rsq_thresh,ppp
;---------------------------------------------------------------------
; 	IDL Code to calculate wind speed at a fixed heights of 2 and 10 m
; thresh slopex oset
;					Jason Box.
;					Oct, 1997
;					revised Aug 1998
;					revised Sept 1999
;---------------------------------------------------------------------
print,''
print,'Begin solving for wind speed at constant heights of 2 and 10 m.'


;-------------------------------------------------------- User Choices
plt='n'
pr='n'

; ------------------------------------ initialize computational variables
print,''
print,'  Begin processing.'

flag=fltarr(nlines)
flag(*)=1
zu1=0.
zu2=0.
h=0.
dz=0.
cx=0.
du=0.
m=0.
b=0.
u10m=0.
u2m=0.
fflag=0
c=fltarr(8)
oset=0.4
slopex=0.12
; --------------------------------------------- redifeined arrays
u1=d(12,*)
u2=d(13,*)
z0_constant=0.0005

; --------------------------------- CASE: wind 1 bad wind 2 and heights good

for i=0,nlines-1 do begin

  zu1=d(32,i)
  zu2=d(33,i)

; --------------------------------------- filter for usable wind speeds
  if u1(i) eq u2(i) then flag(i)=0
  if ((u1(i) eq 0.) and (u2(i) eq 0.))then flag(i)=0

; ----------------------------------------- Filter by wind sensor heights
  if ((zu1 lt 0) or (zu1 eq 999.)) then begin
    print,'Invalid wind sensor 2 height ',zu2
    flag(i)=0
  endif

  if ((zu2 lt 0) or (zu2 eq 999.)) then begin
    print,'Invalid wind sensor 1 height ',zu1
    flag(i)=0
  endif

endfor ; i

du='y'

if du eq 'y' then begin
for i=0,nlines-1 do begin

  zu1=d(32,i)
  zu2=d(33,i)

  if flag(i) eq 1 then begin


; ---- synthesize wind 1 if wind 1 = 0 and wind 2 gt thresh

    if ((u1(i) eq 0.) or (u1(i) eq 999.))then begin
      if ((u2(i) ne 0.) and (u2(i) ne 999.))then begin
        y=fltarr(2)
        y(0)=alog(z0_constant)
        y(1)=alog(zu2)
        x=fltarr(2)
        x(0)=0
        x(1)=u2(i)
        m=(y(1)-y(0))/(x(1)-x(0))
        b=y(0)-(m*x(0))
        u1(i)=(alog(zu1)-b)/m
        if ((u1(i) ge 0.)and(u1(i) lt 35.)) then begin
          d(12,i)=u1(i)
          modvar(12,i)=6
          flag(i)=1
        endif
        c(3)=c(3)+1
      endif
    endif
  endif ; flag eq 1
endfor ; i

print,'Wind 1 synthetic ',c(3)
;read,s



; --------------------------------------------- CASE: wind 2 bad wind 1 and heights good

for i=0,nlines-1 do begin

  if flag(i) eq 1 then begin
; --------------------------------- synthesize wind 2 if wind 1 and height 1 are good
    if ((u2(i) eq 0.) or (u2(i) eq 999.))then begin
      if ((u1(i) ne 0.) and (u1(i) ne 999.))then begin
        y=fltarr(2)
        y(0)=alog(z0_constant)
        y(1)=alog(zu1)
        x=fltarr(2)
        x(0)=0
        x(1)=u1(i)
        m=(y(1)-y(0))/(x(1)-x(0))
        b=y(0)-(m*x(0))
        u2(i)=(alog(zu2)-b)/m
        if ((u2(i) ge 0.)and(u2(i) lt 35.)) then begin
          d(13,i)=u2(i)
          modvar(13,i)=6
          flag(i)=1
        endif
        c(2)=c(2)+1
      endif
    endif
  endif ; flag eq 1
endfor ; i

print,'Wind 2 synthetic ',c(2)




; --------------------------------------------- CASE: wind 2 bad wind 1 and heightsx good

print,'Wind reversals ',c(0)








; --------------------------------------------- CASE: wind 2 bad wind 1 and heights good

for i=0,nlines-1 do begin

  if flag(i) eq 1 then begin
; ------------------------------------- reverse negative momentum gradient wind speeds?
    if ((u1(i) eq 999.) and (u2(i) eq 0.)) then begin
      u1(i)=999.
      flag(i)=0
      c(7)=c(7)+1
    endif
    if ((u2(i) eq 999.) and (u1(i) eq 0.)) then begin
      u2(i)=999.
      flag(i)=0
      c(7)=c(7)+1
    endif
  endif ; flag eq 1
endfor ; i

print,'Set wind 1 and 2 to 999 when only 1 is 0 ',c(7)











; ------------------------------------ derive logarithmic 2m and 10m wind speeds
u10mx=0.
u2mx=0.

for i=0,nlines-1 do begin

  if flag(i) eq 1 then begin

y=fltarr(2)
y(0)=alog(zu1)
y(1)=alog(zu2)
x=fltarr(2)
x(0)=u1(i)
x(1)=u2(i)
m=(y(1)-y(0))/(x(1)-x(0))

U10m=999.
U2m=999.

  b=y(1)-(m*x(1))
  U10m=(alog(10.)-b)/m
  U2m=(alog(2.)-b)/m

  u10mx=u2(i)/((zu2/10.)^(1./7.))
  u2mx=u2(i)/((zu2/2.)^(1./7.))



if b gt 0. then begin
  print,'negative slope intercept for wind speed!'
  U10m=999.
  U2m=999.
endif

  if U2m lt 0 then print,'Negative wind speeds ',d(2,i)
  if U10m lt 0 then print,'Negative wind speeds ',d(2,i)

  d(30,i)=U2m
  d(31,i)=U10m
;  print,'log fit ',d(2,i),u2m,U10m
;  print,'pwr law ',d(2,i),u2mx,U10mx
;  print,d(2,i),b,m,y(0),y(1),x(0),x(1),flag(i)
;read,s
  ;if abs(u10m-u10mx) gt 1 then read,s


  c(5)=c(5)+1

  endif ; flag eq 1
endfor ; i

if plt eq 'y' then begin

window,1,xsize=500,ysize=700

!p.multi=[0,1,2,0,1]


plot,d(30,*),$
	max_value=990.,$
	title='2 m Wind',$
	/xstyle

plot,d(31,*),$
	max_value=990.,$
	title='10 m Wind',$
	/xstyle

window,2,xsize=500,ysize=700

!p.multi=[0,1,2,0,1]


plot,u1,$
	max_value=990.,$
	title='u1',$
	/xstyle

plot,u2,$
	max_value=990.,$
	title='u2',$
	/xstyle

window,0,xsize=700,ysize=500
read,s
endif ; plt

print,'Fraction of available synthetic wind speed ',c(5)/nlines
print,'Fraction when wind 1 > wind 2 ',cx/nlines
print,'Fraction of reversed winds ',c(0)/nlines
print,'Fraction of synth U1 when U1 = 0. abd U2 > 0.1 ',c(1)/nlines
temp=c(4)/nlines
c(4)=0.

;read,s





endif ; du
end



















pro t_cor_w_rh,nlines,d,modvar,jx,stnum,path3,yr,nstations,ppp
; ---------------------------------------------------------------------------
; IDL sub-routine to reconstruct temperature data based on the correlation of
;  RH and TC AIR
;
; Jason Box, Sept 21, 1999
; ---------------------------------------------------------------------------


; initialize some variables
rh_col=[10,11]
t_col=[8,9]
nam=['1','2']

;------------------------------------------------------------ Input file
openr,22,path3+stnum(jx)+'_t_using_rh_coef.dat'
coefs=fltarr(6,2)
readf,22,coefs
close,22

;------------------------------------------------------------ Plot Settings
plt1=ppp
plt2=ppp

path='/data2/aws/temp/'

openr,14,path3+yr+'_n_hum_instr_changes.dat'
nchgs=fltarr(2,nstations)
readf,14,nchgs
close,14
print,'  Done reading number of hum instrument changes.'

timeframes=fltarr(2,nchgs(1,jx))
openr,14,path3+stnum(jx)+'_'+yr+'_hum_timeframes.dat'
readf,14,timeframes
close,14
print,'  Done reading instrument timeframes.'

print,'  Number of humidity instrument changes = ',nchgs(1,jx)
num=['0','1','2','3','4']
step=1.


for kk=0,1 do begin

for kkk=0,nchgs(1,jx)-1 do begin

  print,'  Instrument timeframe ',kkk+1,timeframes(0,kkk),timeframes(1,kkk)

  print,'Instrument, Interval-lo,-hi, Offset, Count'

;  for i=nlines-1,0,-1 do if  d(10+kk,i) gt 70. and d(10+kk,i) ne 999. and d(6+kk,i) lt -40 then print,kk+1,d(2,i),d(6+kk,i),d(10+kk,i)
;read,s

  i_f=0
  i_0=nlines-1

  ; ----------------- find min and max array indexes for RH correction
  for i=nlines-1,0,-1 do if  (d(2,i) ge timeframes(0,kkk)) then i_0=i
  for i=0,nlines-1 do if (d(2,i) le timeframes(1,kkk)) then i_f=i


  print,'  Beginning array index ',i_0
  print,'  Ending array index ',i_f
  print,''

;------------------------------------------------------------ Output file


lothresh=-49.
highthresh=-40.
c=0

print,''
print,'Instrument number ',kk+1

for i=i_0,i_f do begin
  if ((d(6+kk,i) lt highthresh) and (d(6+kk,i) ge lothresh) and (d(10+kk,i) ne 999.)) then begin
    c=c+1
  endif
endfor

r=0.
a0=0.
coef=0.

if c eq 0 then print,'No data to work with.'

if c gt 0 then begin

var=fltarr(2,c)
xx=fltarr(c)
yy=xx
id=intarr(c)

c=0

for i=i_0,i_f do begin
  if ((d(6+kk,i) lt highthresh) and (d(6+kk,i) ge lothresh) and (d(10+kk,i) ne 999.)) then begin
    xx(c)=d(10+kk,i)
    yy(c)=d(6+kk,i)
    var(0,c)=xx(c)
    var(1,c)=yy(c)
    id(c)=i
    c=c+1
  endif
endfor

nbins=100

trange=(findgen(nbins)/10)+lothresh
minx=fltarr(nbins)
minx(*)=10.
miny=fltarr(nbins)


for i=0,c-1 do begin
  for t=0,nbins-1 do begin
    if yy(i) gt trange(t) and yy(i) le trange(t)+0.05 then begin
      if xx(i) gt minx(t) then begin
	minx(t)=xx(i)
	miny(t)=yy(i)
	;print,trange(t),trange(t)+0.05,minx(t),miny(t)
      endif
    endif
  endfor
endfor

cx=0

for i=0,nbins-1 do begin
  if minx(i) ne 10. then cx=cx+1
endfor

if cx gt 30 then begin

minxx=fltarr(cx)
minyy=minxx

cx=0

for i=0,nbins-1 do begin
  if minx(i) ne 10. then begin
	minxx(cx)=minx(i)
	minyy(cx)=miny(i)
	cx=cx+1
  endif
endfor

regression,minxx,minyy,w,a0,coef,resid,Yfit,sigma,FTest,r,RMul,ChiSqr,/noprint
print,'Coef ',coef,'a0 ',a0

; --------------------------- use proven equations


if plt2 eq 'y' then begin

  xxx=findgen(100)

  !p.multi=0

  plot,xx(*),yy(*),psym=3,$
	/xstyle,$
	/ystyle,$
	yrange=[-65,-35],$
	xrange=[40,120],$
	ytitle='TC Air temperature [C]',$
	xtitle='CS-500 RH [%]',$
	subtitle=r^2,$
	title='Instrument change '+num(kkk),$
	color=180,background=0

  oplot,xxx,(xxx*coef)+a0


oplot,minx,miny,psym=3,color=100

;read,s

endif ; plt2


endif ; cx gt 0
endif ; c gt 0


if r^2 lt 0.9 then begin
  Print, 'Use established regression instead of this one'
  a0=coefs(2,kk)
  coef=coefs(1,kk)
  r=1.
  ;read,s
endif

cc=fltarr(2,2)

if r^2 gt 0.9 then begin

print,'  Begin synthesizing temperatures.'

for i=i_0,i_f do begin

  if d(10+kk,i) ne 999. then begin

;    if d(1,i)+(d(2,i)/365.9583) lt 2000.5 then begin
;      if d(6+kk,i) lt -49. then begin
;	if d(8+kk,i) lt -39. then begin
;	      d(6+kk,i)=(d(10+kk,i)*coef)+a0
;	      print,'a',d(2,i),d(6+kk,i),d(8+kk,i),d(10+kk,i)
; 	      modvar(6+kk,i)=8
;              cc(0,kk)=cc(0,kk)+1
;          endif
;        endif
;      endif

	if d(8+kk,i) le -39. or d(8+kk,i) eq 999. then begin
	d(8+kk,i)=(d(10+kk,i)*coef)+a0
	print,'Synth T',kk+1,d(2,i),d(6+kk,i),d(8+kk,i),d(10+kk,i),d(8+kk,i)-d(6+kk,i),cc(1,kk)
        modvar(8+kk,i)=8
        cc(1,kk)=cc(1,kk)+1
    endif
  endif
endfor

;read,s

print,'  End synthesizing temperatures.'

endif

print,'Number of synthetic temperatures.',kk+1,cc(0,kk)
print,'Number of synthetic temperatures.',kk+1,cc(1,kk)



endfor ; kkk (n instrument changes)

openw,21,path3+stnum(jx)+'_'+yr+'_t_cor_w_rh_stats_'+nam(kk)+'_'+num(kkk)+'.dat'
printf,21,'Instrument Change, Coef, Intercept, Rsq, N, Number of synthetics TC, TCS'
printf,21,kk+1,coef,a0,r^2,c,cc(0,kk),cc(1,kk),$
	format='(i2,1x,3f9.3,3f6.0)'
print,'instrument,Coef,intercept,Rsq,N, Number of synthetics, n changes'
print,kk+1,coef,a0,r^2,c,cc,kkk
close,21
;read,s

endfor ; kk (2 instruments)


; --------------------------------------------------------------------- END
end




















pro snow_height_revert,nlines,d2,stnum,jx,nstations,icol,fcol,ival
; --------------------------------------------------------------------
; 	idl sub-routine to revert positive accumulation into decreasing
; ADG height, used for CP1 reconstructed data from CP 2 data.
; --------------------------------------------------------------------

;printf,6,'Begin snow_height revert'
print,'Begin snow_height revert'


for k=icol,fcol do begin ; -----------------

  ;printf,6,'Column ',k+1
  print,'Column ',k+1

  ival=0.

  ival=iv(k-16,jx)

  ;printf,6,'Initial Snow Height Value',ival
  ;printf,6,''
  print,'Initial Snow Height Value',ival
  print,''

  for i=ival,nlines-1 do if d2(k,i) ne 999.then d2(k,i)=(ival-d2(k,ival))


endfor ; k ----------------------------------

;printf,6,'End Snow Height invert loop.'
;printf,6,''
print,'End Snow Height invert loop.'
print,''

end




pro aws_mult,d,stnum,jx,path,nlines,year,nstations,yr
; --------------------------------------------------------------------
; 	idl sub-routine to multiply aws data by calibration coeficients
; and make offsets.
; --------------------------------------------------------------------


; =========================== USER Defined Variables =================
lolimit=[0,1994,0,0,0,-600,-80,-80,-80,-80,40,40,0,0,0,0,300,0.05,.05,-80,-80,-80,-80,-80,-80,-80,-80,-80,-80,8.,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100]
hilimit=[39,2014,366.999,1350,1350,800,8,8,8,8,120,120,50,50,360.1,360.1,1100,6,6,8,8,8,8,8,8,8,8,8,8,24.,998,998,998,998,998,998,998,998,998,998]

ncoefs=23

ncols=40
; ===================================================================
prealb=0.
albedo=0.
nocor=0.
c=intarr(40)
siz=0.
ccc=0
path2='/data2/aws/ancillary/'

  c(*)=0

  nchanges=0.
  inputfile='/data2/aws/ancillary/'+stnum(jx)+'_cal_coef.dat'
  c=0
  garb=''
  openr,1,inputfile
  while not eof(1) do begin
    readf,1,garb
    c=c+1
  endwhile
  close,1
  nchanges=c

  ncoefs=24

  print,'The number of calibrations performed on this station is ',nchanges
  print,''

  print,'Begin reading multiplier and calibration coeficient file.'
  coefs=fltarr(28,nchanges)
  openr,1,'/data2/aws/ancillary/'+stnum(jx)+'_cal_coef.dat'
  readf,1,coefs
  close,1
  print,'Done reading multiplier and calibration coeficient file.'

  mult=fltarr(25)

flag=0
tr=0.
tk=0.
yrvar=0.
yrvar2=0.


if stnum(jx) eq '03' then begin
  if yr eq '1998' then begin
    for i=0,nlines-1 do begin
      if d(2,i) ge 132.7083 then d(16,i)=d(16,i)+400.
    endfor
  endif
  if yr eq '1999' then begin
    for i=0,nlines-1 do begin
      if d(2,i) ge 1.0 then d(16,i)=d(16,i)+400.
    endfor
  endif
endif

print,'Begin loop over data.'
  for i=0,nlines-1 do begin



    if d(1,i) eq 1996. then yrvar2=366.
    if d(1,i) ne 1996. then yrvar2=365.
    yrvar=(d(1,i)-1900.)+(d(2,i)/yrvar2)

    fflag=0

    for j=0,nchanges-1 do begin
      lolim=(coefs(0,j)-1900.)+(coefs(1,j)/365.9853)
      hilim=(coefs(2,j)-1900.)+(coefs(3,j)/365.9853)
      if((yrvar ge lolim) and (yrvar le hilim))then begin
        for k=0,ncoefs-1 do mult(k+1)=coefs(k+4,j)
        fflag=1
      endif
    endfor

    if fflag eq 0 then begin
      print,i,d(1,i),d(2,i),'No calibration coeficients!'
      ;read,s
    endif

; TCA 1.
    d(6,i)=((d(6,i)+273.15)*mult(6))-273.15
; TCS500 1.
    d(8,i)=((d(8,i)+273.15)*mult(8))-273.15
; RH 1.
;    if mult(10) eq 1. then begin
;      mult(10)=1.033
      ;print,jx,i,'using empirical mult'
;    endif

;    d(10,i)=d(10,i)*mult(10)
; U 1.
    d(12,i)=d(12,i)*mult(12)
    for t=19,28 do if ((d(t,i) ne 999.) and (mult(t-4) ne 1.0)) then begin
      d(t,i)=((d(t,i)+273.15)*mult(t-4))-273.15
    endif


  ; sw incomming.
    if d(3,i) ne 999. then d(3,i)=d(3,i)*mult(1)
; sw reflected.
    if d(4,i) ne 999. then begin
      d(4,i)=d(4,i)*mult(2)
      d(4,i)=d(4,i)*abs(1-mult(3))
    endif
    if(d(5,i) gt 0.)then d(5,i)=d(5,i)*mult(4) ; Positive Qnet multiplier
    if(d(5,i) lt 0.)then d(5,i)=d(5,i)*mult(5) ; Negative Qnet multiplier
; pressure.
    d(16,i)=d(16,i)+mult(14)
    if(d(16,i) lt 500)then d(16,i)=999.

; snow height speed of sound correction moved to own sub routine.

;--------------------- data limits filter set invalid to 999.

      for k=0,ncols-1 do begin
        if( (d(k,i) lt lolimit(k)) or (d(k,i) gt hilimit(k))) then begin
          d(k,i)=999.
        endif
      endfor ; k

      ccc=ccc+1

 endfor ; i

  print,'End loop over data.'
  print,''


end




; --------------------------------------------------- scatter-gram sub-routine
pro scattergram,ppp,nlines,stnames,layot,plot_prompt,d,xcol,ycol,jx,yr,xvarname,yvarname
; ----------------------------------------------------------------------------
; This sub-routine plots the scatter of data given the xcolumn number and the
; y column number, xcol, ycol.  The data are filtered of 999. values and then
; a linear regression is calculated.
; Currently this routine is used only for diagnostics and the regressions
; are not used quantitatively.
; ----------------------------------------------------------------------------
if ppp eq 'y' then begin
print,''
print,'Begin Scattergram sub-routine.'

  !p.multi=0

c=0

print,'  Counting non 999. values'

for i=0,nlines-1 do if((d(xcol,i) ne 999.) and (d(ycol,i) ne 999.))then c=c+1

if c gt 2 then begin

xx=fltarr(c)
yy=xx

c=0

print,'  Initialize x and y arrays'
minx=999.
maxx=-999.
miny=999.
maxy=-999.

for i=0,nlines-1 do begin
  if((d(xcol,i) ne 999.) and (d(ycol,i) ne 999.))then begin
    if minx gt d(xcol,i) then minx=d(xcol,i)
    if maxx lt d(xcol,i) then maxx=d(xcol,i)
    if miny gt d(ycol,i) then miny=d(ycol,i)
    if maxy lt d(ycol,i) then maxy=d(ycol,i)
    xx(c)=d(xcol,i)
    yy(c)=d(ycol,i)
    c=c+1
  endif
endfor

maxxxx=0.
minxxx=0.

if minx lt miny then minxxx=minx
if miny lt minx then minxxx=miny
if maxx gt maxy then maxxxx=maxx
if maxy gt maxx then maxxxx=maxy

regression,xx,yy,w,a0,coef,resid,Yfit,sigma,FTest,r,RMul,ChiSqr,/noprint

print,''
print,'---------------------------- Regression Results.'
print,'  R squared = ',r^2
print,'  Slope = ',coef
print,'  Intercept = ',a0
print,'  Minimum x ',minx
print,'  Minimum y ',miny
print,'  Maximum x ',maxx
print,'  Maximum y ',maxy
print,''

  plot,xx,yy,$
	/xstyle,$
	/ystyle,$
	title='Scattergram '+stnames(jx)+' '+yr,$
	xtitle=xvarname,$
	ytitle=yvarname,$
	xrange=[minxxx,maxxxx],$
	yrange=[minxxx,maxxxx],$
	psym=3,$
;	symsize=0.5,$
	subtitle=r^2

oplot,xx,(xx*coef)+a0
oplot,[minxxx,maxxxx],[minxxx,maxxxx],line=2

endif

if c eq 0 then begin
  print,'Sorry, insufficient data available'
  xx=findgen(nlines)
  yy=findgen(nlines)
endif

print,'End Scattergram sub-routine.'

  if ((layot eq 'x' ) and (plot_prompt eq 'y'))then read,s

endif ; ppp

; ------------------------------------------------------- end scatter-gram sub-routine
end













pro Histo,nlines,d,icol,fcol,mmin,mmax,bin,varname,xtit,ytit,xmin,xmax,flag
; -------------------------------------------------------------------
;	idl procedure to plot histogram
;	Jason Box, Sept 1998
; -----------------------------------------------------------------
print,''
print,'-------------------------------------'
print,'|     Thanks for choosing HIST-O     |'
print,'|The leader for your histogram needs |'
print,'-------------------------------------'
print,''
print,'Minimum in search and statistics range =',mmin
print,'Minimum in search and statistics range =',mmax
print,'histogram bin size=',bin
print,''

for kkk=0,fcol-icol do begin

var=d(icol+kkk,*)

print,'Begin Binning.'

nbins=(mmax+mmin)/bin
sum=fltarr(nbins)
ivar=(findgen(nbins)*bin)-mmin

for i=0,nlines-1 do begin
  k=0
  for j=0.,nbins-2 do begin
    if ((var(i) ge ivar(j)) and (var(i) lt ivar(j+1)))then sum(k)=sum(k)+1.
    k=k+1
  endfor ; j
endfor ; i

print,'Done Binning.'
c=0

print,'Search for good data.'

for i=0,nlines-1 do begin
  if ((var(i) ne 999)and(var(i) ne flag)) then c=c+1
endfor

print,'Found ',c,' Out of ',nlines

stat_var=fltarr(c)

c=0

print,'Initialize array with good data.'

for i=0,nlines-1 do begin
  if ((var(i) ne 999)and(var(i) ne flag)) then begin
    stat_var(c)=var(i)
    c=c+1
  endif
endfor

;----------------------------- calculate histogram stats
meadvar=0.
medvar=median(stat_var)
std=0.
mean1=0.
result=moment(stat_var)
mean1=result(0)
std=sqrt(result(1))
skewness=result(2)
kurtosis=result(3)
medvar=median(var)

print,''
print,'histogram Statistics'
print,'--------------------'
print,'Mean = ',mean1
print,'Median =',medvar
print,'Standard Deviation = ',std
print,'Skewness = ',skewness
print,'Kurtosis = ',kurtosis
print,''


x1=(findgen(nbins)*bin)-mmin
x2=x1+bin

!p.multi=0

if kkk eq 0 then begin

  plot,[x1(0),x2(0)],[sum(0),sum(0)],$
	/xstyle,$
	/ystyle,$
	title=tit,$
	xtitle=xt,$
	ytitle=yt,$
	xrange=[xmin,xmax],$
	yrange=[0,max(sum)*1.5],$
	charsize=cs,$
	thick=2

  for i=1,nbins-1 do oplot,[x1(i),x2(i)],[sum(i),sum(i)]
  for i=1,nbins-2 do oplot,[x2(i),x2(i)],[sum(i),sum(i+1)]
  for i=2,nbins-1 do oplot,[x1(i),x1(i)],[sum(i-1),sum(i)]

  oplot,[0,0],[0.0001,100000],line=1
endif

if kkk gt 0 then begin

  for i=0,nbins-1 do oplot,[x1(i),x2(i)],[sum(i),sum(i)],line=1
  for i=1,nbins-2 do oplot,[x2(i),x2(i)],[sum(i),sum(i+1)],line=1
  for i=2,nbins-1 do oplot,[x1(i),x1(i)],[sum(i-1),sum(i)],line=1

  oplot,[0,0],[0.0001,100000],line=kk
endif

endfor ; kkk

print,''
print,'Done histo, a Jason Box product.'
print,''
end






pro qi_init,nlines,d2,ncols,modvar
; --------------------------------------------------------------------
; 	idl sub-routine to initialize the quality identifiers to 9 for missing data
; and 1 for present raw data.  This initialization comes before any synthesizing
;
; Nov 9 1999
; J. Box
; --------------------------------------------------------------------


print,''
print,'Begin quality identifier initialization '

modvar=intarr(ncols,nlines)
modvar(*,*)=9

for k=3,ncols-1 do begin
  for i=0,nlines-1 do begin
    if (d2(k,i) ne 999.) then modvar(k,i)=1
  endfor
endfor

print,'End quality identifier initialization '
print,''

end








pro qi_init_final,nlines,d2,ncols,modvar
; --------------------------------------------------------------------
; 	idl sub-routine to initialize the quality identifiers to 9 for missing data
; and 1 for present raw data.  This initialization comes before any synthesizing
;
; Jan 25 2000
; J. Box
; --------------------------------------------------------------------


print,''
print,'Begin final quality identifier initialization '

for k=3,ncols-1 do begin
  for i=0,nlines-1 do begin
    if (d2(k,i) eq 999.) then modvar(k,i)=9
  endfor
endfor

print,'End final quality identifier initialization '
print,''

end




























pro rh_ice,nlines,d,stnum,jx,yr,path3,nstations,stnames,percentile,t_col,rh_col,ppp
; ---------------------------------------------------------------------------
; IDL sub-routine to sort RH data by temperature, then bin,
; then resort by bin, then pick 98th percentile, then create least squares fit.
;
; purpose: to correct RH for w/ respect to ice, not liquid water.
; Author: Jason Box, Sept 21, 1999
; revised Jan. 2000
; ---------------------------------------------------------------------------

; prompt user?
prmpt='n'

; ---------------------------------------------------------------------------
;constants
Lv=2.5001e6
Ls=2.8337e6
kk=273.15
Rv=461.5

; initialize some variables
Es_water=0.
Es_ice=0.

nam=['1','2']
;------------------------------------------------------------ Plot Settings
plt1=ppp
plt2=ppp
plt3=ppp



path='/data2/aws/temp/'

; ---------------------------------------------------------------------------
; part one, correct for RH with respect to ice, no water!


tt=fltarr(2,nlines)
tt(*,*)=999.

ct=0.

  for k=0,1 do begin

for i=0,nlines-1 do begin
  T=999.

    flag=0
    if d(8+k,i) ne 999. and d(8+k,i) gt -40. then begin
      T=d(8+k,i)+kk
      flag=1
    endif
    if ((d(8+k,i) eq 999.) and (d(6+k,i) ne 999.)) then begin
      T=d(6+k,i)+kk
      flag=1
    endif

        if ((d(9,i) ne 999.) and (flag eq 0)) then begin
          T=d(9,i)+kk
          flag=1
 	  print,'Used alternate temperature for RH correction (a)'
        endif
        if ((d(9,i) eq 999.) and (d(7,i) ne 999.) and (flag eq 0)) then begin
          T=d(7,i)+kk
          flag=1
 	  print,'Used alternate temperature for RH correction (b)'
        endif
        if ((d(7,i) ne 999.) and (flag eq 0)) then begin
          T=d(7,i)+kk
          flag=1
 	  print,'Used alternate temperature for RH correction (c)'
        endif
        if ((d(7,i) eq 999.) and (d(6,i) ne 999.) and (flag eq 0)) then begin
          T=d(6,i)+kk
          flag=1
 	  print,'Used alternate temperature for RH correction (d)'
        endif

    if flag eq 0 then begin
	print,'No temperature measurement available for RH correction!',ct
        d(10+k,i)=999.
        ct=ct+1.
    endif
	if d(10+k,i) eq 999. then T=999.

    if T lt kk then begin
      Es_water=6.11*(exp( (Lv/Rv) * ( (1/kk) - (1/T) ) ) )
      Es_ice=6.11*(exp( (Ls/Rv) * ( (1/kk) - (1/T) ) ) )
      if d(10+k,i) ne 999. then begin
        d(10+k,i)=d(10+k,i)*(Es_water/Es_ice)
      endif
    endif

	tt(k,i)=T-kk

  endfor ; i
endfor ; k

print,'Fraction of no temperature measurement available for RH correction!',ct/nlines



if ppp eq 'y' then begin

!p.multi=[0,1,2,0,1]


plot,d(rh_col(0),*),max_value=300.,psym=3,/xstyle
plot,d(rh_col(1),*),max_value=300.,psym=3,/xstyle

;read,s


for k=0,1 do begin
  print,'variable',k+1

  plot,tt(k,*),d(rh_col(k),*),$
	psym=3,$
	/xstyle,/ystyle,$
	xrange=[-65,8],yrange=[40,120],$
	title=stnames(jx)+' CS-500 '+nam(k)+' '+yr,$
	xtitle='Temperature [C]',$
	ytitle='Relative humidity [%]',$
	color=200,background=0

oplot,[-100,100],[100,100],line=1


endfor ; k

endif ; ppp



if ppp eq 'y' then begin

plot,tt(0,*),max_value=300.,psym=3,/xstyle,$
	color=120,background=0
plot,tt(1,*),max_value=300.,psym=3,/xstyle,$
	color=120,background=0

endif ; ppp




if ppp eq 'y' then begin
for k=0,1 do begin
  print,'variable',k+1


  plot,tt(k,*),d(rh_col(k),*),$
	psym=3,$
	/xstyle,/ystyle,$
	xrange=[-65,8],yrange=[40,120],$
	title=stnames(jx)+' CS-500 '+nam(k)+' '+yr,$
	xtitle='Temperature [C]',$
	ytitle='Relative humidity [%]',$
	color=200,background=0

oplot,[-100,100],[100,100],line=1


endfor ; k
endif ; ppp


; ------------------------------------------- tool for finding suspect bad data
;if ((yr eq '1998') and (jx eq 6)) then begin
;  for i=0,nlines-1 do begin
;    if ((d(11,i) gt 105)and (d(11,i) ne 999.) and (d(9,i) lt -35))then begin
;      print,k,d(2,i),d(11,i)
;      d(11,i)=100.
;    endif
;  endfor
;endif

; ---------------------------------------------------------------------------
; part three, adjust RH to offset value by temperature bin, P. Anderson 1994, J. A. O. Tech.

openr,14,path3+yr+'_n_hum_instr_changes.dat'
nchgs=fltarr(2,nstations)
readf,14,nchgs
close,14
print,'  Done reading number of hum instrument changes.'

timeframes=fltarr(2,nchgs(1,jx))
openr,14,path3+stnum(jx)+'_'+yr+'_hum_timeframes.dat'
readf,14,timeframes
close,14

print,'  Done reading instrument timeframes.'

print,'  Number of humidity instrument changes = ',nchgs(1,jx)
num=['0','1','2','3','4']
step=1.


for kkk=0,nchgs(1,jx)-1 do begin

  print,'  Instrument timeframe ',kkk+1,timeframes(0,kkk),timeframes(1,kkk)

  openw,3,path3+stnum(jx)+'_'+yr+'_RH_offset'+num(kkk)+'.dat'
  print,'Instrument, Interval-lo,-hi, Offset, Count'

  i_f=0
  i_0=nlines-1

  ; ----------------- find min and max array indexes for RH correction
  for i=nlines-1,0,-1 do if  (d(2,i) ge timeframes(0,kkk)) then i_0=i
  for i=0,nlines-1 do if (d(2,i) le timeframes(1,kkk)) then i_f=i


  print,'  Beginning array index ',i_0
  print,'  Ending array index ',i_f
  print,''

; ----------------------- endx is the upper limit of the offset correction
endx=0.

;if ((yr eq '1996') and (jx eq 6)) then endx=-13

for k=0,1 do begin

for j=-40,endx,step do begin

  oset=0.
  c=0
  cc=0.

  for i=i_0,i_f do if ((d(rh_col(k),i) ne 999.) and (tt(k,i) lt j+step)and (tt(k,i) ge j)) then c=c+1

    if c gt 0 then begin

      vartosort=fltarr(c)

      c=0

      for i=i_0,i_f do begin
if ((d(rh_col(k),i) ne 999.) and (tt(k,i) lt j+step)and (tt(k,i) ge j)) then begin

          vartosort(c)=d(rh_col(k),i)
          c=c+1
        endif
      endfor

        pointers=intarr(c)
        pointers(*)=sort(vartosort)
        oset=vartosort(pointers(c*percentile))-100.
    endif

  printf,3,kkk+1,fix(nchgs(1,jx)),k+1,j,fix(j+step),oset,c,format='(i2,1x,i2,1x,i1,1x,2(i3,1x),f9.4,1x,i4)'
  print,'Change num.',kkk+1,'N changes',fix(nchgs(1,jx)),'Instr.',k+1,'Interval',j,fix(j+step),' Offset ',oset,'Count',c,$
	format='(a11,1x,i1,2x,a7,1x,i1,1x,a6,1x,i1,2x,a8,i4,i4,a8,1x,f7.3,2x,a5,1x,i4)'


  for i=i_0,i_f do begin
    if ((d(rh_col(k),i) ne 999.) and (tt(k,i) lt j+step)and (tt(k,i) ge j)) then d(rh_col(k),i)=d(rh_col(k),i)-oset

  endfor
  endfor ; i

endfor ; j



for k=0,1 do begin
  for i=0,nlines-1 do begin
  if  ((d(rh_col(k),i) ne 999.) and (tt(k,i) le -39.)) then begin
      d(rh_col(k),i)=100.
      cc=cc+1.
    endif
  endfor
    print,k+1,' Number of RH values set to 100.% / nlines ',cc/nlines
endfor

close,3






if plt3  eq 'y' and ppp eq 'y' then begin
psname=path+'rh_cor_3.ps'
layot='x' 	; 'l' for postscript eps file to print, 'x' for x-window
; ===================================================================



; -------------------------------------- end plot settings



for k=0,1 do begin
  print,'variable',k+1

  plot,tt(k,*),d(rh_col(k),*),$
	psym=3,$
	/xstyle,/ystyle,$
	xrange=[-65,10],yrange=[40,110],$
	title=stnames(jx)+' CS-500 '+nam(k)+' '+yr,$
	xtitle='Temperature [C]',$
	ytitle='Relative humidity [%]'

oplot,[-100,100],[100,100],line=1

print,''

endfor ; k

if((layot eq 'p') or (layot eq 'P') or (layot eq 'l')) then device,/close
if prmpt eq 'y' then read,s


endif ; plt3

endfor ; kkk



; --------------------------------------------------------------------- END
end







pro instrument_reverse,nlines,d,varname,modvar,year,yearx,i_time,f_time,col_1,col_2
; #########################################################################
; created Aug 23 2000, J. Box

print,''
print,'Begin instrument reverse sub routine'

c=0

if yearx eq year then begin
  for i=0,nlines-1 do begin
    if ((d(2,i) ge i_time) and (d(2,i) le f_time))then begin
      temp=d(col_2,i)
      d(col_2,i)=d(col_1,i)
      d(col_1,i)=temp
      if d(col_1,i) ne 999. then modvar(col_1,i)=7
      if d(col_2,i) ne 999. then modvar(col_2,i)=7
      c=c+1
    endif
  endfor
endif ; yearx

print,'  Count of reversed instrument values = ',c
print,''
print,'Done instrument reverse sub routine'
; #########################################################################
end








pro fix_neg_wind_gradients,nlines,d,wind1col,wind2col,dir1col,z1col,modvar,stnum,yr,jx,path2
; --------------------------------------------------------------------
; 	idl sub-routine to identify suspect wind directions for wind
; speed shading.
;
; Dec 28 1999
; J. Box
; --------------------------------------------------------------------
!p.multi=0
z0_constant=0.0005
print,''
print,'End fix negative wind speed gradients.'


dif=0.
c=0.

for i=0,nlines-1 do begin
  if ((d(wind2col,i) ne 999.) and  (d(wind1col,i) ne 999.)) then dif = d(wind2col,i)-d(wind1col,i)
  if ((dif lt 0. )and (d(dir1col,i) ne 999.))then c=c+1.
endfor

if c gt 0 then begin

dir=fltarr(c)

c=0.

for i=0,nlines-1 do begin
  if d(z1col,i) gt 0. then begin

  dif=0.
  if ((d(wind2col,i) ne 999.) and  (d(wind1col,i) ne 999.)) then dif=d(wind2col,i)-d(wind1col,i)
   if ((dif lt 0. ) and (d(dir1col,i) ne 999.))then begin
    dir(c)=d(dir1col,i)

   ; ----------------------- logarithmic slope-intercept solution for wind speed
  ;  print,d(2,i),d(wind1col,i),d(wind2col,i),d(z1col,i),d(z1col+1,i)
    y=fltarr(2)
    y(0)=alog(z0_constant)
    y(1)=alog(d(z1col,i))
    x=fltarr(2)
    x(0)=0.
    x(1)=d(wind1col,i)
    m=(y(1)-y(0))/(x(1)-x(0))
    b=y(0)-(m*x(0))
    d(wind2col,i)=(alog(d(z1col+1,i))-b)/m
    modvar(wind2col,i)=8
   ; print,d(2,i),d(wind1col,i),d(wind2col,i),b,m
    c=c+1.
  endif

endif ; z1col gt 0.
endfor

print,'  Fraction of negative wind gradients ',c/nlines

endif ;c gt 0


c=0.
thresh=2.

for i=0,nlines-1 do begin
  dif=0.
   if d(z1col,i) gt 0. then begin
 if ((d(wind2col,i) ne 999.) and  (d(wind1col,i) ne 999.)) then dif=d(wind2col,i)-d(wind1col,i)
  if (dif gt thresh) then begin
   ; ----------------------- logarithmic slope-intercept solution for wind speed
;    print,d(2,i),d(wind1col,i),d(wind2col,i),d(z1col,i),d(z1col+1,i)
    y=fltarr(2)
    y(0)=alog(z0_constant)
    y(1)=alog(d(z1col+1,i))
    x=fltarr(2)
    x(0)=0.
    x(1)=d(wind2col,i)
    m=(y(1)-y(0))/(x(1)-x(0))
    b=y(0)-(m*x(0))
    d(wind1col,i)=(alog(d(z1col,i))-b)/m
    modvar(wind1col,i)=8
;    print,d(2,i),d(wind1col,i),d(wind2col,i),b,m
    c=c+1.
  endif
endif ; z1col gt 0.
endfor ; i

print,'  Fraction of too large wind gradients ',c/nlines

c=0.

for i=0,nlines-1 do begin
  dif=0.
  if d(z1col,i) gt 0. then begin
  if ((d(wind2col,i) ne 999.) and  (d(wind1col,i) ne 999.)) then dif=d(wind2col,i)-d(wind1col,i)
  if (dif gt thresh) then begin
   ; ----------------------- logarithmic slope-intercept solution for wind speed
;    print,d(2,i),d(wind1col,i),d(wind2col,i),d(z1col,i),d(z1col+1,i)
    y=fltarr(2)
    y(0)=alog(z0_constant)
    y(1)=alog(d(z1col+1,i))
    x=fltarr(2)
    x(0)=0.
    x(1)=d(wind2col,i)
    m=(y(1)-y(0))/(x(1)-x(0))
    b=y(0)-(m*x(0))
    d(wind1col,i)=(alog(d(z1col,i))-b)/m
    modvar(wind1col,i)=8
;    print,d(2,i),d(wind1col,i),d(wind2col,i),b,m
    c=c+1.
  endif

  endif ; z1col gt 0.
endfor ; i


print,'  Fraction of too large wind gradients ',c/nlines

print,'End fix negative wind speed gradients.'
print,''

end









pro tower_wake_filter,nlines,d,wind1col,wind2col,dir1col,z1col,modvar,stnum,yr,jx,path2,azi_min,azi_max,year,yearx,mintime,maxtime,ppp
; --------------------------------------------------------------------
; 	idl sub-routine to identify suspect wind directions for wind
; speed shading.
;
; Sept 9 2000
; J. Box
; --------------------------------------------------------------------

if year eq yearx then begin

!p.multi=0
print,''
print,'Begin wind shade clean.'


!p.multi=[0,1,2,0,1]


; ################################################### filter

c1=0.
c2=0.

for i=0,nlines-1 do begin
  if d(2,i) ge mintime and d(2,i) le maxtime then begin
    dir=999.
    if d(dir1col+1,i) ne 999. then dir = d(dir1col+1,i)
    if dir eq 999. and d(dir1col,i) ne 999. then dir=d(dir1col,i)

    if dir ne 999. and dir ge azi_min and dir le azi_max then begin
      if d(wind1col,i) ne 999. then begin
        d(wind1col,i)=999.
        modvar(wind1col,i)=5
        c1=c1+1.
      endif
     if d(wind2col,i) ne 999. then begin
        d(wind2col,i)=999.
        modvar(wind2col,i)=5
        c2=c2+1.
      endif
    endif
  endif ; timerange
endfor

if ppp eq 'y' then begin
; ################################################### plot after adjustments
plot,d(dir1col,*),(d(wind2col,*)-d(wind1col,*))/(d(z1col+1,*)-d(z1col,*)),$
	max_value=10,min_value=-10.,$
	xtitle='wind direction',$
	ytitle='wind speed difference',$
	/xstyle,/ystyle,$
	psym=3,$
	xrange=[-10,370]

oplot,[-1,370],[0,0],line=2

plot,d(dir1col+1,*),(d(wind2col,*)-d(wind1col,*))/(d(z1col+1,*)-d(z1col,*)),$
	max_value=10,min_value=-10.,$
	xtitle='wind direction',$
	ytitle='wind speed difference',$
	/xstyle,/ystyle,$
	psym=3,$
	xrange=[-10,370]

oplot,[-1,370],[0,0],line=2

endif ; ppp

print,'Fraction of wind 1 shaded values rejected ',c1/nlines
print,'Fraction of wind 2 shaded values rejected ',c2/nlines


;read,s

print,'End fix negative wind speed gradients.'
print,''

endif ; year eq yearx

end









pro plot_tower_wake_effects,nlines,d,wind1col,wind2col,dir1col,z1col,ppp
; --------------------------------------------------------------------
; 	idl sub-routine to identify suspect wind directions for wind
; speed shading.
;
; Sept 9 2000
; J. Box
; --------------------------------------------------------------------

if ppp eq 'y' then begin

!p.multi=0
print,''
print,'Begin plot potential wake effects.'

!p.multi=[0,1,2,0,1]

dir1=fltarr(nlines)
dir2=fltarr(nlines)
dir1(*)=999.
dir2(*)=999.
dz=dir2
du=fltarr(nlines)

for i=0,nlines-1 do begin
    if d(dir1col,i) ne 999. then dir1(i) = d(dir1col,i)
    if d(dir1col+1,i) ne 999. then dir2(i)=d(dir1col+1,i)
    if d(z1col+1,i) ne 999. and d(z1col,i) ne 999. then dz(i)=(d(z1col+1,i)-d(z1col,i))
    if d(wind1col+1,i) ne 999. and d(wind1col,i) ne 999. then du(i)=(d(wind1col+1,i)-d(wind1col,i))
endfor


; ################################################### plot
plot,dir1,du,$
	max_value=10,min_value=-10.,$
	xtitle='wind direction',$
	ytitle='wind speed difference',$
	/xstyle,/ystyle,$
	psym=3,$
	xrange=[-10,370]

oplot,[-1,370],[0,0],line=2

plot,dir2,du,$
	max_value=10,min_value=-10.,$
	xtitle='wind direction',$
	ytitle='wind speed difference',$
	/xstyle,/ystyle,$
	psym=3,$
	xrange=[-10,370]

oplot,[-1,370],[0,0],line=2



print,'End plot potential wake effects.'
print,''

endif ; ppp

;read,s

end






; -------------------------------------------------------------------------
pro dtdz_filter,nlines,d,varname,mod_count,year,tcol_1,tcol_2,ppp,plot_prompt
; -------------------------------------------------------------------------
!p.multi=[0,2,2,0,1]

dt=fltarr(nlines)
dt(*)=999.

for i=0,nlines-1 do begin
  if ((d(tcol_2,i)ne 999.)and (d(tcol_1,i) ne 999.))then dt(i)=d(tcol_2,i)-d(tcol_1,i)
endfor

if ppp eq 'y' then begin

  plot,d(2,*),dt,$
	max_value=1.,$
	min_value=-1.,$
	psym=3,$
	/xstyle,/ystyle,$
	title='6 7'

oplot,[0,367],[0,0],line=1

endif ; ppp

dt(*)=999.
tcol_1=tcol_1+2
tcol_2=tcol_2+2

for i=0,nlines-1 do begin
  if ((d(tcol_2,i)ne 999.)and (d(tcol_1,i) ne 999.))then dt(i)=d(tcol_2,i)-d(tcol_1,i)
endfor

if ppp eq 'y' then begin

  plot,d(2,*),dt,$
	max_value=1.,$
	min_value=-1.,$
	psym=3,$
	/xstyle,/ystyle,$
	title='8 9'

oplot,[0,367],[0,0],line=1

endif ; ppp

dt(*)=999.
tcol_1=6
tcol_2=9

for i=0,nlines-1 do begin
  if ((d(tcol_2,i)ne 999.)and (d(tcol_1,i) ne 999.))then dt(i)=d(tcol_2,i)-d(tcol_1,i)
endfor

if ppp eq 'y' then begin

  plot,d(2,*),dt,$
	max_value=1.,$
	min_value=-1.,$
	psym=3,$
	/xstyle,/ystyle,$
	title='6 9'
oplot,[0,367],[0,0],line=1

endif ; ppp

tcol_1=8
tcol_2=7

for i=0,nlines-1 do begin
  if ((d(tcol_2,i)ne 999.)and (d(tcol_1,i) ne 999.))then dt(i)=d(tcol_2,i)-d(tcol_1,i)
endfor

if ppp eq 'y' then begin

  plot,d(2,*),dt,$
	max_value=1.,$
	min_value=-1.,$
	psym=3,$
	/xstyle,/ystyle,$
	title='8 7'

oplot,[0,367],[0,0],line=1

endif ; ppp

if plot_prompt eq 'y' then read,s

end

; -------------------------------------------------------------------------



















pro correct_overheat,d,nlines,modvar,stnum,jx,yr,path2,m
; --------------------------------------------------------------------
; 	idl sub-routine to reduce air temperature measurements based
; upon a correction derived from the observed difference of non-ventilated
; air temperature measurements with ventilated ones as a function of wind
; speed in m/s and incoming solar radiation in w/m^2 for air temperatures
; greater than -12 C.
;
;	September 1999
; --------------------------------------------------------------------

c=fltarr(4)
cor=0.
s=0.
u=0.
lo_T_thresh=-12.
hi_u_thresh=6.
lo_s_thresh=100.

for i=0,nlines-1 do begin
  for k=0,1 do begin
    if((d(6+k,i) gt lo_T_thresh)and(d(6+k,i) ne 999.)and(d(12+k,i) lt hi_u_thresh)and(d(3,i) gt lo_s_thresh)and(d(3,i)lt 999.))then begin
      s=d(3,i)
      u=d(12+k,i)

      cor=-(0.207-0.701*u+0.014*s+0.131*u*u-0.002*u*s-4.743e-6*s*s)

     if cor lt 0. then begin
        ;print,jx+1,'TC',d(2,i),d(6+k,i),d(12+k,i),d(3,i),k+1,cor,d(6+k,i)+cor
	;d(6+k,i)=d(6+k,i)+cor
	m(10,i)=cor
	;modvar(6+k,i)=8
	c(0+k)=c(0+k)+1.
     endif
    endif
    if((d(8+k,i) gt lo_T_thresh)and(d(8+k,i) ne 999.)and(d(12+k,i) lt hi_u_thresh)and(d(3,i) gt lo_s_thresh)and(d(3,i)lt 999.))then begin
      s=d(3,i)
      u=d(12+k,i)
      cor=-(0.207-0.701*u+0.014*s+0.131*u*u-0.002*u*s-4.743e-6*s*s)
      if cor lt 0. then begin
        ;print,jx+1,'CS',d(2,i),d(8+k,i),d(12+k,i),d(3,i),k+1,cor,d(8+k,i)+cor
	;d(8+k,i)=d(8+k,i)+cor
	m(11,i)=cor
	;modvar(8+k,i)=8
	c(2+k)=c(2+k)+1.
     endif
   endif
  endfor
endfor
;read,s

openw,21,path2+stnum(jx)+'_'+yr+'_overheat_stat.dat'
  printf,21,'Count of potential overheating corrections for each of 4 sensors and fraction of total number of cases'
  for k=0,3 do printf,21,c(k),c(k)/nlines
close,21

print,'N cases likely for overheating ',c
print,'Fraction of cases likely for overheating ',c/nlines
;read,s

; ----------------------------------------------- End correct overheat
end






; -----------------------------------------------
pro write_out_end_of_year_snow_n_instr_z,jx,stnum,path2,d,yr,nlines
; -----------------------------------------------
openw,22,path2+stnum(jx)+'_'+yr+'_end_of_year_sn_heights.dat'
eval=fltarr(2)
flag=intarr(2)

for i=nlines-1,0,-1 do begin
  for k=0,1 do begin
    if d(17+k,i) ne 999 and flag(k) ne 1 and d(2,i) gt 355. then begin
	flag(k)=1
	eval(k)=d(17+k,i)
    endif ; flag
  endfor ; k
endfor ; i

printf,22,eval
close,22


openw,22,path2+stnum(jx)+'_'+yr+'_end_of_year_instr_heights.dat'
eval=fltarr(2)
flag=intarr(2)

for i=nlines-1,0,-1 do begin
  for k=0,1 do begin
    if d(32+k,i) ne 999 and flag(k) ne 1 then begin
	flag(k)=1
	eval(k)=d(32+k,i)
    endif ; flag
  endfor ; k
endfor ; i

printf,22,eval
close,22

end
; -----------------------------------------------




; -----------------------------------------------
pro read_in_end_of_last_year_snow_heights,jx,stnum,path2,d,yr,nlines,ly,nstations,ivals
; -----------------------------------------------
nl=fltarr(2,nstations)
openr,1,path2+'n'+ly+'.dat'
readf,1,nl
close,1

if nl(1,jx) gt 0 then begin

openr,22,path2+stnum(jx)+'_'+ly+'_end_of_year_sn_heights.dat'
eval=fltarr(2)
readf,22,eval

dif=fltarr(2)
flag=intarr(2)

for i=0,nlines-1 do begin
  for k=0,1 do begin
    if d(17+k,i) ne 999. and flag(k) ne 1 and d(2,i) lt 10. then begin
	dif(k)=eval(k)-d(17+k,i)
	flag(k)=1
    endif
	if dif(k) ne 0 and flag(k) eq 1 then d(17+k,i)=d(17+k,i)+dif(k)
  endfor ; k
endfor ; i

close,22


;openr,22,path2+stnum(jx)+'_'+ly+'_end_of_year_instr_heights.dat'
;ivals=fltarr(2)
;readf,22,ivals
;close,22

endif ; nlines gt 0

end
; -----------------------------------------------














; -----------------------------------------------------------------

pro speed_of_sound_cor,nlines,d,ppp
; -----------------------------------------------------------------
; routine to apply speed of sound correction to surface height data
; -----------------------------------------------------------------

kk=273.15
nocor=0
tk=0.
tr=0.

if ppp eq 'y' then begin
!p.multi=[0,1,2,0,1]
xmin=0
xmax=480

plot,d(17,*),max_value=990,$
        /xstyle,xrange=[xmin,xmax],$
	title='before'
plot,d(18,*),max_value=990,$
	/xstyle,xrange=[xmin,xmax],$
	title='before'
;read,s
endif ; ppp

 for i=0,nlines-1 do begin

    flag=0
    if((d(6,i) ne 999.)and(d(7,i) ne 999.))then begin
      tk=((d(6,i)+d(7,i))/2.)+kk
      flag=1
    endif
    if((flag ne 1) and (d(7,i) ne 999.) and (d(6,i) eq 999.))then begin
      tk=d(7,i)+kk
      flag=2
    endif
    if((flag ne 1) and (flag ne 2) and (d(7,i) eq 999.) and (d(6,i) ne 999.))then begin
      tk=d(6,i)+kk
      flag=3
    endif
    if((flag ne 1) and (flag ne 1) and (flag ne 3) and (d(6,i)eq 999.) and (d(7,i)eq 999.) and (d(8,i) ne 999.)and(d(9,i) ne 999.))then begin
        tk=((d(8,i)+d(9,i))/2)+kk
        flag=4
      endif
    if((flag ne 1) and (flag ne 1) and (flag ne 3) and (flag ne 4)and (d(6,i)eq 999.) and (d(7,i)eq 999.) and (d(8,i) eq 999.)and(d(9,i) ne 999.))then begin
        tk=d(9,i)+kk
        flag=5
      endif
    if((flag ne 1) and (flag ne 2) and (flag ne 3) and (flag ne 4) and (flag ne 5)and (d(6,i)eq 999.) and (d(7,i)eq 999.) and (d(8,i) ne 999.)and(d(9,i) eq 999.))then begin
        tk=d(8,i)+kk
        flag=6
      endif
      if ((flag eq 0) and (d(17,i) lt 10.) and (d(18,i) lt 10.)) then begin
	nocor=nocor+1
        print,'No temperature measurements available for snow height correction ',flag,tk,i,d(6,i),d(7,i),d(8,i),d(9,i),nocor
      endif


      if (flag gt 0) then begin
        tr=tk/kk
        tr=sqrt(tr)
        if(d(17,i) lt 10) and (d(17,i) gt 0.)then d(17,i)=d(17,i)*tr
        if(d(18,i) lt 10) and (d(18,i) gt 0.)then d(18,i)=d(18,i)*tr
      endif else begin
	d(17,i)=999.
	d(18,i)=999.
      endelse

endfor ; i

if ppp eq 'y' then begin

!p.multi=[0,1,2,0,1]

plot,d(17,*),max_value=990,$
	/xstyle,xrange=[xmin,xmax],$
	title='after'
plot,d(18,*),max_value=990,$
       /xstyle,xrange=[xmin,xmax],$
	title='after'

;read,s
endif ; ppp

end
; -----------------------------------------------------------------








; -----------------------------------------------------------------

pro calc_snow_t_z,nlines,d,stnum,jx,anc_path,z,nstations,outpath,year
; -----------------------------------------------------------------
; -----------------------------------------------------------------

  nchanges=0.
  inputfile=anc_path+stnum(jx)+'_TC_depths.dat'
  c=0
  garb=''
  openr,1,inputfile
  while not eof(1) do begin
    readf,1,garb
    c=c+1
  endwhile
  close,1
  nchanges=c

if nchanges gt 0 then begin

openr,1,anc_path+stnum(jx)+'_TC_depths.dat'
ddd=fltarr(14,nchanges)
readf,1,ddd
close,1

dep=fltarr(10)
h=fltarr(nlines)
tflag=h
zx=fltarr(10,nlines)
zx(*,*)=999.
z=zx
tx=zx

jt=0. & jtx=0.

cum=0.

for i=1,nlines-1 do begin

  jt=d(1,i)+d(2,i)/12.

  for J=0,NCHANGEs-1 do begin
    jtx1=ddd(0,j)+ddd(1,j)/366.
    jtx2=ddd(2,j)+ddd(3,j)/366.
    if jt ge jtx1 and jt lt jtx2 then begin
	tflag(i)=ddd(1,j)
      for jj=0,9 do dep(jj)=ddd(4+jj,j)
    endif
  endfor

  flag=0

  if d(18,i) ne 999. and d(17,i) ne 999 then begin
    h(i)=(d(18,i)+d(17,i))/2
    flag=1
  endif
  if flag eq 0 and d(17,i) ne 999. then begin
	h(i)=d(17,i)
	flag=1
  endif
  if flag eq 0 and d(18,i) ne 999. then begin
	h(i)=d(18,i)
	flag=1
  endif

  if tflag(i) ne tflag(i-1) then begin
	cum=0.
  endif

 ; if flag eq 0 then h(i)=h(i-1)

  if flag eq 1 and h(i)-h(i-1) lt 1. then cum=cum+(h(i)-h(i-1))

  ;print,cum,tflag(i),tflag(i-1),h(i)-h(i-1),h(i),h(i-1)
;read,s

  if flag eq 1 then begin
    for j=0,9 do zx(j,i)=dep(j)+cum
   ; print,i,d(2,i),h
  ;  print,'Unsorted',d(1,i),d(2,i),zx(*,i)

  endif

  for j=0,9 do tx(j,i)=d(19+j,i)

  result=sort(zx(*,i))

  for j=0,9 do begin
    z(j,i)=zx(result(j),i)
    d(19+j,i)=tx(result(j),i)
  endfor
   ; print,'Sorted  ',d(1,i),d(2,i),z(*,i)

  ;for j=0,9 do if d(19+j,i) ne 999. and d(19+j,i) gt 0. then d(19+j,i)=0.

endfor ; i

;openw,1,outpath+stnum(jx)+'_'+year+'_snow_T.dat'
;print,'Outputting T Snow data to individual file'
;for i=0,nlines-1 do begin
;printf,1,fix(d(0,i)),fix(d(1,i)),d(2,i),d(19:28,i),z(*,i),$
;	format='(i2,1x,i4,1x,f8.4,1x,20f7.2)'
;endfor ; i
;print,'Done outputting T Snow data to individual file'
;close,1

endif ; nchanges gt 0

end
; -----------------------------------------------------------------






; -----------------------------------------------------------------

pro calc_T_snow_fixed_intervals,nlines,d,z,tt,zz,jx,anc_path,nstations
; -----------------------------------------------------------------
; -----------------------------------------------------------------

print,'Begin calc_T_snow_fixed_intervals'
plt='n'

openr,1,anc_path+'aws_number_TC_changes.dat'
nchange=fltarr(2,nstations)
readf,1,nchange
close,1


tt=fltarr(14,nlines)
tt(*,*)=999.
zz=tt

if nchange(1,jx) gt 0 then begin

dif=1.

for i=0,nlines-1 do begin
  for j=1,8 do begin
    if d(19+j-1,i) ne 999. and d(19+j,i) eq 999. and d(19+j+1,i) ne 999. then begin
	d(19+j,i)=(d(18+j,i)+d(20+j,i))/2.
      print,'Interpolated one!'
    endif
  endfor
endfor

for i=1,nlines-2 do begin
  for j=1,8 do begin
    if d(19+j,i-1) ne 999. and d(19+j,i) eq 999. and d(19+j,i+1) ne 999. then begin
	d(19+j,i)=(d(19+j,i-1)+d(19,i+1))/2.
      print,'Interpolated another!'
    endif
  endfor
endfor

for i=0,nlines-1 do begin
  c=intarr(14)
  for k=0.,13. do begin
    for j=0.,9. do begin
      if z(j,i) le dif+k and z(j,i) ge k-dif and d(19+j,i) ne 999. then c(k)=c(k)+1
    endfor ; j
  endfor ; k

  ;print,'Count',c
  for k=0.,13. do begin
    ;print,'TC ',k+1
    if c(k) gt 1 then begin
    x=fltarr(c(k))
    y=x
    cc=0
    for j=0,9 do begin
      if z(j,i) le dif+k and z(j,i) ge k-dif and d(19+j,i) ne 999. then begin
        ;print,'Info ',z(j,i),dif+k,k-dif,k,dif
        x(cc)=z(j,i)
        y(cc)=d(19+j,i)
        cc=cc+1
      endif
    endfor

  ;print,'x',x
  ;print,'y',y

  regression,x,y,w,a0,coef,resid,Yfit,sigma,FTest,r,RMul,ChiSqr,/noprint

  if tt(k,i) gt 0. then tt(k,i)=0.
  tt(k,i)=(k*coef)+a0
  if tt(k,i) gt 0. then tt(k,i)=0.
  tt(k,i)=tt(k,i)+273.15


if plt eq 'y' then begin

  print,nlines-i

  plot,x,y,$
	psym=1,$
	/xstyle,xrange=[-1,15],$
	/ystyle,yrange=[-40,5]
  xx=[k,k+1]
  oplot,[0,0],[-50,50],line=1

  oplot,[1,1],[-50,50],line=1
  oplot,[k,k],[(k*coef)+a0,(k*coef)+a0],psym=1,symsize=2

  ;print,'Outcome ',k,(k*coef)+a0,y
;read,s

endif ; plt


  endif

  zz(k,i)=k

  endfor ; k

endfor ; i

endif ; nchanges gt 0

print,'End calc_T_snow_fixed_intervals'

end
; -----------------------------------------------------------------





; -------------------------------------------

pro specific_humidity,d,nlines,path2,nstations,jx

; -------------------------------------------
; Author: J. Box, Oct 23, 2001
;
; Temperature (t) must be given in Kelvins
; Pressure (p) must be given in hPa
; Relative Humidity (rh) must be given in percent, i.e. 82.1
; function outputs humidity in g / m^3
; not to be confused with w v mixing ratio, which has g / kg units
; -------------------------------------------

prt='n'


kk=273.15
Psi=2317.
epsilon=0.622
e_T0=6.1115
Rv=461.41
Lv=2.501e6
Ls=Lv+0.3336e6
latent=Ls

pp=fltarr(2,nstations)
openr,1,path2+'aws_average_pressure.dat'
readf,1,pp
close,1


for k=0,1 do begin

for i=0,nlines-1 do begin
ppx=999.
if d(16,i) ne 999. then ppx=d(16,i)

if ppx eq 999. then begin
  print,'Warning!!!!!! '
  print,'Day ',d(2,i)
  print,'Annual average pressure of ', pp(1,jx),'used to derive specific humidity!'
  ppx=pp(1,jx)
endif

t=999.
q=999.

if d(8+k,i) ne 999. then t=d(8+k,i)+kk

if d(6+k,i) ne 999. and t eq 999. then t=d(6+k,i)+kk

rh=d(10+k,i)
if t ne 999. and  rh ne 999. then begin

if t+kk ge kk-10. then latent=lv

  term1=(1/kk) - (1/(t))
  term2=alog((t)/kk)
  term4=latent+(kk*Psi)
  es=e_T0*(exp( 1/Rv * ((term4*term1)  - (psi*term2)) ) )
  e=(es*(d(10+k,i)/100.))
  q=(epsilon*e/(ppx-(0.378*e)))*1000.


if prt eq 'y' then begin
print,'sensor ',k+1
print,'Day ',d(2,i)
print,'e ',e,' es ',es
print,'T ',t
print,'RH ',rh
print,'Specific humidity ',q
print,'Pressure',d(16,i)

read,s

endif ; prt

d(10+k,i)=q

endif ; t and rh ne 999.


endfor ; i
  endfor ; k

end

; -------------------------------------------




pro shift_wind_dir,nlines,d,jx,stnum,col,itime,stnumx,shift,yearx,year

if stnum(jx) eq stnumx and year eq yearx then begin
for i=0,nlines-1 do begin
  if d(2,i) ge itime then begin
    d(col,i)=d(col,i)-shift
    if d(col,i) lt 0 then d(col,i)=d(col,i)+360
    if d(col,i) gt 360 then d(col,i)=360-d(col,i)
    print,'shifting wind dir ',col
  endif
endfor
endif
print,'done'
;read,s
end
